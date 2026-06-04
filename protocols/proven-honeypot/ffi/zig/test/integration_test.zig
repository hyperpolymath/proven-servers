// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
const std = @import("std");
const hp = @import("honeypot");

test "abi version" { try std.testing.expectEqual(@as(u32, 1), hp.hp_abi_version()); }
test "ServiceEmulation encoding (7)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hp.ServiceEmulation.ssh)); try std.testing.expectEqual(@as(u8, 6), @intFromEnum(hp.ServiceEmulation.rdp)); }
test "InteractionLevel encoding (3)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hp.InteractionLevel.low)); try std.testing.expectEqual(@as(u8, 2), @intFromEnum(hp.InteractionLevel.high)); }
test "AlertSeverity encoding (5)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hp.AlertSeverity.info)); try std.testing.expectEqual(@as(u8, 4), @intFromEnum(hp.AlertSeverity.critical)); }
test "AttackerAction encoding (6)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hp.AttackerAction.scan)); try std.testing.expectEqual(@as(u8, 5), @intFromEnum(hp.AttackerAction.exfiltration)); }
test "ServerState encoding (4)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hp.ServerState.idle)); try std.testing.expectEqual(@as(u8, 3), @intFromEnum(hp.ServerState.shutdown)); }

test "create in Deployed" { const s = hp.hp_create("h".ptr, 1, 0, 1); try std.testing.expect(s >= 0); defer hp.hp_destroy(s); try std.testing.expectEqual(@as(u8, 1), hp.hp_state(s)); }
test "create rejects bad service" { try std.testing.expectEqual(@as(c_int, -1), hp.hp_create("h".ptr, 1, 99, 0)); }
test "record_action transitions to Engaged" {
    const s = hp.hp_create("h".ptr, 1, 0, 1); defer hp.hp_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), hp.hp_record_action(s, 0, 1));
    try std.testing.expectEqual(@as(u8, 2), hp.hp_state(s));
    try std.testing.expectEqual(@as(u32, 1), hp.hp_alert_count(s));
    try std.testing.expectEqual(@as(u32, 1), hp.hp_action_count(s));
}
test "reset_engagement -> Deployed" {
    const s = hp.hp_create("h".ptr, 1, 0, 1); defer hp.hp_destroy(s);
    _ = hp.hp_record_action(s, 0, 0);
    try std.testing.expectEqual(@as(u8, 0), hp.hp_reset_engagement(s));
    try std.testing.expectEqual(@as(u8, 1), hp.hp_state(s));
}
test "shutdown and cleanup" {
    const s = hp.hp_create("h".ptr, 1, 0, 0); defer hp.hp_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), hp.hp_shutdown(s));
    try std.testing.expectEqual(@as(u8, 0), hp.hp_cleanup(s));
    try std.testing.expectEqual(@as(u8, 0), hp.hp_state(s));
}
test "transition table" {
    try std.testing.expectEqual(@as(u8, 1), hp.hp_can_transition(0, 1)); try std.testing.expectEqual(@as(u8, 1), hp.hp_can_transition(1, 2));
    try std.testing.expectEqual(@as(u8, 1), hp.hp_can_transition(2, 1)); try std.testing.expectEqual(@as(u8, 1), hp.hp_can_transition(1, 3));
    try std.testing.expectEqual(@as(u8, 1), hp.hp_can_transition(3, 0)); try std.testing.expectEqual(@as(u8, 0), hp.hp_can_transition(0, 2));
}
test "invalid slot safety" { try std.testing.expectEqual(@as(u8, 0), hp.hp_state(-1)); try std.testing.expectEqual(@as(u8, 1), hp.hp_shutdown(-1)); }
