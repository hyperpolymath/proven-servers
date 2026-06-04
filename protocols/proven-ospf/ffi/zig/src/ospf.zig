// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// ospf.zig — Zig FFI implementation of proven-ospf.
//
// Implements the OSPF (RFC 2328) neighbor state machine with:
//   - Slot-based context management (up to 64 concurrent neighbors)
//   - Neighbor state machine (Down -> Init -> TwoWay -> ExStart ->
//     Exchange -> Loading -> Full, with Attempt for NBMA)
//   - LSA database tracking per neighbor
//   - Packet send tracking
//   - Area type configuration
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)

const std = @import("std");

// ── Enums (matching Idris2 Types.idr tag assignments exactly) ──────────

/// PacketType — matches packetTypeToTag
pub const PacketType = enum(u8) {
    hello = 0,
    database_description = 1,
    link_state_request = 2,
    link_state_update = 3,
    link_state_ack = 4,
};

/// NeighborState — matches neighborStateToTag
pub const NeighborState = enum(u8) {
    down = 0,
    attempt = 1,
    init = 2,
    two_way = 3,
    ex_start = 4,
    exchange = 5,
    loading = 6,
    full = 7,
};

/// LSAType — matches lsaTypeToTag
pub const LSAType = enum(u8) {
    router_lsa = 0,
    network_lsa = 1,
    summary_lsa = 2,
    asbr_summary_lsa = 3,
    as_external_lsa = 4,
};

/// AreaType — matches areaTypeToTag
pub const AreaType = enum(u8) {
    normal = 0,
    stub = 1,
    totally_stub = 2,
    nssa = 3,
};

/// OSPFError — matches ospfErrorToTag
pub const OSPFError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    invalid_packet = 4,
    area_error = 5,
    flood_limit = 6,
};

// ── Neighbor Context instance ──────────────────────────────────────────

/// Maximum LSA database size per neighbor (hard limit).
const MAX_LSA_DB: usize = 256;

const NeighborCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current neighbor state.
    state: NeighborState,
    /// Area type for this neighbor relationship.
    area_type: AreaType,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of LSAs in the database.
    lsa_count: u32,
    /// Number of packets sent.
    packet_count: u32,
    /// LSA type database (kind tags).
    lsa_db: [MAX_LSA_DB]u8,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: NeighborCtx = .{
    .active = false,
    .state = .down,
    .area_type = .normal,
    .last_error = 255,
    .lsa_count = 0,
    .packet_count = 0,
    .lsa_db = [_]u8{0} ** MAX_LSA_DB,
};

var contexts: [MAX_CONTEXTS]NeighborCtx = [_]NeighborCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*NeighborCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match OSPFABI.Foreign.abiVersion (currently 1).
pub export fn ospf_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new OSPF neighbor context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn ospf_create(area_type: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (area_type > 3) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.area_type = @enumFromInt(area_type);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a neighbor context, freeing its slot.
pub export fn ospf_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current NeighborState tag for a slot.
pub export fn ospf_get_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.state);
}

/// Get the AreaType tag for a slot.
pub export fn ospf_get_area_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.area_type);
}

/// Get the number of LSAs in the database.
pub export fn ospf_get_lsa_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.lsa_count;
}

/// Get the number of packets sent.
pub export fn ospf_get_packet_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.packet_count;
}

/// Get the last error tag, or 255 if no error.
pub export fn ospf_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── State transitions ───────────────────────────────────────────────────

/// Check whether a neighbor state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches RFC 2328 Section 10.1 neighbor state machine.
pub export fn ospf_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Down (0) -> Attempt (1) (NBMA only)
    if (from == 0 and to == 1) return 1;
    // Down (0) -> Init (2) (received Hello)
    if (from == 0 and to == 2) return 1;
    // Attempt (1) -> Init (2) (received Hello)
    if (from == 1 and to == 2) return 1;
    // Init (2) -> TwoWay (3) (2-Way received)
    if (from == 2 and to == 3) return 1;
    // TwoWay (3) -> ExStart (4) (adjacency decision)
    if (from == 3 and to == 4) return 1;
    // ExStart (4) -> Exchange (5) (negotiation done)
    if (from == 4 and to == 5) return 1;
    // Exchange (5) -> Loading (6) (DD exchange complete)
    if (from == 5 and to == 6) return 1;
    // Loading (6) -> Full (7) (LSAs loaded)
    if (from == 6 and to == 7) return 1;
    // Full (7) -> Down (0) (neighbor lost)
    if (from == 7 and to == 0) return 1;
    // Any active state -> Down (0) (KillNbr/InactivityTimer)
    if (to == 0 and from >= 1 and from <= 7) return 1;
    // TwoWay (3) -> Down (0) via 1-Way (RFC 2328)
    // Already covered by any->Down above
    return 0;
}

/// Advance a neighbor to a new state, validating the transition.
pub export fn ospf_transition(slot: c_int, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(OSPFError.invalid_slot);

    const from = @intFromEnum(ctx.state);
    if (ospf_can_transition(from, new_state) == 0) {
        ctx.last_error = @intFromEnum(OSPFError.invalid_transition);
        return @intFromEnum(OSPFError.invalid_transition);
    }

    // Reset LSA count when neighbor goes down
    if (new_state == @intFromEnum(NeighborState.down)) {
        ctx.lsa_count = 0;
        ctx.packet_count = 0;
    }

    ctx.state = @enumFromInt(new_state);
    ctx.last_error = 255;
    return @intFromEnum(OSPFError.ok);
}

// ── Packet tracking ─────────────────────────────────────────────────────

/// Record sending a packet of the given type.
pub export fn ospf_send_packet(slot: c_int, packet_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(OSPFError.invalid_slot);

    if (packet_type > 4) {
        ctx.last_error = @intFromEnum(OSPFError.invalid_packet);
        return @intFromEnum(OSPFError.invalid_packet);
    }

    ctx.packet_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(OSPFError.ok);
}

// ── LSA management ──────────────────────────────────────────────────────

/// Add an LSA to the neighbor's database.
pub export fn ospf_add_lsa(slot: c_int, lsa_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(OSPFError.invalid_slot);

    if (lsa_type > 4) {
        ctx.last_error = @intFromEnum(OSPFError.invalid_packet);
        return @intFromEnum(OSPFError.invalid_packet);
    }

    if (ctx.lsa_count >= MAX_LSA_DB) {
        ctx.last_error = @intFromEnum(OSPFError.flood_limit);
        return @intFromEnum(OSPFError.flood_limit);
    }

    ctx.lsa_db[ctx.lsa_count] = lsa_type;
    ctx.lsa_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(OSPFError.ok);
}
