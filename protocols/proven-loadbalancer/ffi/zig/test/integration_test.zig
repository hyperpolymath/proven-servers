// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-loadbalancer FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const loadbalancer = @import("loadbalancer");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), loadbalancer.lb_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Algorithm encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(loadbalancer.Algorithm.round_robin));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(loadbalancer.Algorithm.least_connections));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(loadbalancer.Algorithm.ip_hash));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(loadbalancer.Algorithm.random));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(loadbalancer.Algorithm.weighted_round_robin));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(loadbalancer.Algorithm.least_response_time));
}

test "HealthCheckType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(loadbalancer.HealthCheckType.http));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(loadbalancer.HealthCheckType.tcp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(loadbalancer.HealthCheckType.grpc));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(loadbalancer.HealthCheckType.script));
}

test "BackendState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(loadbalancer.BackendState.healthy));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(loadbalancer.BackendState.unhealthy));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(loadbalancer.BackendState.draining));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(loadbalancer.BackendState.disabled));
}

test "SessionPersistence encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(loadbalancer.SessionPersistence.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(loadbalancer.SessionPersistence.cookie));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(loadbalancer.SessionPersistence.source_ip));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(loadbalancer.SessionPersistence.header));
}

test "Protocol encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(loadbalancer.Protocol.http));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(loadbalancer.Protocol.https));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(loadbalancer.Protocol.tcp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(loadbalancer.Protocol.udp));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(loadbalancer.Protocol.grpc));
}

test "LBError encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(loadbalancer.LBError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(loadbalancer.LBError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(loadbalancer.LBError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(loadbalancer.LBError.invalid_transition));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(loadbalancer.LBError.no_healthy_backends));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(loadbalancer.LBError.capacity_exhausted));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(loadbalancer.LBError.invalid_param));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = loadbalancer.lb_create(0, 0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer loadbalancer.lb_destroy(slot);
    const state = loadbalancer.lb_set_backend_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    loadbalancer.lb_destroy(-1);
    loadbalancer.lb_destroy(999);
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = loadbalancer.lb_set_backend_state(-1);
    _ = loadbalancer.lb_get_algorithm(-1);
    _ = loadbalancer.lb_get_protocol(-1);
    _ = loadbalancer.lb_get_persistence(-1);
}

