// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-apiserver FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Gateway lifecycle (create/destroy)
//   - Route registration (register/unregister/count)
//   - Request handling with auth and version validation
//   - Rate limiting (set/check)
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const apiserver = @import("apiserver");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), apiserver.apiserver_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "AuthScheme encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(apiserver.AuthScheme.api_key));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(apiserver.AuthScheme.bearer));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(apiserver.AuthScheme.basic));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(apiserver.AuthScheme.oauth2));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(apiserver.AuthScheme.hmac));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(apiserver.AuthScheme.mtls));
}

test "RateLimitStrategy encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(apiserver.RateLimitStrategy.fixed_window));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(apiserver.RateLimitStrategy.sliding_window));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(apiserver.RateLimitStrategy.token_bucket));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(apiserver.RateLimitStrategy.leaky_bucket));
}

test "APIVersion encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(apiserver.APIVersion.v1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(apiserver.APIVersion.v2));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(apiserver.APIVersion.v3));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(apiserver.APIVersion.latest));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(apiserver.APIVersion.deprecated));
}

test "ResponseFormat encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(apiserver.ResponseFormat.json));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(apiserver.ResponseFormat.xml));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(apiserver.ResponseFormat.protobuf));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(apiserver.ResponseFormat.messagepack));
}

test "GatewayError encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(apiserver.GatewayError.unauthorized));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(apiserver.GatewayError.rate_limited));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(apiserver.GatewayError.not_found));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(apiserver.GatewayError.bad_request));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(apiserver.GatewayError.service_unavailable));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(apiserver.GatewayError.circuit_open));
}

test "GatewayState encoding (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(apiserver.GatewayState.ready));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(apiserver.GatewayState.serving));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(apiserver.GatewayState.draining));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(apiserver.GatewayState.stopped));
}

// =========================================================================
// Gateway lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const slot = apiserver.apiserver_create(8080);
    try std.testing.expect(slot >= 0);
    defer apiserver.apiserver_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_state(slot)); // Ready
}

test "create rejects port 0" {
    const slot = apiserver.apiserver_create(0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    apiserver.apiserver_destroy(-1);
    apiserver.apiserver_destroy(999);
}

// =========================================================================
// Route registration
// =========================================================================

test "register_route transitions Ready -> Serving" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/users";
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_register_route(
        slot, path.ptr, path.len, 0, 0, 0, // V1, APIKey, JSON
    ));
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 1), apiserver.apiserver_route_count(slot));
}

test "register_route rejects duplicate path" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/users";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_register_route(
        slot, path.ptr, path.len, 1, 1, 1,
    ));
}

test "register_route rejects invalid version" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/test";
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_register_route(
        slot, path.ptr, path.len, 99, 0, 0,
    ));
}

test "unregister_route last route transitions Serving -> Ready" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/users";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_state(slot));

    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_unregister_route(
        slot, path.ptr, path.len,
    ));
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_state(slot)); // Ready
}

// =========================================================================
// Request handling
// =========================================================================

test "handle_request succeeds with correct auth and version" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/users";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 1, 0); // V1, Bearer

    try std.testing.expectEqual(@as(u8, 255), apiserver.apiserver_handle_request(
        slot, path.ptr, path.len, 0, 1, // V1, Bearer
    )); // 255 = success
}

test "handle_request rejects wrong auth" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/users";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 1, 0); // V1, Bearer

    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_handle_request(
        slot, path.ptr, path.len, 0, 0, // V1, APIKey (wrong)
    )); // 0 = Unauthorized
}

test "handle_request rejects unknown path" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/users";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 0, 0);

    const bad = "/api/unknown";
    try std.testing.expectEqual(@as(u8, 2), apiserver.apiserver_handle_request(
        slot, bad.ptr, bad.len, 0, 0,
    )); // 2 = NotFound
}

// =========================================================================
// Rate limiting
// =========================================================================

test "set_rate_limit and check_rate_limit" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/data";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 0, 0);

    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_set_rate_limit(slot, 0, 2)); // FixedWindow, max 2

    // First two requests should succeed
    try std.testing.expectEqual(@as(u8, 255), apiserver.apiserver_handle_request(slot, path.ptr, path.len, 0, 0));
    try std.testing.expectEqual(@as(u8, 255), apiserver.apiserver_handle_request(slot, path.ptr, path.len, 0, 0));
    // Third should be rate limited
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_handle_request(slot, path.ptr, path.len, 0, 0)); // RateLimited
}

test "check_rate_limit allows when no limit set" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_check_rate_limit(slot));
}

test "request_count increments" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/data";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 0, 0);

    _ = apiserver.apiserver_handle_request(slot, path.ptr, path.len, 0, 0);
    _ = apiserver.apiserver_handle_request(slot, path.ptr, path.len, 0, 0);
    try std.testing.expectEqual(@as(u64, 2), apiserver.apiserver_request_count(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Serving -> Draining" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/test";
    _ = apiserver.apiserver_register_route(slot, path.ptr, path.len, 0, 0, 0);

    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 2), apiserver.apiserver_state(slot)); // Draining
}

test "cleanup transitions Draining -> Stopped" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    _ = apiserver.apiserver_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 3), apiserver.apiserver_state(slot)); // Stopped
}

test "cleanup rejected from non-Draining state" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "apiserver_can_transition matches expected" {
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_can_transition(0, 1)); // Ready -> Serving
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_can_transition(1, 0)); // Serving -> Ready
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_can_transition(1, 1)); // Serving -> Serving
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_can_transition(0, 2)); // Ready -> Draining
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_can_transition(1, 2)); // Serving -> Draining
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_can_transition(2, 3)); // Draining -> Stopped

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_can_transition(3, 0)); // Stopped -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_can_transition(0, 3)); // Ready -/-> Stopped
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_can_transition(2, 1)); // Draining -/-> Serving
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_state(-1));
    try std.testing.expectEqual(@as(u32, 0), apiserver.apiserver_route_count(-1));
    try std.testing.expectEqual(@as(u64, 0), apiserver.apiserver_request_count(-1));
    try std.testing.expectEqual(@as(u8, 0), apiserver.apiserver_check_rate_limit(-1));
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_shutdown(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot register route from Draining" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    _ = apiserver.apiserver_shutdown(slot);
    const path = "/api/test";
    try std.testing.expectEqual(@as(u8, 1), apiserver.apiserver_register_route(
        slot, path.ptr, path.len, 0, 0, 0,
    ));
}

test "cannot handle request from Ready (no routes)" {
    const slot = apiserver.apiserver_create(8080);
    defer apiserver.apiserver_destroy(slot);

    const path = "/api/test";
    try std.testing.expectEqual(@as(u8, 4), apiserver.apiserver_handle_request(
        slot, path.ptr, path.len, 0, 0,
    )); // 4 = ServiceUnavailable
}
