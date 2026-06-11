// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ldap FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ldap = @import("ldap");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ldap.ldap_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "SessionState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.SessionState.anonymous));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.SessionState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.SessionState.closed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldap.SessionState.binding));
}

test "Operation encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.Operation.bind));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.Operation.unbind));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.Operation.search));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldap.Operation.modify));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ldap.Operation.add));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ldap.Operation.delete));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ldap.Operation.mod_dn));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ldap.Operation.compare));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ldap.Operation.abandon));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ldap.Operation.extended));
}

test "SearchScope encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.SearchScope.base_object));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.SearchScope.single_level));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.SearchScope.whole_subtree));
}

test "ResultCode encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.ResultCode.success));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.ResultCode.operations_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.ResultCode.protocol_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldap.ResultCode.time_limit_exceeded));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ldap.ResultCode.size_limit_exceeded));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ldap.ResultCode.auth_method_not_supported));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ldap.ResultCode.no_such_object));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ldap.ResultCode.invalid_credentials));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ldap.ResultCode.insufficient_access_rights));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ldap.ResultCode.busy));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(ldap.ResultCode.unavailable));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ldap.ldap_create();
    try std.testing.expect(slot >= 0);
    defer ldap.ldap_destroy(slot);
    const state = ldap.ldap_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    ldap.ldap_destroy(-1);
    ldap.ldap_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = ldap.ldap_state(-1);
}

