// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// telnet.zig -- Zig FFI implementation of proven-telnet.
//
// INSECURE PROTOCOL -- for legacy interoperability only.
//
// Implements the Telnet (RFC 854) session state machine with:
//   - 64-slot mutex-protected session pool
//   - Option negotiation state tracking (10 options per session)
//   - Command send/receive
//   - Subnegotiation data handling
//   - Session state machine (Idle -> Negotiating -> Active -> Subneg -> Closing)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching TelnetABI.Types exactly.

const std = @import("std");

// =========================================================================
// Enums (matching TelnetABI.Types tag assignments)
// =========================================================================

/// Telnet commands (ABI tags 0-15).
pub const Command = enum(u8) {
    se = 0,
    nop = 1,
    data_mark = 2,
    brk = 3,
    interrupt_process = 4,
    abort_output = 5,
    are_you_there = 6,
    erase_char = 7,
    erase_line = 8,
    go_ahead = 9,
    sb = 10,
    will = 11,
    wont = 12,
    do_ = 13,
    dont = 14,
    iac = 15,
};

/// Telnet options (ABI tags 0-9).
pub const TelnetOption = enum(u8) {
    echo = 0,
    suppress_go_ahead = 1,
    status = 2,
    timing_mark = 3,
    terminal_type = 4,
    window_size = 5,
    terminal_speed = 6,
    remote_flow_control = 7,
    linemode = 8,
    environment = 9,
};

/// Negotiation state per option (ABI tags 0-3).
pub const NegotiationState = enum(u8) {
    inactive = 0,
    will_sent = 1,
    do_sent = 2,
    active = 3,
};

/// Session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    negotiating = 1,
    active = 2,
    subneg = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Number of tracked options per session.
const MAX_OPTIONS: usize = 10;

/// Maximum subnegotiation data length.
const MAX_SUBNEG_LEN: usize = 512;

/// Maximum application data length per send.
const MAX_DATA_LEN: usize = 4096;

/// A Telnet session.
const Session = struct {
    /// Current session lifecycle state.
    state: SessionState,
    /// Negotiation state for each option (indexed by option tag 0-9).
    option_states: [MAX_OPTIONS]NegotiationState,
    /// Current subnegotiation option (valid only in subneg state).
    subneg_option: TelnetOption,
    /// Subnegotiation data buffer.
    subneg_data: [MAX_SUBNEG_LEN]u8,
    subneg_len: u32,
    /// Total bytes of application data sent.
    bytes_sent: u64,
    /// Total commands sent.
    commands_sent: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .option_states = [_]NegotiationState{.inactive} ** MAX_OPTIONS,
    .subneg_option = .echo,
    .subneg_data = [_]u8{0} ** MAX_SUBNEG_LEN,
    .subneg_len = 0,
    .bytes_sent = 0,
    .commands_sent = 0,
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
pub export fn telnet_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new Telnet session. Returns slot index (>=0) or -1 on failure.
pub export fn telnet_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn telnet_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SessionState tag for a session.
pub export fn telnet_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Send a Telnet command. Returns 0 on success, 1 on rejection.
pub export fn telnet_send_command(slot: c_int, cmd: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (cmd > 15) return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .closing) return 1;

    sessions[idx].commands_sent += 1;
    return 0;
}

/// Negotiate an option (WILL/WONT/DO/DONT). Returns 0 on success, 1 on rejection.
/// Transitions Idle -> Negotiating on first negotiation.
pub export fn telnet_negotiate(slot: c_int, cmd: u8, option: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (option >= MAX_OPTIONS) return 1;
    // cmd must be WILL(11), WONT(12), DO(13), or DONT(14)
    if (cmd < 11 or cmd > 14) return 1;

    const state = sessions[idx].state;
    if (state == .closing) return 1;

    // Update negotiation state based on command
    if (cmd == 11) { // WILL
        sessions[idx].option_states[option] = .will_sent;
    } else if (cmd == 13) { // DO
        sessions[idx].option_states[option] = .do_sent;
    } else if (cmd == 12 or cmd == 14) { // WONT or DONT
        sessions[idx].option_states[option] = .inactive;
    }

    // Transition Idle -> Negotiating
    if (sessions[idx].state == .idle) {
        sessions[idx].state = .negotiating;
    }

    sessions[idx].commands_sent += 1;
    return 0;
}

/// Returns negotiation state for an option.
pub export fn telnet_option_state(slot: c_int, option: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (option >= MAX_OPTIONS) return 0;
    return @intFromEnum(sessions[idx].option_states[option]);
}

/// Activate the session (negotiation complete). Returns 0 on success, 1 on rejection.
/// Transitions Negotiating -> Active.
pub export fn telnet_activate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .negotiating) return 1;
    sessions[idx].state = .active;
    return 0;
}

/// Begin subnegotiation. Returns 0 on success, 1 on rejection.
/// Transitions Active -> Subneg.
pub export fn telnet_subneg_begin(slot: c_int, option: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (option >= MAX_OPTIONS) return 1;

    sessions[idx].subneg_option = @enumFromInt(option);
    sessions[idx].subneg_len = 0;
    sessions[idx].state = .subneg;
    return 0;
}

/// Send subnegotiation data. Returns 0 on success, 1 on rejection.
pub export fn telnet_subneg_data(
    slot: c_int,
    data_ptr: [*]const u8,
    data_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .subneg) return 1;
    if (data_len == 0 or data_len > MAX_SUBNEG_LEN) return 1;

    @memcpy(sessions[idx].subneg_data[0..data_len], data_ptr[0..data_len]);
    sessions[idx].subneg_len = data_len;
    return 0;
}

/// End subnegotiation. Returns 0 on success, 1 on rejection.
/// Transitions Subneg -> Active.
pub export fn telnet_subneg_end(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .subneg) return 1;

    // Mark the option as active after successful subnegotiation
    const opt_idx = @intFromEnum(sessions[idx].subneg_option);
    sessions[idx].option_states[opt_idx] = .active;
    sessions[idx].state = .active;
    return 0;
}

/// Send application data. Returns 0 on success, 1 on rejection.
pub export fn telnet_send_data(
    slot: c_int,
    data_ptr: [*]const u8,
    data_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = data_ptr;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (data_len == 0 or data_len > MAX_DATA_LEN) return 1;

    sessions[idx].bytes_sent += data_len;
    return 0;
}

/// Disconnect the session. Returns 0 on success, 1 on rejection.
pub export fn telnet_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .negotiating or state == .active or state == .subneg) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup after disconnect. Returns 0 on success, 1 on rejection.
pub export fn telnet_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].option_states = [_]NegotiationState{.inactive} ** MAX_OPTIONS;
    sessions[idx].subneg_len = 0;
    sessions[idx].bytes_sent = 0;
    sessions[idx].commands_sent = 0;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn telnet_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Negotiating
    if (from == 1 and to == 2) return 1; // Negotiating -> Active
    if (from == 2 and to == 3) return 1; // Active -> Subneg
    if (from == 3 and to == 2) return 1; // Subneg -> Active
    if (from == 1 and to == 4) return 1; // Negotiating -> Closing
    if (from == 2 and to == 4) return 1; // Active -> Closing
    if (from == 3 and to == 4) return 1; // Subneg -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    return 0;
}

/// Returns number of active sessions.
pub export fn telnet_session_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}
