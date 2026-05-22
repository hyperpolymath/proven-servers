// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// irc.zig -- Zig FFI implementation of proven-irc.
//
// Implements the IRC server state machine with:
//   - 64-slot mutex-protected client session pool
//   - Command processing (RFC 2812)
//   - Channel join/part/mode tracking (max 16 channels per client)
//   - Client lifecycle: Disconnected -> Connecting -> Registered -> InChannel -> Quitting
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching IrcABI.Types exactly.

const std = @import("std");

// =========================================================================
// Enums (matching IrcABI.Types tag assignments)
// =========================================================================

/// IRC protocol commands (ABI tags 0-16).
pub const Command = enum(u8) {
    nick = 0,
    user = 1,
    join = 2,
    part = 3,
    privmsg = 4,
    notice = 5,
    quit = 6,
    ping = 7,
    pong = 8,
    mode = 9,
    kick = 10,
    topic = 11,
    invite = 12,
    names = 13,
    list = 14,
    who = 15,
    whois = 16,
};

/// Numeric reply codes (ABI tags 0-10).
pub const NumericReply = enum(u8) {
    welcome = 0,
    your_host = 1,
    created = 2,
    my_info = 3,
    bounce = 4,
    nick_in_use = 5,
    no_such_nick = 6,
    no_such_channel = 7,
    channel_is_full = 8,
    invite_only_chan = 9,
    banned_from_chan = 10,
};

/// Channel modes (ABI tags 0-9).
pub const ChannelMode = enum(u8) {
    op = 0,
    voice = 1,
    ban = 2,
    limit = 3,
    invite_only = 4,
    moderated = 5,
    no_external_msgs = 6,
    topic_lock = 7,
    secret = 8,
    private = 9,
};

/// Client connection lifecycle state (ABI tags 0-4).
pub const IRCState = enum(u8) {
    disconnected = 0,
    connecting = 1,
    registered = 2,
    in_channel = 3,
    quitting = 4,
};

/// IRC error categories (ABI tags 0-5).
pub const IRCError = enum(u8) {
    none = 0,
    nick_in_use = 1,
    channel_full = 2,
    invite_only = 3,
    banned = 4,
    not_registered = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent client sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum channels per client.
const MAX_CHANNELS: usize = 16;

/// A channel membership record.
const ChannelRecord = struct {
    /// Whether this channel slot is active.
    active: bool,
    /// Channel mode flags (bitmask of ChannelMode tags).
    modes: u16,
};

/// Default (empty) channel record.
const empty_channel: ChannelRecord = .{
    .active = false,
    .modes = 0,
};

/// An IRC client session.
const Session = struct {
    /// Current client lifecycle state.
    state: IRCState,
    /// Whether NICK has been received.
    has_nick: bool,
    /// Whether USER has been received.
    has_user: bool,
    /// Channels the client has joined.
    channels: [MAX_CHANNELS]ChannelRecord,
    /// Number of active channel memberships.
    channel_count: u32,
    /// Last command received (for state tracking).
    last_command: Command,
    /// Last error encountered.
    last_error: IRCError,
    /// Total messages sent by this client (monotonic counter).
    message_count: u64,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .disconnected,
    .has_nick = false,
    .has_user = false,
    .channels = [_]ChannelRecord{empty_channel} ** MAX_CHANNELS,
    .channel_count = 0,
    .last_command = .nick,
    .last_error = .none,
    .message_count = 0,
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

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn irc_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new IRC client session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Connecting state (TCP just connected).
pub export fn irc_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.state = .connecting;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a client session, releasing its slot.
pub export fn irc_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

// -- State queries ------------------------------------------------------------

/// Returns the current IRCState tag for a session.
pub export fn irc_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // disconnected fallback
    return @intFromEnum(sessions[idx].state);
}

/// Returns the last error tag for a session.
pub export fn irc_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].last_error);
}

/// Returns whether NICK has been received.
pub export fn irc_has_nick(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].has_nick) 1 else 0;
}

/// Returns whether USER has been received.
pub export fn irc_has_user(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].has_user) 1 else 0;
}

/// Returns the number of channels the client has joined.
pub export fn irc_channel_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].channel_count;
}

/// Returns total message count for this session.
pub export fn irc_message_count(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].message_count;
}

// -- Registration commands ----------------------------------------------------

/// Process NICK command. Returns 0 on success, error tag on failure.
/// Must be in Connecting state. Sets has_nick flag.
/// If both NICK and USER received, transitions to Registered.
pub export fn irc_nick(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .connecting) return @intFromEnum(IRCError.not_registered);

    sessions[idx].has_nick = true;
    sessions[idx].last_command = .nick;
    sessions[idx].message_count += 1;

    if (sessions[idx].has_nick and sessions[idx].has_user) {
        sessions[idx].state = .registered;
    }
    return 0;
}

/// Process USER command. Returns 0 on success, error tag on failure.
/// Must be in Connecting state. Sets has_user flag.
/// If both NICK and USER received, transitions to Registered.
pub export fn irc_user(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .connecting) return @intFromEnum(IRCError.not_registered);

    sessions[idx].has_user = true;
    sessions[idx].last_command = .user;
    sessions[idx].message_count += 1;

    if (sessions[idx].has_nick and sessions[idx].has_user) {
        sessions[idx].state = .registered;
    }
    return 0;
}

// -- Channel commands ---------------------------------------------------------

/// Process JOIN command. Returns 0 on success, error tag on failure.
/// Must be Registered or InChannel. Transitions to InChannel on first join.
pub export fn irc_join(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .registered and sessions[idx].state != .in_channel) {
        return @intFromEnum(IRCError.not_registered);
    }

    // Find a free channel slot
    for (&sessions[idx].channels) |*ch| {
        if (!ch.active) {
            ch.active = true;
            ch.modes = 0;
            sessions[idx].channel_count += 1;
            sessions[idx].state = .in_channel;
            sessions[idx].last_command = .join;
            sessions[idx].message_count += 1;
            return 0;
        }
    }
    return @intFromEnum(IRCError.channel_full);
}

/// Process PART command. Returns 0 on success, error tag on failure.
/// Must be InChannel. If last channel left, transitions to Registered.
pub export fn irc_part(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .in_channel) {
        return @intFromEnum(IRCError.not_registered);
    }

    // Remove last active channel
    var i: usize = MAX_CHANNELS;
    while (i > 0) {
        i -= 1;
        if (sessions[idx].channels[i].active) {
            sessions[idx].channels[i] = empty_channel;
            sessions[idx].channel_count -= 1;
            break;
        }
    }

    sessions[idx].last_command = .part;
    sessions[idx].message_count += 1;

    if (sessions[idx].channel_count == 0) {
        sessions[idx].state = .registered;
    }
    return 0;
}

// -- Message commands ---------------------------------------------------------

/// Process PRIVMSG command. Returns 0 on success, error tag on failure.
/// Must be Registered or InChannel.
pub export fn irc_privmsg(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .registered and sessions[idx].state != .in_channel) {
        return @intFromEnum(IRCError.not_registered);
    }

    sessions[idx].last_command = .privmsg;
    sessions[idx].message_count += 1;
    return 0;
}

/// Process NOTICE command. Returns 0 on success, error tag on failure.
pub export fn irc_notice(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .registered and sessions[idx].state != .in_channel) {
        return @intFromEnum(IRCError.not_registered);
    }

    sessions[idx].last_command = .notice;
    sessions[idx].message_count += 1;
    return 0;
}

// -- Ping/Pong ----------------------------------------------------------------

/// Process PING (server sends, expects PONG). Returns 0 on success.
pub export fn irc_ping(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    sessions[idx].last_command = .ping;
    sessions[idx].message_count += 1;
    return 0;
}

/// Process PONG response. Returns 0 on success.
pub export fn irc_pong(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    sessions[idx].last_command = .pong;
    sessions[idx].message_count += 1;
    return 0;
}

// -- Mode command -------------------------------------------------------------

/// Set a channel mode. Returns 0 on success, error tag on failure.
/// mode_tag is a ChannelMode ABI tag (0-9).
pub export fn irc_set_mode(slot: c_int, channel_idx: u8, mode_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state != .in_channel) return @intFromEnum(IRCError.not_registered);
    if (mode_tag > 9) return @intFromEnum(IRCError.not_registered);
    if (channel_idx >= MAX_CHANNELS) return @intFromEnum(IRCError.not_registered);
    if (!sessions[idx].channels[channel_idx].active) return @intFromEnum(IRCError.not_registered);

    sessions[idx].channels[channel_idx].modes |= @as(u16, 1) << @intCast(mode_tag);
    sessions[idx].last_command = .mode;
    sessions[idx].message_count += 1;
    return 0;
}

/// Get channel modes bitmask. Returns modes or 0 on error.
pub export fn irc_get_modes(slot: c_int, channel_idx: u8) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (channel_idx >= MAX_CHANNELS) return 0;
    if (!sessions[idx].channels[channel_idx].active) return 0;
    return sessions[idx].channels[channel_idx].modes;
}

// -- QUIT command -------------------------------------------------------------

/// Process QUIT command. Transitions to Quitting.
/// Returns 0 on success.
pub export fn irc_quit(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(IRCError.not_registered);
    if (sessions[idx].state == .disconnected or sessions[idx].state == .quitting) {
        return @intFromEnum(IRCError.not_registered);
    }

    sessions[idx].state = .quitting;
    sessions[idx].last_command = .quit;
    sessions[idx].message_count += 1;
    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a state transition is valid.
pub export fn irc_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Disconnected -> Connecting (implicit on TCP connect)
    if (from == 0 and to == 1) return 1;
    // Connecting -> Registered (after NICK + USER)
    if (from == 1 and to == 2) return 1;
    // Registered -> InChannel (after JOIN)
    if (from == 2 and to == 3) return 1;
    // InChannel -> Registered (after PART last channel)
    if (from == 3 and to == 2) return 1;
    // Registered -> Quitting (QUIT)
    if (from == 2 and to == 4) return 1;
    // InChannel -> Quitting (QUIT)
    if (from == 3 and to == 4) return 1;
    // Connecting -> Quitting (QUIT before registration)
    if (from == 1 and to == 4) return 1;
    return 0;
}
