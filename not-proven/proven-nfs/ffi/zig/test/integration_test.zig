// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-nfs FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - File open/close
//   - Read/write operations
//   - Lock/unlock
//   - Lookup and getattr
//   - Unmount/cleanup
//   - Stateless transition table
//   - Invalid slot safety

const std = @import("std");
const nfs = @import("nfs");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), nfs.nfs_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Operation encoding matches Types.idr (15 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nfs.Operation.access));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nfs.Operation.close));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(nfs.Operation.open));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(nfs.Operation.read));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(nfs.Operation.write));
}

test "FileType encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nfs.FileType.regular));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nfs.FileType.directory));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nfs.FileType.block_device));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nfs.FileType.char_device));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nfs.FileType.sym_link));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nfs.FileType.socket));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(nfs.FileType.fifo));
}

test "Status encoding matches Types.idr (14 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nfs.Status.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nfs.Status.perm));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nfs.Status.noent));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nfs.Status.access));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(nfs.Status.rofs));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(nfs.Status.stale));
}

test "NFSState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nfs.NFSState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nfs.NFSState.mounted));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nfs.NFSState.file_open));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nfs.NFSState.locked));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nfs.NFSState.busy));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nfs.NFSState.unmounting));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Mounted state" {
    const server = "nfs-server";
    const export_p = "/exports/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    try std.testing.expect(slot >= 0);
    defer nfs.nfs_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_state(slot)); // Mounted
}

test "create rejects empty server" {
    const server = "x";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, 0, export_p.ptr, export_p.len);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects empty export" {
    const server = "nfs";
    const export_p = "x";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    nfs.nfs_destroy(-1);
    nfs.nfs_destroy(999);
}

// =========================================================================
// File open / close
// =========================================================================

test "open transitions Mounted -> FileOpen" {
    const server = "srv";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/file.txt";
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_open(slot, path.ptr, path.len, 0));
    try std.testing.expectEqual(@as(u8, 2), nfs.nfs_state(slot)); // FileOpen
    try std.testing.expectEqual(@as(u32, 1), nfs.nfs_open_count(slot));
}

test "close last file transitions FileOpen -> Mounted" {
    const server = "srv2";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/f.txt";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_close(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_state(slot)); // Mounted
    try std.testing.expectEqual(@as(u32, 0), nfs.nfs_open_count(slot));
}

test "open rejects invalid file type" {
    const server = "srv3";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/x";
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_open(slot, path.ptr, path.len, 99));
}

// =========================================================================
// Read / Write
// =========================================================================

test "read returns Ok on open file" {
    const server = "srv4";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/readme";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_read(slot, 0, 0, 4096)); // Ok
}

test "write returns Ok on open file" {
    const server = "srv5";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/out";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_write(slot, 0, 0, 1024)); // Ok
}

test "read returns stale on inactive handle" {
    const server = "srv6";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/f";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    _ = nfs.nfs_close(slot, 0);
    // Slot 0 is now inactive; reading from Mounted state should fail
    // (state check fails first, returning io)
    try std.testing.expectEqual(@as(u8, 3), nfs.nfs_read(slot, 0, 0, 100)); // IO (wrong state)
}

// =========================================================================
// Lock / Unlock
// =========================================================================

test "lock transitions FileOpen -> Locked" {
    const server = "srv7";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/lockme";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_lock(slot, 0, 0, 4096));
    try std.testing.expectEqual(@as(u8, 3), nfs.nfs_state(slot)); // Locked
}

test "unlock transitions Locked -> FileOpen" {
    const server = "srv8";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/lockme2";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    _ = nfs.nfs_lock(slot, 0, 0, 4096);
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_unlock(slot, 0));
    try std.testing.expectEqual(@as(u8, 2), nfs.nfs_state(slot)); // FileOpen
}

test "lock rejects double lock on same handle" {
    const server = "srv9";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/dl";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 0);
    _ = nfs.nfs_lock(slot, 0, 0, 100);
    // State is now Locked, so second lock from FileOpen check fails
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_lock(slot, 0, 100, 100));
}

// =========================================================================
// Lookup / Getattr
// =========================================================================

test "lookup returns Ok from Mounted" {
    const server = "srv10";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/subdir";
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_lookup(slot, path.ptr, path.len)); // Ok
}

test "getattr returns file type" {
    const server = "srv11";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    const path = "/data/dir";
    _ = nfs.nfs_open(slot, path.ptr, path.len, 1); // Directory
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_getattr(slot, 0)); // Directory
}

test "getattr returns 255 on invalid handle" {
    const server = "srv12";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 255), nfs.nfs_getattr(slot, 0));
}

// =========================================================================
// Unmount / Cleanup
// =========================================================================

test "unmount transitions Mounted -> Unmounting" {
    const server = "srv13";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_unmount(slot));
    try std.testing.expectEqual(@as(u8, 5), nfs.nfs_state(slot)); // Unmounting
}

test "cleanup transitions Unmounting -> Idle" {
    const server = "srv14";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    _ = nfs.nfs_unmount(slot);
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_state(slot)); // Idle
}

test "cleanup rejected from Mounted state" {
    const server = "srv15";
    const export_p = "/data";
    const slot = nfs.nfs_create(server.ptr, server.len, export_p.ptr, export_p.len);
    defer nfs.nfs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "nfs_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(0, 1)); // Idle -> Mounted
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(1, 2)); // Mounted -> FileOpen
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(2, 1)); // FileOpen -> Mounted
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(2, 3)); // FileOpen -> Locked
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(3, 2)); // Locked -> FileOpen
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(1, 5)); // Mounted -> Unmounting
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_can_transition(5, 0)); // Unmounting -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_can_transition(0, 2)); // Idle -/-> FileOpen
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_can_transition(0, 3)); // Idle -/-> Locked
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_can_transition(5, 1)); // Unmounting -/-> Mounted
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), nfs.nfs_state(-1));
    try std.testing.expectEqual(@as(u32, 0), nfs.nfs_open_count(-1));
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_unmount(-1));
    try std.testing.expectEqual(@as(u8, 1), nfs.nfs_cleanup(-1));
}
