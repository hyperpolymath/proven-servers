// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// snmp.zig — Zig FFI implementation of proven-snmp.
//
// Implements the SNMP session management primitive with:
//   - Slot-based session management (up to 64 concurrent sessions)
//   - Protocol version tracking (v1/v2c/v3)
//   - PDU type validation per version (v2c/v3-only PDU types)
//   - Error status management (RFC 3416)
//   - Variable binding count tracking
//   - PDU send counting
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)
//   - C header   (generated/abi/snmp.h)

const std = @import("std");

// ── Enums (matching Idris2 SNMPABI.Types tag assignments exactly) ────────

/// Version — matches versionToTag
pub const Version = enum(u8) {
    v1 = 0,
    v2c = 1,
    v3 = 2,
};

/// PDUType — matches pduTypeToTag
pub const PDUType = enum(u8) {
    get_request = 0,
    get_next_request = 1,
    get_response = 2,
    set_request = 3,
    get_bulk_request = 4,
    inform_request = 5,
    snmpv2_trap = 6,
};

/// ErrorStatus — matches errorStatusToTag
pub const ErrorStatus = enum(u8) {
    no_error = 0,
    too_big = 1,
    no_such_name = 2,
    bad_value = 3,
    read_only = 4,
    gen_err = 5,
    no_access = 6,
    wrong_type = 7,
    wrong_length = 8,
    wrong_value = 9,
    no_creation = 10,
    inconsistent_value = 11,
    resource_unavailable = 12,
    commit_failed = 13,
    undo_failed = 14,
    authorization_error = 15,
};

/// SNMPError — error codes for FFI operations
pub const SNMPError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_version = 3,
    invalid_pdu = 4,
    version_mismatch = 5,
    invalid_error_status = 6,
    varbind_limit = 7,
};

// ── Session Context ─────────────────────────────────────────────────────

/// Maximum variable bindings per PDU.
const MAX_VARBINDS: usize = 128;

const SessionCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// SNMP protocol version.
    version: Version,
    /// Current error status.
    error_status: ErrorStatus,
    /// Number of PDUs sent in this session.
    pdu_count: u32,
    /// Current variable binding count.
    varbind_count: u32,
    /// Last PDU type sent (255 = none).
    last_pdu_type: u8,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: SessionCtx = .{
    .active = false,
    .version = .v1,
    .error_status = .no_error,
    .pdu_count = 0,
    .varbind_count = 0,
    .last_pdu_type = 255,
};

var contexts: [MAX_CONTEXTS]SessionCtx = [_]SessionCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*SessionCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match SNMPABI.Foreign.abiVersion (currently 1).
pub export fn snmp_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new SNMP session.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn snmp_create(version: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate version (0-2)
    if (version > 2) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.version = @enumFromInt(version);
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy an SNMP session, freeing its slot.
pub export fn snmp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the SNMP version tag for a slot.
/// Returns V1 (0) for invalid/inactive slots.
pub export fn snmp_get_version(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.version);
}

/// Get the current error status tag for a slot.
/// Returns NoError (0) for invalid/inactive slots.
pub export fn snmp_get_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.error_status);
}

/// Get the number of PDUs sent in this session.
pub export fn snmp_get_pdu_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.pdu_count;
}

/// Get the current variable binding count.
pub export fn snmp_get_varbind_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.varbind_count;
}

/// Get the last PDU type sent (255 = none).
pub export fn snmp_get_last_pdu_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_pdu_type;
}

// ── Operations ──────────────────────────────────────────────────────────

/// Set the error status for a session.
/// Returns SNMPError tag.
pub export fn snmp_set_error(slot: c_int, err: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SNMPError.invalid_slot);

    if (err > 15) {
        return @intFromEnum(SNMPError.invalid_error_status);
    }

    ctx.error_status = @enumFromInt(err);
    return @intFromEnum(SNMPError.ok);
}

/// Send a PDU of the given type.
/// Validates that the PDU type is valid for the session's SNMP version.
/// Returns SNMPError tag.
pub export fn snmp_send_pdu(slot: c_int, pdu: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SNMPError.invalid_slot);

    // Validate PDU type (0-6)
    if (pdu > 6) {
        return @intFromEnum(SNMPError.invalid_pdu);
    }

    // Check version compatibility
    if (snmp_can_send_pdu(@intFromEnum(ctx.version), pdu) == 0) {
        return @intFromEnum(SNMPError.version_mismatch);
    }

    ctx.last_pdu_type = pdu;
    ctx.pdu_count += 1;
    return @intFromEnum(SNMPError.ok);
}

/// Add a variable binding to the current PDU.
/// Returns SNMPError tag.
pub export fn snmp_add_varbind(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SNMPError.invalid_slot);

    if (ctx.varbind_count >= MAX_VARBINDS) {
        return @intFromEnum(SNMPError.varbind_limit);
    }

    ctx.varbind_count += 1;
    return @intFromEnum(SNMPError.ok);
}

/// Clear all variable bindings.
pub export fn snmp_clear_varbinds(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return;
    ctx.varbind_count = 0;
}

/// Set the SNMP version for a session.
/// Returns SNMPError tag.
pub export fn snmp_set_version(slot: c_int, ver: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SNMPError.invalid_slot);

    if (ver > 2) {
        return @intFromEnum(SNMPError.invalid_version);
    }

    ctx.version = @enumFromInt(ver);
    return @intFromEnum(SNMPError.ok);
}

// ── Stateless PDU-version validation ────────────────────────────────────

/// Check whether a PDU type is valid for a given SNMP version.
/// Returns 1 if valid, 0 if not.
/// V1 (0): GetRequest(0), GetNextRequest(1), GetResponse(2), SetRequest(3)
/// V2c (1) and V3 (2): all 7 PDU types
pub export fn snmp_can_send_pdu(version: u8, pdu: u8) callconv(.c) u8 {
    // All versions support PDU types 0-3
    if (pdu <= 3) return 1;
    // PDU types 4-6 require v2c (1) or v3 (2)
    if (pdu <= 6 and version >= 1) return 1;
    return 0;
}
