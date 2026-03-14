// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// audit.zig — Zig FFI implementation of proven-audit.
//
// Implements provably complete audit trail management with:
//   - Slot-based trail session management (up to 64 concurrent)
//   - Configurable audit level, integrity mechanism, retention policy
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via mutex
//
// Tag values MUST match:
//   - Idris2 ABI (src/AuditABI/Layout.idr)
//   - C header   (generated/abi/audit.h)

const std = @import("std");

// ── Enums (matching AuditABI.Layout.idr tag assignments exactly) ────────

/// AuditLevel — matches auditLevelToTag
pub const AuditLevel = enum(u8) {
    none = 0,
    minimal = 1,
    standard = 2,
    verbose = 3,
    full = 4,
};

/// EventCategory — matches eventCategoryToTag
pub const EventCategory = enum(u8) {
    state_transition = 0,
    authentication = 1,
    authorization = 2,
    data_access = 3,
    configuration = 4,
    err = 5,
    security = 6,
    lifecycle = 7,
};

/// Integrity — matches integrityToTag
pub const Integrity = enum(u8) {
    unsigned_ = 0,
    hmac = 1,
    signed_ = 2,
    chained = 3,
    merkle_proof = 4,
};

/// RetentionPolicy — matches retentionPolicyToTag
pub const RetentionPolicy = enum(u8) {
    ephemeral = 0,
    session = 1,
    daily = 2,
    indefinite = 3,
    regulatory = 4,
};

/// AuditError — matches auditErrorToTag
pub const AuditError = enum(u8) {
    storage_full = 0,
    write_failure = 1,
    integrity_violation = 2,
    timestamp_error = 3,
    chain_broken = 4,
};

/// AuditTrailState — matches Transitions.idr AuditTrailState
pub const AuditTrailState = enum(u8) {
    idle = 0,
    recording = 1,
    sealed = 2,
    archived = 3,
    failed = 4,
};

// ── Trail session ───────────────────────────────────────────────────────

const MAX_EVENTS: usize = 4096;

const Session = struct {
    state: AuditTrailState,
    level: AuditLevel,
    integrity: Integrity,
    retention: RetentionPolicy,
    event_count: u32,
    last_error: u8, // 255 = no error
    active: bool,
};

const MAX_SESSIONS: usize = 64;
var sessions: [MAX_SESSIONS]Session = [_]Session{.{
    .state = .idle,
    .level = .none,
    .integrity = .unsigned_,
    .retention = .ephemeral,
    .event_count = 0,
    .last_error = 255,
    .active = false,
}} ** MAX_SESSIONS;

var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match AuditABI.Foreign.abiVersion (currently 1).
pub export fn audit_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new audit trail session in Idle state.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn audit_create(level: u8, integrity: u8, retention: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (level > 4) return -1;
    if (integrity > 4) return -1;
    if (retention > 4) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = .{
                .state = .idle,
                .level = @enumFromInt(level),
                .integrity = @enumFromInt(integrity),
                .retention = @enumFromInt(retention),
                .event_count = 0,
                .last_error = 255,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy an audit trail session, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn audit_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current AuditTrailState tag for a slot.
/// Returns Idle (0) for invalid/inactive slots.
pub export fn audit_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Get the last AuditError tag, or 255 if no error.
pub export fn audit_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].last_error;
}

/// Get the number of events recorded in this trail.
pub export fn audit_event_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].event_count;
}

/// Get the AuditLevel tag for a slot.
pub export fn audit_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].level);
}

/// Get the Integrity tag for a slot.
pub export fn audit_integrity(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].integrity);
}

/// Get the RetentionPolicy tag for a slot.
pub export fn audit_retention(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].retention);
}

// ── Transitions ─────────────────────────────────────────────────────────

/// Open an audit trail: Idle -> Recording.
/// Returns 0 (accepted) or 1 (rejected).
pub export fn audit_open(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;

    if (sessions[idx].state == .idle) {
        sessions[idx].state = .recording;
        sessions[idx].event_count = 0;
        sessions[idx].last_error = 255;
        return 0; // accepted
    }
    sessions[idx].last_error = 0; // storage_full as generic rejection indicator
    return 1; // rejected
}

/// Seal an audit trail: Recording -> Sealed.
/// Returns 0 (accepted) or 1 (rejected).
pub export fn audit_seal(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;

    if (sessions[idx].state == .recording) {
        sessions[idx].state = .sealed;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

/// Archive a sealed trail: Sealed -> Archived.
/// Returns 0 (accepted) or 1 (rejected).
pub export fn audit_archive(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;

    if (sessions[idx].state == .sealed) {
        sessions[idx].state = .archived;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

/// Mark trail as failed: Recording -> Failed.
/// Returns 0 (accepted) or 1 (rejected).
pub export fn audit_fail(slot: c_int, err_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;

    if (sessions[idx].state == .recording) {
        sessions[idx].state = .failed;
        sessions[idx].last_error = err_tag;
        return 0;
    }
    return 1;
}

/// Reset a trail: Failed|Sealed|Archived -> Idle.
/// Returns 0 (accepted) or 1 (rejected).
pub export fn audit_reset(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;

    if (sessions[idx].state == .failed or
        sessions[idx].state == .sealed or
        sessions[idx].state == .archived)
    {
        sessions[idx].state = .idle;
        sessions[idx].event_count = 0;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

// ── Event recording ─────────────────────────────────────────────────────

/// Record an audit event. Only valid in Recording state.
/// Returns 255 (ok) or an AuditError tag.
pub export fn audit_record_event(slot: c_int, category: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // write_failure
    if (sessions[idx].state != .recording) return 1; // write_failure
    if (category > 7) return 1; // write_failure — invalid category

    // Check capacity
    if (sessions[idx].event_count >= MAX_EVENTS) return 0; // storage_full

    sessions[idx].event_count += 1;
    return 255; // ok
}

// ── Stateless validation ────────────────────────────────────────────────

/// Check whether a transition from one AuditTrailState to another is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateAuditTransition exactly.
pub export fn audit_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle -> Recording
    if (from == 0 and to == 1) return 1;
    // Recording -> Sealed
    if (from == 1 and to == 2) return 1;
    // Recording -> Failed
    if (from == 1 and to == 4) return 1;
    // Sealed -> Archived
    if (from == 2 and to == 3) return 1;
    // Sealed -> Idle
    if (from == 2 and to == 0) return 1;
    // Archived -> Idle
    if (from == 3 and to == 0) return 1;
    // Failed -> Idle
    if (from == 4 and to == 0) return 1;
    return 0;
}
