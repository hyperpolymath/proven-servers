// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
const std = @import("std");
const hrd = @import("hardened");

test "abi version" { try std.testing.expectEqual(@as(u32, 1), hrd.hrd_abi_version()); }
test "HardeningLevel encoding (4)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hrd.HardeningLevel.minimal)); try std.testing.expectEqual(@as(u8, 3), @intFromEnum(hrd.HardeningLevel.maximum)); }
test "SecurityControl encoding (7)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hrd.SecurityControl.aslr)); try std.testing.expectEqual(@as(u8, 6), @intFromEnum(hrd.SecurityControl.audit_log)); }
test "ComplianceStandard encoding (5)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hrd.ComplianceStandard.cis)); try std.testing.expectEqual(@as(u8, 4), @intFromEnum(hrd.ComplianceStandard.fips140)); }
test "AuditEvent encoding (6)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hrd.AuditEvent.process_start)); try std.testing.expectEqual(@as(u8, 5), @intFromEnum(hrd.AuditEvent.auth_attempt)); }
test "HealthStatus encoding (4)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hrd.HealthStatus.healthy)); try std.testing.expectEqual(@as(u8, 3), @intFromEnum(hrd.HealthStatus.unresponsive)); }
test "ServerState encoding (5)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(hrd.ServerState.idle)); try std.testing.expectEqual(@as(u8, 4), @intFromEnum(hrd.ServerState.shutdown)); }

test "create in Hardening" { const s = hrd.hrd_create("h".ptr, 1, 2); try std.testing.expect(s >= 0); defer hrd.hrd_destroy(s); try std.testing.expectEqual(@as(u8, 1), hrd.hrd_state(s)); }
test "create rejects bad level" { try std.testing.expectEqual(@as(c_int, -1), hrd.hrd_create("h".ptr, 1, 99)); }
test "enable control" { const s = hrd.hrd_create("h".ptr, 1, 0); defer hrd.hrd_destroy(s); try std.testing.expectEqual(@as(u8, 0), hrd.hrd_enable_control(s, 0)); try std.testing.expectEqual(@as(u32, 1), hrd.hrd_control_count(s)); }
test "enable control rejects duplicate" { const s = hrd.hrd_create("h".ptr, 1, 0); defer hrd.hrd_destroy(s); _ = hrd.hrd_enable_control(s, 0); try std.testing.expectEqual(@as(u8, 1), hrd.hrd_enable_control(s, 0)); }
test "activate transitions Hardening -> Active" { const s = hrd.hrd_create("h".ptr, 1, 0); defer hrd.hrd_destroy(s); try std.testing.expectEqual(@as(u8, 0), hrd.hrd_activate(s)); try std.testing.expectEqual(@as(u8, 2), hrd.hrd_state(s)); }
test "audit lifecycle" {
    const s = hrd.hrd_create("h".ptr, 1, 0); defer hrd.hrd_destroy(s);
    _ = hrd.hrd_activate(s);
    try std.testing.expectEqual(@as(u8, 0), hrd.hrd_begin_audit(s));
    try std.testing.expectEqual(@as(u8, 3), hrd.hrd_state(s));
    try std.testing.expectEqual(@as(u8, 0), hrd.hrd_log_event(s, 0));
    try std.testing.expectEqual(@as(u8, 0), hrd.hrd_finish_audit(s));
    try std.testing.expectEqual(@as(u8, 2), hrd.hrd_state(s));
}
test "health returns healthy" { const s = hrd.hrd_create("h".ptr, 1, 0); defer hrd.hrd_destroy(s); try std.testing.expectEqual(@as(u8, 0), hrd.hrd_health(s)); }
test "shutdown and cleanup" {
    const s = hrd.hrd_create("h".ptr, 1, 0); defer hrd.hrd_destroy(s);
    _ = hrd.hrd_activate(s);
    try std.testing.expectEqual(@as(u8, 0), hrd.hrd_shutdown(s));
    try std.testing.expectEqual(@as(u8, 0), hrd.hrd_cleanup(s));
    try std.testing.expectEqual(@as(u8, 0), hrd.hrd_state(s));
}
test "transition table" {
    try std.testing.expectEqual(@as(u8, 1), hrd.hrd_can_transition(0, 1)); try std.testing.expectEqual(@as(u8, 1), hrd.hrd_can_transition(1, 2));
    try std.testing.expectEqual(@as(u8, 1), hrd.hrd_can_transition(2, 3)); try std.testing.expectEqual(@as(u8, 1), hrd.hrd_can_transition(3, 2));
    try std.testing.expectEqual(@as(u8, 1), hrd.hrd_can_transition(4, 0)); try std.testing.expectEqual(@as(u8, 0), hrd.hrd_can_transition(0, 2));
}
test "invalid slot safety" { try std.testing.expectEqual(@as(u8, 0), hrd.hrd_state(-1)); try std.testing.expectEqual(@as(u8, 1), hrd.hrd_shutdown(-1)); }
