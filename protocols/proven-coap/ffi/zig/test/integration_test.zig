// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-coap FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Endpoint lifecycle (create/destroy)
//   - Resource registration (register/unregister/count)
//   - Request handling with method validation
//   - Observation (add/remove/notify)
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const coap = @import("coap");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), coap.coap_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Method encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(coap.Method.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(coap.Method.post));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(coap.Method.put));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(coap.Method.delete));
}

test "MessageType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(coap.MessageType.confirmable));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(coap.MessageType.non_confirmable));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(coap.MessageType.acknowledgement));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(coap.MessageType.reset));
}

test "ContentFormat encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(coap.ContentFormat.text_plain));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(coap.ContentFormat.link_format));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(coap.ContentFormat.xml));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(coap.ContentFormat.octet_stream));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(coap.ContentFormat.exi));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(coap.ContentFormat.json));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(coap.ContentFormat.cbor));
}

test "ResponseClass encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(coap.ResponseClass.success));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(coap.ResponseClass.client_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(coap.ResponseClass.server_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(coap.ResponseClass.signaling));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(coap.ResponseClass.empty));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(coap.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(coap.SessionState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(coap.SessionState.serving));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(coap.SessionState.observing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(coap.SessionState.shutdown));
}

// =========================================================================
// Endpoint lifecycle
// =========================================================================

test "create returns valid slot in Bound state" {
    const slot = coap.coap_create(5683);
    try std.testing.expect(slot >= 0);
    defer coap.coap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), coap.coap_state(slot)); // Bound
}

test "create rejects port 0" {
    const slot = coap.coap_create(0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    coap.coap_destroy(-1);
    coap.coap_destroy(999);
}

// =========================================================================
// Resource registration
// =========================================================================

test "register_resource transitions Bound -> Serving" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    try std.testing.expectEqual(@as(u8, 0), coap.coap_register_resource(
        slot, path.ptr, path.len, 0x01, // GET only
    ));
    try std.testing.expectEqual(@as(u8, 2), coap.coap_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 1), coap.coap_resource_count(slot));
}

test "register_resource rejects empty methods bitmask" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/sensor";
    try std.testing.expectEqual(@as(u8, 1), coap.coap_register_resource(
        slot, path.ptr, path.len, 0x00, // no methods
    ));
}

test "register_resource rejects invalid methods bitmask" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/sensor";
    try std.testing.expectEqual(@as(u8, 1), coap.coap_register_resource(
        slot, path.ptr, path.len, 0x10, // bit4 set, invalid
    ));
}

test "register_resource rejects duplicate path" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);
    try std.testing.expectEqual(@as(u8, 1), coap.coap_register_resource(
        slot, path.ptr, path.len, 0x03,
    ));
}

test "multiple resources stay in Serving" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const p1 = "/temperature";
    const p2 = "/humidity";
    const p3 = "/light";
    _ = coap.coap_register_resource(slot, p1.ptr, p1.len, 0x01);
    _ = coap.coap_register_resource(slot, p2.ptr, p2.len, 0x01);
    _ = coap.coap_register_resource(slot, p3.ptr, p3.len, 0x0F);
    try std.testing.expectEqual(@as(u8, 2), coap.coap_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 3), coap.coap_resource_count(slot));
}

test "unregister_resource last resource transitions Serving -> Bound" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);
    try std.testing.expectEqual(@as(u8, 2), coap.coap_state(slot));

    try std.testing.expectEqual(@as(u8, 0), coap.coap_unregister_resource(
        slot, path.ptr, path.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), coap.coap_state(slot)); // Bound
    try std.testing.expectEqual(@as(u32, 0), coap.coap_resource_count(slot));
}

// =========================================================================
// Request handling
// =========================================================================

test "handle_request succeeds for allowed method" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01); // GET only

    const payload = "x";
    try std.testing.expectEqual(@as(u8, 0), coap.coap_handle_request(
        slot, 0, 0, 1234, 4, path.ptr, path.len, payload.ptr, payload.len,
    )); // 0 = success
}

test "handle_request rejects disallowed method" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01); // GET only

    const payload = "x";
    // method 2 = PUT, not allowed
    try std.testing.expectEqual(@as(u8, 1), coap.coap_handle_request(
        slot, 2, 0, 1234, 4, path.ptr, path.len, payload.ptr, payload.len,
    )); // 1 = client_error
}

test "handle_request rejects unknown resource" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);

    const bad_path = "/unknown";
    const payload = "x";
    try std.testing.expectEqual(@as(u8, 1), coap.coap_handle_request(
        slot, 0, 0, 1234, 4, bad_path.ptr, bad_path.len, payload.ptr, payload.len,
    )); // 1 = client_error (Not Found)
}

// =========================================================================
// Observation (RFC 7641)
// =========================================================================

test "add_observer transitions Serving -> Observing" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);

    try std.testing.expectEqual(@as(u8, 0), coap.coap_add_observer(
        slot, path.ptr, path.len, 0xDEADBEEF,
    ));
    try std.testing.expectEqual(@as(u8, 3), coap.coap_state(slot)); // Observing
    try std.testing.expectEqual(@as(u32, 1), coap.coap_observer_count(slot));
}

test "add_observer rejects non-existent resource" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);

    const bad = "/humidity";
    try std.testing.expectEqual(@as(u8, 1), coap.coap_add_observer(
        slot, bad.ptr, bad.len, 0x1234,
    ));
}

test "remove_observer last observer transitions Observing -> Serving" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);
    _ = coap.coap_add_observer(slot, path.ptr, path.len, 0xDEADBEEF);
    try std.testing.expectEqual(@as(u8, 3), coap.coap_state(slot));

    try std.testing.expectEqual(@as(u8, 0), coap.coap_remove_observer(
        slot, path.ptr, path.len, 0xDEADBEEF,
    ));
    try std.testing.expectEqual(@as(u8, 2), coap.coap_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 0), coap.coap_observer_count(slot));
}

test "notify_observers returns count of matching observers" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);
    _ = coap.coap_add_observer(slot, path.ptr, path.len, 0x1111);
    _ = coap.coap_add_observer(slot, path.ptr, path.len, 0x2222);

    try std.testing.expectEqual(@as(u32, 2), coap.coap_notify_observers(
        slot, path.ptr, path.len,
    ));
}

test "unregister_resource cancels observers on that resource" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const p1 = "/temperature";
    const p2 = "/humidity";
    _ = coap.coap_register_resource(slot, p1.ptr, p1.len, 0x01);
    _ = coap.coap_register_resource(slot, p2.ptr, p2.len, 0x01);
    _ = coap.coap_add_observer(slot, p1.ptr, p1.len, 0x1111);
    _ = coap.coap_add_observer(slot, p2.ptr, p2.len, 0x2222);
    try std.testing.expectEqual(@as(u32, 2), coap.coap_observer_count(slot));

    _ = coap.coap_unregister_resource(slot, p1.ptr, p1.len);
    try std.testing.expectEqual(@as(u32, 1), coap.coap_observer_count(slot));
    try std.testing.expectEqual(@as(u8, 3), coap.coap_state(slot)); // Still Observing
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Bound -> Shutdown" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), coap.coap_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), coap.coap_state(slot)); // Shutdown
}

test "shutdown transitions Serving -> Shutdown" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);

    try std.testing.expectEqual(@as(u8, 0), coap.coap_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), coap.coap_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    _ = coap.coap_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), coap.coap_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), coap.coap_state(slot)); // Idle
}

test "cleanup clears resources and observers" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);
    _ = coap.coap_add_observer(slot, path.ptr, path.len, 0xDEAD);

    _ = coap.coap_shutdown(slot);
    _ = coap.coap_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), coap.coap_resource_count(slot));
    try std.testing.expectEqual(@as(u32, 0), coap.coap_observer_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), coap.coap_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "coap_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(0, 1)); // Idle -> Bound
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(1, 2)); // Bound -> Serving
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(2, 2)); // Serving -> Serving
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(2, 1)); // Serving -> Bound
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(2, 3)); // Serving -> Observing
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(3, 3)); // Observing -> Observing
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(3, 2)); // Observing -> Serving

    // Shutdown edges
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(1, 4)); // Bound -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(2, 4)); // Serving -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(3, 4)); // Observing -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), coap.coap_can_transition(0, 2)); // Idle -/-> Serving
    try std.testing.expectEqual(@as(u8, 0), coap.coap_can_transition(0, 3)); // Idle -/-> Observing
    try std.testing.expectEqual(@as(u8, 0), coap.coap_can_transition(4, 1)); // Shutdown -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), coap.coap_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), coap.coap_state(-1));
    try std.testing.expectEqual(@as(u8, 0), coap.coap_can_serve(-1));
    try std.testing.expectEqual(@as(u32, 0), coap.coap_resource_count(-1));
    try std.testing.expectEqual(@as(u32, 0), coap.coap_observer_count(-1));
    try std.testing.expectEqual(@as(u8, 1), coap.coap_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), coap.coap_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot register resource from Idle" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    _ = coap.coap_shutdown(slot);
    _ = coap.coap_cleanup(slot);
    const path = "/sensor";
    try std.testing.expectEqual(@as(u8, 1), coap.coap_register_resource(
        slot, path.ptr, path.len, 0x01,
    ));
}

test "cannot add observer from Bound" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/sensor";
    try std.testing.expectEqual(@as(u8, 1), coap.coap_add_observer(
        slot, path.ptr, path.len, 0x1234,
    ));
}

test "can_serve returns 0 from Bound" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), coap.coap_can_serve(slot));
}

test "can_serve returns 1 from Serving" {
    const slot = coap.coap_create(5683);
    defer coap.coap_destroy(slot);

    const path = "/temperature";
    _ = coap.coap_register_resource(slot, path.ptr, path.len, 0x01);
    try std.testing.expectEqual(@as(u8, 1), coap.coap_can_serve(slot));
}
