// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// storageconn_test.zig — Integration tests for proven-storageconn FFI.

const std = @import("std");
const testing = std.testing;
const storageconn = @import("storageconn");

test "ABI version returns 1" {
    try testing.expectEqual(@as(u32, 1), storageconn.storageconn_abi_version());
}

test "connect returns handle in connected state" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err);
    try testing.expect(h != null);
    try testing.expectEqual(storageconn.StorageError.none, err);
    try testing.expectEqual(storageconn.StorageState.connected, storageconn.storageconn_state(h));
    _ = storageconn.storageconn_disconnect(h);
}

test "put object from connected succeeds" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err).?;
    const result = storageconn.storageconn_put(h, null, 0, null, 5, null, 100, .sha256);
    try testing.expectEqual(storageconn.StorageError.none, result);
    try testing.expectEqual(storageconn.StorageState.connected, storageconn.storageconn_state(h));
    _ = storageconn.storageconn_disconnect(h);
}

test "put rejects overlong key" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err).?;
    const result = storageconn.storageconn_put(h, null, 0, null, storageconn.MAX_KEY_LENGTH + 1, null, 100, .sha256);
    try testing.expectEqual(storageconn.StorageError.path_traversal, result);
    _ = storageconn.storageconn_disconnect(h);
}

test "get returns object_not_found on empty storage" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err).?;
    var buf_len: u32 = 0;
    const result = storageconn.storageconn_get(h, null, 0, null, 5, null, 0, &buf_len);
    try testing.expectEqual(storageconn.StorageError.object_not_found, result);
    _ = storageconn.storageconn_disconnect(h);
}

test "delete from connected succeeds" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err).?;
    const result = storageconn.storageconn_delete(h, null, 0, null, 5);
    try testing.expectEqual(storageconn.StorageError.none, result);
    _ = storageconn.storageconn_disconnect(h);
}

test "head returns not_found on empty storage" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err).?;
    const result = storageconn.storageconn_head(h, null, 0, null, 5);
    try testing.expectEqual(storageconn.ObjectStatus.not_found, result);
    _ = storageconn.storageconn_disconnect(h);
}

test "disconnect from connected succeeds" {
    var err: storageconn.StorageError = .none;
    const h = storageconn.storageconn_connect(null, 9000, 1, &err).?;
    const result = storageconn.storageconn_disconnect(h);
    try testing.expectEqual(storageconn.StorageError.none, result);
}

test "NULL handle safety" {
    try testing.expectEqual(storageconn.StorageState.disconnected, storageconn.storageconn_state(null));
    try testing.expect(storageconn.storageconn_disconnect(null) != storageconn.StorageError.none);
    try testing.expect(storageconn.storageconn_put(null, null, 0, null, 0, null, 0, .sha256) != storageconn.StorageError.none);
    try testing.expect(storageconn.storageconn_get(null, null, 0, null, 0, null, 0, null) != storageconn.StorageError.none);
    try testing.expect(storageconn.storageconn_delete(null, null, 0, null, 0) != storageconn.StorageError.none);
    try testing.expectEqual(storageconn.ObjectStatus.not_found, storageconn.storageconn_head(null, null, 0, null, 0));
    var dummy_err: storageconn.StorageError = .none;
    _ = storageconn.storageconn_connect(null, 0, 0, &dummy_err); // doesn't crash
}

test "StorageOp enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(storageconn.StorageOp.put_object));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(storageconn.StorageOp.get_object));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(storageconn.StorageOp.delete_object));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(storageconn.StorageOp.list_objects));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(storageconn.StorageOp.head_object));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(storageconn.StorageOp.copy_object));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(storageconn.StorageOp.create_bucket));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(storageconn.StorageOp.delete_bucket));
}

test "StorageState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(storageconn.StorageState.disconnected));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(storageconn.StorageState.connected));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(storageconn.StorageState.uploading));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(storageconn.StorageState.downloading));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(storageconn.StorageState.failed));
}

test "ObjectStatus enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(storageconn.ObjectStatus.exists));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(storageconn.ObjectStatus.not_found));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(storageconn.ObjectStatus.archived));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(storageconn.ObjectStatus.deleted));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(storageconn.ObjectStatus.pending));
}

test "StorageError enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(storageconn.StorageError.none));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(storageconn.StorageError.bucket_not_found));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(storageconn.StorageError.object_not_found));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(storageconn.StorageError.access_denied));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(storageconn.StorageError.quota_exceeded));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(storageconn.StorageError.integrity_check_failed));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(storageconn.StorageError.upload_incomplete));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(storageconn.StorageError.path_traversal));
    try testing.expectEqual(@as(u8, 8), @intFromEnum(storageconn.StorageError.tls_required));
}

test "IntegrityCheck enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(storageconn.IntegrityCheck.sha256));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(storageconn.IntegrityCheck.sha384));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(storageconn.IntegrityCheck.sha512));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(storageconn.IntegrityCheck.blake3));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(storageconn.IntegrityCheck.none_));
}
