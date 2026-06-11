// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-doh FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Proxy lifecycle (create/destroy)
//   - Path registration (add/remove/count)
//   - Query handling with method and content type validation
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const doh = @import("doh");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), doh.doh_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ContentType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doh.ContentType.dns_message));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doh.ContentType.dns_json));
}

test "RequestMethod encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doh.RequestMethod.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doh.RequestMethod.post));
}

test "WireFormat encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doh.WireFormat.binary));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doh.WireFormat.json));
}

test "ErrorReason encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doh.ErrorReason.bad_content_type));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doh.ErrorReason.bad_method));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(doh.ErrorReason.payload_too_large));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(doh.ErrorReason.upstream_timeout));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(doh.ErrorReason.upstream_error));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doh.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doh.SessionState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(doh.SessionState.serving));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(doh.SessionState.resolving));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(doh.SessionState.shutdown));
}

// =========================================================================
// Proxy lifecycle
// =========================================================================

test "create returns valid slot in Bound state" {
    const slot = doh.doh_create(443);
    try std.testing.expect(slot >= 0);
    defer doh.doh_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), doh.doh_state(slot)); // Bound
}

test "create rejects port 0" {
    const slot = doh.doh_create(0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    doh.doh_destroy(-1);
    doh.doh_destroy(999);
}

// =========================================================================
// Path registration
// =========================================================================

test "add_path transitions Bound -> Serving" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    try std.testing.expectEqual(@as(u8, 0), doh.doh_add_path(
        slot, path.ptr, path.len, 0, // binary wire format
    ));
    try std.testing.expectEqual(@as(u8, 2), doh.doh_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 1), doh.doh_path_count(slot));
}

test "add_path rejects invalid wire format" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    try std.testing.expectEqual(@as(u8, 1), doh.doh_add_path(
        slot, path.ptr, path.len, 99,
    ));
}

test "add_path rejects duplicate path" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 1), doh.doh_add_path(
        slot, path.ptr, path.len, 1,
    ));
}

test "remove_path last path transitions Serving -> Bound" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 2), doh.doh_state(slot));

    try std.testing.expectEqual(@as(u8, 0), doh.doh_remove_path(
        slot, path.ptr, path.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), doh.doh_state(slot)); // Bound
    try std.testing.expectEqual(@as(u32, 0), doh.doh_path_count(slot));
}

// =========================================================================
// Query handling
// =========================================================================

test "handle_query succeeds with valid POST request" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);

    const body = "dns-wire-format-query";
    try std.testing.expectEqual(@as(u8, 0xFF), doh.doh_handle_query(
        slot, path.ptr, path.len, 1, 0, body.ptr, body.len, // POST, dns-message
    )); // 0xFF = success
}

test "handle_query rejects invalid method" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);

    const body = "query";
    try std.testing.expectEqual(@as(u8, 1), doh.doh_handle_query(
        slot, path.ptr, path.len, 99, 0, body.ptr, body.len,
    )); // 1 = bad_method
}

test "handle_query rejects POST without body" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);

    const body = "";
    try std.testing.expectEqual(@as(u8, 1), doh.doh_handle_query(
        slot, path.ptr, path.len, 1, 0, body.ptr, 0,
    )); // 1 = bad_method (POST needs body)
}

test "handle_query tracks queries handled" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);

    const body = "query";
    _ = doh.doh_handle_query(slot, path.ptr, path.len, 1, 0, body.ptr, body.len);
    _ = doh.doh_handle_query(slot, path.ptr, path.len, 1, 0, body.ptr, body.len);

    try std.testing.expectEqual(@as(u64, 2), doh.doh_queries_handled(slot));
}

test "can_serve returns 1 from Serving" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_serve(slot));
}

test "can_serve returns 0 from Bound" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), doh.doh_can_serve(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Bound -> Shutdown" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), doh.doh_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), doh.doh_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    _ = doh.doh_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), doh.doh_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), doh.doh_state(slot)); // Idle
}

test "cleanup clears paths" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    _ = doh.doh_add_path(slot, path.ptr, path.len, 0);

    _ = doh.doh_shutdown(slot);
    _ = doh.doh_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), doh.doh_path_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), doh.doh_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "doh_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(0, 1)); // Idle -> Bound
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(1, 2)); // Bound -> Serving
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(2, 2)); // Serving -> Serving
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(2, 1)); // Serving -> Bound
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(2, 3)); // Serving -> Resolving
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(3, 2)); // Resolving -> Serving

    // Shutdown edges
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(1, 4)); // Bound -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(2, 4)); // Serving -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(3, 4)); // Resolving -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), doh.doh_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), doh.doh_can_transition(0, 2)); // Idle -/-> Serving
    try std.testing.expectEqual(@as(u8, 0), doh.doh_can_transition(4, 1)); // Shutdown -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), doh.doh_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), doh.doh_state(-1));
    try std.testing.expectEqual(@as(u8, 0), doh.doh_can_serve(-1));
    try std.testing.expectEqual(@as(u32, 0), doh.doh_path_count(-1));
    try std.testing.expectEqual(@as(u64, 0), doh.doh_queries_handled(-1));
    try std.testing.expectEqual(@as(u8, 1), doh.doh_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), doh.doh_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot add path from Idle" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    _ = doh.doh_shutdown(slot);
    _ = doh.doh_cleanup(slot);
    const path = "/dns-query";
    try std.testing.expectEqual(@as(u8, 1), doh.doh_add_path(
        slot, path.ptr, path.len, 0,
    ));
}

test "cannot handle query from Bound" {
    const slot = doh.doh_create(443);
    defer doh.doh_destroy(slot);

    const path = "/dns-query";
    const body = "query";
    // No paths registered, still in Bound state
    const result = doh.doh_handle_query(slot, path.ptr, path.len, 1, 0, body.ptr, body.len);
    try std.testing.expect(result != 0xFF); // should not succeed
}
