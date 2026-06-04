// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-modbus FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Gateway lifecycle (create/destroy)
//   - Listen (Idle -> Listening)
//   - Read coils / Read holding registers
//   - Write coil / Write register
//   - Transaction completion (Processing -> Listening)
//   - Error reporting and recovery
//   - Register file read-back
//   - Stop / Cleanup
//   - Stateless gateway transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const modbus = @import("modbus");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), modbus.modbus_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "FunctionCode encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(modbus.FunctionCode.read_coils));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(modbus.FunctionCode.read_discrete_inputs));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(modbus.FunctionCode.read_holding_registers));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(modbus.FunctionCode.read_input_registers));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(modbus.FunctionCode.write_single_coil));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(modbus.FunctionCode.write_single_register));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(modbus.FunctionCode.write_multiple_coils));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(modbus.FunctionCode.write_multiple_registers));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(modbus.FunctionCode.read_write_multiple_registers));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(modbus.FunctionCode.mask_write_register));
}

test "ExceptionCode encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(modbus.ExceptionCode.illegal_function));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(modbus.ExceptionCode.illegal_data_address));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(modbus.ExceptionCode.illegal_data_value));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(modbus.ExceptionCode.slave_device_failure));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(modbus.ExceptionCode.acknowledge));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(modbus.ExceptionCode.slave_device_busy));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(modbus.ExceptionCode.memory_parity_error));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(modbus.ExceptionCode.gateway_path_unavailable));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(modbus.ExceptionCode.gateway_target_device_failed));
}

test "DeviceRole encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(modbus.DeviceRole.master));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(modbus.DeviceRole.slave));
}

test "GatewayState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(modbus.GatewayState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(modbus.GatewayState.listening));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(modbus.GatewayState.processing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(modbus.GatewayState.err));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(modbus.GatewayState.stopping));
}

// =========================================================================
// Gateway lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const slot = modbus.modbus_create(1, 1); // unit_id=1, slave
    try std.testing.expect(slot >= 0);
    defer modbus.modbus_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_state(slot)); // Idle
}

test "create rejects unit_id 0" {
    try std.testing.expectEqual(@as(c_int, -1), modbus.modbus_create(0, 1));
}

test "create rejects invalid role" {
    try std.testing.expectEqual(@as(c_int, -1), modbus.modbus_create(1, 99));
}

test "destroy is safe with invalid slot" {
    modbus.modbus_destroy(-1);
    modbus.modbus_destroy(999);
}

// =========================================================================
// Listen
// =========================================================================

test "listen transitions Idle -> Listening" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_listen(slot, 502));
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_state(slot)); // Listening
}

test "listen rejects port 0" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_listen(slot, 0));
}

test "listen rejected from non-Idle" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    _ = modbus.modbus_listen(slot, 502);
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_listen(slot, 502));
}

// =========================================================================
// Read/Write operations
// =========================================================================

test "read_coils transitions Listening -> Processing" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_read_coils(slot, 0, 10));
    try std.testing.expectEqual(@as(u8, 2), modbus.modbus_state(slot)); // Processing
    try std.testing.expectEqual(@as(u32, 1), modbus.modbus_pending_count(slot));
}

test "read_coils rejects out-of-range address" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_read_coils(slot, 250, 10));
}

test "read_coils rejects zero count" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_read_coils(slot, 0, 0));
}

test "read_holding transitions Listening -> Processing" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_read_holding(slot, 0, 5));
    try std.testing.expectEqual(@as(u8, 2), modbus.modbus_state(slot));
}

test "write_coil sets coil and transitions to Processing" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_write_coil(slot, 5, 1));
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_get_coil(slot, 5));
}

test "write_register sets register and transitions to Processing" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_write_register(slot, 10, 42));
    try std.testing.expectEqual(@as(u16, 42), modbus.modbus_get_register(slot, 10));
}

// =========================================================================
// Transaction completion
// =========================================================================

test "complete_transaction transitions Processing -> Listening when last" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    _ = modbus.modbus_read_coils(slot, 0, 1);
    try std.testing.expectEqual(@as(u32, 1), modbus.modbus_pending_count(slot));

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_complete_transaction(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_state(slot)); // Listening
    try std.testing.expectEqual(@as(u32, 0), modbus.modbus_pending_count(slot));
}

test "multiple transactions stay Processing until all complete" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    _ = modbus.modbus_read_coils(slot, 0, 1);
    _ = modbus.modbus_read_holding(slot, 0, 1);
    try std.testing.expectEqual(@as(u32, 2), modbus.modbus_pending_count(slot));

    _ = modbus.modbus_complete_transaction(slot, 1);
    try std.testing.expectEqual(@as(u8, 2), modbus.modbus_state(slot)); // Still Processing
}

// =========================================================================
// Error reporting and recovery
// =========================================================================

test "report_error transitions Listening -> Error" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_report_error(slot, 0)); // IllegalFunction
    try std.testing.expectEqual(@as(u8, 3), modbus.modbus_state(slot)); // Error
}

test "recover transitions Error -> Listening" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);
    _ = modbus.modbus_report_error(slot, 0);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_recover(slot));
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_state(slot)); // Listening
}

test "recover rejected from non-Error" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_recover(slot));
}

test "report_error rejects invalid exception code" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_report_error(slot, 99));
}

// =========================================================================
// Stop / Cleanup
// =========================================================================

test "stop transitions Listening -> Stopping" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_stop(slot));
    try std.testing.expectEqual(@as(u8, 4), modbus.modbus_state(slot)); // Stopping
}

test "cleanup transitions Stopping -> Idle" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);
    _ = modbus.modbus_stop(slot);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 0), modbus.modbus_pending_count(slot));
}

test "cleanup rejected from non-Stopping" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_cleanup(slot));
}

test "stop rejected from Idle" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_stop(slot));
}

// =========================================================================
// Register file read-back
// =========================================================================

test "get_coil returns 0 for unset coil" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_get_coil(slot, 0));
}

test "get_register returns 0 for unset register" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u16, 0), modbus.modbus_get_register(slot, 0));
}

test "write_coil normalizes nonzero to 1" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);
    _ = modbus.modbus_listen(slot, 502);

    _ = modbus.modbus_write_coil(slot, 0, 255);
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_get_coil(slot, 0));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "modbus_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(0, 1)); // Idle -> Listening
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(1, 2)); // Listening -> Processing
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(2, 2)); // Processing -> Processing
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(2, 1)); // Processing -> Listening
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(1, 3)); // Listening -> Error
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(2, 3)); // Processing -> Error
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(3, 1)); // Error -> Listening
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(1, 4)); // Listening -> Stopping
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(2, 4)); // Processing -> Stopping
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(3, 4)); // Error -> Stopping
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_can_transition(4, 0)); // Stopping -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_can_transition(0, 2)); // Idle -/-> Processing
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_can_transition(0, 3)); // Idle -/-> Error
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_can_transition(4, 1)); // Stopping -/-> Listening
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_can_transition(0, 4)); // Idle -/-> Stopping
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_state(-1));
    try std.testing.expectEqual(@as(u32, 0), modbus.modbus_pending_count(-1));
    try std.testing.expectEqual(@as(u8, 0), modbus.modbus_get_coil(-1, 0));
    try std.testing.expectEqual(@as(u16, 0), modbus.modbus_get_register(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_stop(-1));
    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot read_coils from Idle" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_read_coils(slot, 0, 1));
}

test "cannot write_register from Idle" {
    const slot = modbus.modbus_create(1, 1);
    defer modbus.modbus_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), modbus.modbus_write_register(slot, 0, 42));
}
