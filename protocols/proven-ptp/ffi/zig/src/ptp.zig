// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ptp.zig — Zig FFI implementation of proven-ptp.
//
// Implements the IEEE 1588 Precision Time Protocol port state machine with:
//   - Slot-based context management (up to 64 concurrent clocks)
//   - Port state machine (Initializing -> Listening -> Master/Slave/Passive,
//     with Faulty/Disabled/PreMaster/Uncalibrated transitions)
//   - Clock class and delay mechanism configuration
//   - Message send tracking with Sync message counting
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)

const std = @import("std");

// ── Enums (matching Idris2 Types.idr tag assignments exactly) ──────────

/// MessageType — matches messageTypeToTag
pub const MessageType = enum(u8) {
    sync = 0,
    delay_req = 1,
    pdelay_req = 2,
    pdelay_resp = 3,
    follow_up = 4,
    delay_resp = 5,
    pdelay_resp_follow_up = 6,
    announce = 7,
    signaling = 8,
    management = 9,
};

/// ClockClass — matches clockClassToTag
pub const ClockClass = enum(u8) {
    primary_clock = 0,
    application_specific = 1,
    slave_only = 2,
    default_class = 3,
};

/// PortState — matches portStateToTag
pub const PortState = enum(u8) {
    initializing = 0,
    faulty = 1,
    disabled = 2,
    listening = 3,
    pre_master = 4,
    master = 5,
    passive = 6,
    uncalibrated = 7,
    slave = 8,
};

/// DelayMechanism — matches delayMechanismToTag
pub const DelayMechanism = enum(u8) {
    e2e = 0,
    p2p = 1,
    dm_disabled = 2,
};

/// PTPError — matches ptpErrorToTag
pub const PTPError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    invalid_message = 4,
    sync_error = 5,
    bmc_error = 6,
};

// ── Clock Context instance ──────────────────────────────────────────────

const ClockCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current port state.
    port_state: PortState,
    /// Clock quality class.
    clock_class: ClockClass,
    /// Delay measurement mechanism.
    delay_mechanism: DelayMechanism,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Total number of messages sent.
    message_count: u32,
    /// Number of Sync messages sent.
    sync_count: u32,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: ClockCtx = .{
    .active = false,
    .port_state = .initializing,
    .clock_class = .default_class,
    .delay_mechanism = .e2e,
    .last_error = 255,
    .message_count = 0,
    .sync_count = 0,
};

var contexts: [MAX_CONTEXTS]ClockCtx = [_]ClockCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*ClockCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match PTPABI.Foreign.abiVersion (currently 1).
pub export fn ptp_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new PTP clock context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn ptp_create(clock_class: u8, delay_mechanism: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (clock_class > 3) return -1;
    if (delay_mechanism > 2) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.clock_class = @enumFromInt(clock_class);
            ctx.delay_mechanism = @enumFromInt(delay_mechanism);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a clock context, freeing its slot.
pub export fn ptp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current PortState tag.
pub export fn ptp_get_port_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.port_state);
}

/// Get the ClockClass tag.
pub export fn ptp_get_clock_class(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 3; // DefaultClass
    return @intFromEnum(ctx.clock_class);
}

/// Get the DelayMechanism tag.
pub export fn ptp_get_delay_mechanism(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.delay_mechanism);
}

/// Get the total message count.
pub export fn ptp_get_message_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.message_count;
}

/// Get the Sync message count.
pub export fn ptp_get_sync_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.sync_count;
}

/// Get the last error tag, or 255 if no error.
pub export fn ptp_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── State transitions ───────────────────────────────────────────────────

/// Check whether a port state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches IEEE 1588-2008 Section 9.2.5.
pub export fn ptp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Initializing (0) -> Listening (3) (POWERUP/INITIALIZE)
    if (from == 0 and to == 3) return 1;
    // Initializing (0) -> Faulty (1)
    if (from == 0 and to == 1) return 1;
    // Initializing (0) -> Disabled (2)
    if (from == 0 and to == 2) return 1;
    // Listening (3) -> PreMaster (4) (DECISION_CODE = MASTER)
    if (from == 3 and to == 4) return 1;
    // Listening (3) -> Uncalibrated (7) (DECISION_CODE = SLAVE)
    if (from == 3 and to == 7) return 1;
    // Listening (3) -> Passive (6)
    if (from == 3 and to == 6) return 1;
    // PreMaster (4) -> Master (5) (QUALIFICATION_TIMEOUT)
    if (from == 4 and to == 5) return 1;
    // Uncalibrated (7) -> Slave (8) (MASTER_CLOCK_SELECTED)
    if (from == 7 and to == 8) return 1;
    // Master (5) -> Listening (3) (ANNOUNCE_RECEIPT_TIMEOUT)
    if (from == 5 and to == 3) return 1;
    // Slave (8) -> Listening (3) (ANNOUNCE_RECEIPT_TIMEOUT)
    if (from == 8 and to == 3) return 1;
    // Passive (6) -> Listening (3)
    if (from == 6 and to == 3) return 1;
    // Any state -> Faulty (1) (FAULT_DETECTED)
    if (to == 1 and from >= 0 and from <= 8 and from != 1) return 1;
    // Faulty (1) -> Initializing (0) (FAULT_CLEARED)
    if (from == 1 and to == 0) return 1;
    // Disabled (2) -> Initializing (0) (ENABLE)
    if (from == 2 and to == 0) return 1;
    // Any state -> Disabled (2) (DISABLE)
    if (to == 2 and from != 2) return 1;
    return 0;
}

/// Advance a port to a new state, validating the transition.
pub export fn ptp_transition(slot: c_int, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(PTPError.invalid_slot);

    if (new_state > 8) {
        ctx.last_error = @intFromEnum(PTPError.invalid_transition);
        return @intFromEnum(PTPError.invalid_transition);
    }

    const from = @intFromEnum(ctx.port_state);
    if (ptp_can_transition(from, new_state) == 0) {
        ctx.last_error = @intFromEnum(PTPError.invalid_transition);
        return @intFromEnum(PTPError.invalid_transition);
    }

    ctx.port_state = @enumFromInt(new_state);
    ctx.last_error = 255;
    return @intFromEnum(PTPError.ok);
}

// ── Message tracking ────────────────────────────────────────────────────

/// Record sending a PTP message of the given type.
pub export fn ptp_send_message(slot: c_int, msg_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(PTPError.invalid_slot);

    if (msg_type > 9) {
        ctx.last_error = @intFromEnum(PTPError.invalid_message);
        return @intFromEnum(PTPError.invalid_message);
    }

    ctx.message_count += 1;

    // Track Sync messages separately
    if (msg_type == @intFromEnum(MessageType.sync)) {
        ctx.sync_count += 1;
    }

    ctx.last_error = 255;
    return @intFromEnum(PTPError.ok);
}
