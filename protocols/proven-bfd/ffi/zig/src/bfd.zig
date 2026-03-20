// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// bfd.zig -- Zig FFI implementation of proven-bfd.
//
// Implements the BFD (RFC 5880) session state machine with:
//   - 64-slot mutex-protected session pool
//   - BFD FSM per session (AdminDown/Down/Init/Up per RFC 5880 Section 6.2)
//   - Desired min TX/Required min RX interval tracking
//   - Detection multiplier
//   - Packet counter per session
//   - Diagnostic code tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching BFDABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching BFDABI.Types.idr tag assignments)
// =========================================================================

/// BFD session states (ABI tags 0-3, matching RFC 5880 Section 4.1).
pub const BfdState = enum(u8) {
    admin_down = 0,
    down = 1,
    init = 2,
    up = 3,
};

/// BFD diagnostic codes (ABI tags 0-8).
pub const Diagnostic = enum(u8) {
    no_diagnostic = 0,
    control_detection_time_expired = 1,
    echo_function_failed = 2,
    neighbor_signaled_session_down = 3,
    forwarding_plane_reset = 4,
    path_down = 5,
    concatenated_path_down = 6,
    administratively_down = 7,
    reverse_concatenated_path_down = 8,
};

/// BFD session modes (ABI tags 0-1).
pub const SessionMode = enum(u8) {
    async_mode = 0,
    demand_mode = 1,
};

/// BFD session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    ss_down = 1,
    negotiating = 2,
    established = 3,
    teardown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// A BFD session.
const Session = struct {
    /// FFI lifecycle state.
    state: SessionState,
    /// BFD discriminator (local session identifier).
    discriminator: u32,
    /// Desired minimum TX interval in microseconds.
    desired_min_tx: u32,
    /// Required minimum RX interval in microseconds.
    required_min_rx: u32,
    /// Detection multiplier.
    detect_mult: u8,
    /// Session operating mode.
    mode: u8,
    /// Current BFD protocol state.
    bfd_state: BfdState,
    /// Current diagnostic code.
    diagnostic: Diagnostic,
    /// Packets sent counter.
    packets_sent: u64,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .discriminator = 0,
    .desired_min_tx = 1000000,
    .required_min_rx = 1000000,
    .detect_mult = 3,
    .mode = 0,
    .bfd_state = .down,
    .diagnostic = .no_diagnostic,
    .packets_sent = 0,
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
pub export fn bfd_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new BFD session. Returns slot index (>=0) or -1 on failure.
pub export fn bfd_create(
    discriminator: u32,
    desired_min_tx: u32,
    required_min_rx: u32,
    detect_mult: u8,
    mode: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (discriminator == 0) return -1; // discriminator must be non-zero
    if (detect_mult == 0) return -1; // must be >= 1
    if (mode > 1) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.discriminator = discriminator;
            s.desired_min_tx = if (desired_min_tx == 0) 1000000 else desired_min_tx;
            s.required_min_rx = if (required_min_rx == 0) 1000000 else required_min_rx;
            s.detect_mult = detect_mult;
            s.mode = mode;
            s.state = .ss_down; // Idle -> Down
            s.bfd_state = .down;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn bfd_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SessionState tag.
pub export fn bfd_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Signal that peer sent Init. Transitions Down -> Negotiating.
pub export fn bfd_peer_init(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ss_down) return 1;

    sessions[idx].state = .negotiating;
    sessions[idx].bfd_state = .init;
    return 0;
}

/// Signal that peer is Up. Transitions Negotiating -> Established.
pub export fn bfd_peer_up(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .negotiating) return 1;

    sessions[idx].state = .established;
    sessions[idx].bfd_state = .up;
    return 0;
}

/// Signal that peer went Down. Transitions Established -> Down.
pub export fn bfd_peer_down(slot: c_int, diag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .established) return 1;
    if (diag > 8) return 1;

    sessions[idx].state = .ss_down;
    sessions[idx].bfd_state = .down;
    sessions[idx].diagnostic = @enumFromInt(diag);
    return 0;
}

/// Administratively shut down the session. Transitions any active -> Teardown.
pub export fn bfd_admin_down(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .ss_down or state == .negotiating or state == .established) {
        sessions[idx].state = .teardown;
        sessions[idx].bfd_state = .admin_down;
        sessions[idx].diagnostic = .administratively_down;
        return 0;
    }
    return 1;
}

/// Returns 1 if the session is Established (Up), 0 otherwise.
pub export fn bfd_is_up(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .established) 1 else 0;
}

/// Returns the number of packets sent.
pub export fn bfd_packets_sent(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].packets_sent;
}

/// Send a BFD control packet. Returns 0 on success, 1 on rejection.
/// Only allowed from Established state.
pub export fn bfd_send_packet(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .established) return 1;

    sessions[idx].packets_sent += 1;
    return 0;
}

/// Begin teardown. Returns 0 on success, 1 on rejection.
pub export fn bfd_teardown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .ss_down or state == .negotiating or state == .established) {
        sessions[idx].state = .teardown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after teardown. Returns 0 on success, 1 on rejection.
pub export fn bfd_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .teardown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].bfd_state = .down;
    sessions[idx].diagnostic = .no_diagnostic;
    sessions[idx].packets_sent = 0;

    return 0;
}

/// Check if a session state transition is valid.
pub export fn bfd_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Down
    if (from == 1 and to == 2) return 1; // Down -> Negotiating
    if (from == 2 and to == 3) return 1; // Negotiating -> Established
    if (from == 3 and to == 1) return 1; // Established -> Down (peer down)
    if (from == 1 and to == 4) return 1; // Down -> Teardown
    if (from == 2 and to == 4) return 1; // Negotiating -> Teardown
    if (from == 3 and to == 4) return 1; // Established -> Teardown
    if (from == 4 and to == 0) return 1; // Teardown -> Idle
    return 0;
}
