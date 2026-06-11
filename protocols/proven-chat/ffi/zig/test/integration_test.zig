// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-chat FFI.
//
// Verifies that the Zig implementation matches the Idris2 formal
// specification in ChatABI.Types.

const std = @import("std");
const chat = @import("chat");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), chat.chat_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MessageType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(chat.MessageType.text));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(chat.MessageType.image));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(chat.MessageType.file));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(chat.MessageType.system));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(chat.MessageType.reaction));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(chat.MessageType.edit));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(chat.MessageType.delete));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(chat.MessageType.reply));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(chat.MessageType.thread));
}

test "PresenceStatus encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(chat.PresenceStatus.online));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(chat.PresenceStatus.away));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(chat.PresenceStatus.dnd));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(chat.PresenceStatus.invisible));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(chat.PresenceStatus.offline));
}

test "RoomType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(chat.RoomType.direct));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(chat.RoomType.group));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(chat.RoomType.channel));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(chat.RoomType.broadcast));
}

test "Permission encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(chat.Permission.read));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(chat.Permission.write));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(chat.Permission.admin));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(chat.Permission.invite));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(chat.Permission.kick));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(chat.Permission.ban));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(chat.Permission.pin));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(chat.Permission.delete_others));
}

test "Event encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(chat.Event.message_sent));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(chat.Event.message_delivered));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(chat.Event.message_read));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(chat.Event.user_joined));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(chat.Event.user_left));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(chat.Event.typing));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(chat.Event.room_created));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create room returns valid slot with correct config" {
    const slot = chat.chat_create_room(2, 100); // Channel, max 100
    try std.testing.expect(slot >= 0);
    defer chat.chat_destroy_room(slot);
    try std.testing.expectEqual(@as(u8, 2), chat.chat_room_type(slot)); // Channel
    try std.testing.expectEqual(@as(u16, 100), chat.chat_max_users(slot));
    try std.testing.expectEqual(@as(u16, 0), chat.chat_user_count(slot));
}

test "create room rejects invalid room type" {
    const slot = chat.chat_create_room(99, 50);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    chat.chat_destroy_room(-1);
    chat.chat_destroy_room(999);
}

// =========================================================================
// Messaging
// =========================================================================

test "send message increments counter" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 0), chat.chat_send_message(slot, 0)); // Text
    try std.testing.expectEqual(@as(u8, 0), chat.chat_send_message(slot, 1)); // Image
    try std.testing.expectEqual(@as(u8, 0), chat.chat_send_message(slot, 7)); // Reply
    try std.testing.expectEqual(@as(u32, 3), chat.chat_message_count(slot));
}

test "send message rejects invalid type" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 1), chat.chat_send_message(slot, 99));
}

test "send message rejects invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), chat.chat_send_message(-1, 0));
}

// =========================================================================
// User management
// =========================================================================

test "join and leave users" {
    const slot = chat.chat_create_room(1, 3); // Group, max 3
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 0), chat.chat_join_user(slot));
    try std.testing.expectEqual(@as(u8, 0), chat.chat_join_user(slot));
    try std.testing.expectEqual(@as(u16, 2), chat.chat_user_count(slot));

    try std.testing.expectEqual(@as(u8, 0), chat.chat_leave_user(slot));
    try std.testing.expectEqual(@as(u16, 1), chat.chat_user_count(slot));
}

test "join rejects when room is full" {
    const slot = chat.chat_create_room(0, 2); // Direct, max 2
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 0), chat.chat_join_user(slot));
    try std.testing.expectEqual(@as(u8, 0), chat.chat_join_user(slot));
    try std.testing.expectEqual(@as(u8, 1), chat.chat_join_user(slot)); // Full
}

test "leave rejects when room is empty" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 1), chat.chat_leave_user(slot));
}

// =========================================================================
// Presence
// =========================================================================

test "set and get presence" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 0), chat.chat_get_presence(slot)); // Online (default)
    try std.testing.expectEqual(@as(u8, 0), chat.chat_set_presence(slot, 2)); // DND
    try std.testing.expectEqual(@as(u8, 2), chat.chat_get_presence(slot));
}

test "set presence rejects invalid tag" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 1), chat.chat_set_presence(slot, 99));
}

// =========================================================================
// Permissions
// =========================================================================

test "default permissions include read and write" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 1), chat.chat_has_permission(slot, 0)); // Read
    try std.testing.expectEqual(@as(u8, 1), chat.chat_has_permission(slot, 1)); // Write
    try std.testing.expectEqual(@as(u8, 0), chat.chat_has_permission(slot, 2)); // Admin (not default)
}

test "grant permission enables it" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 0), chat.chat_has_permission(slot, 5)); // Ban not set
    try std.testing.expectEqual(@as(u8, 0), chat.chat_grant_permission(slot, 5)); // Grant Ban
    try std.testing.expectEqual(@as(u8, 1), chat.chat_has_permission(slot, 5)); // Ban now set
}

test "grant permission rejects invalid tag" {
    const slot = chat.chat_create_room(0, 10);
    defer chat.chat_destroy_room(slot);

    try std.testing.expectEqual(@as(u8, 1), chat.chat_grant_permission(slot, 99));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), chat.chat_room_type(-1));
    try std.testing.expectEqual(@as(u32, 0), chat.chat_message_count(-1));
    try std.testing.expectEqual(@as(u16, 0), chat.chat_user_count(-1));
    try std.testing.expectEqual(@as(u16, 0), chat.chat_max_users(-1));
    try std.testing.expectEqual(@as(u8, 4), chat.chat_get_presence(-1)); // Offline fallback
    try std.testing.expectEqual(@as(u8, 0), chat.chat_has_permission(-1, 0));
}
