// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// loadbalancer_test.zig — Integration tests for the proven-loadbalancer FFI.
//
// Tests cover:
//   - ABI version check
//   - Pool lifecycle (create, destroy, queries)
//   - Backend management (add, state transitions)
//   - Request routing (round-robin across healthy backends)
//   - Algorithm and configuration setters
//   - Edge cases (invalid slots, capacity limits, etc.)

const std = @import("std");
const lb = @import("lb");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), lb.lb_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = lb.lb_create(0, 0, 0, 0); // RoundRobin, HTTP, None, HTTP
    try expect(slot >= 0);
    lb.lb_destroy(slot);
}

test "create with invalid algorithm returns -1" {
    try expectEqual(@as(c_int, -1), lb.lb_create(99, 0, 0, 0));
}

test "create with invalid protocol returns -1" {
    try expectEqual(@as(c_int, -1), lb.lb_create(0, 99, 0, 0));
}

test "create with invalid persistence returns -1" {
    try expectEqual(@as(c_int, -1), lb.lb_create(0, 0, 99, 0));
}

test "create with invalid health check type returns -1" {
    try expectEqual(@as(c_int, -1), lb.lb_create(0, 0, 0, 99));
}

test "destroy invalid slot is safe" {
    lb.lb_destroy(-1);
    lb.lb_destroy(999);
}

test "double destroy is safe" {
    const slot = lb.lb_create(0, 0, 0, 0);
    lb.lb_destroy(slot);
    lb.lb_destroy(slot);
}

// ── State Queries ───────────────────────────────────────────────────────

test "fresh pool has correct algorithm" {
    const slot = lb.lb_create(1, 0, 0, 0); // LeastConnections
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 1), lb.lb_get_algorithm(slot));
}

test "fresh pool has correct protocol" {
    const slot = lb.lb_create(0, 1, 0, 0); // HTTPS
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 1), lb.lb_get_protocol(slot));
}

test "fresh pool has correct persistence" {
    const slot = lb.lb_create(0, 0, 2, 0); // SourceIP
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 2), lb.lb_get_persistence(slot));
}

test "fresh pool has correct health check type" {
    const slot = lb.lb_create(0, 0, 0, 2); // gRPC
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 2), lb.lb_get_health_check_type(slot));
}

test "fresh pool has zero backends" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u32, 0), lb.lb_get_backend_count(slot));
}

test "fresh pool has zero requests" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u32, 0), lb.lb_get_total_requests(slot));
}

test "fresh pool has no error (255)" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 255), lb.lb_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_algorithm on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), lb.lb_get_algorithm(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), lb.lb_get_last_error(-1));
}

// ── Backend Management ──────────────────────────────────────────────────

test "add backend increments count" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 0), lb.lb_add_backend(slot, 1)); // Ok
    try expectEqual(@as(u32, 1), lb.lb_get_backend_count(slot));
    try expectEqual(@as(u8, 0), lb.lb_add_backend(slot, 2));
    try expectEqual(@as(u32, 2), lb.lb_get_backend_count(slot));
}

test "add backend with zero weight fails" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 6), lb.lb_add_backend(slot, 0)); // InvalidParam
}

test "add backend on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), lb.lb_add_backend(-1, 1));
}

test "fresh backend is healthy" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    try expectEqual(@as(u8, 0), lb.lb_get_backend_state(slot, 0)); // Healthy
}

test "set backend state to unhealthy" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    try expectEqual(@as(u8, 0), lb.lb_set_backend_state(slot, 0, 1)); // Unhealthy
    try expectEqual(@as(u8, 1), lb.lb_get_backend_state(slot, 0));
}

test "set backend state to draining" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    try expectEqual(@as(u8, 0), lb.lb_set_backend_state(slot, 0, 2)); // Draining
    try expectEqual(@as(u8, 2), lb.lb_get_backend_state(slot, 0));
}

test "set backend state with invalid index fails" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 6), lb.lb_set_backend_state(slot, 0, 0)); // InvalidParam (no backends)
}

test "set backend state with invalid state value fails" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    try expectEqual(@as(u8, 6), lb.lb_set_backend_state(slot, 0, 99)); // InvalidParam
}

// ── Request Routing ─────────────────────────────────────────────────────

test "route request to single healthy backend" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    const backend = lb.lb_route_request(slot);
    try expectEqual(@as(c_int, 0), backend);
    try expectEqual(@as(u32, 1), lb.lb_get_total_requests(slot));
}

test "route request round-robins across healthy backends" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_add_backend(slot, 1);

    const b0 = lb.lb_route_request(slot);
    const b1 = lb.lb_route_request(slot);
    const b2 = lb.lb_route_request(slot);
    try expectEqual(@as(c_int, 0), b0);
    try expectEqual(@as(c_int, 1), b1);
    try expectEqual(@as(c_int, 2), b2);
    try expectEqual(@as(u32, 3), lb.lb_get_total_requests(slot));
}

test "route request skips unhealthy backends" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_set_backend_state(slot, 0, 1); // Mark first as unhealthy
    const backend = lb.lb_route_request(slot);
    try expectEqual(@as(c_int, 1), backend); // Routes to second
}

test "route request returns -1 when no healthy backends" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_set_backend_state(slot, 0, 1); // Unhealthy
    try expectEqual(@as(c_int, -1), lb.lb_route_request(slot));
}

test "route request on empty pool returns -1" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(c_int, -1), lb.lb_route_request(slot));
}

test "route request on invalid slot returns -1" {
    try expectEqual(@as(c_int, -1), lb.lb_route_request(-1));
}

// ── Algorithm Setter ────────────────────────────────────────────────────

test "set algorithm" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 0), lb.lb_set_algorithm(slot, 3)); // Random
    try expectEqual(@as(u8, 3), lb.lb_get_algorithm(slot));
}

test "set algorithm with invalid value fails" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    try expectEqual(@as(u8, 6), lb.lb_set_algorithm(slot, 99)); // InvalidParam
}

// ── Healthy Count ───────────────────────────────────────────────────────

test "healthy count tracks backend states" {
    const slot = lb.lb_create(0, 0, 0, 0);
    defer lb.lb_destroy(slot);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_add_backend(slot, 1);
    _ = lb.lb_add_backend(slot, 1);
    try expectEqual(@as(u32, 3), lb.lb_get_healthy_count(slot));
    _ = lb.lb_set_backend_state(slot, 1, 1); // Unhealthy
    try expectEqual(@as(u32, 2), lb.lb_get_healthy_count(slot));
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full lifecycle: create pool, add backends, route, drain, destroy" {
    const slot = lb.lb_create(0, 1, 1, 0); // RoundRobin, HTTPS, Cookie, HTTP-check
    defer lb.lb_destroy(slot);

    // Add backends
    try expectEqual(@as(u8, 0), lb.lb_add_backend(slot, 1));
    try expectEqual(@as(u8, 0), lb.lb_add_backend(slot, 2));

    // Route requests
    _ = lb.lb_route_request(slot);
    _ = lb.lb_route_request(slot);
    try expectEqual(@as(u32, 2), lb.lb_get_total_requests(slot));

    // Drain first backend
    try expectEqual(@as(u8, 0), lb.lb_set_backend_state(slot, 0, 2)); // Draining
    try expectEqual(@as(u32, 1), lb.lb_get_healthy_count(slot));

    // All requests now go to backend 1
    const target = lb.lb_route_request(slot);
    try expectEqual(@as(c_int, 1), target);
}
