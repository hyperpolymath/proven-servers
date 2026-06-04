// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-dds FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Participant lifecycle (create/destroy)
//   - Topic management (create/delete/count)
//   - DataWriter management (create/delete/count)
//   - DataReader management (create/delete/count)
//   - QoS policy enforcement
//   - Sample writing and counting
//   - Leave / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const dds = @import("dds");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), dds.dds_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ReliabilityKind encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dds.ReliabilityKind.best_effort));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dds.ReliabilityKind.reliable));
}

test "DurabilityKind encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dds.DurabilityKind.@"volatile"));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dds.DurabilityKind.transient_local));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dds.DurabilityKind.transient));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dds.DurabilityKind.persistent));
}

test "HistoryKind encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dds.HistoryKind.keep_last));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dds.HistoryKind.keep_all));
}

test "OwnershipKind encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dds.OwnershipKind.shared));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dds.OwnershipKind.exclusive));
}

test "EntityType encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dds.EntityType.participant));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dds.EntityType.publisher));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dds.EntityType.subscriber));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dds.EntityType.topic));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dds.EntityType.data_writer));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dds.EntityType.data_reader));
}

test "ParticipantState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dds.ParticipantState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dds.ParticipantState.joined));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dds.ParticipantState.publishing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dds.ParticipantState.subscribing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dds.ParticipantState.leaving));
}

// =========================================================================
// Participant lifecycle
// =========================================================================

test "create returns valid slot in Joined state" {
    const slot = dds.dds_create(0);
    try std.testing.expect(slot >= 0);
    defer dds.dds_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), dds.dds_state(slot)); // Joined
}

test "destroy is safe with invalid slot" {
    dds.dds_destroy(-1);
    dds.dds_destroy(999);
}

// =========================================================================
// Topic management
// =========================================================================

test "create_topic registers topic with QoS" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const name = "SensorData";
    try std.testing.expectEqual(@as(u8, 0), dds.dds_create_topic(
        slot, name.ptr, name.len, 1, 0, 0, // reliable, volatile, keep_last
    ));
    try std.testing.expectEqual(@as(u32, 1), dds.dds_topic_count(slot));
}

test "create_topic rejects duplicate name" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const name = "SensorData";
    _ = dds.dds_create_topic(slot, name.ptr, name.len, 0, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), dds.dds_create_topic(
        slot, name.ptr, name.len, 0, 0, 0,
    ));
}

test "create_topic rejects invalid reliability" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const name = "Bad";
    try std.testing.expectEqual(@as(u8, 1), dds.dds_create_topic(
        slot, name.ptr, name.len, 99, 0, 0,
    ));
}

test "create_topic rejects invalid durability" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const name = "Bad";
    try std.testing.expectEqual(@as(u8, 1), dds.dds_create_topic(
        slot, name.ptr, name.len, 0, 99, 0,
    ));
}

test "delete_topic removes topic" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const name = "SensorData";
    _ = dds.dds_create_topic(slot, name.ptr, name.len, 0, 0, 0);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_delete_topic(
        slot, name.ptr, name.len,
    ));
    try std.testing.expectEqual(@as(u32, 0), dds.dds_topic_count(slot));
}

test "delete_topic rejects topic with active writer" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const name = "SensorData";
    _ = dds.dds_create_topic(slot, name.ptr, name.len, 0, 0, 0);
    _ = dds.dds_create_writer(slot, name.ptr, name.len);

    try std.testing.expectEqual(@as(u8, 1), dds.dds_delete_topic(
        slot, name.ptr, name.len,
    ));
}

// =========================================================================
// DataWriter management
// =========================================================================

test "create_writer transitions Joined -> Publishing" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 1, 0, 0);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_create_writer(
        slot, topic.ptr, topic.len,
    ));
    try std.testing.expectEqual(@as(u8, 2), dds.dds_state(slot)); // Publishing
    try std.testing.expectEqual(@as(u32, 1), dds.dds_writer_count(slot));
}

test "create_writer rejects non-existent topic" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "NonExistent";
    try std.testing.expectEqual(@as(u8, 1), dds.dds_create_writer(
        slot, topic.ptr, topic.len,
    ));
}

test "delete_writer last writer transitions Publishing -> Joined" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    _ = dds.dds_create_writer(slot, topic.ptr, topic.len);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_delete_writer(
        slot, topic.ptr, topic.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), dds.dds_state(slot)); // Joined
}

// =========================================================================
// DataReader management
// =========================================================================

test "create_reader transitions Joined -> Subscribing" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_create_reader(
        slot, topic.ptr, topic.len,
    ));
    try std.testing.expectEqual(@as(u8, 3), dds.dds_state(slot)); // Subscribing
    try std.testing.expectEqual(@as(u32, 1), dds.dds_reader_count(slot));
}

test "delete_reader last reader transitions Subscribing -> Joined" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    _ = dds.dds_create_reader(slot, topic.ptr, topic.len);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_delete_reader(
        slot, topic.ptr, topic.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), dds.dds_state(slot)); // Joined
}

// =========================================================================
// Sample writing
// =========================================================================

test "write_sample increments counter" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    _ = dds.dds_create_writer(slot, topic.ptr, topic.len);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_write_sample(
        slot, topic.ptr, topic.len,
    ));
    try std.testing.expectEqual(@as(u8, 0), dds.dds_write_sample(
        slot, topic.ptr, topic.len,
    ));
    try std.testing.expectEqual(@as(u64, 2), dds.dds_samples_written(slot));
}

test "write_sample rejects from non-Publishing state" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    // No writer created, so state is still Joined

    try std.testing.expectEqual(@as(u8, 1), dds.dds_write_sample(
        slot, topic.ptr, topic.len,
    ));
}

// =========================================================================
// Leave / Cleanup
// =========================================================================

test "leave transitions Joined -> Leaving" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_leave(slot));
    try std.testing.expectEqual(@as(u8, 4), dds.dds_state(slot)); // Leaving
}

test "leave transitions Publishing -> Leaving" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    _ = dds.dds_create_writer(slot, topic.ptr, topic.len);

    try std.testing.expectEqual(@as(u8, 0), dds.dds_leave(slot));
    try std.testing.expectEqual(@as(u8, 4), dds.dds_state(slot));
}

test "cleanup transitions Leaving -> Idle" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    _ = dds.dds_leave(slot);
    try std.testing.expectEqual(@as(u8, 0), dds.dds_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), dds.dds_state(slot)); // Idle
}

test "cleanup clears topics, writers, readers" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    _ = dds.dds_create_writer(slot, topic.ptr, topic.len);

    _ = dds.dds_leave(slot);
    _ = dds.dds_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), dds.dds_topic_count(slot));
    try std.testing.expectEqual(@as(u32, 0), dds.dds_writer_count(slot));
    try std.testing.expectEqual(@as(u32, 0), dds.dds_reader_count(slot));
    try std.testing.expectEqual(@as(u64, 0), dds.dds_samples_written(slot));
}

test "cleanup rejected from non-Leaving state" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), dds.dds_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "dds_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(0, 1)); // Idle -> Joined
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(1, 2)); // Joined -> Publishing
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(1, 3)); // Joined -> Subscribing
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(2, 1)); // Publishing -> Joined
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(3, 1)); // Subscribing -> Joined
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(2, 3)); // Publishing -> Subscribing
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(3, 2)); // Subscribing -> Publishing
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(1, 4)); // Joined -> Leaving
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(2, 4)); // Publishing -> Leaving
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(3, 4)); // Subscribing -> Leaving
    try std.testing.expectEqual(@as(u8, 1), dds.dds_can_transition(4, 0)); // Leaving -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), dds.dds_can_transition(0, 2)); // Idle -/-> Publishing
    try std.testing.expectEqual(@as(u8, 0), dds.dds_can_transition(4, 1)); // Leaving -/-> Joined
    try std.testing.expectEqual(@as(u8, 0), dds.dds_can_transition(0, 4)); // Idle -/-> Leaving
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), dds.dds_state(-1));
    try std.testing.expectEqual(@as(u32, 0), dds.dds_topic_count(-1));
    try std.testing.expectEqual(@as(u32, 0), dds.dds_writer_count(-1));
    try std.testing.expectEqual(@as(u32, 0), dds.dds_reader_count(-1));
    try std.testing.expectEqual(@as(u64, 0), dds.dds_samples_written(-1));
    try std.testing.expectEqual(@as(u8, 1), dds.dds_leave(-1));
    try std.testing.expectEqual(@as(u8, 1), dds.dds_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot create topic from Idle" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    _ = dds.dds_leave(slot);
    _ = dds.dds_cleanup(slot);
    const name = "Bad";
    try std.testing.expectEqual(@as(u8, 1), dds.dds_create_topic(
        slot, name.ptr, name.len, 0, 0, 0,
    ));
}

test "cannot create writer from Leaving" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    const topic = "SensorData";
    _ = dds.dds_create_topic(slot, topic.ptr, topic.len, 0, 0, 0);
    _ = dds.dds_leave(slot);

    try std.testing.expectEqual(@as(u8, 1), dds.dds_create_writer(
        slot, topic.ptr, topic.len,
    ));
}

test "leave rejected from Idle" {
    const slot = dds.dds_create(0);
    defer dds.dds_destroy(slot);

    _ = dds.dds_leave(slot);
    _ = dds.dds_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), dds.dds_leave(slot));
}
