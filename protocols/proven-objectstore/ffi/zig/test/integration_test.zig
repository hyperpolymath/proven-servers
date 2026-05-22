// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-objectstore FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Bucket management (create/delete/select)
//   - Object operations (put/get/head/delete)
//   - Multipart upload lifecycle
//   - ACL enforcement
//   - Close / Cleanup transitions
//   - BucketNotEmpty enforcement
//   - Invalid slot safety

const std = @import("std");
const os = @import("objectstore");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), os.objectstore_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Operation encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(os.Operation.put_object));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(os.Operation.get_object));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(os.Operation.delete_object));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(os.Operation.list_objects));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(os.Operation.head_object));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(os.Operation.copy_object));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(os.Operation.create_bucket));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(os.Operation.delete_bucket));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(os.Operation.list_buckets));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(os.Operation.init_multipart_upload));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(os.Operation.upload_part));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(os.Operation.complete_multipart_upload));
}

test "StorageClass encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(os.StorageClass.standard));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(os.StorageClass.infrequent_access));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(os.StorageClass.glacier));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(os.StorageClass.deep_archive));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(os.StorageClass.one_zone));
}

test "ACL encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(os.ACL.private));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(os.ACL.public_read));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(os.ACL.public_read_write));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(os.ACL.authenticated_read));
}

test "ErrorCode encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(os.ObjErrorCode.no_such_bucket));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(os.ObjErrorCode.no_such_key));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(os.ObjErrorCode.bucket_already_exists));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(os.ObjErrorCode.bucket_not_empty));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(os.ObjErrorCode.access_denied));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(os.ObjErrorCode.entity_too_large));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(os.ObjErrorCode.invalid_part));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(os.ObjErrorCode.incomplete_body));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(os.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(os.SessionState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(os.SessionState.bucket_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(os.SessionState.uploading));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(os.SessionState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    try std.testing.expect(slot >= 0);
    defer os.objectstore_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_state(slot)); // Ready
}

test "create rejects empty region" {
    const region = "x";
    const slot = os.objectstore_create(region.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    os.objectstore_destroy(-1);
    os.objectstore_destroy(999);
}

// =========================================================================
// Bucket management
// =========================================================================

test "create_bucket adds bucket" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const name = "my-bucket";
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_create_bucket(slot, name.ptr, name.len, 0));
    try std.testing.expectEqual(@as(u32, 1), os.objectstore_bucket_count(slot));
}

test "create_bucket rejects duplicate name" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const name = "dupe";
    _ = os.objectstore_create_bucket(slot, name.ptr, name.len, 0);
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_create_bucket(slot, name.ptr, name.len, 0));
}

test "create_bucket rejects invalid ACL" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const name = "bad-acl";
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_create_bucket(slot, name.ptr, name.len, 99));
}

test "select_bucket transitions Ready -> BucketActive" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const name = "test-bucket";
    _ = os.objectstore_create_bucket(slot, name.ptr, name.len, 0);
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_select_bucket(slot, name.ptr, name.len));
    try std.testing.expectEqual(@as(u8, 2), os.objectstore_state(slot)); // BucketActive
}

test "select_bucket rejects non-existent bucket" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const name = "nope";
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_select_bucket(slot, name.ptr, name.len));
}

test "delete_bucket rejects non-empty bucket" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "has-objects";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "obj1";
    const body = "data";
    _ = os.objectstore_put_object(slot, key.ptr, key.len, body.ptr, body.len, 0);

    try std.testing.expectEqual(@as(u8, 1), os.objectstore_delete_bucket(slot, bucket.ptr, bucket.len));
}

test "delete_bucket succeeds on empty bucket" {
    const region = "eu-west-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "empty-bucket";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_delete_bucket(slot, bucket.ptr, bucket.len));
    try std.testing.expectEqual(@as(u32, 0), os.objectstore_bucket_count(slot));
}

// =========================================================================
// Object operations
// =========================================================================

test "put_object and head_object" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "data";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "file.txt";
    const body = "hello world";
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_put_object(
        slot, key.ptr, key.len, body.ptr, body.len, 0,
    ));
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_head_object(slot, key.ptr, key.len));
}

test "get_object returns 0 for existing key" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "data";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "doc.pdf";
    const body = "pdf-bytes";
    _ = os.objectstore_put_object(slot, key.ptr, key.len, body.ptr, body.len, 0);
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_get_object(slot, key.ptr, key.len));
}

test "get_object returns 1 for missing key" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "data";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "missing";
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_get_object(slot, key.ptr, key.len));
}

test "delete_object removes object" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "data";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "temp.txt";
    const body = "temp";
    _ = os.objectstore_put_object(slot, key.ptr, key.len, body.ptr, body.len, 0);
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_delete_object(slot, key.ptr, key.len));
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_head_object(slot, key.ptr, key.len));
}

test "put_object rejects invalid storage class" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "data";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "bad";
    const body = "x";
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_put_object(
        slot, key.ptr, key.len, body.ptr, body.len, 99,
    ));
}

// =========================================================================
// Multipart upload
// =========================================================================

test "init_multipart transitions BucketActive -> Uploading" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "uploads";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "large-file.bin";
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_init_multipart(slot, key.ptr, key.len));
    try std.testing.expectEqual(@as(u8, 3), os.objectstore_state(slot)); // Uploading
}

test "complete_multipart transitions Uploading -> BucketActive" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "uploads";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_select_bucket(slot, bucket.ptr, bucket.len);

    const key = "large-file.bin";
    _ = os.objectstore_init_multipart(slot, key.ptr, key.len);
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_complete_multipart(slot));
    try std.testing.expectEqual(@as(u8, 2), os.objectstore_state(slot)); // BucketActive
}

// =========================================================================
// Close / Cleanup
// =========================================================================

test "close transitions Ready -> Closing" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), os.objectstore_close(slot));
    try std.testing.expectEqual(@as(u8, 4), os.objectstore_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    _ = os.objectstore_close(slot);
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_state(slot)); // Idle
}

test "cleanup clears buckets" {
    const region = "us-east-1";
    const slot = os.objectstore_create(region.ptr, region.len);
    defer os.objectstore_destroy(slot);

    const bucket = "temp";
    _ = os.objectstore_create_bucket(slot, bucket.ptr, bucket.len, 0);
    _ = os.objectstore_close(slot);
    _ = os.objectstore_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), os.objectstore_bucket_count(slot));
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), os.objectstore_state(-1));
    try std.testing.expectEqual(@as(u32, 0), os.objectstore_bucket_count(-1));
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_close(-1));
    try std.testing.expectEqual(@as(u8, 1), os.objectstore_cleanup(-1));
}
