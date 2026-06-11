// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-webdav FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Resource lifecycle (create/destroy)
//   - Lock management (lock/unlock/is_locked/scope)
//   - Property management (set/remove/count)
//   - Collection management (mkcol/is_collection)
//   - Copy/move operations
//   - Invalid slot safety
//   - Lock conflict rejection

const std = @import("std");
const webdav = @import("webdav");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), webdav.webdav_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Method encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(webdav.Method.propfind));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(webdav.Method.proppatch));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(webdav.Method.mkcol));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(webdav.Method.copy));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(webdav.Method.move));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(webdav.Method.lock));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(webdav.Method.unlock));
}

test "StatusCode encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(webdav.StatusCode.multi_status));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(webdav.StatusCode.unprocessable_entity));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(webdav.StatusCode.locked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(webdav.StatusCode.failed_dependency));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(webdav.StatusCode.insufficient_storage));
}

test "LockScope encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(webdav.LockScope.exclusive));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(webdav.LockScope.shared));
}

test "Depth encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(webdav.Depth.zero));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(webdav.Depth.one));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(webdav.Depth.infinity));
}

test "PropertyOp encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(webdav.PropertyOp.set));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(webdav.PropertyOp.remove));
}

// =========================================================================
// Resource lifecycle
// =========================================================================

test "create returns valid slot" {
    const path = "/documents/report.txt";
    const slot = webdav.webdav_create(path.ptr, path.len);
    try std.testing.expect(slot >= 0);
    defer webdav.webdav_destroy(slot);
}

test "create rejects empty path" {
    const path = "x";
    const slot = webdav.webdav_create(path.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    webdav.webdav_destroy(-1);
    webdav.webdav_destroy(999);
}

// =========================================================================
// Lock management
// =========================================================================

test "lock acquires exclusive lock" {
    const path = "/test/lock";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_is_locked(slot));
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_lock(slot, 0, 2, 3600)); // exclusive, infinity
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_is_locked(slot));
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_lock_scope(slot)); // exclusive
}

test "lock rejected when already locked" {
    const path = "/test/lock2";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    _ = webdav.webdav_lock(slot, 0, 0, 3600);
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_lock(slot, 0, 0, 3600));
}

test "lock rejects invalid scope" {
    const path = "/test/lock3";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_lock(slot, 99, 0, 3600));
}

test "unlock releases lock" {
    const path = "/test/unlock";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    _ = webdav.webdav_lock(slot, 1, 0, 3600); // shared
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_unlock(slot));
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_is_locked(slot));
}

test "unlock rejected when not locked" {
    const path = "/test/unlock2";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_unlock(slot));
}

// =========================================================================
// Property management
// =========================================================================

test "set_property adds property" {
    const path = "/test/prop";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    const name = "displayname";
    const val = "My Document";
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_set_property(
        slot, name.ptr, name.len, val.ptr, val.len,
    ));
    try std.testing.expectEqual(@as(u32, 1), webdav.webdav_property_count(slot));
}

test "set_property updates existing" {
    const path = "/test/prop2";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    const name = "getcontenttype";
    const val1 = "text/plain";
    const val2 = "text/html";
    _ = webdav.webdav_set_property(slot, name.ptr, name.len, val1.ptr, val1.len);
    _ = webdav.webdav_set_property(slot, name.ptr, name.len, val2.ptr, val2.len);
    try std.testing.expectEqual(@as(u32, 1), webdav.webdav_property_count(slot));
}

test "remove_property removes property" {
    const path = "/test/prop3";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    const name = "author";
    const val = "Alice";
    _ = webdav.webdav_set_property(slot, name.ptr, name.len, val.ptr, val.len);
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_remove_property(slot, name.ptr, name.len));
    try std.testing.expectEqual(@as(u32, 0), webdav.webdav_property_count(slot));
}

test "remove_property rejected for nonexistent" {
    const path = "/test/prop4";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    const name = "nonexistent";
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_remove_property(slot, name.ptr, name.len));
}

// =========================================================================
// Collection management
// =========================================================================

test "mkcol marks resource as collection" {
    const path = "/test/dir/";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_is_collection(slot));
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_mkcol(slot));
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_is_collection(slot));
}

test "mkcol rejected if already collection" {
    const path = "/test/dir2/";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    _ = webdav.webdav_mkcol(slot);
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_mkcol(slot));
}

// =========================================================================
// Copy/move
// =========================================================================

test "copy transfers properties" {
    const path1 = "/src/file";
    const path2 = "/dst/file";
    const src = webdav.webdav_create(path1.ptr, path1.len);
    const dst = webdav.webdav_create(path2.ptr, path2.len);
    defer webdav.webdav_destroy(src);
    defer webdav.webdav_destroy(dst);

    const name = "author";
    const val = "Bob";
    _ = webdav.webdav_set_property(src, name.ptr, name.len, val.ptr, val.len);
    _ = webdav.webdav_mkcol(src);

    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_copy(src, dst, 2));
    try std.testing.expectEqual(@as(u32, 1), webdav.webdav_property_count(dst));
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_is_collection(dst));
    // Source still has properties
    try std.testing.expectEqual(@as(u32, 1), webdav.webdav_property_count(src));
}

test "move transfers and clears source" {
    const path1 = "/move/src";
    const path2 = "/move/dst";
    const src = webdav.webdav_create(path1.ptr, path1.len);
    const dst = webdav.webdav_create(path2.ptr, path2.len);
    defer webdav.webdav_destroy(src);
    defer webdav.webdav_destroy(dst);

    const name = "title";
    const val = "Doc";
    _ = webdav.webdav_set_property(src, name.ptr, name.len, val.ptr, val.len);

    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_move(src, dst));
    try std.testing.expectEqual(@as(u32, 1), webdav.webdav_property_count(dst));
    try std.testing.expectEqual(@as(u32, 0), webdav.webdav_property_count(src));
}

test "copy rejected for same slot" {
    const path = "/same";
    const slot = webdav.webdav_create(path.ptr, path.len);
    defer webdav.webdav_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_copy(slot, slot, 0));
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_is_locked(-1));
    try std.testing.expectEqual(@as(u8, 0), webdav.webdav_is_collection(-1));
    try std.testing.expectEqual(@as(u32, 0), webdav.webdav_property_count(-1));
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_lock(-1, 0, 0, 0));
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_unlock(-1));
    try std.testing.expectEqual(@as(u8, 1), webdav.webdav_mkcol(-1));
}
