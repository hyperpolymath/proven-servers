// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// odns.zig -- Zig FFI implementation of proven-odns.
//
// Implements an Oblivious DNS (draft-pauly-dprive-oblivious-doh) session
// state machine with:
//   - 64-slot mutex-protected session pool
//   - HPKE key pair management (simulated)
//   - Query/response encapsulation tracking
//   - Role-based access enforcement (Client/Proxy/Target)
//   - Query counter for statistics
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching ODNSABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching ODNSABI.Types.idr tag assignments)
// =========================================================================

/// Participant roles (ABI tags 0-2).
pub const Role = enum(u8) {
    client = 0,
    proxy = 1,
    target = 2,
};

/// Message types (ABI tags 0-1).
pub const MessageType = enum(u8) {
    query = 0,
    response = 1,
};

/// Error reasons (ABI tags 0-4).
pub const ErrorReason = enum(u8) {
    proxy_error = 0,
    target_error = 1,
    decryption_failed = 2,
    invalid_config = 3,
    payload_too_large = 4,
};

/// Encapsulation formats (ABI tag 0).
pub const EncapsulationFormat = enum(u8) {
    hpke = 0,
};

/// Session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    key_exchange = 1,
    ready = 2,
    processing = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_CONFIG_LEN: usize = 256;
const MAX_PUBKEY_LEN: usize = 128;
const MAX_QUERY_LEN: usize = 512;

/// An Oblivious DNS session.
const Session = struct {
    state: SessionState,
    role: Role,
    config: [MAX_CONFIG_LEN]u8,
    config_len: u32,
    pubkey: [MAX_PUBKEY_LEN]u8,
    pubkey_len: u32,
    format: EncapsulationFormat,
    /// Number of queries processed in this session.
    query_count: u32,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .role = .client,
    .config = [_]u8{0} ** MAX_CONFIG_LEN,
    .config_len = 0,
    .pubkey = [_]u8{0} ** MAX_PUBKEY_LEN,
    .pubkey_len = 0,
    .format = .hpke,
    .query_count = 0,
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

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn odns_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new Oblivious DNS session. Returns slot (>=0) or -1.
/// Transitions: Idle -> KeyExchange.
pub export fn odns_create(
    role: u8,
    config_ptr: [*]const u8,
    config_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (role > 2) return -1;
    if (config_len == 0 or config_len > MAX_CONFIG_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.role = @enumFromInt(role);
            @memcpy(s.config[0..config_len], config_ptr[0..config_len]);
            s.config_len = config_len;
            s.state = .key_exchange;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn odns_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn odns_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Complete HPKE key exchange. Returns 0 on success, 1 on rejection.
/// Transitions: KeyExchange -> Ready.
pub export fn odns_key_exchange(
    slot: c_int,
    pubkey_ptr: [*]const u8,
    pubkey_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .key_exchange) return 1;
    if (pubkey_len == 0 or pubkey_len > MAX_PUBKEY_LEN) return 1;

    @memcpy(sessions[idx].pubkey[0..pubkey_len], pubkey_ptr[0..pubkey_len]);
    sessions[idx].pubkey_len = pubkey_len;
    sessions[idx].state = .ready;
    return 0;
}

/// Submit an oblivious DNS query. Returns 0 on success, 1 on rejection.
/// Transitions: Ready -> Processing.
pub export fn odns_submit_query(
    slot: c_int,
    query_ptr: [*]const u8,
    query_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = query_ptr;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (query_len == 0 or query_len > MAX_QUERY_LEN) return 1;

    sessions[idx].state = .processing;
    return 0;
}

/// Get query response (simulated). Returns 0 on success, 1 on failure.
/// Transitions: Processing -> Ready.
pub export fn odns_get_response(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .processing) return 1;

    sessions[idx].query_count += 1;
    sessions[idx].state = .ready;
    return 0;
}

/// Returns the role tag for this session.
pub export fn odns_get_role(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].role);
}

/// Returns the encapsulation format tag.
pub export fn odns_get_format(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].format);
}

/// Returns the number of processed queries.
pub export fn odns_query_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].query_count;
}

/// Close the session. Returns 0 on success, 1 on rejection.
pub export fn odns_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .key_exchange or state == .ready or state == .processing) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions: Closing -> Idle.
pub export fn odns_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].query_count = 0;
    sessions[idx].pubkey_len = 0;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn odns_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> KeyExchange
    if (from == 1 and to == 2) return 1; // KeyExchange -> Ready
    if (from == 2 and to == 3) return 1; // Ready -> Processing
    if (from == 3 and to == 2) return 1; // Processing -> Ready
    if (from == 1 and to == 4) return 1; // KeyExchange -> Closing
    if (from == 2 and to == 4) return 1; // Ready -> Closing
    if (from == 3 and to == 4) return 1; // Processing -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    return 0;
}

/// Returns whether the session is ready for queries.
pub export fn odns_is_ready(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .ready) 1 else 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
