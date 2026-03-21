// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// webdav.zig -- Zig FFI implementation of proven-webdav.
//
// Implements the WebDAV resource state machine with:
//   - 64-slot mutex-protected resource pool
//   - Lock management (scope, depth, timeout)
//   - Property storage (max 32 per resource)
//   - Collection flag tracking
//   - Copy/move operations between slots
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching WebDAVABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching WebDAVABI.Types.idr tag assignments)
// =========================================================================

/// WebDAV methods (ABI tags 0-6).
pub const Method = enum(u8) {
    propfind = 0,
    proppatch = 1,
    mkcol = 2,
    copy = 3,
    move = 4,
    lock = 5,
    unlock = 6,
};

/// WebDAV status codes (ABI tags 0-4).
pub const StatusCode = enum(u8) {
    multi_status = 0,
    unprocessable_entity = 1,
    locked = 2,
    failed_dependency = 3,
    insufficient_storage = 4,
};

/// Lock scope (ABI tags 0-1).
pub const LockScope = enum(u8) {
    exclusive = 0,
    shared = 1,
};

/// Lock type (ABI tag 0).
pub const LockType = enum(u8) {
    write = 0,
};

/// Depth values (ABI tags 0-2).
pub const Depth = enum(u8) {
    zero = 0,
    one = 1,
    infinity = 2,
};

/// Property operations (ABI tags 0-1).
pub const PropertyOp = enum(u8) {
    set = 0,
    remove = 1,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_PROPERTIES: usize = 32;
const MAX_NAME_LEN: usize = 256;
const MAX_VALUE_LEN: usize = 1024;
const MAX_PATH_LEN: usize = 512;

/// A property entry.
const Property = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    value: [MAX_VALUE_LEN]u8,
    value_len: u32,
    active: bool,
};

/// Default (empty) property.
const empty_property: Property = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .value = [_]u8{0} ** MAX_VALUE_LEN,
    .value_len = 0,
    .active = false,
};

/// A lock state.
const LockState = struct {
    locked: bool,
    scope: LockScope,
    depth: Depth,
    timeout: u32,
};

const empty_lock: LockState = .{
    .locked = false,
    .scope = .exclusive,
    .depth = .zero,
    .timeout = 0,
};

/// A WebDAV resource.
const Resource = struct {
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    is_collection: bool,
    lock_state: LockState,
    properties: [MAX_PROPERTIES]Property,
    property_count: u32,
    active: bool,
};

const empty_resource: Resource = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .is_collection = false,
    .lock_state = empty_lock,
    .properties = [_]Property{empty_property} ** MAX_PROPERTIES,
    .property_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var resources: [MAX_SESSIONS]Resource = [_]Resource{empty_resource} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!resources[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn webdav_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a resource entry. Returns slot (>=0) or -1 on failure.
pub export fn webdav_create(
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (path_len == 0 or path_len > MAX_PATH_LEN) return -1;

    for (&resources, 0..) |*r, i| {
        if (!r.active) {
            r.* = empty_resource;
            @memcpy(r.path[0..path_len], path_ptr[0..path_len]);
            r.path_len = path_len;
            r.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn webdav_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    resources[@intCast(slot)] = empty_resource;
}

/// Acquire a lock. Returns 0 on success, 1 on rejection.
pub export fn webdav_lock(slot: c_int, scope: u8, depth: u8, timeout: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (scope > 1) return 1;
    if (depth > 2) return 1;
    if (resources[idx].lock_state.locked) return 1; // Already locked

    resources[idx].lock_state = .{
        .locked = true,
        .scope = @enumFromInt(scope),
        .depth = @enumFromInt(depth),
        .timeout = timeout,
    };
    return 0;
}

/// Release a lock. Returns 0 on success, 1 on rejection.
pub export fn webdav_unlock(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (!resources[idx].lock_state.locked) return 1;

    resources[idx].lock_state = empty_lock;
    return 0;
}

/// Returns 1 if resource is locked, 0 otherwise.
pub export fn webdav_is_locked(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (resources[idx].lock_state.locked) 1 else 0;
}

/// Returns lock scope tag.
pub export fn webdav_lock_scope(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(resources[idx].lock_state.scope);
}

/// Set a property. Returns 0 on success, 1 on rejection.
pub export fn webdav_set_property(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    val_ptr: [*]const u8,
    val_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (val_len > MAX_VALUE_LEN) return 1;

    // Update existing property if name matches
    const name = name_ptr[0..name_len];
    for (&resources[idx].properties) |*p| {
        if (p.active and p.name_len == name_len and
            std.mem.eql(u8, p.name[0..p.name_len], name))
        {
            if (val_len > 0) {
                @memcpy(p.value[0..val_len], val_ptr[0..val_len]);
            }
            p.value_len = val_len;
            return 0;
        }
    }

    // Find a free property slot
    for (&resources[idx].properties) |*p| {
        if (!p.active) {
            @memcpy(p.name[0..name_len], name_ptr[0..name_len]);
            p.name_len = name_len;
            if (val_len > 0) {
                @memcpy(p.value[0..val_len], val_ptr[0..val_len]);
            }
            p.value_len = val_len;
            p.active = true;
            resources[idx].property_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Remove a property. Returns 0 on success, 1 on rejection.
pub export fn webdav_remove_property(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    const name = name_ptr[0..name_len];
    for (&resources[idx].properties) |*p| {
        if (p.active and p.name_len == name_len and
            std.mem.eql(u8, p.name[0..p.name_len], name))
        {
            p.* = empty_property;
            resources[idx].property_count -= 1;
            return 0;
        }
    }
    return 1;
}

pub export fn webdav_property_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return resources[idx].property_count;
}

/// Mark resource as collection. Returns 0 on success.
pub export fn webdav_mkcol(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (resources[idx].is_collection) return 1; // Already a collection
    resources[idx].is_collection = true;
    return 0;
}

/// Returns 1 if resource is a collection, 0 otherwise.
pub export fn webdav_is_collection(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (resources[idx].is_collection) 1 else 0;
}

/// Copy resource properties from src to dst. Returns 0 on success.
pub export fn webdav_copy(src: c_int, dst: c_int, depth: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = depth;

    const si = validSlot(src) orelse return 1;
    const di = validSlot(dst) orelse return 1;
    if (si == di) return 1;

    // Copy properties
    resources[di].properties = resources[si].properties;
    resources[di].property_count = resources[si].property_count;
    resources[di].is_collection = resources[si].is_collection;
    return 0;
}

/// Move resource to new slot. Returns 0 on success.
pub export fn webdav_move(src: c_int, dst: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const si = validSlot(src) orelse return 1;
    const di = validSlot(dst) orelse return 1;
    if (si == di) return 1;

    // Copy all state except path and active flag
    resources[di].properties = resources[si].properties;
    resources[di].property_count = resources[si].property_count;
    resources[di].is_collection = resources[si].is_collection;
    resources[di].lock_state = resources[si].lock_state;

    // Clear source
    resources[si].properties = [_]Property{empty_property} ** MAX_PROPERTIES;
    resources[si].property_count = 0;
    resources[si].is_collection = false;
    resources[si].lock_state = empty_lock;

    return 0;
}
