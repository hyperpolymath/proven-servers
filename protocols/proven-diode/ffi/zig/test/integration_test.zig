// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-diode FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Gateway lifecycle (create/destroy)
//   - Segment management (enqueue/validate/transfer/confirm)
//   - Queue depth and transfer count tracking
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const diode = @import("diode");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), diode.diode_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Direction encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(diode.Direction.high_to_low));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(diode.Direction.low_to_high));
}

test "Protocol encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(diode.Protocol.udp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(diode.Protocol.tcp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(diode.Protocol.file_transfer));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(diode.Protocol.syslog));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(diode.Protocol.snmp));
}

test "ValidationResult encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(diode.ValidationResult.passed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(diode.ValidationResult.format_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(diode.ValidationResult.size_exceeded));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(diode.ValidationResult.policy_blocked));
}

test "GatewayState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(diode.GatewayState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(diode.GatewayState.configured));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(diode.GatewayState.transferring));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(diode.GatewayState.validating));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(diode.GatewayState.shutdown));
}

// =========================================================================
// Gateway lifecycle
// =========================================================================

test "create returns valid slot in Configured state" {
    const slot = diode.diode_create(0, 0); // HighToLow, UDP
    try std.testing.expect(slot >= 0);
    defer diode.diode_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), diode.diode_state(slot)); // Configured
}

test "create rejects invalid direction" {
    const slot = diode.diode_create(99, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid protocol" {
    const slot = diode.diode_create(0, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    diode.diode_destroy(-1);
    diode.diode_destroy(999);
}

// =========================================================================
// Segment management
// =========================================================================

test "enqueue adds a segment to the queue" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    const data = "test-payload";
    try std.testing.expectEqual(@as(u8, 0), diode.diode_enqueue(
        slot, data.ptr, data.len, 0, // CRC32
    ));
    try std.testing.expectEqual(@as(u32, 1), diode.diode_queue_depth(slot));
}

test "enqueue rejects invalid integrity algorithm" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    const data = "test";
    try std.testing.expectEqual(@as(u8, 1), diode.diode_enqueue(
        slot, data.ptr, data.len, 99,
    ));
}

test "validate then transfer then confirm completes transfer" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    const data = "classified-data";
    _ = diode.diode_enqueue(slot, data.ptr, data.len, 1); // SHA256

    // Validate
    try std.testing.expectEqual(@as(u8, 0), diode.diode_validate(slot)); // Passed
    try std.testing.expectEqual(@as(u8, 3), diode.diode_state(slot)); // Validating

    // Transfer
    try std.testing.expectEqual(@as(u8, 0), diode.diode_transfer(slot));
    try std.testing.expectEqual(@as(u8, 2), diode.diode_state(slot)); // Transferring

    // Confirm
    try std.testing.expectEqual(@as(u8, 0), diode.diode_confirm(slot));
    try std.testing.expectEqual(@as(u64, 1), diode.diode_transferred_count(slot));
    try std.testing.expectEqual(@as(u32, 0), diode.diode_queue_depth(slot));
}

test "can_transfer returns 1 from Configured" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transfer(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Configured -> Shutdown" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), diode.diode_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), diode.diode_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    _ = diode.diode_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), diode.diode_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), diode.diode_state(slot)); // Idle
}

test "cleanup clears queue" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    const data = "payload";
    _ = diode.diode_enqueue(slot, data.ptr, data.len, 0);

    _ = diode.diode_shutdown(slot);
    _ = diode.diode_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), diode.diode_queue_depth(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), diode.diode_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "diode_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(0, 1)); // Idle -> Configured
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(1, 3)); // Configured -> Validating
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(3, 2)); // Validating -> Transferring
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(2, 1)); // Transferring -> Configured
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(2, 3)); // Transferring -> Validating

    // Shutdown edges
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(1, 4)); // Configured -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(2, 4)); // Transferring -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(3, 4)); // Validating -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), diode.diode_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), diode.diode_can_transition(0, 2)); // Idle -/-> Transferring
    try std.testing.expectEqual(@as(u8, 0), diode.diode_can_transition(4, 1)); // Shutdown -/-> Configured
    try std.testing.expectEqual(@as(u8, 0), diode.diode_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), diode.diode_state(-1));
    try std.testing.expectEqual(@as(u8, 0), diode.diode_can_transfer(-1));
    try std.testing.expectEqual(@as(u32, 0), diode.diode_queue_depth(-1));
    try std.testing.expectEqual(@as(u64, 0), diode.diode_transferred_count(-1));
    try std.testing.expectEqual(@as(u8, 1), diode.diode_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), diode.diode_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot enqueue from Idle" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    _ = diode.diode_shutdown(slot);
    _ = diode.diode_cleanup(slot);
    const data = "payload";
    try std.testing.expectEqual(@as(u8, 1), diode.diode_enqueue(
        slot, data.ptr, data.len, 0,
    ));
}

test "cannot transfer without validating first" {
    const slot = diode.diode_create(0, 0);
    defer diode.diode_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), diode.diode_transfer(slot));
}
