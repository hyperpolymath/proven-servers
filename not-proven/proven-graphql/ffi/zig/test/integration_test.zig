// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-graphql FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const graphql = @import("graphql");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), graphql.graphql_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "OperationType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.OperationType.query));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.OperationType.mutation));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.OperationType.subscription));
}

test "TypeKind encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.TypeKind.scalar));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.TypeKind.object));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.TypeKind.interface));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(graphql.TypeKind.input_object));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(graphql.TypeKind.list));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(graphql.TypeKind.non_null));
}

test "ScalarKind encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.ScalarKind.gql_int));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.ScalarKind.gql_float));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.ScalarKind.gql_string));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(graphql.ScalarKind.gql_boolean));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(graphql.ScalarKind.gql_id));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(graphql.ScalarKind.gql_custom));
}

test "DirectiveLocation encoding matches Types.idr (18 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.DirectiveLocation.query_loc));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.DirectiveLocation.mutation_loc));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.DirectiveLocation.subscription_loc));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(graphql.DirectiveLocation.field));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(graphql.DirectiveLocation.fragment_definition));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(graphql.DirectiveLocation.fragment_spread));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(graphql.DirectiveLocation.inline_fragment));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(graphql.DirectiveLocation.schema));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(graphql.DirectiveLocation.scalar_loc));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(graphql.DirectiveLocation.object_loc));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(graphql.DirectiveLocation.field_definition));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(graphql.DirectiveLocation.argument_definition));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(graphql.DirectiveLocation.interface_loc));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(graphql.DirectiveLocation.union_loc));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(graphql.DirectiveLocation.enum_loc));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(graphql.DirectiveLocation.enum_value));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(graphql.DirectiveLocation.input_object_loc));
    try std.testing.expectEqual(@as(u8, 17), @intFromEnum(graphql.DirectiveLocation.input_field_definition));
}

test "ErrorCategory encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.ErrorCategory.parse_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.ErrorCategory.validation_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.ErrorCategory.execution_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(graphql.ErrorCategory.auth_error));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(graphql.ErrorCategory.rate_limited));
}

test "RequestPhase encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.RequestPhase.parse));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.RequestPhase.validate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.RequestPhase.execute));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(graphql.RequestPhase.resolve));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(graphql.RequestPhase.serialize));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(graphql.RequestPhase.failed));
}

test "SubscriptionPhase encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.SubscriptionPhase.subscribe));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.SubscriptionPhase.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.SubscriptionPhase.unsubscribe));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(graphql.SubscriptionPhase.sub_failed));
}

test "IntrospectionField encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.IntrospectionField.schema_field));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.IntrospectionField.type_field));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.IntrospectionField.typename_field));
}

test "BatchQueryStatus encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(graphql.BatchQueryStatus.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(graphql.BatchQueryStatus.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(graphql.BatchQueryStatus.complete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(graphql.BatchQueryStatus.bq_failed));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = graphql.graphql_batch_create(0);
    try std.testing.expect(slot >= 0);
    defer graphql.graphql_batch_destroy(slot);
}

test "destroy is safe with invalid slot" {
    graphql.graphql_batch_destroy(-1);
    graphql.graphql_batch_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), graphql.graphql_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), graphql.graphql_can_transition(0, 0)); // self-loop
}

