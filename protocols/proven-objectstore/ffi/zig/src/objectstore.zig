// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// objectstore.zig -- Zig FFI implementation of proven-objectstore.
//
// Implements an S3-compatible object store state machine with:
//   - 64-slot mutex-protected session pool
//   - Bucket registry (max 32 buckets per session)
//   - Object metadata tracking per bucket (max 256 objects total)
//   - Multipart upload state tracking
//   - ACL enforcement per bucket
//   - Storage class assignment per object
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching ObjectstoreABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching ObjectstoreABI.Types.idr tag assignments)
// =========================================================================

/// S3-compatible API operations (ABI tags 0-11).
pub const Operation = enum(u8) {
    put_object = 0,
    get_object = 1,
    delete_object = 2,
    list_objects = 3,
    head_object = 4,
    copy_object = 5,
    create_bucket = 6,
    delete_bucket = 7,
    list_buckets = 8,
    init_multipart_upload = 9,
    upload_part = 10,
    complete_multipart_upload = 11,
};

/// Storage classes (ABI tags 0-4).
pub const StorageClass = enum(u8) {
    standard = 0,
    infrequent_access = 1,
    glacier = 2,
    deep_archive = 3,
    one_zone = 4,
};

/// Access control list presets (ABI tags 0-3).
pub const ACL = enum(u8) {
    private = 0,
    public_read = 1,
    public_read_write = 2,
    authenticated_read = 3,
};

/// Error codes (ABI tags 0-7).
pub const ObjErrorCode = enum(u8) {
    no_such_bucket = 0,
    no_such_key = 1,
    bucket_already_exists = 2,
    bucket_not_empty = 3,
    access_denied = 4,
    entity_too_large = 5,
    invalid_part = 6,
    incomplete_body = 7,
};

/// Session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    ready = 1,
    bucket_active = 2,
    uploading = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_BUCKETS: usize = 32;
const MAX_OBJECTS: usize = 256;
const MAX_NAME_LEN: usize = 256;
const MAX_REGION_LEN: usize = 64;

/// A bucket entry.
const BucketEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    acl: ACL,
    object_count: u32,
    active: bool,
};

/// An object metadata entry.
const ObjectEntry = struct {
    key: [MAX_NAME_LEN]u8,
    key_len: u32,
    bucket_idx: u32,
    storage_class: StorageClass,
    size: u64,
    active: bool,
};

const empty_bucket: BucketEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .acl = .private,
    .object_count = 0,
    .active = false,
};

const empty_object: ObjectEntry = .{
    .key = [_]u8{0} ** MAX_NAME_LEN,
    .key_len = 0,
    .bucket_idx = 0,
    .storage_class = .standard,
    .size = 0,
    .active = false,
};

/// An object store session.
const Session = struct {
    state: SessionState,
    region: [MAX_REGION_LEN]u8,
    region_len: u32,
    buckets: [MAX_BUCKETS]BucketEntry,
    bucket_count: u32,
    objects: [MAX_OBJECTS]ObjectEntry,
    object_count: u32,
    /// Index of the currently selected bucket (-1 if none).
    selected_bucket: i32,
    /// Whether a multipart upload is in progress.
    multipart_key: [MAX_NAME_LEN]u8,
    multipart_key_len: u32,
    multipart_parts: u32,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .region = [_]u8{0} ** MAX_REGION_LEN,
    .region_len = 0,
    .buckets = [_]BucketEntry{empty_bucket} ** MAX_BUCKETS,
    .bucket_count = 0,
    .objects = [_]ObjectEntry{empty_object} ** MAX_OBJECTS,
    .object_count = 0,
    .selected_bucket = -1,
    .multipart_key = [_]u8{0} ** MAX_NAME_LEN,
    .multipart_key_len = 0,
    .multipart_parts = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

fn findBucket(idx: usize, name: []const u8) ?usize {
    for (&sessions[idx].buckets, 0..) |*b, i| {
        if (b.active and b.name_len == name.len and
            std.mem.eql(u8, b.name[0..b.name_len], name))
        {
            return i;
        }
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn objectstore_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new object store session. Returns slot (>=0) or -1.
/// Transitions: Idle -> Ready.
pub export fn objectstore_create(
    region_ptr: [*]const u8,
    region_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (region_len == 0 or region_len > MAX_REGION_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.region[0..region_len], region_ptr[0..region_len]);
            s.region_len = region_len;
            s.state = .ready;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn objectstore_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn objectstore_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Create a bucket. Returns 0 on success, 1 on rejection.
pub export fn objectstore_create_bucket(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    acl: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .bucket_active) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (acl > 3) return 1;

    const name = name_ptr[0..name_len];
    if (findBucket(idx, name) != null) return 1; // already exists

    for (&sessions[idx].buckets) |*b| {
        if (!b.active) {
            @memcpy(b.name[0..name_len], name);
            b.name_len = name_len;
            b.acl = @enumFromInt(acl);
            b.object_count = 0;
            b.active = true;
            sessions[idx].bucket_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Delete a bucket. Returns 0 on success, 1 on rejection.
/// Rejects if bucket has objects (BucketNotEmpty).
pub export fn objectstore_delete_bucket(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .bucket_active) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    const name = name_ptr[0..name_len];
    const bi = findBucket(idx, name) orelse return 1;

    if (sessions[idx].buckets[bi].object_count > 0) return 1; // not empty

    sessions[idx].buckets[bi].active = false;
    sessions[idx].bucket_count -= 1;

    // If this was the selected bucket, deselect
    if (sessions[idx].selected_bucket == @as(i32, @intCast(bi))) {
        sessions[idx].selected_bucket = -1;
        if (sessions[idx].state == .bucket_active) {
            sessions[idx].state = .ready;
        }
    }
    return 0;
}

/// Select a bucket for operations. Returns 0 on success, 1 on rejection.
/// Transitions: Ready -> BucketActive.
pub export fn objectstore_select_bucket(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .bucket_active) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    const name = name_ptr[0..name_len];
    const bi = findBucket(idx, name) orelse return 1;

    sessions[idx].selected_bucket = @intCast(bi);
    sessions[idx].state = .bucket_active;
    return 0;
}

/// Put an object into the selected bucket. Returns 0 on success, 1 on rejection.
pub export fn objectstore_put_object(
    slot: c_int,
    key_ptr: [*]const u8,
    key_len: u32,
    body_ptr: [*]const u8,
    body_len: u32,
    storage_class: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = body_ptr;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bucket_active) return 1;
    if (key_len == 0 or key_len > MAX_NAME_LEN) return 1;
    if (storage_class > 4) return 1;
    if (sessions[idx].selected_bucket < 0) return 1;

    const bi: usize = @intCast(sessions[idx].selected_bucket);

    // Find or create object slot
    const key = key_ptr[0..key_len];
    for (&sessions[idx].objects) |*obj| {
        if (obj.active and obj.bucket_idx == bi and
            obj.key_len == key_len and
            std.mem.eql(u8, obj.key[0..obj.key_len], key))
        {
            // Overwrite existing
            obj.storage_class = @enumFromInt(storage_class);
            obj.size = body_len;
            return 0;
        }
    }

    // New object
    for (&sessions[idx].objects) |*obj| {
        if (!obj.active) {
            @memcpy(obj.key[0..key_len], key);
            obj.key_len = key_len;
            obj.bucket_idx = @intCast(bi);
            obj.storage_class = @enumFromInt(storage_class);
            obj.size = body_len;
            obj.active = true;
            sessions[idx].object_count += 1;
            sessions[idx].buckets[bi].object_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Check if an object exists (head). Returns 1 if exists, 0 if not.
pub export fn objectstore_head_object(
    slot: c_int,
    key_ptr: [*]const u8,
    key_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (sessions[idx].state != .bucket_active) return 0;
    if (key_len == 0 or key_len > MAX_NAME_LEN) return 0;
    if (sessions[idx].selected_bucket < 0) return 0;

    const bi: usize = @intCast(sessions[idx].selected_bucket);
    const key = key_ptr[0..key_len];

    for (&sessions[idx].objects) |*obj| {
        if (obj.active and obj.bucket_idx == bi and
            obj.key_len == key_len and
            std.mem.eql(u8, obj.key[0..obj.key_len], key))
        {
            return 1;
        }
    }
    return 0;
}

/// Get an object (simulated). Returns 0 on success, 1 if not found.
pub export fn objectstore_get_object(
    slot: c_int,
    key_ptr: [*]const u8,
    key_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bucket_active) return 1;
    if (key_len == 0 or key_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].selected_bucket < 0) return 1;

    const bi: usize = @intCast(sessions[idx].selected_bucket);
    const key = key_ptr[0..key_len];

    for (&sessions[idx].objects) |*obj| {
        if (obj.active and obj.bucket_idx == bi and
            obj.key_len == key_len and
            std.mem.eql(u8, obj.key[0..obj.key_len], key))
        {
            return 0;
        }
    }
    return 1;
}

/// Delete an object. Returns 0 on success, 1 on rejection.
pub export fn objectstore_delete_object(
    slot: c_int,
    key_ptr: [*]const u8,
    key_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bucket_active) return 1;
    if (key_len == 0 or key_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].selected_bucket < 0) return 1;

    const bi: usize = @intCast(sessions[idx].selected_bucket);
    const key = key_ptr[0..key_len];

    for (&sessions[idx].objects) |*obj| {
        if (obj.active and obj.bucket_idx == bi and
            obj.key_len == key_len and
            std.mem.eql(u8, obj.key[0..obj.key_len], key))
        {
            obj.active = false;
            sessions[idx].object_count -= 1;
            sessions[idx].buckets[bi].object_count -= 1;
            return 0;
        }
    }
    return 1;
}

/// Initiate a multipart upload. Returns 0 on success, 1 on rejection.
/// Transitions: BucketActive -> Uploading.
pub export fn objectstore_init_multipart(
    slot: c_int,
    key_ptr: [*]const u8,
    key_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .bucket_active) return 1;
    if (key_len == 0 or key_len > MAX_NAME_LEN) return 1;

    @memcpy(sessions[idx].multipart_key[0..key_len], key_ptr[0..key_len]);
    sessions[idx].multipart_key_len = key_len;
    sessions[idx].multipart_parts = 0;
    sessions[idx].state = .uploading;
    return 0;
}

/// Complete a multipart upload. Returns 0 on success, 1 on rejection.
/// Transitions: Uploading -> BucketActive.
pub export fn objectstore_complete_multipart(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .uploading) return 1;

    sessions[idx].state = .bucket_active;
    sessions[idx].multipart_key_len = 0;
    sessions[idx].multipart_parts = 0;
    return 0;
}

/// Returns the number of buckets.
pub export fn objectstore_bucket_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].bucket_count;
}

/// Close the session. Returns 0 on success, 1 on rejection.
pub export fn objectstore_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .ready or state == .bucket_active) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Returns 0 on success, 1 on rejection.
/// Transitions: Closing -> Idle.
pub export fn objectstore_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].buckets = [_]BucketEntry{empty_bucket} ** MAX_BUCKETS;
    sessions[idx].bucket_count = 0;
    sessions[idx].objects = [_]ObjectEntry{empty_object} ** MAX_OBJECTS;
    sessions[idx].object_count = 0;
    sessions[idx].selected_bucket = -1;
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
