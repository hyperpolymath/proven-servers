// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-git FFI.

const std = @import("std");
const git = @import("git");

test "abi version" { try std.testing.expectEqual(@as(u32, 1), git.git_abi_version()); }

test "Command encoding (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(git.Command.upload_pack));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(git.Command.receive_pack));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(git.Command.upload_archive));
}
test "PacketType encoding (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(git.PacketType.flush));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(git.PacketType.sideband_error));
}
test "RefType encoding (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(git.RefType.branch));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(git.RefType.note));
}
test "Capability encoding (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(git.Capability.multi_ack));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(git.Capability.object_format));
}
test "HookResult encoding (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(git.HookResult.accept));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(git.HookResult.reject));
}
test "ServerState encoding (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(git.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(git.ServerState.shutdown));
}

test "create returns slot in Discovery state" {
    const path = "/repo.git";
    const slot = git.git_create(path.ptr, path.len, 0);
    try std.testing.expect(slot >= 0);
    defer git.git_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), git.git_state(slot));
}
test "create rejects empty path" { try std.testing.expectEqual(@as(c_int, -1), git.git_create("x".ptr, 0, 0)); }
test "create rejects invalid command" { try std.testing.expectEqual(@as(c_int, -1), git.git_create("r".ptr, 1, 99)); }
test "destroy safe on invalid slot" { git.git_destroy(-1); git.git_destroy(999); }

test "advertise_ref adds ref" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    const name = "refs/heads/main";
    try std.testing.expectEqual(@as(u8, 0), git.git_advertise_ref(slot, 0, name.ptr, name.len));
    try std.testing.expectEqual(@as(u32, 1), git.git_ref_count(slot));
}
test "advertise_ref rejects invalid ref type" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), git.git_advertise_ref(slot, 99, "x".ptr, 1));
}

test "negotiation lifecycle: Discovery -> Negotiating -> Transfer -> Idle" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), git.git_begin_negotiation(slot));
    try std.testing.expectEqual(@as(u8, 2), git.git_state(slot));
    try std.testing.expectEqual(@as(u8, 0), git.git_finish_negotiation(slot));
    try std.testing.expectEqual(@as(u8, 3), git.git_state(slot));
    try std.testing.expectEqual(@as(u8, 0), git.git_finish_transfer(slot));
    try std.testing.expectEqual(@as(u8, 0), git.git_state(slot));
}
test "begin_negotiation rejects from non-Discovery" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    _ = git.git_begin_negotiation(slot);
    try std.testing.expectEqual(@as(u8, 1), git.git_begin_negotiation(slot));
}

test "run_hook succeeds from Transfer" {
    const slot = git.git_create("/r".ptr, 2, 1); defer git.git_destroy(slot);
    _ = git.git_begin_negotiation(slot);
    _ = git.git_finish_negotiation(slot);
    try std.testing.expectEqual(@as(u8, 0), git.git_run_hook(slot, 0));
}

test "shutdown from Discovery" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), git.git_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), git.git_state(slot));
}
test "cleanup -> Idle" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    _ = git.git_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), git.git_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), git.git_state(slot));
}
test "cleanup clears refs" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    _ = git.git_advertise_ref(slot, 0, "m".ptr, 1);
    _ = git.git_shutdown(slot); _ = git.git_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), git.git_ref_count(slot));
}
test "cleanup rejected from non-Shutdown" {
    const slot = git.git_create("/r".ptr, 2, 0); defer git.git_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), git.git_cleanup(slot));
}

test "transition table" {
    try std.testing.expectEqual(@as(u8, 1), git.git_can_transition(0, 1));
    try std.testing.expectEqual(@as(u8, 1), git.git_can_transition(1, 2));
    try std.testing.expectEqual(@as(u8, 1), git.git_can_transition(2, 3));
    try std.testing.expectEqual(@as(u8, 1), git.git_can_transition(3, 0));
    try std.testing.expectEqual(@as(u8, 1), git.git_can_transition(1, 4));
    try std.testing.expectEqual(@as(u8, 1), git.git_can_transition(4, 0));
    try std.testing.expectEqual(@as(u8, 0), git.git_can_transition(0, 3));
    try std.testing.expectEqual(@as(u8, 0), git.git_can_transition(4, 1));
}

test "invalid slot safety" {
    try std.testing.expectEqual(@as(u8, 0), git.git_state(-1));
    try std.testing.expectEqual(@as(u32, 0), git.git_ref_count(-1));
    try std.testing.expectEqual(@as(u8, 1), git.git_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), git.git_cleanup(-1));
}
