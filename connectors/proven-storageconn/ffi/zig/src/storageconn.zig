// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// storageconn.zig — Zig FFI implementation for proven-storageconn.
//
// Skeleton implementation enforcing the storage connection state machine.

const std = @import("std");

pub const ABI_VERSION: u32 = 1;
pub const MAX_KEY_LENGTH: u32 = 1024;
pub const MAX_BUCKET_NAME_LEN: u32 = 63;

pub const StorageOp = enum(u8) {
    put_object = 0,
    get_object = 1,
    delete_object = 2,
    list_objects = 3,
    head_object = 4,
    copy_object = 5,
    create_bucket = 6,
    delete_bucket = 7,
};

pub const StorageState = enum(u8) {
    disconnected = 0,
    connected = 1,
    uploading = 2,
    downloading = 3,
    failed = 4,
};

pub const ObjectStatus = enum(u8) {
    exists = 0,
    not_found = 1,
    archived = 2,
    deleted = 3,
    pending = 4,
};

pub const StorageError = enum(u8) {
    none = 0,
    bucket_not_found = 1,
    object_not_found = 2,
    access_denied = 3,
    quota_exceeded = 4,
    integrity_check_failed = 5,
    upload_incomplete = 6,
    path_traversal = 7,
    tls_required = 8,
};

pub const IntegrityCheck = enum(u8) {
    sha256 = 0,
    sha384 = 1,
    sha512 = 2,
    blake3 = 3,
    none_ = 4,
};

pub const StorageHandle = struct {
    state: StorageState,
    port: u16,
    require_tls: bool,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub export fn storageconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

pub export fn storageconn_connect(
    endpoint: ?[*:0]const u8,
    port: u16,
    require_tls: u8,
    err: *StorageError,
) callconv(.c) ?*StorageHandle {
    _ = endpoint;
    const handle = allocator.create(StorageHandle) catch {
        err.* = StorageError.bucket_not_found;
        return null;
    };
    handle.* = StorageHandle{
        .state = StorageState.connected,
        .port = port,
        .require_tls = require_tls != 0,
    };
    err.* = StorageError.none;
    return handle;
}

pub export fn storageconn_disconnect(h: ?*StorageHandle) callconv(.c) StorageError {
    const handle = h orelse return StorageError.bucket_not_found;
    switch (handle.state) {
        .connected, .uploading, .downloading => {
            handle.state = StorageState.disconnected;
            allocator.destroy(handle);
            return StorageError.none;
        },
        .disconnected, .failed => return StorageError.bucket_not_found,
    }
}

pub export fn storageconn_state(h: ?*const StorageHandle) callconv(.c) StorageState {
    const handle = h orelse return StorageState.disconnected;
    return handle.state;
}

pub export fn storageconn_put(
    h: ?*StorageHandle,
    bucket: ?[*]const u8,
    bucket_len: u32,
    key: ?[*]const u8,
    key_len: u32,
    body: ?*const anyopaque,
    body_len: u32,
    integrity: IntegrityCheck,
) callconv(.c) StorageError {
    const handle = h orelse return StorageError.bucket_not_found;
    _ = bucket;
    _ = bucket_len;
    _ = key;
    _ = body;
    _ = body_len;
    _ = integrity;

    switch (handle.state) {
        .connected => {
            // Validate key length
            if (key_len > MAX_KEY_LENGTH) return StorageError.path_traversal;
            // Skeleton: briefly enter uploading, then back to connected
            handle.state = StorageState.uploading;
            handle.state = StorageState.connected;
            return StorageError.none;
        },
        .uploading, .downloading => return StorageError.upload_incomplete,
        .disconnected, .failed => return StorageError.bucket_not_found,
    }
}

pub export fn storageconn_get(
    h: ?*StorageHandle,
    bucket: ?[*]const u8,
    bucket_len: u32,
    key: ?[*]const u8,
    key_len: u32,
    buf: ?*anyopaque,
    buf_cap: u32,
    buf_len: ?*u32,
) callconv(.c) StorageError {
    const handle = h orelse return StorageError.bucket_not_found;
    _ = bucket;
    _ = bucket_len;
    _ = key;
    _ = key_len;
    _ = buf;
    _ = buf_cap;

    switch (handle.state) {
        .connected => {
            // Skeleton: object not found
            if (buf_len) |bl| bl.* = 0;
            return StorageError.object_not_found;
        },
        .uploading, .downloading => return StorageError.upload_incomplete,
        .disconnected, .failed => return StorageError.bucket_not_found,
    }
}

pub export fn storageconn_delete(
    h: ?*StorageHandle,
    bucket: ?[*]const u8,
    bucket_len: u32,
    key: ?[*]const u8,
    key_len: u32,
) callconv(.c) StorageError {
    const handle = h orelse return StorageError.bucket_not_found;
    _ = bucket;
    _ = bucket_len;
    _ = key;
    _ = key_len;

    switch (handle.state) {
        .connected => return StorageError.none,
        .uploading, .downloading => return StorageError.upload_incomplete,
        .disconnected, .failed => return StorageError.bucket_not_found,
    }
}

pub export fn storageconn_head(
    h: ?*StorageHandle,
    bucket: ?[*]const u8,
    bucket_len: u32,
    key: ?[*]const u8,
    key_len: u32,
) callconv(.c) ObjectStatus {
    const handle = h orelse return ObjectStatus.not_found;
    _ = bucket;
    _ = bucket_len;
    _ = key;
    _ = key_len;

    switch (handle.state) {
        .connected => return ObjectStatus.not_found, // skeleton: nothing stored
        .uploading, .downloading, .disconnected, .failed => return ObjectStatus.not_found,
    }
}

pub export fn storageconn_reset(h: ?*StorageHandle) callconv(.c) StorageError {
    const handle = h orelse return StorageError.bucket_not_found;
    switch (handle.state) {
        .failed => {
            handle.state = StorageState.disconnected;
            return StorageError.none;
        },
        .disconnected => return StorageError.none,
        .connected, .uploading, .downloading => return StorageError.bucket_not_found,
    }
}
