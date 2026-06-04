// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-fileserver FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - File operation execution
//   - Lock management (acquire/release)
//   - Operations while locked
//   - Disconnect / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const fs = @import("fileserver");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), fs.fs_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Operation encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fs.Operation.read));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fs.Operation.write));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fs.Operation.create));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fs.Operation.delete));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fs.Operation.rename));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fs.Operation.list));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fs.Operation.stat));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fs.Operation.lock));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(fs.Operation.unlock));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(fs.Operation.watch));
}

test "FileType encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fs.FileType.regular));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fs.FileType.directory));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fs.FileType.symlink));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fs.FileType.block_device));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fs.FileType.char_device));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fs.FileType.fifo));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fs.FileType.socket));
}

test "Permission encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fs.Permission.owner_read));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fs.Permission.owner_write));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fs.Permission.owner_execute));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fs.Permission.group_read));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fs.Permission.group_write));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fs.Permission.group_execute));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fs.Permission.other_read));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fs.Permission.other_write));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(fs.Permission.other_execute));
}

test "LockType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fs.LockType.shared));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fs.LockType.exclusive));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fs.LockType.advisory));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fs.LockType.mandatory));
}

test "ErrorCode encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fs.ErrorCode.not_found));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fs.ErrorCode.permission_denied));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fs.ErrorCode.already_exists));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fs.ErrorCode.not_empty));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fs.ErrorCode.is_directory));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fs.ErrorCode.not_directory));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fs.ErrorCode.no_space));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fs.ErrorCode.read_only));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(fs.ErrorCode.locked));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(fs.ErrorCode.io_error));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fs.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fs.SessionState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fs.SessionState.operating));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fs.SessionState.locked));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fs.SessionState.disconnecting));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const root = "/data";
    const slot = fs.fs_create(root.ptr, root.len);
    try std.testing.expect(slot >= 0);
    defer fs.fs_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), fs.fs_state(slot)); // Connected
}

test "create rejects empty root" {
    const root = "x";
    const slot = fs.fs_create(root.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    fs.fs_destroy(-1);
    fs.fs_destroy(999);
}

// =========================================================================
// File operations
// =========================================================================

test "execute_op succeeds from Connected" {
    const root = "/files";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/files/test.txt";
    try std.testing.expectEqual(@as(u8, 0), fs.fs_execute_op(slot, 0, path.ptr, path.len)); // read
    try std.testing.expectEqual(@as(u32, 1), fs.fs_op_count(slot));
    try std.testing.expectEqual(@as(u8, 1), fs.fs_state(slot)); // back to Connected
}

test "execute_op rejects invalid operation" {
    const root = "/files";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/files/x";
    try std.testing.expectEqual(@as(u8, 1), fs.fs_execute_op(slot, 99, path.ptr, path.len));
}

// =========================================================================
// Lock management
// =========================================================================

test "acquire_lock transitions Connected -> Locked" {
    const root = "/locktest";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/locktest/file";
    try std.testing.expectEqual(@as(u8, 0), fs.fs_acquire_lock(slot, 1, path.ptr, path.len)); // exclusive
    try std.testing.expectEqual(@as(u8, 3), fs.fs_state(slot)); // Locked
    try std.testing.expectEqual(@as(u8, 1), fs.fs_is_locked(slot));
    try std.testing.expectEqual(@as(u8, 1), fs.fs_lock_type(slot)); // exclusive
}

test "release_lock transitions Locked -> Connected" {
    const root = "/releasetest";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/releasetest/file";
    _ = fs.fs_acquire_lock(slot, 0, path.ptr, path.len); // shared
    try std.testing.expectEqual(@as(u8, 0), fs.fs_release_lock(slot));
    try std.testing.expectEqual(@as(u8, 1), fs.fs_state(slot)); // Connected
    try std.testing.expectEqual(@as(u8, 0), fs.fs_is_locked(slot));
}

test "execute_op succeeds while Locked" {
    const root = "/lockedop";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/lockedop/file";
    _ = fs.fs_acquire_lock(slot, 1, path.ptr, path.len);
    try std.testing.expectEqual(@as(u8, 0), fs.fs_execute_op(slot, 1, path.ptr, path.len)); // write
    try std.testing.expectEqual(@as(u8, 3), fs.fs_state(slot)); // stays Locked
}

test "acquire_lock rejects from non-Connected" {
    const root = "/badlock";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/badlock/file";
    _ = fs.fs_acquire_lock(slot, 0, path.ptr, path.len);
    try std.testing.expectEqual(@as(u8, 1), fs.fs_acquire_lock(slot, 0, path.ptr, path.len)); // already locked
}

test "acquire_lock rejects invalid lock type" {
    const root = "/badlocktype";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/badlocktype/file";
    try std.testing.expectEqual(@as(u8, 1), fs.fs_acquire_lock(slot, 99, path.ptr, path.len));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Connected -> Disconnecting" {
    const root = "/discfs";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), fs.fs_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), fs.fs_state(slot)); // Disconnecting
}

test "disconnect from Locked releases lock state" {
    const root = "/lockdisc";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/lockdisc/file";
    _ = fs.fs_acquire_lock(slot, 0, path.ptr, path.len);
    try std.testing.expectEqual(@as(u8, 0), fs.fs_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), fs.fs_state(slot));
}

test "cleanup transitions Disconnecting -> Idle" {
    const root = "/cleanfs";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    _ = fs.fs_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), fs.fs_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), fs.fs_state(slot)); // Idle
}

test "cleanup clears op count and lock" {
    const root = "/clearfs";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    const path = "/clearfs/file";
    _ = fs.fs_execute_op(slot, 0, path.ptr, path.len);
    _ = fs.fs_disconnect(slot);
    _ = fs.fs_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), fs.fs_op_count(slot));
    try std.testing.expectEqual(@as(u8, 0), fs.fs_is_locked(slot));
}

test "cleanup rejected from non-Disconnecting state" {
    const root = "/badcleanfs";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), fs.fs_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "fs_can_transition matches Types.idr transitions" {
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(1, 2)); // Connected -> Operating
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(2, 1)); // Operating -> Connected
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(1, 3)); // Connected -> Locked
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(3, 2)); // Locked -> Operating
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(2, 3)); // Operating -> Locked
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(3, 1)); // Locked -> Connected
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(1, 4)); // Connected -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(3, 4)); // Locked -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(2, 4)); // Operating -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), fs.fs_can_transition(4, 0)); // Disconnecting -> Idle

    try std.testing.expectEqual(@as(u8, 0), fs.fs_can_transition(0, 2)); // Idle -/-> Operating
    try std.testing.expectEqual(@as(u8, 0), fs.fs_can_transition(4, 1)); // Disconnecting -/-> Connected
    try std.testing.expectEqual(@as(u8, 0), fs.fs_can_transition(0, 4)); // Idle -/-> Disconnecting
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), fs.fs_state(-1));
    try std.testing.expectEqual(@as(u32, 0), fs.fs_op_count(-1));
    try std.testing.expectEqual(@as(u8, 0), fs.fs_is_locked(-1));
    try std.testing.expectEqual(@as(u8, 1), fs.fs_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), fs.fs_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot operate from Idle" {
    const root = "/idleop";
    const slot = fs.fs_create(root.ptr, root.len);
    defer fs.fs_destroy(slot);

    _ = fs.fs_disconnect(slot);
    _ = fs.fs_cleanup(slot);
    const path = "/idleop/file";
    try std.testing.expectEqual(@as(u8, 1), fs.fs_execute_op(slot, 0, path.ptr, path.len));
}
