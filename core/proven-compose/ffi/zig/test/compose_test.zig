// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// compose_test.zig — Integration tests for proven-compose FFI.

const std = @import("std");
const compose = @import("compose");

// ═══════════════════════════════════════════════════════════════════════
// ABI version
// ═══════════════════════════════════════════════════════════════════════

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), compose.compose_abi_version());
}

// ═══════════════════════════════════════════════════════════════════════
// Enum encoding seams
// ═══════════════════════════════════════════════════════════════════════

test "Combinator encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(compose.Combinator.chain));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(compose.Combinator.parallel));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(compose.Combinator.proxy));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(compose.Combinator.relay));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(compose.Combinator.mux));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(compose.Combinator.demux));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(compose.Combinator.filter));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(compose.Combinator.transform));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(compose.Combinator.tap));
}

test "Compatibility encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(compose.Compatibility.compatible));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(compose.Compatibility.incompatible_types));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(compose.Compatibility.incompatible_framing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(compose.Compatibility.incompatible_security));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(compose.Compatibility.incompatible_direction));
}

test "Direction encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(compose.Direction.upstream));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(compose.Direction.downstream));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(compose.Direction.bidirectional));
}

test "CompositionError encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(compose.CompositionError.type_mismatch));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(compose.CompositionError.security_downgrade));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(compose.CompositionError.cycle_detected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(compose.CompositionError.missing_dependency));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(compose.CompositionError.ambiguous_route));
}

test "PipelineStage encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(compose.PipelineStage.ingress));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(compose.PipelineStage.process));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(compose.PipelineStage.egress));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(compose.PipelineStage.error_handler));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(compose.PipelineStage.audit));
}

test "PipelineState encoding matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(compose.PipelineState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(compose.PipelineState.configured));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(compose.PipelineState.assembled));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(compose.PipelineState.running));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(compose.PipelineState.stopped));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(compose.PipelineState.failed));
}

// ═══════════════════════════════════════════════════════════════════════
// Lifecycle
// ═══════════════════════════════════════════════════════════════════════

test "create returns valid slot" {
    const slot = compose.compose_create(0); // chain
    try std.testing.expect(slot >= 0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_state(slot)); // idle
}

test "create stores combinator" {
    const slot = compose.compose_create(4); // mux
    try std.testing.expect(slot >= 0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 4), compose.compose_combinator(slot));
}

test "create rejects invalid combinator" {
    try std.testing.expectEqual(@as(c_int, -1), compose.compose_create(99));
}

test "destroy is safe with invalid slot" {
    compose.compose_destroy(-1);
    compose.compose_destroy(999);
}

// ═══════════════════════════════════════════════════════════════════════
// Valid transitions — full lifecycle
// ═══════════════════════════════════════════════════════════════════════

test "Configure: Idle -> Configured" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_configure(slot));
    try std.testing.expectEqual(@as(u8, 1), compose.compose_state(slot)); // configured
}

test "Assemble: Configured -> Assembled" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_assemble(slot));
    try std.testing.expectEqual(@as(u8, 2), compose.compose_state(slot)); // assembled
}

test "Activate: Assembled -> Running" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_activate(slot));
    try std.testing.expectEqual(@as(u8, 3), compose.compose_state(slot)); // running
}

test "Deactivate: Running -> Stopped" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_deactivate(slot));
    try std.testing.expectEqual(@as(u8, 4), compose.compose_state(slot)); // stopped
}

test "ResetStopped: Stopped -> Idle" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    _ = compose.compose_deactivate(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), compose.compose_state(slot)); // idle
}

test "FailRunning + ResetFailed" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_fail(slot, 2)); // cycle_detected
    try std.testing.expectEqual(@as(u8, 5), compose.compose_state(slot)); // failed
    try std.testing.expectEqual(@as(u8, 2), compose.compose_last_error(slot)); // cycle_detected
    try std.testing.expectEqual(@as(u8, 0), compose.compose_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), compose.compose_state(slot)); // idle
}

test "FailConfigure: Configured -> Failed" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_fail(slot, 0)); // type_mismatch
    try std.testing.expectEqual(@as(u8, 5), compose.compose_state(slot));
}

test "FailAssemble: Assembled -> Failed" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_fail(slot, 3)); // missing_dependency
    try std.testing.expectEqual(@as(u8, 5), compose.compose_state(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Invalid transitions (impossibility proofs)
// ═══════════════════════════════════════════════════════════════════════

test "cannot configure while running" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_configure(slot)); // rejected
}

test "cannot activate from Idle" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_activate(slot)); // rejected
}

test "cannot assemble from Idle" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_assemble(slot)); // rejected
}

test "cannot activate from Configured (must assemble first)" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_activate(slot)); // rejected
}

test "cannot fail from Idle" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_fail(slot, 0)); // rejected
}

test "cannot reset from Running" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_reset(slot)); // rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Direction management
// ═══════════════════════════════════════════════════════════════════════

test "default direction is downstream" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_direction(slot)); // downstream
}

test "set direction while idle" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_set_direction(slot, 2)); // bidirectional
    try std.testing.expectEqual(@as(u8, 2), compose.compose_direction(slot));
}

test "set direction while configured" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_set_direction(slot, 0)); // upstream
    try std.testing.expectEqual(@as(u8, 0), compose.compose_direction(slot));
}

test "cannot set direction while running" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_set_direction(slot, 0)); // rejected
}

test "reject invalid direction tag" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_set_direction(slot, 99)); // rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Stage management
// ═══════════════════════════════════════════════════════════════════════

test "add stages while idle" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_add_stage(slot, 0)); // ingress
    try std.testing.expectEqual(@as(u8, 0), compose.compose_add_stage(slot, 1)); // process
    try std.testing.expectEqual(@as(u8, 0), compose.compose_add_stage(slot, 2)); // egress
    try std.testing.expectEqual(@as(u8, 3), compose.compose_stage_count(slot));
}

test "cannot add stage while running" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    _ = compose.compose_configure(slot);
    _ = compose.compose_assemble(slot);
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_add_stage(slot, 0)); // rejected
}

test "reject invalid stage tag" {
    const slot = compose.compose_create(0);
    defer compose.compose_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_add_stage(slot, 99)); // rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Compatibility checks
// ═══════════════════════════════════════════════════════════════════════

test "same combinator is compatible" {
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(0, 0)); // chain + chain
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(4, 4)); // mux + mux
}

test "chain/filter/transform/tap are compatible" {
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(0, 6)); // chain + filter
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(7, 8)); // transform + tap
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(6, 0)); // filter + chain
}

test "mux + demux are compatible" {
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(4, 5)); // mux + demux
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(5, 4)); // demux + mux
}

test "proxy + relay are compatible" {
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(2, 3)); // proxy + relay
    try std.testing.expectEqual(@as(u8, 0), compose.compose_check_compat(3, 2)); // relay + proxy
}

test "incompatible combinators return incompatible_framing" {
    try std.testing.expectEqual(@as(u8, 2), compose.compose_check_compat(0, 4)); // chain + mux
    try std.testing.expectEqual(@as(u8, 2), compose.compose_check_compat(1, 6)); // parallel + filter
}

test "invalid combinator tags return incompatible_types" {
    try std.testing.expectEqual(@as(u8, 1), compose.compose_check_compat(99, 0));
    try std.testing.expectEqual(@as(u8, 1), compose.compose_check_compat(0, 99));
}

// ═══════════════════════════════════════════════════════════════════════
// Transition table
// ═══════════════════════════════════════════════════════════════════════

test "compose_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(0, 1)); // Idle -> Configured
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(1, 2)); // Configured -> Assembled
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(2, 3)); // Assembled -> Running
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(3, 4)); // Running -> Stopped
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(1, 5)); // Configured -> Failed
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(2, 5)); // Assembled -> Failed
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(3, 5)); // Running -> Failed
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(5, 0)); // Failed -> Idle
    try std.testing.expectEqual(@as(u8, 1), compose.compose_can_transition(4, 0)); // Stopped -> Idle
    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), compose.compose_can_transition(3, 1)); // Running -/-> Configured
    try std.testing.expectEqual(@as(u8, 0), compose.compose_can_transition(0, 3)); // Idle -/-> Running
    try std.testing.expectEqual(@as(u8, 0), compose.compose_can_transition(0, 2)); // Idle -/-> Assembled
    try std.testing.expectEqual(@as(u8, 0), compose.compose_can_transition(1, 3)); // Configured -/-> Running
    try std.testing.expectEqual(@as(u8, 0), compose.compose_can_transition(4, 3)); // Stopped -/-> Running
}

// ═══════════════════════════════════════════════════════════════════════
// Full pipeline lifecycle roundtrip
// ═══════════════════════════════════════════════════════════════════════

test "full lifecycle: create -> configure -> assemble -> activate -> deactivate -> reset -> reuse" {
    const slot = compose.compose_create(1); // parallel
    defer compose.compose_destroy(slot);

    // Add stages
    _ = compose.compose_add_stage(slot, 0); // ingress
    _ = compose.compose_add_stage(slot, 1); // process
    _ = compose.compose_add_stage(slot, 2); // egress
    try std.testing.expectEqual(@as(u8, 3), compose.compose_stage_count(slot));

    // Set direction
    _ = compose.compose_set_direction(slot, 2); // bidirectional

    // Configure
    _ = compose.compose_configure(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_state(slot));

    // Assemble
    _ = compose.compose_assemble(slot);
    try std.testing.expectEqual(@as(u8, 2), compose.compose_state(slot));

    // Activate
    _ = compose.compose_activate(slot);
    try std.testing.expectEqual(@as(u8, 3), compose.compose_state(slot));

    // Deactivate
    _ = compose.compose_deactivate(slot);
    try std.testing.expectEqual(@as(u8, 4), compose.compose_state(slot));

    // Reset
    _ = compose.compose_reset(slot);
    try std.testing.expectEqual(@as(u8, 0), compose.compose_state(slot));
    try std.testing.expectEqual(@as(u8, 0), compose.compose_stage_count(slot)); // stages cleared

    // Can reuse
    _ = compose.compose_configure(slot);
    try std.testing.expectEqual(@as(u8, 1), compose.compose_state(slot));
}
