// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
const std = @import("std");
const imap = @import("imap");

test "abi version" { try std.testing.expectEqual(@as(u32, 1), imap.imap_abi_version()); }
test "Command encoding (14)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(imap.Command.login)); try std.testing.expectEqual(@as(u8, 13), @intFromEnum(imap.Command.capability)); }
test "ImapState encoding (4)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(imap.ImapState.not_authenticated)); try std.testing.expectEqual(@as(u8, 3), @intFromEnum(imap.ImapState.logout_state)); }
test "Flag encoding (6)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(imap.Flag.seen)); try std.testing.expectEqual(@as(u8, 5), @intFromEnum(imap.Flag.recent)); }

test "create in NotAuthenticated" {
    const s = imap.imap_create(); try std.testing.expect(s >= 0); defer imap.imap_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), imap.imap_state(s));
}
test "login transitions NotAuthenticated -> Authenticated" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), imap.imap_login(s, "user".ptr, 4, "pass".ptr, 4));
    try std.testing.expectEqual(@as(u8, 1), imap.imap_state(s));
}
test "login rejects when already authenticated" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    _ = imap.imap_login(s, "u".ptr, 1, "p".ptr, 1);
    try std.testing.expectEqual(@as(u8, 1), imap.imap_login(s, "u".ptr, 1, "p".ptr, 1));
}
test "select transitions Authenticated -> Selected" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    _ = imap.imap_login(s, "u".ptr, 1, "p".ptr, 1);
    try std.testing.expectEqual(@as(u8, 0), imap.imap_select(s, "INBOX".ptr, 5));
    try std.testing.expectEqual(@as(u8, 2), imap.imap_state(s));
    try std.testing.expectEqual(@as(u32, 1), imap.imap_mailbox_count(s));
}
test "select rejects from NotAuthenticated" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    try std.testing.expectEqual(@as(u8, 1), imap.imap_select(s, "INBOX".ptr, 5));
}
test "close transitions Selected -> Authenticated" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    _ = imap.imap_login(s, "u".ptr, 1, "p".ptr, 1);
    _ = imap.imap_select(s, "INBOX".ptr, 5);
    try std.testing.expectEqual(@as(u8, 0), imap.imap_close(s));
    try std.testing.expectEqual(@as(u8, 1), imap.imap_state(s));
}
test "logout from any state" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), imap.imap_logout(s));
    try std.testing.expectEqual(@as(u8, 3), imap.imap_state(s));
}
test "logout rejects double logout" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    _ = imap.imap_logout(s);
    try std.testing.expectEqual(@as(u8, 1), imap.imap_logout(s));
}
test "cmd_count tracks commands" {
    const s = imap.imap_create(); defer imap.imap_destroy(s);
    _ = imap.imap_login(s, "u".ptr, 1, "p".ptr, 1);
    _ = imap.imap_select(s, "INBOX".ptr, 5);
    _ = imap.imap_close(s);
    try std.testing.expectEqual(@as(u32, 3), imap.imap_cmd_count(s));
}
test "transition table" {
    try std.testing.expectEqual(@as(u8, 1), imap.imap_can_transition(0, 1)); // NotAuth -> Auth
    try std.testing.expectEqual(@as(u8, 1), imap.imap_can_transition(1, 2)); // Auth -> Selected
    try std.testing.expectEqual(@as(u8, 1), imap.imap_can_transition(2, 1)); // Selected -> Auth
    try std.testing.expectEqual(@as(u8, 1), imap.imap_can_transition(0, 3)); // NotAuth -> Logout
    try std.testing.expectEqual(@as(u8, 1), imap.imap_can_transition(1, 3)); // Auth -> Logout
    try std.testing.expectEqual(@as(u8, 1), imap.imap_can_transition(2, 3)); // Selected -> Logout
    try std.testing.expectEqual(@as(u8, 0), imap.imap_can_transition(0, 2)); // NotAuth -/-> Selected
    try std.testing.expectEqual(@as(u8, 0), imap.imap_can_transition(3, 0)); // Logout -/-> NotAuth
}
test "invalid slot safety" {
    try std.testing.expectEqual(@as(u8, 0), imap.imap_state(-1));
    try std.testing.expectEqual(@as(u32, 0), imap.imap_cmd_count(-1));
    try std.testing.expectEqual(@as(u32, 0), imap.imap_mailbox_count(-1));
}
