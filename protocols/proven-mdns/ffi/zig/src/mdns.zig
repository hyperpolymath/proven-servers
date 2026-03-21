// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mdns.zig -- Zig FFI implementation of proven-mdns.
//
// Implements the mDNS/DNS-SD responder state machine with:
//   - 64-slot mutex-protected responder pool
//   - Per-responder service registration (max 16 services)
//   - Per-responder record cache (max 64 records)
//   - Probing/announcing/running lifecycle per RFC 6762
//   - Conflict detection and resolution
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching abi.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching abi.Types.idr tag assignments)
// =========================================================================

/// DNS record types (ABI tags 0-4).
pub const RecordType = enum(u8) {
    a = 0,
    aaaa = 1,
    ptr = 2,
    srv = 3,
    txt = 4,
};

/// mDNS query modes (ABI tags 0-2).
pub const QueryType = enum(u8) {
    standard = 0,
    one_shot = 1,
    continuous = 2,
};

/// Conflict resolution actions (ABI tags 0-2).
pub const ConflictAction = enum(u8) {
    probe = 0,
    defend = 1,
    withdraw = 2,
};

/// Service registration flags (ABI tags 0-1).
pub const ServiceFlag = enum(u8) {
    unique = 0,
    shared = 1,
};

/// Responder lifecycle states (ABI tags 0-4).
pub const ResponderState = enum(u8) {
    idle = 0,
    probing = 1,
    announcing = 2,
    running = 3,
    shutting_down = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent responder sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum services per responder.
const MAX_SERVICES: usize = 16;

/// Maximum cached records per responder.
const MAX_RECORDS: usize = 64;

/// Maximum name length in bytes.
const MAX_NAME_LEN: usize = 256;

/// Maximum hostname length.
const MAX_HOSTNAME_LEN: usize = 128;

/// A registered service entry.
const ServiceEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    service_type: [MAX_NAME_LEN]u8,
    stype_len: u32,
    port: u16,
    flag: ServiceFlag,
    active: bool,
};

/// Default (empty) service entry.
const empty_service: ServiceEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .service_type = [_]u8{0} ** MAX_NAME_LEN,
    .stype_len = 0,
    .port = 0,
    .flag = .unique,
    .active = false,
};

/// A cached DNS record entry.
const RecordEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    rtype: RecordType,
    active: bool,
};

/// Default (empty) record entry.
const empty_record: RecordEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .rtype = .a,
    .active = false,
};

/// An mDNS responder session.
const Session = struct {
    /// Current responder lifecycle state.
    state: ResponderState,
    /// Hostname.
    hostname: [MAX_HOSTNAME_LEN]u8,
    hostname_len: u32,
    /// Registered services.
    services: [MAX_SERVICES]ServiceEntry,
    /// Number of active services.
    service_count: u32,
    /// Cached records.
    records: [MAX_RECORDS]RecordEntry,
    /// Number of active records.
    record_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .hostname = [_]u8{0} ** MAX_HOSTNAME_LEN,
    .hostname_len = 0,
    .services = [_]ServiceEntry{empty_service} ** MAX_SERVICES,
    .service_count = 0,
    .records = [_]RecordEntry{empty_record} ** MAX_RECORDS,
    .record_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn mdns_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new mDNS responder session. Returns slot index (>=0) or -1 on failure.
pub export fn mdns_create(
    hostname_ptr: [*]const u8,
    hostname_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (hostname_len == 0 or hostname_len > MAX_HOSTNAME_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.hostname[0..hostname_len], hostname_ptr[0..hostname_len]);
            s.hostname_len = hostname_len;
            s.state = .idle;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a responder session, releasing its slot.
pub export fn mdns_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current ResponderState tag.
pub export fn mdns_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Register a service. Returns 0 on success, 1 on rejection.
pub export fn mdns_register_service(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    stype_ptr: [*]const u8,
    stype_len: u32,
    port: u16,
    flag: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (stype_len == 0 or stype_len > MAX_NAME_LEN) return 1;
    if (flag > 1) return 1;
    if (port == 0) return 1;
    if (sessions[idx].service_count >= MAX_SERVICES) return 1;

    // Check for duplicate service name
    const name = name_ptr[0..name_len];
    for (&sessions[idx].services) |*svc| {
        if (svc.active and svc.name_len == name_len and
            std.mem.eql(u8, svc.name[0..svc.name_len], name))
        {
            return 1;
        }
    }

    // Find a free service slot
    for (&sessions[idx].services) |*svc| {
        if (!svc.active) {
            @memcpy(svc.name[0..name_len], name);
            svc.name_len = name_len;
            @memcpy(svc.service_type[0..stype_len], stype_ptr[0..stype_len]);
            svc.stype_len = stype_len;
            svc.port = port;
            svc.flag = @enumFromInt(flag);
            svc.active = true;
            sessions[idx].service_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Unregister a service by name. Returns 0 on success, 1 on rejection.
pub export fn mdns_unregister_service(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    const name = name_ptr[0..name_len];
    for (&sessions[idx].services) |*svc| {
        if (svc.active and svc.name_len == name_len and
            std.mem.eql(u8, svc.name[0..svc.name_len], name))
        {
            svc.active = false;
            svc.name_len = 0;
            sessions[idx].service_count -= 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of registered services.
pub export fn mdns_service_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].service_count;
}

/// Start probing. Transitions Idle -> Probing.
pub export fn mdns_start_probing(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .idle) return 1;

    sessions[idx].state = .probing;
    return 0;
}

/// Finish probing. Transitions Probing -> Announcing.
pub export fn mdns_finish_probing(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .probing) return 1;

    sessions[idx].state = .announcing;
    return 0;
}

/// Finish announcing. Transitions Announcing -> Running.
pub export fn mdns_finish_announcing(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .announcing) return 1;

    sessions[idx].state = .running;
    return 0;
}

/// Handle a conflict. Returns 0 on success, 1 on rejection.
pub export fn mdns_handle_conflict(slot: c_int, action: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (action > 2) return 1;

    const state = sessions[idx].state;
    if (state != .probing and state != .running) return 1;

    // Withdraw -> back to idle; Probe -> back to probing; Defend -> stay
    if (action == 2) { // Withdraw
        sessions[idx].state = .idle;
    } else if (action == 0) { // Probe (re-probe)
        sessions[idx].state = .probing;
    }
    // Defend (1) -> no state change
    return 0;
}

/// Submit a query. Only valid from Running state. Returns 0 on success.
pub export fn mdns_query(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    rtype: u8,
    qtype: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (rtype > 4) return 1;
    if (qtype > 2) return 1;
    if (sessions[idx].record_count >= MAX_RECORDS) return 1;

    // Add to record cache
    for (&sessions[idx].records) |*rec| {
        if (!rec.active) {
            @memcpy(rec.name[0..name_len], name_ptr[0..name_len]);
            rec.name_len = name_len;
            rec.rtype = @enumFromInt(rtype);
            rec.active = true;
            sessions[idx].record_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of cached records.
pub export fn mdns_record_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].record_count;
}

/// Shutdown the responder. Transitions to ShuttingDown.
pub export fn mdns_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .probing or state == .announcing or state == .running) {
        sessions[idx].state = .shutting_down;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions ShuttingDown -> Idle.
pub export fn mdns_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutting_down) return 1;

    sessions[idx].state = .idle;
    sessions[idx].services = [_]ServiceEntry{empty_service} ** MAX_SERVICES;
    sessions[idx].service_count = 0;
    sessions[idx].records = [_]RecordEntry{empty_record} ** MAX_RECORDS;
    sessions[idx].record_count = 0;

    return 0;
}

/// Check if a responder state transition is valid.
pub export fn mdns_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Probing
    if (from == 1 and to == 2) return 1; // Probing -> Announcing
    if (from == 2 and to == 3) return 1; // Announcing -> Running
    if (from == 1 and to == 0) return 1; // Probing -> Idle (conflict withdraw)
    if (from == 3 and to == 1) return 1; // Running -> Probing (conflict re-probe)
    if (from == 3 and to == 0) return 1; // Running -> Idle (conflict withdraw)
    if (from == 1 and to == 4) return 1; // Probing -> ShuttingDown
    if (from == 2 and to == 4) return 1; // Announcing -> ShuttingDown
    if (from == 3 and to == 4) return 1; // Running -> ShuttingDown
    if (from == 4 and to == 0) return 1; // ShuttingDown -> Idle
    return 0;
}
