// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// graphql_test.zig -- Integration tests for proven-graphql FFI.
//
// Verifies that the Zig FFI implementation matches the Idris2 ABI
// definitions exactly: tag encodings, transition tables, lifecycle
// invariants, introspection rules, batch queries, and limit checks.

const std = @import("std");
const gql = @import("graphql");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), gql.graphql_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "OperationType encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.OperationType.query));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.OperationType.mutation));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.OperationType.subscription));
}

test "TypeKind encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.TypeKind.scalar));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.TypeKind.object));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.TypeKind.interface));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gql.TypeKind.@"union"));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gql.TypeKind.@"enum"));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(gql.TypeKind.input_object));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(gql.TypeKind.list));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(gql.TypeKind.non_null));
}

test "ScalarKind encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.ScalarKind.gql_int));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.ScalarKind.gql_float));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.ScalarKind.gql_string));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gql.ScalarKind.gql_boolean));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gql.ScalarKind.gql_id));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(gql.ScalarKind.gql_custom));
}

test "DirectiveLocation encoding matches Layout.idr (18 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.DirectiveLocation.query_loc));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(gql.DirectiveLocation.schema));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(gql.DirectiveLocation.field_definition));
    try std.testing.expectEqual(@as(u8, 17), @intFromEnum(gql.DirectiveLocation.input_field_definition));
}

test "ErrorCategory encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.ErrorCategory.parse_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.ErrorCategory.validation_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.ErrorCategory.execution_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gql.ErrorCategory.auth_error));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gql.ErrorCategory.rate_limited));
}

test "RequestPhase encoding matches Transitions.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.RequestPhase.parse));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.RequestPhase.validate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.RequestPhase.execute));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gql.RequestPhase.resolve));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gql.RequestPhase.serialize));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(gql.RequestPhase.failed));
}

test "SubscriptionPhase encoding matches Transitions.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.SubscriptionPhase.subscribe));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.SubscriptionPhase.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.SubscriptionPhase.unsubscribe));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gql.SubscriptionPhase.sub_failed));
}

test "IntrospectionField encoding matches Introspection.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.IntrospectionField.schema_field));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.IntrospectionField.type_field));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.IntrospectionField.typename_field));
}

test "BatchQueryStatus encoding matches Query.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gql.BatchQueryStatus.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gql.BatchQueryStatus.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gql.BatchQueryStatus.complete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gql.BatchQueryStatus.bq_failed));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot for query" {
    const slot = gql.graphql_create(0); // Query
    try std.testing.expect(slot >= 0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_phase(slot)); // parse
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_operation_type(slot)); // query
}

test "create returns valid slot for mutation" {
    const slot = gql.graphql_create(1); // Mutation
    try std.testing.expect(slot >= 0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_operation_type(slot)); // mutation
}

test "create rejects invalid operation type" {
    try std.testing.expectEqual(@as(c_int, -1), gql.graphql_create(99));
}

test "destroy is safe with invalid slot" {
    gql.graphql_destroy(-1);
    gql.graphql_destroy(999);
}

// =========================================================================
// Valid transitions -- full request lifecycle
// =========================================================================

test "full lifecycle: Parse -> Validate -> Execute -> Resolve -> Serialize" {
    const slot = gql.graphql_create(0); // Query
    defer gql.graphql_destroy(slot);

    // Parse -> Validate
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_advance(slot));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_phase(slot));

    // Validate -> Execute
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_advance(slot));
    try std.testing.expectEqual(@as(u8, 2), gql.graphql_phase(slot));

    // Execute -> Resolve
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_advance(slot));
    try std.testing.expectEqual(@as(u8, 3), gql.graphql_phase(slot));

    // Resolve -> Serialize
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_advance(slot));
    try std.testing.expectEqual(@as(u8, 4), gql.graphql_phase(slot));

    // Cannot advance past Serialize
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_advance(slot));
}

// =========================================================================
// Abort transitions
// =========================================================================

test "abort from Parse with ParseError" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_abort(slot, 0)); // parse_error
    try std.testing.expectEqual(@as(u8, 5), gql.graphql_phase(slot)); // failed
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_error_category(slot));
}

test "abort from Validate with ValidationError" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_advance(slot); // -> Validate
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_abort(slot, 1)); // validation_error
    try std.testing.expectEqual(@as(u8, 5), gql.graphql_phase(slot));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_error_category(slot));
}

test "abort from Resolve with AuthError" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_advance(slot); // -> Validate
    _ = gql.graphql_advance(slot); // -> Execute
    _ = gql.graphql_advance(slot); // -> Resolve
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_abort(slot, 3)); // auth_error
    try std.testing.expectEqual(@as(u8, 5), gql.graphql_phase(slot));
}

test "cannot abort from Serialize (terminal)" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_advance(slot); // -> Validate
    _ = gql.graphql_advance(slot); // -> Execute
    _ = gql.graphql_advance(slot); // -> Resolve
    _ = gql.graphql_advance(slot); // -> Serialize
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_abort(slot, 2)); // rejected
}

test "cannot abort from Failed (terminal)" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_abort(slot, 0); // -> Failed
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_abort(slot, 0)); // rejected
}

test "abort rejects invalid error category tag" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_abort(slot, 99));
}

// =========================================================================
// Query parser state
// =========================================================================

test "set and get query depth" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u16, 0), gql.graphql_query_depth(slot));
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_set_query_depth(slot, 12));
    try std.testing.expectEqual(@as(u16, 12), gql.graphql_query_depth(slot));
}

test "set and get complexity" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u16, 0), gql.graphql_complexity(slot));
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_set_complexity(slot, 500));
    try std.testing.expectEqual(@as(u16, 500), gql.graphql_complexity(slot));
}

// =========================================================================
// Field resolver
// =========================================================================

test "resolve_field increments counter in Resolve phase" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_advance(slot); // -> Validate
    _ = gql.graphql_advance(slot); // -> Execute
    _ = gql.graphql_advance(slot); // -> Resolve

    // Resolve a Scalar(Int) field
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_resolve_field(slot, 0, 0));
    try std.testing.expectEqual(@as(u16, 1), gql.graphql_fields_resolved(slot));

    // Resolve an Object field (scalar_kind ignored for non-Scalar)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_resolve_field(slot, 1, 255));
    try std.testing.expectEqual(@as(u16, 2), gql.graphql_fields_resolved(slot));
}

test "resolve_field rejected outside Resolve phase" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    // Still in Parse phase
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_resolve_field(slot, 0, 0));
}

test "resolve_field rejects invalid type_kind" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_advance(slot); // -> Validate
    _ = gql.graphql_advance(slot); // -> Execute
    _ = gql.graphql_advance(slot); // -> Resolve
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_resolve_field(slot, 99, 0));
}

test "resolve_field rejects invalid scalar_kind for Scalar type" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_advance(slot); // -> Validate
    _ = gql.graphql_advance(slot); // -> Execute
    _ = gql.graphql_advance(slot); // -> Resolve
    // type_kind=0 (Scalar) but scalar_kind=99 (invalid)
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_resolve_field(slot, 0, 99));
}

// =========================================================================
// Stateless request transition table
// =========================================================================

test "graphql_can_transition matches Transitions.idr" {
    // Forward pipeline
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(0, 1)); // Parse -> Validate
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(1, 2)); // Validate -> Execute
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(2, 3)); // Execute -> Resolve
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(3, 4)); // Resolve -> Serialize

    // Abort edges
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(0, 5)); // Parse -> Failed
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(1, 5)); // Validate -> Failed
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(2, 5)); // Execute -> Failed
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_can_transition(3, 5)); // Resolve -> Failed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_can_transition(4, 0)); // Serialize -> Parse (terminal!)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_can_transition(5, 0)); // Failed -> Parse (terminal!)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_can_transition(0, 3)); // Parse -> Resolve (skip!)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_can_transition(0, 4)); // Parse -> Serialize (skip!)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_can_transition(3, 0)); // Resolve -> Parse (backwards!)
}

// =========================================================================
// Subscription lifecycle
// =========================================================================

test "subscription create requires subscription operation type" {
    const slot = gql.graphql_create(0); // Query, not Subscription
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(c_int, -1), gql.graphql_sub_create(slot));
}

test "subscription full lifecycle: Subscribe -> Active -> Unsubscribe" {
    const slot = gql.graphql_create(2); // Subscription
    defer gql.graphql_destroy(slot);

    const sub_id = gql.graphql_sub_create(slot);
    try std.testing.expect(sub_id >= 0);

    // Subscribe phase
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_phase(slot));

    // Subscribe -> Active
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_advance(slot));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_phase(slot));

    // Active -> Active (emit events via dedicated function)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_emit_event(slot));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_phase(slot));
    try std.testing.expectEqual(@as(u32, 1), gql.graphql_sub_event_count(slot));

    // Another event
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_emit_event(slot));
    try std.testing.expectEqual(@as(u32, 2), gql.graphql_sub_event_count(slot));

    // Active -> Unsubscribe (graceful close via advance)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_advance(slot));
    try std.testing.expectEqual(@as(u8, 2), gql.graphql_sub_phase(slot)); // unsubscribe

    // Cannot advance past Unsubscribe (terminal)
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_advance(slot));
}

test "sub_emit_event rejected outside Active phase" {
    const slot = gql.graphql_create(2);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_sub_create(slot);
    // Still in Subscribe phase
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_emit_event(slot));
}

test "subscription abort from Subscribe" {
    const slot = gql.graphql_create(2);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_sub_create(slot);

    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_abort(slot));
    try std.testing.expectEqual(@as(u8, 3), gql.graphql_sub_phase(slot)); // sub_failed
}

test "subscription abort from Active" {
    const slot = gql.graphql_create(2);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_sub_create(slot);
    _ = gql.graphql_sub_advance(slot); // -> Active

    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_abort(slot));
    try std.testing.expectEqual(@as(u8, 3), gql.graphql_sub_phase(slot)); // sub_failed
}

test "subscription cannot abort from SubFailed (terminal)" {
    const slot = gql.graphql_create(2);
    defer gql.graphql_destroy(slot);
    _ = gql.graphql_sub_create(slot);
    _ = gql.graphql_sub_abort(slot); // -> SubFailed
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_abort(slot)); // rejected
}

test "subscription cannot create twice" {
    const slot = gql.graphql_create(2);
    defer gql.graphql_destroy(slot);
    const first = gql.graphql_sub_create(slot);
    try std.testing.expect(first >= 0);
    try std.testing.expectEqual(@as(c_int, -1), gql.graphql_sub_create(slot)); // rejected
}

// =========================================================================
// Stateless subscription transition table
// =========================================================================

test "graphql_sub_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_can_transition(0, 1)); // Subscribe -> Active
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_can_transition(1, 1)); // Active -> Active
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_can_transition(1, 2)); // Active -> Unsubscribe
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_can_transition(0, 3)); // Subscribe -> SubFailed
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_sub_can_transition(1, 3)); // Active -> SubFailed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_can_transition(2, 0)); // Unsubscribe -> Subscribe (terminal!)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_can_transition(3, 0)); // SubFailed -> Subscribe (terminal!)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_sub_can_transition(0, 2)); // Subscribe -> Unsubscribe (skip!)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 5), gql.graphql_phase(-1)); // failed fallback
    try std.testing.expectEqual(@as(u8, 255), gql.graphql_operation_type(-1));
    try std.testing.expectEqual(@as(u8, 255), gql.graphql_error_category(-1));
    try std.testing.expectEqual(@as(u16, 0), gql.graphql_query_depth(-1));
    try std.testing.expectEqual(@as(u16, 0), gql.graphql_complexity(-1));
    try std.testing.expectEqual(@as(u16, 0), gql.graphql_fields_resolved(-1));
    try std.testing.expectEqual(@as(u8, 3), gql.graphql_sub_phase(-1)); // sub_failed fallback
    try std.testing.expectEqual(@as(u32, 0), gql.graphql_sub_event_count(-1));
}

// =========================================================================
// Cannot skip request phases
// =========================================================================

test "cannot skip from Parse to Resolve" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    // After one advance we are at Validate(1), not Resolve(3)
    _ = gql.graphql_advance(slot);
    try std.testing.expect(gql.graphql_phase(slot) != 3);
}

test "error category initially unset" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), gql.graphql_error_category(slot));
}

// =========================================================================
// Introspection (matches Introspection.idr CanIntrospect)
// =========================================================================

test "__schema valid on Query operation" {
    const slot = gql.graphql_create(0); // Query
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_introspection_query(slot, 0)); // __schema
}

test "__type valid on Query operation" {
    const slot = gql.graphql_create(0); // Query
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_introspection_query(slot, 1)); // __type
}

test "__typename valid on any operation" {
    const query_slot = gql.graphql_create(0);
    defer gql.graphql_destroy(query_slot);
    const mut_slot = gql.graphql_create(1);
    defer gql.graphql_destroy(mut_slot);
    const sub_slot = gql.graphql_create(2);
    defer gql.graphql_destroy(sub_slot);

    try std.testing.expectEqual(@as(u8, 0), gql.graphql_introspection_query(query_slot, 2));
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_introspection_query(mut_slot, 2));
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_introspection_query(sub_slot, 2));
}

test "__schema rejected on Mutation operation" {
    const slot = gql.graphql_create(1); // Mutation
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_introspection_query(slot, 0)); // __schema
}

test "__type rejected on Mutation operation" {
    const slot = gql.graphql_create(1); // Mutation
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_introspection_query(slot, 1)); // __type
}

test "__schema rejected on Subscription operation" {
    const slot = gql.graphql_create(2); // Subscription
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_introspection_query(slot, 0)); // __schema
}

test "__type rejected on Subscription operation" {
    const slot = gql.graphql_create(2); // Subscription
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_introspection_query(slot, 1)); // __type
}

test "introspection rejects invalid field tag" {
    const slot = gql.graphql_create(0);
    defer gql.graphql_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_introspection_query(slot, 99));
}

test "introspection rejects invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_introspection_query(-1, 0));
}

// =========================================================================
// Batch query support (matches Query.idr batch types)
// =========================================================================

test "batch create with valid count" {
    const batch_id = gql.graphql_batch_create(3);
    try std.testing.expect(batch_id >= 0);
    defer gql.graphql_batch_destroy(batch_id);

    // Initial status: all pending
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_status(batch_id)); // pending
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_query_status(batch_id, 0)); // pending
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_query_status(batch_id, 1)); // pending
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_query_status(batch_id, 2)); // pending
}

test "batch create rejects zero count" {
    try std.testing.expectEqual(@as(c_int, -1), gql.graphql_batch_create(0));
}

test "batch create rejects count exceeding max" {
    try std.testing.expectEqual(@as(c_int, -1), gql.graphql_batch_create(17));
}

test "batch set operation type" {
    const batch_id = gql.graphql_batch_create(2);
    defer gql.graphql_batch_destroy(batch_id);

    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_set_op(batch_id, 0, 0)); // query
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_set_op(batch_id, 1, 1)); // mutation
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_batch_set_op(batch_id, 2, 0)); // out of bounds
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_batch_set_op(batch_id, 0, 99)); // invalid op
}

test "batch advance lifecycle: pending -> running -> complete" {
    const batch_id = gql.graphql_batch_create(2);
    defer gql.graphql_batch_destroy(batch_id);

    // Start first query (pending -> running)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_advance(batch_id));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_batch_query_status(batch_id, 0)); // running
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_query_status(batch_id, 1)); // pending
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_batch_status(batch_id)); // running

    // Complete first query (running -> complete)
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_advance(batch_id));
    try std.testing.expectEqual(@as(u8, 2), gql.graphql_batch_query_status(batch_id, 0)); // complete

    // Start second query
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_advance(batch_id));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_batch_query_status(batch_id, 1)); // running

    // Complete second query
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_batch_advance(batch_id));
    try std.testing.expectEqual(@as(u8, 2), gql.graphql_batch_query_status(batch_id, 1)); // complete

    // Batch is now complete
    try std.testing.expectEqual(@as(u8, 2), gql.graphql_batch_status(batch_id)); // complete

    // No more to advance
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_batch_advance(batch_id)); // rejected
}

test "batch destroy is safe with invalid id" {
    gql.graphql_batch_destroy(-1);
    gql.graphql_batch_destroy(999);
}

test "batch status returns failed fallback for invalid id" {
    try std.testing.expectEqual(@as(u8, 3), gql.graphql_batch_status(-1)); // failed
}

test "batch query status returns failed for out-of-bounds index" {
    const batch_id = gql.graphql_batch_create(1);
    defer gql.graphql_batch_destroy(batch_id);
    try std.testing.expectEqual(@as(u8, 3), gql.graphql_batch_query_status(batch_id, 5));
}

// =========================================================================
// Depth/complexity limit checks (matches Query.idr checkDepth/checkComplexity)
// =========================================================================

test "check_depth within bounds" {
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_check_depth(5, 15));
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_check_depth(15, 15)); // boundary
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_check_depth(0, 15));
}

test "check_depth exceeds bounds" {
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_check_depth(16, 15));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_check_depth(100, 15));
}

test "check_complexity within bounds" {
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_check_complexity(500, 1000));
    try std.testing.expectEqual(@as(u8, 0), gql.graphql_check_complexity(1000, 1000)); // boundary
}

test "check_complexity exceeds bounds" {
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_check_complexity(1001, 1000));
    try std.testing.expectEqual(@as(u8, 1), gql.graphql_check_complexity(5000, 1000));
}
