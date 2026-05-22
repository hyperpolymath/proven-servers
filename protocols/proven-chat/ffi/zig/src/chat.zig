// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// chat.zig -- Zig FFI implementation of proven-chat.
//
// Implements a chat room session manager with:
//   - 64-slot room pool
//   - Per-room type, user count, message counter
//   - Presence tracking per room session
//   - Permission bitmask per room
//   - Thread-safe via mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching ChatABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching ChatABI.Types.idr tag assignments)
// =========================================================================

/// Message types (tags 0-8).
pub const MessageType = enum(u8) {
    text = 0,
    image = 1,
    file = 2,
    system = 3,
    reaction = 4,
    edit = 5,
    delete = 6,
    reply = 7,
    thread = 8,
};

/// Presence statuses (tags 0-4).
pub const PresenceStatus = enum(u8) {
    online = 0,
    away = 1,
    dnd = 2,
    invisible = 3,
    offline = 4,
};

/// Room types (tags 0-3).
pub const RoomType = enum(u8) {
    direct = 0,
    group = 1,
    channel = 2,
    broadcast = 3,
};

/// Permissions (tags 0-7).
pub const Permission = enum(u8) {
    read = 0,
    write = 1,
    admin = 2,
    invite = 3,
    kick = 4,
    ban = 5,
    pin = 6,
    delete_others = 7,
};

/// Chat events (tags 0-6).
pub const Event = enum(u8) {
    message_sent = 0,
    message_delivered = 1,
    message_read = 2,
    user_joined = 3,
    user_left = 4,
    typing = 5,
    room_created = 6,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent chat rooms.
const MAX_SESSIONS: usize = 64;

/// A chat room session.
const Session = struct {
    /// Room type.
    room_type: RoomType,
    /// Maximum number of users allowed.
    max_users: u16,
    /// Current number of users in the room.
    user_count: u16,
    /// Total messages sent in the room.
    message_count: u32,
    /// Current presence status for this session.
    presence: PresenceStatus,
    /// Permission bitmask (bit N = permission tag N is granted).
    permissions: u8,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .room_type = .direct,
    .max_users = 0,
    .user_count = 0,
    .message_count = 0,
    .presence = .offline,
    .permissions = 0,
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

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn chat_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new chat room. Returns slot index (>=0) or -1.
pub export fn chat_create_room(room_type: u8, max_users: u16) callconv(.c) c_int {
    if (room_type > 3) return -1;

    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.room_type = @enumFromInt(room_type);
            s.max_users = max_users;
            s.presence = .online;
            s.permissions = 0x03; // Read + Write by default
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a room, releasing its slot.
pub export fn chat_destroy_room(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the room type tag.
pub export fn chat_room_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].room_type);
}

/// Send a message. Returns 0 on success, 1 on invalid slot/type.
pub export fn chat_send_message(slot: c_int, msg_type: u8) callconv(.c) u8 {
    if (msg_type > 8) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    sessions[idx].message_count += 1;
    return 0;
}

/// Returns total messages sent in the room.
pub export fn chat_message_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].message_count;
}

/// Add a user to the room. Returns 0 on success, 1 if full/invalid.
pub export fn chat_join_user(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].max_users > 0 and sessions[idx].user_count >= sessions[idx].max_users) return 1;
    sessions[idx].user_count += 1;
    return 0;
}

/// Remove a user from the room. Returns 0 on success, 1 if empty/invalid.
pub export fn chat_leave_user(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].user_count == 0) return 1;
    sessions[idx].user_count -= 1;
    return 0;
}

/// Returns the current user count in the room.
pub export fn chat_user_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].user_count;
}

/// Returns the max user capacity for the room.
pub export fn chat_max_users(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].max_users;
}

/// Set presence status. Returns 0 on success, 1 on invalid.
pub export fn chat_set_presence(slot: c_int, status: u8) callconv(.c) u8 {
    if (status > 4) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    sessions[idx].presence = @enumFromInt(status);
    return 0;
}

/// Returns the current presence status tag.
pub export fn chat_get_presence(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // Offline as fallback
    return @intFromEnum(sessions[idx].presence);
}

/// Whether the room has a given permission set. Returns 1=yes, 0=no.
pub export fn chat_has_permission(slot: c_int, perm: u8) callconv(.c) u8 {
    if (perm > 7) return 0;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    const mask: u8 = @as(u8, 1) << @intCast(perm);
    return if (sessions[idx].permissions & mask != 0) 1 else 0;
}

/// Grant a permission. Returns 0 on success, 1 on invalid.
pub export fn chat_grant_permission(slot: c_int, perm: u8) callconv(.c) u8 {
    if (perm > 7) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const mask: u8 = @as(u8, 1) << @intCast(perm);
    sessions[idx].permissions |= mask;
    return 0;
}
