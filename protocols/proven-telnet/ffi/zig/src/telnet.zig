// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
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

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("telnet_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

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

// ── ABI conformance guard ────────────────────────────────────────────────
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(Command.se) != gen.CMD_SE) @compileError("ABI drift: Command.se");
    if (@intFromEnum(Command.nop) != gen.CMD_NOP) @compileError("ABI drift: Command.nop");
    if (@intFromEnum(Command.data_mark) != gen.CMD_DATA_MARK) @compileError("ABI drift: Command.data_mark");
    if (@intFromEnum(Command.brk) != gen.CMD_BRK) @compileError("ABI drift: Command.brk");
    if (@intFromEnum(Command.interrupt_process) != gen.CMD_INTERRUPT_PROCESS) @compileError("ABI drift: Command.interrupt_process");
    if (@intFromEnum(Command.abort_output) != gen.CMD_ABORT_OUTPUT) @compileError("ABI drift: Command.abort_output");
    if (@intFromEnum(Command.are_you_there) != gen.CMD_ARE_YOU_THERE) @compileError("ABI drift: Command.are_you_there");
    if (@intFromEnum(Command.erase_char) != gen.CMD_ERASE_CHAR) @compileError("ABI drift: Command.erase_char");
    if (@intFromEnum(Command.erase_line) != gen.CMD_ERASE_LINE) @compileError("ABI drift: Command.erase_line");
    if (@intFromEnum(Command.go_ahead) != gen.CMD_GO_AHEAD) @compileError("ABI drift: Command.go_ahead");
    if (@intFromEnum(Command.sb) != gen.CMD_SB) @compileError("ABI drift: Command.sb");
    if (@intFromEnum(Command.will) != gen.CMD_WILL) @compileError("ABI drift: Command.will");
    if (@intFromEnum(Command.wont) != gen.CMD_WONT) @compileError("ABI drift: Command.wont");
    if (@intFromEnum(Command.do_) != gen.CMD_DO_) @compileError("ABI drift: Command.do_");
    if (@intFromEnum(Command.dont) != gen.CMD_DONT) @compileError("ABI drift: Command.dont");
    if (@intFromEnum(Command.iac) != gen.CMD_IAC) @compileError("ABI drift: Command.iac");

    if (@intFromEnum(TelnetOption.echo) != gen.OPT_ECHO) @compileError("ABI drift: TelnetOption.echo");
    if (@intFromEnum(TelnetOption.suppress_go_ahead) != gen.OPT_SUPPRESS_GO_AHEAD) @compileError("ABI drift: TelnetOption.suppress_go_ahead");
    if (@intFromEnum(TelnetOption.status) != gen.OPT_STATUS) @compileError("ABI drift: TelnetOption.status");
    if (@intFromEnum(TelnetOption.timing_mark) != gen.OPT_TIMING_MARK) @compileError("ABI drift: TelnetOption.timing_mark");
    if (@intFromEnum(TelnetOption.terminal_type) != gen.OPT_TERMINAL_TYPE) @compileError("ABI drift: TelnetOption.terminal_type");
    if (@intFromEnum(TelnetOption.window_size) != gen.OPT_WINDOW_SIZE) @compileError("ABI drift: TelnetOption.window_size");
    if (@intFromEnum(TelnetOption.terminal_speed) != gen.OPT_TERMINAL_SPEED) @compileError("ABI drift: TelnetOption.terminal_speed");
    if (@intFromEnum(TelnetOption.remote_flow_control) != gen.OPT_REMOTE_FLOW_CONTROL) @compileError("ABI drift: TelnetOption.remote_flow_control");
    if (@intFromEnum(TelnetOption.linemode) != gen.OPT_LINEMODE) @compileError("ABI drift: TelnetOption.linemode");
    if (@intFromEnum(TelnetOption.environment) != gen.OPT_ENVIRONMENT) @compileError("ABI drift: TelnetOption.environment");

    if (@intFromEnum(NegotiationState.inactive) != gen.NEG_INACTIVE) @compileError("ABI drift: NegotiationState.inactive");
    if (@intFromEnum(NegotiationState.will_sent) != gen.NEG_WILL_SENT) @compileError("ABI drift: NegotiationState.will_sent");
    if (@intFromEnum(NegotiationState.do_sent) != gen.NEG_DO_SENT) @compileError("ABI drift: NegotiationState.do_sent");
    if (@intFromEnum(NegotiationState.active) != gen.NEG_ACTIVE) @compileError("ABI drift: NegotiationState.active");

    if (@intFromEnum(SessionState.idle) != gen.SESSION_IDLE) @compileError("ABI drift: SessionState.idle");
    if (@intFromEnum(SessionState.negotiating) != gen.SESSION_NEGOTIATING) @compileError("ABI drift: SessionState.negotiating");
    if (@intFromEnum(SessionState.active) != gen.SESSION_ACTIVE) @compileError("ABI drift: SessionState.active");
    if (@intFromEnum(SessionState.subneg) != gen.SESSION_SUBNEG) @compileError("ABI drift: SessionState.subneg");
    if (@intFromEnum(SessionState.closing) != gen.SESSION_CLOSING) @compileError("ABI drift: SessionState.closing");
}

/// Returns the ABI version number.
pub export fn telnet_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
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

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
