// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// nts.zig -- Zig FFI implementation of proven-nts.
//
// Implements the NTS-KE (RFC 8915) session state machine with:
//   - 64-slot mutex-protected session pool
//   - NTS-KE record type tracking
//   - Cookie storage (max 8 cookies per session)
//   - AEAD algorithm negotiation
//   - Handshake state machine transitions
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching NTSABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching NTSABI.Types.idr tag assignments)
// =========================================================================

/// NTS-KE record types (ABI tags 0-8).
pub const RecordType = enum(u8) {
    end_of_message = 0,
    next_protocol = 1,
    err = 2,
    warning = 3,
    aead_algorithm = 4,
    cookie = 5,
    cookie_placeholder = 6,
    ntske_server = 7,
    ntske_port = 8,
};

/// NTS-KE error codes (ABI tags 0-2).
pub const ErrorCode = enum(u8) {
    unrecognized_critical = 0,
    bad_request = 1,
    internal_error = 2,
};

/// AEAD algorithms (ABI tags 0-2).
pub const AEADAlgorithm = enum(u8) {
    aead_aes_128_gcm = 0,
    aead_aes_256_gcm = 1,
    aead_aes_siv_cmac_256 = 2,
};

/// Handshake states (ABI tags 0-3).
pub const HandshakeState = enum(u8) {
    initial = 0,
    negotiating = 1,
    established = 2,
    failed = 3,
};

/// Session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    handshaking = 1,
    negotiating = 2,
    established = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum cookies per session.
const MAX_COOKIES: usize = 8;

/// Maximum cookie length in bytes.
const MAX_COOKIE_LEN: usize = 256;

/// Maximum server name length.
const MAX_SERVER_LEN: usize = 256;

/// A stored NTS cookie.
const CookieEntry = struct {
    data: [MAX_COOKIE_LEN]u8,
    len: u32,
    active: bool,
};

/// Default (empty) cookie entry.
const empty_cookie: CookieEntry = .{
    .data = [_]u8{0} ** MAX_COOKIE_LEN,
    .len = 0,
    .active = false,
};

/// An NTS-KE session.
const Session = struct {
    /// Current session lifecycle state.
    state: SessionState,
    /// NTS-KE server hostname.
    server: [MAX_SERVER_LEN]u8,
    server_len: u32,
    /// NTS-KE port number.
    port: u16,
    /// Negotiated AEAD algorithm.
    aead: AEADAlgorithm,
    /// Stored cookies.
    cookies: [MAX_COOKIES]CookieEntry,
    /// Number of active cookies.
    cookie_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .server = [_]u8{0} ** MAX_SERVER_LEN,
    .server_len = 0,
    .port = 4460,
    .aead = .aead_aes_siv_cmac_256,
    .cookies = [_]CookieEntry{empty_cookie} ** MAX_COOKIES,
    .cookie_count = 0,
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

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn nts_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new NTS-KE session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Handshaking state (Idle -> Handshaking).
pub export fn nts_create(
    server_ptr: [*]const u8,
    server_len: u32,
    port: u16,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (server_len == 0 or server_len > MAX_SERVER_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.server[0..server_len], server_ptr[0..server_len]);
            s.server_len = server_len;
            s.port = if (port == 0) 4460 else port;
            s.state = .handshaking;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn nts_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SessionState tag for a session.
pub export fn nts_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Propose an AEAD algorithm for negotiation. Returns 0 on success, 1 on rejection.
/// Transitions: Handshaking -> Negotiating.
pub export fn nts_negotiate(slot: c_int, aead: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .handshaking) return 1;
    if (aead > 2) return 1;

    sessions[idx].aead = @enumFromInt(aead);
    sessions[idx].state = .negotiating;
    return 0;
}

/// Accept negotiation, establishing the session. Returns 0 on success, 1 on rejection.
/// Transitions: Negotiating -> Established.
pub export fn nts_accept(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .negotiating) return 1;

    sessions[idx].state = .established;
    return 0;
}

/// Add a cookie to the session. Returns 0 on success, 1 on rejection.
pub export fn nts_add_cookie(slot: c_int, cookie_ptr: [*]const u8, cookie_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .established and sessions[idx].state != .negotiating) return 1;
    if (cookie_len == 0 or cookie_len > MAX_COOKIE_LEN) return 1;

    for (&sessions[idx].cookies) |*c| {
        if (!c.active) {
            @memcpy(c.data[0..cookie_len], cookie_ptr[0..cookie_len]);
            c.len = cookie_len;
            c.active = true;
            sessions[idx].cookie_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of stored cookies.
pub export fn nts_cookie_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].cookie_count;
}

/// Returns the negotiated AEAD algorithm tag.
pub export fn nts_get_aead(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].aead);
}

/// Close the session. Returns 0 on success, 1 on rejection.
/// Transitions to Closing from any active state.
pub export fn nts_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .handshaking or state == .negotiating or state == .established) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup after close. Returns 0 on success, 1 on rejection.
/// Transitions: Closing -> Idle.
pub export fn nts_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].cookies = [_]CookieEntry{empty_cookie} ** MAX_COOKIES;
    sessions[idx].cookie_count = 0;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn nts_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Handshaking
    if (from == 1 and to == 2) return 1; // Handshaking -> Negotiating
    if (from == 2 and to == 3) return 1; // Negotiating -> Established
    if (from == 1 and to == 3) return 1; // Handshaking -> Failed (mapped to closing=4 below)
    if (from == 1 and to == 4) return 1; // Handshaking -> Closing
    if (from == 2 and to == 4) return 1; // Negotiating -> Closing
    if (from == 3 and to == 4) return 1; // Established -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    return 0;
}

/// Returns whether the session is established and ready for NTP queries.
pub export fn nts_is_established(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .established) 1 else 0;
}

/// Returns the error code for a failed state (stateless helper).
pub export fn nts_error_for_state(state: u8) callconv(.c) u8 {
    // If in Closing state, return InternalError
    if (state == 4) return 2;
    // Otherwise no error
    return 0;
}
