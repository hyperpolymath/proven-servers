// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-irc FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Registration (NICK + USER -> Registered)
//   - Channel operations (JOIN/PART)
//   - Message commands (PRIVMSG/NOTICE)
//   - Ping/Pong
//   - Mode setting
//   - QUIT command
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const irc = @import("irc");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), irc.irc_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Command encoding matches Types.idr (17 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(irc.Command.nick));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(irc.Command.user));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(irc.Command.join));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(irc.Command.part));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(irc.Command.privmsg));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(irc.Command.notice));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(irc.Command.quit));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(irc.Command.ping));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(irc.Command.pong));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(irc.Command.mode));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(irc.Command.kick));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(irc.Command.topic));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(irc.Command.invite));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(irc.Command.names));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(irc.Command.list));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(irc.Command.who));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(irc.Command.whois));
}

test "NumericReply encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(irc.NumericReply.welcome));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(irc.NumericReply.your_host));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(irc.NumericReply.nick_in_use));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(irc.NumericReply.banned_from_chan));
}

test "ChannelMode encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(irc.ChannelMode.op));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(irc.ChannelMode.voice));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(irc.ChannelMode.invite_only));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(irc.ChannelMode.private));
}

test "IRCState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(irc.IRCState.disconnected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(irc.IRCState.connecting));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(irc.IRCState.registered));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(irc.IRCState.in_channel));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(irc.IRCState.quitting));
}

test "IRCError encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(irc.IRCError.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(irc.IRCError.nick_in_use));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(irc.IRCError.not_registered));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connecting state" {
    const slot = irc.irc_create();
    try std.testing.expect(slot >= 0);
    defer irc.irc_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), irc.irc_state(slot)); // Connecting
}

test "destroy is safe with invalid slot" {
    irc.irc_destroy(-1);
    irc.irc_destroy(999);
}

// =========================================================================
// Registration
// =========================================================================

test "NICK alone does not register" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), irc.irc_nick(slot));
    try std.testing.expectEqual(@as(u8, 1), irc.irc_has_nick(slot));
    try std.testing.expectEqual(@as(u8, 0), irc.irc_has_user(slot));
    try std.testing.expectEqual(@as(u8, 1), irc.irc_state(slot)); // Still Connecting
}

test "USER alone does not register" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), irc.irc_user(slot));
    try std.testing.expectEqual(@as(u8, 0), irc.irc_has_nick(slot));
    try std.testing.expectEqual(@as(u8, 1), irc.irc_has_user(slot));
    try std.testing.expectEqual(@as(u8, 1), irc.irc_state(slot)); // Still Connecting
}

test "NICK + USER transitions to Registered" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expectEqual(@as(u8, 2), irc.irc_state(slot)); // Registered
}

test "USER + NICK also transitions to Registered" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_user(slot);
    _ = irc.irc_nick(slot);
    try std.testing.expectEqual(@as(u8, 2), irc.irc_state(slot)); // Registered
}

// =========================================================================
// Channel operations
// =========================================================================

test "JOIN transitions Registered -> InChannel" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_join(slot));
    try std.testing.expectEqual(@as(u8, 3), irc.irc_state(slot)); // InChannel
    try std.testing.expectEqual(@as(u32, 1), irc.irc_channel_count(slot));
}

test "multiple JOINs increment channel count" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    _ = irc.irc_join(slot);
    _ = irc.irc_join(slot);
    _ = irc.irc_join(slot);
    try std.testing.expectEqual(@as(u32, 3), irc.irc_channel_count(slot));
}

test "PART last channel transitions InChannel -> Registered" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    _ = irc.irc_join(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_part(slot));
    try std.testing.expectEqual(@as(u8, 2), irc.irc_state(slot)); // Registered
    try std.testing.expectEqual(@as(u32, 0), irc.irc_channel_count(slot));
}

test "PART with multiple channels stays InChannel" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    _ = irc.irc_join(slot);
    _ = irc.irc_join(slot);
    _ = irc.irc_part(slot);
    try std.testing.expectEqual(@as(u8, 3), irc.irc_state(slot)); // Still InChannel
    try std.testing.expectEqual(@as(u32, 1), irc.irc_channel_count(slot));
}

// =========================================================================
// Message commands
// =========================================================================

test "PRIVMSG succeeds when registered" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_privmsg(slot));
}

test "NOTICE succeeds when registered" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_notice(slot));
}

test "PRIVMSG fails when connecting" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expect(irc.irc_privmsg(slot) != 0);
}

// =========================================================================
// Ping / Pong
// =========================================================================

test "PING succeeds on active session" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), irc.irc_ping(slot));
}

test "PONG succeeds on active session" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), irc.irc_pong(slot));
}

// =========================================================================
// Mode
// =========================================================================

test "set_mode sets channel mode bit" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    _ = irc.irc_join(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_set_mode(slot, 0, 4)); // InviteOnly
    const modes = irc.irc_get_modes(slot, 0);
    try std.testing.expect(modes & (1 << 4) != 0);
}

// =========================================================================
// QUIT
// =========================================================================

test "QUIT transitions to Quitting from Registered" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), irc.irc_state(slot)); // Quitting
}

test "QUIT transitions to Quitting from InChannel" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    _ = irc.irc_join(slot);
    try std.testing.expectEqual(@as(u8, 0), irc.irc_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), irc.irc_state(slot)); // Quitting
}

test "QUIT transitions to Quitting from Connecting" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), irc.irc_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), irc.irc_state(slot)); // Quitting
}

// =========================================================================
// Message counting
// =========================================================================

test "message_count increments on commands" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    _ = irc.irc_privmsg(slot);
    _ = irc.irc_ping(slot);
    try std.testing.expectEqual(@as(u64, 4), irc.irc_message_count(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "irc_can_transition matches Types.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(0, 1)); // Disconnected -> Connecting
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(1, 2)); // Connecting -> Registered
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(2, 3)); // Registered -> InChannel
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(3, 2)); // InChannel -> Registered
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(2, 4)); // Registered -> Quitting
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(3, 4)); // InChannel -> Quitting
    try std.testing.expectEqual(@as(u8, 1), irc.irc_can_transition(1, 4)); // Connecting -> Quitting

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), irc.irc_can_transition(0, 2)); // Disconnected -/-> Registered
    try std.testing.expectEqual(@as(u8, 0), irc.irc_can_transition(4, 0)); // Quitting -/-> Disconnected
    try std.testing.expectEqual(@as(u8, 0), irc.irc_can_transition(1, 3)); // Connecting -/-> InChannel
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), irc.irc_state(-1));
    try std.testing.expectEqual(@as(u8, 0), irc.irc_last_error(-1));
    try std.testing.expectEqual(@as(u8, 0), irc.irc_has_nick(-1));
    try std.testing.expectEqual(@as(u8, 0), irc.irc_has_user(-1));
    try std.testing.expectEqual(@as(u32, 0), irc.irc_channel_count(-1));
    try std.testing.expectEqual(@as(u64, 0), irc.irc_message_count(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot JOIN when connecting" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    try std.testing.expect(irc.irc_join(slot) != 0);
}

test "cannot PART when not in channel" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expect(irc.irc_part(slot) != 0);
}

test "cannot set mode when not in channel" {
    const slot = irc.irc_create();
    defer irc.irc_destroy(slot);

    _ = irc.irc_nick(slot);
    _ = irc.irc_user(slot);
    try std.testing.expect(irc.irc_set_mode(slot, 0, 0) != 0);
}
