// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// bgp.zig -- Zig FFI implementation of proven-bgp.
//
// Implements the BGP-4 FSM (RFC 4271 Section 8) state machine with:
//   - 64-slot session pool
//   - Full 6-state, 19-event FSM per RFC 4271 Section 8.2.2
//   - Route count tracking per session
//   - Thread-safe via mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching BGPABI.Layout.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching BGPABI.Layout.idr tag assignments)
// =========================================================================

/// BGP FSM states (tags 0-5).
pub const BGPState = enum(u8) {
    idle = 0,
    connect = 1,
    active = 2,
    open_sent = 3,
    open_confirm = 4,
    established = 5,
};

/// BGP events (tags 0-18).
pub const BGPEvent = enum(u8) {
    manual_start = 0,
    manual_stop = 1,
    automatic_start = 2,
    connect_retry_timer_expires = 3,
    hold_timer_expires = 4,
    keepalive_timer_expires = 5,
    delay_open_timer_expires = 6,
    tcp_connection_valid = 7,
    tcp_cr_acked = 8,
    tcp_connection_confirmed = 9,
    tcp_connection_fails = 10,
    bgp_open_received = 11,
    bgp_header_err = 12,
    bgp_open_msg_err = 13,
    notif_msg_ver_err = 14,
    notif_msg = 15,
    keepalive_msg = 16,
    update_msg = 17,
    update_msg_err = 18,
};

/// BGP message types (tags 0-3).
pub const MessageType = enum(u8) {
    open = 0,
    update = 1,
    notification = 2,
    keepalive = 3,
};

/// BGP error codes (tags 0-5).
pub const ErrorCode = enum(u8) {
    message_header_error = 0,
    open_message_error = 1,
    update_message_error = 2,
    hold_timer_expired = 3,
    fsm_error = 4,
    cease = 5,
};

/// BGP origin values (tags 0-2).
pub const Origin = enum(u8) {
    igp = 0,
    egp = 1,
    incomplete = 2,
};

/// AS_PATH segment types (tags 0-1).
pub const ASPathSegmentType = enum(u8) {
    as_set = 0,
    as_sequence = 1,
};

/// Path attribute types (tags 0-7).
pub const PathAttrType = enum(u8) {
    origin = 0,
    as_path = 1,
    next_hop = 2,
    med = 3,
    local_pref = 4,
    atomic_aggr = 5,
    aggregator = 6,
    unknown = 7,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent BGP sessions.
const MAX_SESSIONS: usize = 64;

/// A BGP session.
const Session = struct {
    /// Current FSM state.
    state: BGPState,
    /// Local autonomous system number.
    local_as: u32,
    /// Peer autonomous system number.
    peer_as: u32,
    /// Negotiated hold time in seconds.
    hold_time: u16,
    /// Connect retry counter.
    connect_retry_count: u32,
    /// Number of routes received from this peer.
    routes_received: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .local_as = 0,
    .peer_as = 0,
    .hold_time = 90,
    .connect_retry_count = 0,
    .routes_received = 0,
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

/// Apply the BGP FSM transition function (RFC 4271 Section 8.2.2).
/// Returns the new state after processing the event.
/// This mirrors the total transition function in BGP.FSM (Idris2).
fn fsmTransition(state: BGPState, event: BGPEvent) BGPState {
    return switch (state) {
        .idle => switch (event) {
            .manual_start, .automatic_start => .connect,
            else => .idle,
        },
        .connect => switch (event) {
            .manual_stop => .idle,
            .connect_retry_timer_expires => .connect,
            .tcp_cr_acked, .tcp_connection_confirmed => .open_sent,
            .tcp_connection_fails => .active,
            .bgp_open_received => .open_confirm,
            .bgp_header_err, .bgp_open_msg_err => .idle,
            .notif_msg_ver_err => .idle,
            else => .idle,
        },
        .active => switch (event) {
            .manual_stop => .idle,
            .connect_retry_timer_expires => .connect,
            .tcp_cr_acked, .tcp_connection_confirmed => .open_sent,
            .tcp_connection_fails => .idle,
            .bgp_open_received => .open_confirm,
            else => .idle,
        },
        .open_sent => switch (event) {
            .manual_stop => .idle,
            .hold_timer_expires => .idle,
            .tcp_connection_fails => .active,
            .bgp_open_received => .open_confirm,
            .bgp_header_err, .bgp_open_msg_err => .idle,
            .notif_msg_ver_err => .idle,
            else => .idle,
        },
        .open_confirm => switch (event) {
            .manual_stop => .idle,
            .hold_timer_expires => .idle,
            .keepalive_timer_expires => .open_confirm,
            .tcp_connection_fails => .idle,
            .keepalive_msg => .established,
            .notif_msg => .idle,
            .bgp_header_err, .bgp_open_msg_err => .idle,
            else => .idle,
        },
        .established => switch (event) {
            .manual_stop => .idle,
            .hold_timer_expires => .idle,
            .keepalive_timer_expires => .established,
            .tcp_connection_fails => .idle,
            .keepalive_msg => .established,
            .update_msg => .established,
            .update_msg_err => .idle,
            .notif_msg => .idle,
            else => .idle,
        },
    };
}

/// Check if an event in a given state increments the connect retry counter.
fn shouldIncrementRetry(state: BGPState, event: BGPEvent, new_state: BGPState) bool {
    // Increment when transitioning to Idle due to error (not ManualStop)
    if (new_state != .idle) return false;
    if (event == .manual_stop) return false;
    if (state == .idle) return false;
    // Only increment on error-class events or default-to-idle transitions
    return switch (event) {
        .hold_timer_expires,
        .bgp_header_err,
        .bgp_open_msg_err,
        .update_msg_err,
        .notif_msg,
        => true,
        else => state != .connect or event != .notif_msg_ver_err,
    };
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn bgp_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new BGP session in Idle state. Returns slot index (>=0) or -1.
pub export fn bgp_create(local_as: u32, peer_as: u32, hold_time: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.local_as = local_as;
            s.peer_as = peer_as;
            s.hold_time = hold_time;
            s.state = .idle;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn bgp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current BGPState tag for a session.
pub export fn bgp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle as fallback
    return @intFromEnum(sessions[idx].state);
}

/// Apply a BGPEvent to the session FSM. Returns 0 on success, 1 on rejection.
pub export fn bgp_apply_event(slot: c_int, event: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (event > 18) return 1; // invalid event tag

    const ev: BGPEvent = @enumFromInt(event);
    const old_state = sessions[idx].state;
    const new_state = fsmTransition(old_state, ev);

    // Track connect retry counter
    if (shouldIncrementRetry(old_state, ev, new_state)) {
        sessions[idx].connect_retry_count += 1;
    }

    // Clear routes when leaving Established
    if (old_state == .established and new_state != .established) {
        sessions[idx].routes_received = 0;
    }

    sessions[idx].state = new_state;
    return 0;
}

/// Returns 1 if the session is in Established state, 0 otherwise.
pub export fn bgp_is_established(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .established) 1 else 0;
}

/// Returns the connect retry counter.
pub export fn bgp_connect_retry_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].connect_retry_count;
}

/// Returns the number of routes received.
pub export fn bgp_routes_received(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].routes_received;
}

/// Increment route counter. Returns 0 on success, 1 if not Established.
pub export fn bgp_add_route(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .established) return 1;
    sessions[idx].routes_received += 1;
    return 0;
}

/// Decrement route counter. Returns 0 on success, 1 if not Established or no routes.
pub export fn bgp_withdraw_route(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .established) return 1;
    if (sessions[idx].routes_received == 0) return 1;
    sessions[idx].routes_received -= 1;
    return 0;
}

/// Returns 1 if the session can exchange routes (Established), 0 otherwise.
pub export fn bgp_can_exchange(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .established) 1 else 0;
}

/// Stateless: check if a BGP FSM transition is valid per Transitions.idr.
pub export fn bgp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle -> Connect
    if (from == 0 and to == 1) return 1;
    // Connect -> OpenSent, Active, OpenConfirm, Idle
    if (from == 1 and to == 3) return 1;
    if (from == 1 and to == 2) return 1;
    if (from == 1 and to == 4) return 1;
    if (from == 1 and to == 0) return 1;
    // Active -> Connect, OpenSent, OpenConfirm, Idle
    if (from == 2 and to == 1) return 1;
    if (from == 2 and to == 3) return 1;
    if (from == 2 and to == 4) return 1;
    if (from == 2 and to == 0) return 1;
    // OpenSent -> OpenConfirm, Active, Idle
    if (from == 3 and to == 4) return 1;
    if (from == 3 and to == 2) return 1;
    if (from == 3 and to == 0) return 1;
    // OpenConfirm -> Established, OpenConfirm, Idle
    if (from == 4 and to == 5) return 1;
    if (from == 4 and to == 4) return 1;
    if (from == 4 and to == 0) return 1;
    // Established -> Established, Idle
    if (from == 5 and to == 5) return 1;
    if (from == 5 and to == 0) return 1;
    return 0;
}

/// Returns the negotiated hold time.
pub export fn bgp_hold_time(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].hold_time;
}

/// Returns the local AS number.
pub export fn bgp_local_as(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].local_as;
}

/// Returns the peer AS number.
pub export fn bgp_peer_as(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].peer_as;
}
