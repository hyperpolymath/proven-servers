// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// graphql.zig -- Zig FFI implementation of proven-graphql.
//
// Implements verified GraphQL request lifecycle state machine with:
//   - 64-slot context pool for concurrent request handling
//   - Request phase enforcement matching Idris2 Transitions.idr
//   - Subscription lifecycle management (Subscribe -> Active -> Unsubscribe)
//   - Query parser state tracking (depth, complexity)
//   - Field resolver counting with type/scalar kind recording
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching GraphQLABI.Layout.idr tag assignments) -------------------

/// GraphQL root operation types (3 tags, 0-2).
pub const OperationType = enum(u8) {
    query = 0,
    mutation = 1,
    subscription = 2,
};

/// GraphQL type system kinds (8 tags, 0-7).
pub const TypeKind = enum(u8) {
    scalar = 0,
    object = 1,
    interface = 2,
    @"union" = 3,
    @"enum" = 4,
    input_object = 5,
    list = 6,
    non_null = 7,
};

/// Built-in and custom scalar types (6 tags, 0-5).
pub const ScalarKind = enum(u8) {
    gql_int = 0,
    gql_float = 1,
    gql_string = 2,
    gql_boolean = 3,
    gql_id = 4,
    gql_custom = 5,
};

/// Directive locations (18 tags, 0-17).
pub const DirectiveLocation = enum(u8) {
    query_loc = 0,
    mutation_loc = 1,
    subscription_loc = 2,
    field = 3,
    fragment_definition = 4,
    fragment_spread = 5,
    inline_fragment = 6,
    schema = 7,
    scalar_loc = 8,
    object_loc = 9,
    field_definition = 10,
    argument_definition = 11,
    interface_loc = 12,
    union_loc = 13,
    enum_loc = 14,
    enum_value = 15,
    input_object_loc = 16,
    input_field_definition = 17,
};

/// Error categories (5 tags, 0-4).
pub const ErrorCategory = enum(u8) {
    parse_error = 0,
    validation_error = 1,
    execution_error = 2,
    auth_error = 3,
    rate_limited = 4,
};

/// Request lifecycle phases (6 tags, 0-5).
pub const RequestPhase = enum(u8) {
    parse = 0,
    validate = 1,
    execute = 2,
    resolve = 3,
    serialize = 4,
    failed = 5,
};

/// Subscription lifecycle phases (4 tags, 0-3).
pub const SubscriptionPhase = enum(u8) {
    subscribe = 0,
    active = 1,
    unsubscribe = 2,
    sub_failed = 3,
};

// -- GraphQL context ----------------------------------------------------------

const Context = struct {
    phase: RequestPhase,
    op_type: OperationType,
    error_cat: u8, // 255 = no error
    query_depth: u16, // 0 = not yet set
    complexity: u16, // 0 = not yet set
    fields_resolved: u16,
    // Subscription state (only meaningful when op_type == .subscription)
    sub_phase: SubscriptionPhase,
    sub_event_count: u32,
    sub_active: bool, // whether subscription has been created
    active: bool,
};

const MAX_CONTEXTS: usize = 64;
var contexts: [MAX_CONTEXTS]Context = [_]Context{.{
    .phase = .parse,
    .op_type = .query,
    .error_cat = 255,
    .query_depth = 0,
    .complexity = 0,
    .fields_resolved = 0,
    .sub_phase = .subscribe,
    .sub_event_count = 0,
    .sub_active = false,
    .active = false,
}} ** MAX_CONTEXTS;

var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- Next phase in the request lifecycle --------------------------------------

fn nextPhase(p: RequestPhase) ?RequestPhase {
    return switch (p) {
        .parse => .validate,
        .validate => .execute,
        .execute => .resolve,
        .resolve => .serialize,
        .serialize, .failed => null,
    };
}

// -- Next phase in the subscription lifecycle ---------------------------------

fn nextSubPhase(p: SubscriptionPhase) ?SubscriptionPhase {
    return switch (p) {
        .subscribe => .active,
        .active => .unsubscribe,
        .unsubscribe, .sub_failed => null,
    };
}

// -- ABI version --------------------------------------------------------------

pub export fn graphql_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

pub export fn graphql_create(op_type: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (op_type > 2) return -1;
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = .{
                .phase = .parse,
                .op_type = @enumFromInt(op_type),
                .error_cat = 255,
                .query_depth = 0,
                .complexity = 0,
                .fields_resolved = 0,
                .sub_phase = .subscribe,
                .sub_event_count = 0,
                .sub_active = false,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn graphql_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)].active = false;
}

// -- State queries ------------------------------------------------------------

pub export fn graphql_phase(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5; // failed as fallback
    return @intFromEnum(contexts[idx].phase);
}

pub export fn graphql_operation_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return @intFromEnum(contexts[idx].op_type);
}

pub export fn graphql_error_category(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].error_cat;
}

// -- Request phase transitions ------------------------------------------------

pub export fn graphql_advance(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (nextPhase(contexts[idx].phase)) |np| {
        contexts[idx].phase = np;
        return 0; // accepted
    }
    return 1; // rejected (terminal state)
}

pub export fn graphql_abort(slot: c_int, err_cat: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const phase = contexts[idx].phase;
    // Can abort from Parse, Validate, Execute, Resolve (not Serialize or Failed)
    if (phase == .serialize or phase == .failed) return 1;
    if (err_cat > 4) return 1; // invalid ErrorCategory tag
    contexts[idx].phase = .failed;
    contexts[idx].error_cat = err_cat;
    return 0;
}

// -- Query parser state -------------------------------------------------------

pub export fn graphql_set_query_depth(slot: c_int, depth: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    contexts[idx].query_depth = depth;
    return 0;
}

pub export fn graphql_query_depth(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].query_depth;
}

pub export fn graphql_set_complexity(slot: c_int, score: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    contexts[idx].complexity = score;
    return 0;
}

pub export fn graphql_complexity(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].complexity;
}

// -- Field resolver -----------------------------------------------------------

pub export fn graphql_resolve_field(slot: c_int, type_kind: u8, scalar_kind: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    // Must be in Resolve phase to resolve fields
    if (contexts[idx].phase != .resolve) return 1;
    // Validate type_kind tag (0-7)
    if (type_kind > 7) return 1;
    // scalar_kind only validated when type_kind is Scalar (0)
    if (type_kind == 0 and scalar_kind > 5) return 1;
    contexts[idx].fields_resolved +|= 1; // saturating add
    return 0;
}

pub export fn graphql_fields_resolved(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].fields_resolved;
}

// -- Stateless transition checks ----------------------------------------------

pub export fn graphql_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validateRequestTransition exactly
    if (from == 0 and to == 1) return 1; // Parse -> Validate
    if (from == 1 and to == 2) return 1; // Validate -> Execute
    if (from == 2 and to == 3) return 1; // Execute -> Resolve
    if (from == 3 and to == 4) return 1; // Resolve -> Serialize
    // Abort edges
    if (from == 0 and to == 5) return 1; // Parse -> Failed
    if (from == 1 and to == 5) return 1; // Validate -> Failed
    if (from == 2 and to == 5) return 1; // Execute -> Failed
    if (from == 3 and to == 5) return 1; // Resolve -> Failed
    return 0;
}

// -- Subscription management --------------------------------------------------

pub export fn graphql_sub_create(slot: c_int) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return -1;
    // Must be a subscription operation
    if (contexts[idx].op_type != .subscription) return -1;
    // Cannot create subscription if one is already active
    if (contexts[idx].sub_active) return -1;
    contexts[idx].sub_active = true;
    contexts[idx].sub_phase = .subscribe;
    contexts[idx].sub_event_count = 0;
    return @intCast(idx); // return same slot as sub_id
}

pub export fn graphql_sub_phase(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 3; // sub_failed as fallback
    if (!contexts[idx].sub_active) return 3;
    return @intFromEnum(contexts[idx].sub_phase);
}

pub export fn graphql_sub_advance(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (!contexts[idx].sub_active) return 1;
    if (nextSubPhase(contexts[idx].sub_phase)) |np| {
        contexts[idx].sub_phase = np;
        return 0;
    }
    return 1; // rejected (terminal state)
}

/// Deliver an event to an Active subscription (Active -> Active transition).
/// Returns 0 on success, 1 if not in Active phase.
pub export fn graphql_sub_emit_event(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (!contexts[idx].sub_active) return 1;
    if (contexts[idx].sub_phase != .active) return 1;
    contexts[idx].sub_event_count +|= 1;
    return 0;
}

pub export fn graphql_sub_abort(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (!contexts[idx].sub_active) return 1;
    const phase = contexts[idx].sub_phase;
    // Can abort from Subscribe or Active (not Unsubscribe or SubFailed)
    if (phase == .unsubscribe or phase == .sub_failed) return 1;
    contexts[idx].sub_phase = .sub_failed;
    return 0;
}

pub export fn graphql_sub_event_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (!contexts[idx].sub_active) return 0;
    return contexts[idx].sub_event_count;
}

pub export fn graphql_sub_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validateSubscriptionTransition exactly
    if (from == 0 and to == 1) return 1; // Subscribe -> Active
    if (from == 1 and to == 1) return 1; // Active -> Active (event)
    if (from == 1 and to == 2) return 1; // Active -> Unsubscribe
    if (from == 0 and to == 3) return 1; // Subscribe -> SubFailed
    if (from == 1 and to == 3) return 1; // Active -> SubFailed
    return 0;
}
