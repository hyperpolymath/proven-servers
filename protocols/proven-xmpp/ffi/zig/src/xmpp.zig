// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// xmpp.zig -- Zig FFI implementation of proven-xmpp.
//
// Implements the XMPP stream state machine with:
//   - 64-slot mutex-protected stream pool
//   - Stream lifecycle (Disconnected/Connected/Authenticated/Bound/Error)
//   - Stanza send/receive counting by type
//   - Presence state tracking
//   - Resource binding
//   - Stream error handling
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching XMPPABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching XMPPABI.Types.idr tag assignments)
// =========================================================================

/// Stanza types (ABI tags 0-2).
pub const StanzaType = enum(u8) {
    message = 0,
    presence = 1,
    iq = 2,
};

/// Message types (ABI tags 0-4).
pub const MessageType = enum(u8) {
    chat = 0,
    err = 1,
    groupchat = 2,
    headline = 3,
    normal = 4,
};

/// Presence types (ABI tags 0-4).
pub const PresenceType = enum(u8) {
    available = 0,
    away = 1,
    dnd = 2,
    xa = 3,
    unavailable = 4,
};

/// IQ types (ABI tags 0-3).
pub const IQType = enum(u8) {
    get = 0,
    set = 1,
    result = 2,
    iq_error = 3,
};

/// Stream errors (ABI tags 0-8).
pub const StreamError = enum(u8) {
    bad_format = 0,
    conflict = 1,
    connection_timeout = 2,
    host_gone = 3,
    host_unknown = 4,
    not_authorized = 5,
    policy_violation = 6,
    resource_constraint = 7,
    system_shutdown = 8,
};

/// XMPP stream lifecycle states (ABI tags 0-4).
pub const StreamState = enum(u8) {
    disconnected = 0,
    connected = 1,
    authenticated = 2,
    bound = 3,
    err = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_JID_LEN: usize = 256;
const MAX_RESOURCE_LEN: usize = 128;

/// An XMPP stream session.
const Session = struct {
    /// Current stream state.
    state: StreamState,
    /// JID (bare JID: user@domain).
    jid: [MAX_JID_LEN]u8,
    jid_len: u32,
    /// Bound resource.
    resource: [MAX_RESOURCE_LEN]u8,
    resource_len: u32,
    /// Current presence state.
    presence: PresenceType,
    /// Total stanzas sent.
    stanzas_sent: u32,
    /// Total stanzas received.
    stanzas_received: u32,
    /// Last stream error (if any).
    last_error: StreamError,
    /// Whether this slot is in use.
    active: bool,
};

const empty_session: Session = .{
    .state = .disconnected,
    .jid = [_]u8{0} ** MAX_JID_LEN,
    .jid_len = 0,
    .resource = [_]u8{0} ** MAX_RESOURCE_LEN,
    .resource_len = 0,
    .presence = .unavailable,
    .stanzas_sent = 0,
    .stanzas_received = 0,
    .last_error = .bad_format,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn xmpp_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create an XMPP stream. Returns slot (>=0) or -1 on failure.
pub export fn xmpp_create(
    jid_ptr: [*]const u8,
    jid_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (jid_len == 0 or jid_len > MAX_JID_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.jid[0..jid_len], jid_ptr[0..jid_len]);
            s.jid_len = jid_len;
            s.state = .disconnected;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn xmpp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn xmpp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Transition Disconnected -> Connected. Returns 0 on success.
pub export fn xmpp_connect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnected) return 1;
    sessions[idx].state = .connected;
    return 0;
}

/// Transition Connected -> Authenticated. Returns 0 on success.
pub export fn xmpp_authenticate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    sessions[idx].state = .authenticated;
    return 0;
}

/// Transition Authenticated -> Bound. Returns 0 on success.
pub export fn xmpp_bind(
    slot: c_int,
    resource_ptr: [*]const u8,
    resource_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .authenticated) return 1;
    if (resource_len == 0 or resource_len > MAX_RESOURCE_LEN) return 1;

    @memcpy(sessions[idx].resource[0..resource_len], resource_ptr[0..resource_len]);
    sessions[idx].resource_len = resource_len;
    sessions[idx].state = .bound;
    sessions[idx].presence = .available;
    return 0;
}

/// Send a stanza. Returns 0 on success, 1 on rejection.
pub export fn xmpp_send_stanza(slot: c_int, stanza_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bound) return 1;
    if (stanza_type > 2) return 1;

    sessions[idx].stanzas_sent += 1;
    return 0;
}

/// Receive a stanza. Returns 0 on success, 1 on rejection.
pub export fn xmpp_recv_stanza(slot: c_int, stanza_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bound) return 1;
    if (stanza_type > 2) return 1;

    sessions[idx].stanzas_received += 1;
    return 0;
}

/// Set presence state. Returns 0 on success.
pub export fn xmpp_set_presence(slot: c_int, presence: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bound) return 1;
    if (presence > 4) return 1;

    sessions[idx].presence = @enumFromInt(presence);
    return 0;
}

/// Returns current presence state tag.
pub export fn xmpp_presence(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // unavailable
    return @intFromEnum(sessions[idx].presence);
}

/// Set stream error. Transitions to Error state. Returns 0 on success.
pub export fn xmpp_stream_error(slot: c_int, error_code: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .disconnected or sessions[idx].state == .err) return 1;
    if (error_code > 8) return 1;

    sessions[idx].last_error = @enumFromInt(error_code);
    sessions[idx].state = .err;
    return 0;
}

/// Disconnect. Transitions to Disconnected. Returns 0 on success.
pub export fn xmpp_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .disconnected) return 1;

    sessions[idx].state = .disconnected;
    sessions[idx].presence = .unavailable;
    sessions[idx].resource_len = 0;
    return 0;
}

pub export fn xmpp_stanzas_sent(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].stanzas_sent;
}

pub export fn xmpp_stanzas_received(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].stanzas_received;
}

/// Check if a stream state transition is valid.
pub export fn xmpp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Disconnected -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> Authenticated
    if (from == 2 and to == 3) return 1; // Authenticated -> Bound
    if (from == 1 and to == 4) return 1; // Connected -> Error
    if (from == 2 and to == 4) return 1; // Authenticated -> Error
    if (from == 3 and to == 4) return 1; // Bound -> Error
    if (from == 1 and to == 0) return 1; // Connected -> Disconnected
    if (from == 2 and to == 0) return 1; // Authenticated -> Disconnected
    if (from == 3 and to == 0) return 1; // Bound -> Disconnected
    if (from == 4 and to == 0) return 1; // Error -> Disconnected
    return 0;
}
