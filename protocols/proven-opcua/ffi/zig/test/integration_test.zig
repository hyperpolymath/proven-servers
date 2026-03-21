// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-opcua FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Session activation (Connected -> Created -> Activated)
//   - Node management (add/read/write/browse)
//   - Subscription management (create/delete)
//   - Security mode queries
//   - Close / Cleanup transitions
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const opcua = @import("opcua");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), opcua.opcua_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ServiceType encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(opcua.ServiceType.read));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(opcua.ServiceType.write));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(opcua.ServiceType.browse));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(opcua.ServiceType.subscribe));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(opcua.ServiceType.publish));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(opcua.ServiceType.call));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(opcua.ServiceType.create_session));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(opcua.ServiceType.activate_session));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(opcua.ServiceType.close_session));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(opcua.ServiceType.create_subscription));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(opcua.ServiceType.delete_subscription));
}

test "NodeClass encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(opcua.NodeClass.object));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(opcua.NodeClass.variable));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(opcua.NodeClass.method));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(opcua.NodeClass.object_type));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(opcua.NodeClass.variable_type));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(opcua.NodeClass.reference_type));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(opcua.NodeClass.data_type));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(opcua.NodeClass.view));
}

test "StatusCode encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(opcua.StatusCode.good));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(opcua.StatusCode.uncertain));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(opcua.StatusCode.bad));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(opcua.StatusCode.bad_node_id_unknown));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(opcua.StatusCode.bad_attribute_id_invalid));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(opcua.StatusCode.bad_not_readable));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(opcua.StatusCode.bad_not_writable));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(opcua.StatusCode.bad_out_of_range));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(opcua.StatusCode.bad_type_mismatch));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(opcua.StatusCode.bad_session_id_invalid));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(opcua.StatusCode.bad_subscription_id_invalid));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(opcua.StatusCode.bad_timeout));
}

test "SecurityMode encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(opcua.SecurityMode.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(opcua.SecurityMode.sign));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(opcua.SecurityMode.sign_and_encrypt));
}

test "SessionState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(opcua.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(opcua.SessionState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(opcua.SessionState.created));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(opcua.SessionState.activated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(opcua.SessionState.monitoring));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(opcua.SessionState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0); // SecurityMode.None
    try std.testing.expect(slot >= 0);
    defer opcua.opcua_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_state(slot)); // Connected
}

test "create with SignAndEncrypt security mode" {
    const endpoint = "opc.tcp://secure:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 2); // SignAndEncrypt
    try std.testing.expect(slot >= 0);
    defer opcua.opcua_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), opcua.opcua_get_security_mode(slot));
}

test "create rejects empty endpoint" {
    const endpoint = "x";
    const slot = opcua.opcua_create(endpoint.ptr, 0, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid security mode" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    opcua.opcua_destroy(-1);
    opcua.opcua_destroy(999);
}

// =========================================================================
// Session activation
// =========================================================================

test "create_session transitions Connected -> Created" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_create_session(slot));
    try std.testing.expectEqual(@as(u8, 2), opcua.opcua_state(slot)); // Created
}

test "activate_session transitions Created -> Activated" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    _ = opcua.opcua_create_session(slot);
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_activate_session(slot));
    try std.testing.expectEqual(@as(u8, 3), opcua.opcua_state(slot)); // Activated
}

test "activate_session rejects from Connected" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_activate_session(slot));
}

test "create_session rejects from Activated" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_create_session(slot));
}

// =========================================================================
// Node management
// =========================================================================

test "add_node creates node in address space" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Temperature";
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_add_node(slot, 1001, 1, name.ptr, name.len)); // Variable
    try std.testing.expectEqual(@as(u32, 1), opcua.opcua_node_count(slot));
}

test "add_node rejects duplicate node_id" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Sensor";
    _ = opcua.opcua_add_node(slot, 1001, 0, name.ptr, name.len);
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_add_node(slot, 1001, 0, name.ptr, name.len));
}

test "add_node rejects invalid node class" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Bad";
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_add_node(slot, 9999, 99, name.ptr, name.len));
}

test "read_node succeeds for existing node" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Pressure";
    _ = opcua.opcua_add_node(slot, 2001, 1, name.ptr, name.len); // Variable
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_read_node(slot, 2001, 13));
}

test "read_node rejects for missing node" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_read_node(slot, 9999, 13));
}

test "write_node succeeds for Variable nodes" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "SetPoint";
    _ = opcua.opcua_add_node(slot, 3001, 1, name.ptr, name.len); // Variable
    const value = "42.5";
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_write_node(slot, 3001, 13, value.ptr, value.len));
}

test "write_node rejects for Object nodes" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Folder";
    _ = opcua.opcua_add_node(slot, 4001, 0, name.ptr, name.len); // Object
    const value = "nope";
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_write_node(slot, 4001, 13, value.ptr, value.len));
}

test "browse succeeds for existing node" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Root";
    _ = opcua.opcua_add_node(slot, 85, 0, name.ptr, name.len);
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_browse(slot, 85));
}

// =========================================================================
// Subscription management
// =========================================================================

test "create_subscription transitions Activated -> Monitoring" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_create_subscription(slot, 500));
    try std.testing.expectEqual(@as(u8, 4), opcua.opcua_state(slot)); // Monitoring
    try std.testing.expectEqual(@as(u32, 1), opcua.opcua_subscription_count(slot));
}

test "delete_subscription last transitions Monitoring -> Activated" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    _ = opcua.opcua_create_subscription(slot, 500);
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_delete_subscription(slot, 1));
    try std.testing.expectEqual(@as(u8, 3), opcua.opcua_state(slot)); // Activated
    try std.testing.expectEqual(@as(u32, 0), opcua.opcua_subscription_count(slot));
}

test "multiple subscriptions stay in Monitoring" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    _ = opcua.opcua_create_subscription(slot, 500);
    _ = opcua.opcua_create_subscription(slot, 1000);
    try std.testing.expectEqual(@as(u32, 2), opcua.opcua_subscription_count(slot));

    // Delete first, stays Monitoring
    _ = opcua.opcua_delete_subscription(slot, 1);
    try std.testing.expectEqual(@as(u8, 4), opcua.opcua_state(slot)); // Still Monitoring
}

test "delete_subscription rejects invalid sub_id" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_delete_subscription(slot, 999));
}

// =========================================================================
// Close / Cleanup
// =========================================================================

test "close transitions Connected -> Closing" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_close(slot));
    try std.testing.expectEqual(@as(u8, 5), opcua.opcua_state(slot)); // Closing
}

test "close transitions Monitoring -> Closing" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);
    _ = opcua.opcua_create_subscription(slot, 500);

    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_close(slot));
    try std.testing.expectEqual(@as(u8, 5), opcua.opcua_state(slot));
}

test "cleanup transitions Closing -> Idle" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    _ = opcua.opcua_close(slot);
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_state(slot)); // Idle
}

test "cleanup clears nodes and subscriptions" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);
    _ = opcua.opcua_create_session(slot);
    _ = opcua.opcua_activate_session(slot);

    const name = "Temp";
    _ = opcua.opcua_add_node(slot, 1, 1, name.ptr, name.len);
    _ = opcua.opcua_create_subscription(slot, 500);

    _ = opcua.opcua_close(slot);
    _ = opcua.opcua_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), opcua.opcua_node_count(slot));
    try std.testing.expectEqual(@as(u32, 0), opcua.opcua_subscription_count(slot));
}

test "cleanup rejected from non-Closing state" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "opcua_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(1, 2)); // Connected -> Created
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(2, 3)); // Created -> Activated
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(3, 4)); // Activated -> Monitoring
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(4, 4)); // Monitoring -> Monitoring
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(4, 3)); // Monitoring -> Activated

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(1, 5)); // Connected -> Closing
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(2, 5)); // Created -> Closing
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(3, 5)); // Activated -> Closing
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(4, 5)); // Monitoring -> Closing
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_can_transition(5, 0)); // Closing -> Idle

    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_can_transition(0, 2)); // Idle -/-> Created
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_can_transition(0, 3)); // Idle -/-> Activated
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_can_transition(5, 1)); // Closing -/-> Connected
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_can_transition(1, 3)); // Connected -/-> Activated
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot read from Connected state" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_read_node(slot, 1, 13));
}

test "cannot create subscription from Connected" {
    const endpoint = "opc.tcp://localhost:4840";
    const slot = opcua.opcua_create(endpoint.ptr, endpoint.len, 0);
    defer opcua.opcua_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_create_subscription(slot, 500));
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), opcua.opcua_state(-1));
    try std.testing.expectEqual(@as(u32, 0), opcua.opcua_node_count(-1));
    try std.testing.expectEqual(@as(u32, 0), opcua.opcua_subscription_count(-1));
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_close(-1));
    try std.testing.expectEqual(@as(u8, 1), opcua.opcua_cleanup(-1));
}
