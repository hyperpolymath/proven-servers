// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-appserver FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Server lifecycle (create/destroy/start/ready)
//   - Handler registration (register/count)
//   - Request handling with type validation
//   - Health check probes (liveness/readiness/startup)
//   - Shutdown lifecycle (drain/stop/cleanup)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const appserver = @import("appserver");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), appserver.appserver_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "RequestType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(appserver.RequestType.http));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(appserver.RequestType.websocket));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(appserver.RequestType.grpc));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(appserver.RequestType.graphql));
}

test "LifecycleState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(appserver.LifecycleState.initializing));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(appserver.LifecycleState.starting));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(appserver.LifecycleState.running));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(appserver.LifecycleState.draining));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(appserver.LifecycleState.stopping));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(appserver.LifecycleState.stopped));
}

test "HealthCheck encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(appserver.HealthCheck.liveness));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(appserver.HealthCheck.readiness));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(appserver.HealthCheck.startup));
}

test "DeployStrategy encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(appserver.DeployStrategy.rolling_update));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(appserver.DeployStrategy.blue_green));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(appserver.DeployStrategy.canary));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(appserver.DeployStrategy.recreate));
}

test "ErrorCategory encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(appserver.ErrorCategory.client_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(appserver.ErrorCategory.server_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(appserver.ErrorCategory.timeout));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(appserver.ErrorCategory.circuit_open));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(appserver.ErrorCategory.rate_limited));
}

// =========================================================================
// Server lifecycle
// =========================================================================

test "create returns valid slot in Initializing state" {
    const slot = appserver.appserver_create(8080, 0); // RollingUpdate
    try std.testing.expect(slot >= 0);
    defer appserver.appserver_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_state(slot)); // Initializing
}

test "create rejects port 0" {
    const slot = appserver.appserver_create(0, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid strategy" {
    const slot = appserver.appserver_create(8080, 10);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    appserver.appserver_destroy(-1);
    appserver.appserver_destroy(999);
}

test "start transitions Initializing -> Starting" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_start(slot));
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_state(slot)); // Starting
}

test "ready transitions Starting -> Running" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_ready(slot));
    try std.testing.expectEqual(@as(u8, 2), appserver.appserver_state(slot)); // Running
}

// =========================================================================
// Handler registration
// =========================================================================

test "register_handler succeeds in Running state" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    const path = "/api/users";
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_register_handler(
        slot, path.ptr, path.len, 0, // HTTP
    ));
    try std.testing.expectEqual(@as(u32, 1), appserver.appserver_handler_count(slot));
}

test "register_handler rejected in Initializing state" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    const path = "/api/users";
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_register_handler(
        slot, path.ptr, path.len, 0,
    ));
}

test "register_handler rejects duplicate path" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    const path = "/api/users";
    _ = appserver.appserver_register_handler(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_register_handler(
        slot, path.ptr, path.len, 1,
    ));
}

// =========================================================================
// Request handling
// =========================================================================

test "handle_request succeeds for matching handler" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    const path = "/api/users";
    _ = appserver.appserver_register_handler(slot, path.ptr, path.len, 0); // HTTP

    try std.testing.expectEqual(@as(u8, 255), appserver.appserver_handle_request(
        slot, path.ptr, path.len, 0, // HTTP
    )); // 255 = success
}

test "handle_request rejects wrong request type" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    const path = "/api/users";
    _ = appserver.appserver_register_handler(slot, path.ptr, path.len, 0); // HTTP

    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_handle_request(
        slot, path.ptr, path.len, 2, // gRPC (wrong)
    )); // 0 = ClientError
}

test "handle_request rejects unknown path" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    const path = "/api/users";
    _ = appserver.appserver_register_handler(slot, path.ptr, path.len, 0);

    const bad = "/api/unknown";
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_handle_request(
        slot, bad.ptr, bad.len, 0,
    )); // 0 = ClientError
}

// =========================================================================
// Health checks
// =========================================================================

test "liveness true while running" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_health_check(slot, 0)); // Liveness
}

test "readiness true only while running" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    // Not yet running
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_health_check(slot, 1)); // Readiness

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_health_check(slot, 1)); // Readiness
}

test "startup false during Initializing, true after" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_health_check(slot, 2)); // Startup

    _ = appserver.appserver_start(slot);
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_health_check(slot, 2)); // Startup
}

// =========================================================================
// Shutdown lifecycle
// =========================================================================

test "drain transitions Running -> Draining" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_drain(slot));
    try std.testing.expectEqual(@as(u8, 3), appserver.appserver_state(slot)); // Draining
}

test "stop transitions Draining -> Stopping" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);
    _ = appserver.appserver_drain(slot);

    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_stop(slot));
    try std.testing.expectEqual(@as(u8, 4), appserver.appserver_state(slot)); // Stopping
}

test "cleanup transitions Stopping -> Stopped" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);
    _ = appserver.appserver_drain(slot);
    _ = appserver.appserver_stop(slot);

    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 5), appserver.appserver_state(slot)); // Stopped
}

test "cleanup clears handlers" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    _ = appserver.appserver_ready(slot);

    const path = "/api/test";
    _ = appserver.appserver_register_handler(slot, path.ptr, path.len, 0);

    _ = appserver.appserver_drain(slot);
    _ = appserver.appserver_stop(slot);
    _ = appserver.appserver_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), appserver.appserver_handler_count(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "appserver_can_transition matches expected" {
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_can_transition(0, 1)); // Init -> Starting
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_can_transition(1, 2)); // Starting -> Running
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_can_transition(2, 3)); // Running -> Draining
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_can_transition(3, 4)); // Draining -> Stopping
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_can_transition(4, 5)); // Stopping -> Stopped

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_can_transition(0, 2)); // Init -/-> Running
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_can_transition(2, 0)); // Running -/-> Init
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_can_transition(5, 0)); // Stopped -/-> Init
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_can_transition(3, 2)); // Draining -/-> Running
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_state(-1));
    try std.testing.expectEqual(@as(u32, 0), appserver.appserver_handler_count(-1));
    try std.testing.expectEqual(@as(u8, 0), appserver.appserver_health_check(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_start(-1));
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_drain(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot drain from Initializing" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_drain(slot));
}

test "cannot ready from Initializing" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_ready(slot));
}

test "cannot start twice" {
    const slot = appserver.appserver_create(8080, 0);
    defer appserver.appserver_destroy(slot);

    _ = appserver.appserver_start(slot);
    try std.testing.expectEqual(@as(u8, 1), appserver.appserver_start(slot));
}
