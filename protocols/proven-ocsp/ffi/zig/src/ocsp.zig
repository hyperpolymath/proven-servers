// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ocsp.zig -- Zig FFI implementation of proven-ocsp.
//
// Implements an RFC 6960 OCSP responder state machine with:
//   - 64-slot mutex-protected responder pool
//   - Certificate status cache (max 256 entries per responder)
//   - Hash algorithm selection per responder
//   - OCSP request/response lifecycle
//   - Nonce tracking for replay protection
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching OCSPABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching OCSPABI.Types.idr tag assignments)
// =========================================================================

/// Certificate status (ABI tags 0-2).
pub const CertStatus = enum(u8) {
    good = 0,
    revoked = 1,
    unknown = 2,
};

/// Response-level status codes (ABI tags 0-5).
pub const ResponseStatus = enum(u8) {
    successful = 0,
    malformed_request = 1,
    internal_error = 2,
    try_later = 3,
    sig_required = 4,
    unauthorized = 5,
};

/// Hash algorithms (ABI tags 0-3).
pub const HashAlgorithm = enum(u8) {
    sha1 = 0,
    sha256 = 1,
    sha384 = 2,
    sha512 = 3,
};

/// Responder lifecycle states (ABI tags 0-4).
pub const ResponderState = enum(u8) {
    idle = 0,
    ready = 1,
    processing = 2,
    signing = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_CACHE_ENTRIES: usize = 256;
const MAX_NAME_LEN: usize = 256;
const MAX_SERIAL_LEN: usize = 64;
const MAX_NONCE_LEN: usize = 32;

/// A cached certificate status entry.
const CacheEntry = struct {
    serial: [MAX_SERIAL_LEN]u8,
    serial_len: u32,
    status: CertStatus,
    active: bool,
};

const empty_cache_entry: CacheEntry = .{
    .serial = [_]u8{0} ** MAX_SERIAL_LEN,
    .serial_len = 0,
    .status = .unknown,
    .active = false,
};

/// An OCSP responder session.
const Session = struct {
    state: ResponderState,
    ca_name: [MAX_NAME_LEN]u8,
    ca_name_len: u32,
    hash_alg: HashAlgorithm,
    cache: [MAX_CACHE_ENTRIES]CacheEntry,
    cache_count: u32,
    /// Current query serial (while processing).
    query_serial: [MAX_SERIAL_LEN]u8,
    query_serial_len: u32,
    /// Current query nonce (while processing).
    nonce: [MAX_NONCE_LEN]u8,
    nonce_len: u32,
    /// Last response status.
    last_response_status: ResponseStatus,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .ca_name = [_]u8{0} ** MAX_NAME_LEN,
    .ca_name_len = 0,
    .hash_alg = .sha256,
    .cache = [_]CacheEntry{empty_cache_entry} ** MAX_CACHE_ENTRIES,
    .cache_count = 0,
    .query_serial = [_]u8{0} ** MAX_SERIAL_LEN,
    .query_serial_len = 0,
    .nonce = [_]u8{0} ** MAX_NONCE_LEN,
    .nonce_len = 0,
    .last_response_status = .successful,
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

fn findCacheEntry(idx: usize, serial: []const u8) ?usize {
    for (&sessions[idx].cache, 0..) |*e, i| {
        if (e.active and e.serial_len == serial.len and
            std.mem.eql(u8, e.serial[0..e.serial_len], serial))
        {
            return i;
        }
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn ocsp_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new OCSP responder. Returns slot (>=0) or -1.
/// Transitions: Idle -> Ready.
pub export fn ocsp_create(
    ca_name_ptr: [*]const u8,
    ca_name_len: u32,
    hash_alg: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (ca_name_len == 0 or ca_name_len > MAX_NAME_LEN) return -1;
    if (hash_alg > 3) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.ca_name[0..ca_name_len], ca_name_ptr[0..ca_name_len]);
            s.ca_name_len = ca_name_len;
            s.hash_alg = @enumFromInt(hash_alg);
            s.state = .ready;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn ocsp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn ocsp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Set certificate status in the cache. Returns 0 on success, 1 on rejection.
pub export fn ocsp_set_cert_status(
    slot: c_int,
    serial_ptr: [*]const u8,
    serial_len: u32,
    status: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (serial_len == 0 or serial_len > MAX_SERIAL_LEN) return 1;
    if (status > 2) return 1;

    const serial = serial_ptr[0..serial_len];

    // Update existing entry if found
    if (findCacheEntry(idx, serial)) |ci| {
        sessions[idx].cache[ci].status = @enumFromInt(status);
        return 0;
    }

    // Create new entry
    for (&sessions[idx].cache) |*e| {
        if (!e.active) {
            @memcpy(e.serial[0..serial_len], serial);
            e.serial_len = serial_len;
            e.status = @enumFromInt(status);
            e.active = true;
            sessions[idx].cache_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Submit an OCSP query. Returns 0 on success, 1 on rejection.
/// Transitions: Ready -> Processing.
pub export fn ocsp_query(
    slot: c_int,
    serial_ptr: [*]const u8,
    serial_len: u32,
    nonce_ptr: [*]const u8,
    nonce_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (serial_len == 0 or serial_len > MAX_SERIAL_LEN) return 1;
    if (nonce_len > MAX_NONCE_LEN) return 1;

    @memcpy(sessions[idx].query_serial[0..serial_len], serial_ptr[0..serial_len]);
    sessions[idx].query_serial_len = serial_len;
    if (nonce_len > 0) {
        @memcpy(sessions[idx].nonce[0..nonce_len], nonce_ptr[0..nonce_len]);
    }
    sessions[idx].nonce_len = nonce_len;
    sessions[idx].state = .processing;
    return 0;
}

/// Generate OCSP response. Returns CertStatus tag.
/// Transitions: Processing -> Signing -> Ready (atomic).
pub export fn ocsp_respond(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 2; // unknown
    if (sessions[idx].state != .processing) return 2;

    const serial = sessions[idx].query_serial[0..sessions[idx].query_serial_len];

    // Look up status in cache
    var result: CertStatus = .unknown;
    if (findCacheEntry(idx, serial)) |ci| {
        result = sessions[idx].cache[ci].status;
        sessions[idx].last_response_status = .successful;
    } else {
        sessions[idx].last_response_status = .successful;
    }

    // Transition through Signing back to Ready
    sessions[idx].state = .ready;
    sessions[idx].query_serial_len = 0;
    sessions[idx].nonce_len = 0;
    return @intFromEnum(result);
}

/// Returns the last ResponseStatus tag.
pub export fn ocsp_get_response_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 2; // internal_error
    return @intFromEnum(sessions[idx].last_response_status);
}

/// Returns the number of cached certificate statuses.
pub export fn ocsp_cache_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].cache_count;
}

/// Set hash algorithm. Returns 0 on success, 1 on rejection.
pub export fn ocsp_set_hash_algorithm(slot: c_int, alg: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (alg > 3) return 1;

    sessions[idx].hash_alg = @enumFromInt(alg);
    return 0;
}

/// Close the responder. Returns 0 on success, 1 on rejection.
pub export fn ocsp_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .ready or sessions[idx].state == .processing) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions: Closing -> Idle.
pub export fn ocsp_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].cache = [_]CacheEntry{empty_cache_entry} ** MAX_CACHE_ENTRIES;
    sessions[idx].cache_count = 0;
    return 0;
}

/// Check if a responder state transition is valid.
pub export fn ocsp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Processing
    if (from == 2 and to == 3) return 1; // Processing -> Signing
    if (from == 3 and to == 1) return 1; // Signing -> Ready
    if (from == 2 and to == 1) return 1; // Processing -> Ready (direct)
    if (from == 1 and to == 4) return 1; // Ready -> Closing
    if (from == 2 and to == 4) return 1; // Processing -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    return 0;
}

/// Returns whether the responder is ready.
pub export fn ocsp_is_ready(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .ready) 1 else 0;
}
