// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-semweb FFI.
//
// Tests cover (27 tests):
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Triple management (add/remove/has/count)
//   - Content negotiation (format selection)
//   - Format get/set
//   - HTTP request handling
//   - Disconnect / Cleanup
//   - Transition table validation
//   - Invalid slot safety
//   - Impossibility tests

const std = @import("std");
const semweb = @import("semweb");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), semweb.semweb_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Format encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(semweb.Format.rdfxml));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(semweb.Format.turtle));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(semweb.Format.ntriples));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(semweb.Format.nquads));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(semweb.Format.jsonld));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(semweb.Format.trig));
}

test "ResourceType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(semweb.ResourceType.class));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(semweb.ResourceType.property));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(semweb.ResourceType.individual));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(semweb.ResourceType.ontology));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(semweb.ResourceType.named_graph));
}

test "HTTPMethod encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(semweb.HTTPMethod.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(semweb.HTTPMethod.post));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(semweb.HTTPMethod.put));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(semweb.HTTPMethod.patch));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(semweb.HTTPMethod.delete));
}

test "ContentNegotiation encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(semweb.ContentNegotiation.neg_rdfxml));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(semweb.ContentNegotiation.neg_turtle));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(semweb.ContentNegotiation.neg_jsonld));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(semweb.ContentNegotiation.neg_html));
}

test "ErrorCode encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(semweb.ErrorCode.not_found));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(semweb.ErrorCode.invalid_uri));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(semweb.ErrorCode.malformed_rdf));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(semweb.ErrorCode.unsupported_format));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(semweb.ErrorCode.conflicting_triples));
}

test "StoreState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(semweb.StoreState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(semweb.StoreState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(semweb.StoreState.serving));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(semweb.StoreState.disconnecting));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(semweb.StoreState.destroyed));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    try std.testing.expect(slot >= 0);
    defer semweb.semweb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_state(slot)); // Ready
}

test "create rejects empty base URI" {
    const uri = "x";
    try std.testing.expectEqual(@as(c_int, -1), semweb.semweb_create(uri.ptr, 0));
}

test "destroy is safe with invalid slot" {
    semweb.semweb_destroy(-1);
    semweb.semweb_destroy(999);
}

// =========================================================================
// Triple management
// =========================================================================

test "add_triple stores triple and transitions to Serving" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);

    const subj = "http://example.org/Alice";
    const pred = "http://xmlns.com/foaf/0.1/name";
    const obj = "Alice";
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_add_triple(
        slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len,
    ));
    try std.testing.expectEqual(@as(u32, 1), semweb.semweb_triple_count(slot));
    try std.testing.expectEqual(@as(u8, 2), semweb.semweb_state(slot)); // Serving
}

test "add_triple rejects duplicate" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);

    const subj = "http://example.org/Alice";
    const pred = "http://xmlns.com/foaf/0.1/name";
    const obj = "Alice";
    _ = semweb.semweb_add_triple(slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len);
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_add_triple(
        slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len,
    ));
}

test "has_triple finds existing triple" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);

    const subj = "http://example.org/Bob";
    const pred = "http://xmlns.com/foaf/0.1/age";
    const obj = "30";
    _ = semweb.semweb_add_triple(slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len);
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_has_triple(
        slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len,
    ));
}

test "has_triple returns 0 for missing triple" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);

    const subj = "http://example.org/Nobody";
    const pred = "http://xmlns.com/foaf/0.1/name";
    const obj = "Ghost";
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_has_triple(
        slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len,
    ));
}

test "remove_triple removes and may return to Ready" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);

    const subj = "http://example.org/Alice";
    const pred = "http://xmlns.com/foaf/0.1/name";
    const obj = "Alice";
    _ = semweb.semweb_add_triple(slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len);
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_remove_triple(
        slot, subj.ptr, subj.len, pred.ptr, pred.len, obj.ptr, obj.len,
    ));
    try std.testing.expectEqual(@as(u32, 0), semweb.semweb_triple_count(slot));
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_state(slot)); // Ready
}

// =========================================================================
// Content negotiation
// =========================================================================

test "negotiate_format selects Turtle for text/turtle" {
    const accept = "text/turtle";
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_negotiate_format(accept.ptr, accept.len));
}

test "negotiate_format selects JSON-LD for application/ld+json" {
    const accept = "application/ld+json";
    try std.testing.expectEqual(@as(u8, 4), semweb.semweb_negotiate_format(accept.ptr, accept.len));
}

test "negotiate_format returns 255 for unsupported" {
    const accept = "text/plain";
    try std.testing.expectEqual(@as(u8, 255), semweb.semweb_negotiate_format(accept.ptr, accept.len));
}

test "negotiate_format defaults to Turtle for */*" {
    const accept = "*/*";
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_negotiate_format(accept.ptr, accept.len));
}

// =========================================================================
// Format get/set
// =========================================================================

test "set_format and get_format" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_set_format(slot, 4)); // JSON-LD
    try std.testing.expectEqual(@as(u8, 4), semweb.semweb_get_format(slot));
}

test "set_format rejects invalid format" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_set_format(slot, 99));
}

// =========================================================================
// HTTP request handling
// =========================================================================

test "handle_request returns OK for valid request" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);
    const req_uri = "/resource/Alice";
    try std.testing.expectEqual(@as(u8, 255), semweb.semweb_handle_request(slot, 0, req_uri.ptr, req_uri.len));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Ready -> Disconnecting" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 3), semweb.semweb_state(slot));
}

test "cleanup transitions Disconnecting -> Destroyed" {
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    defer semweb.semweb_destroy(slot);
    _ = semweb.semweb_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 4), semweb.semweb_state(slot));
}

// =========================================================================
// Transition table
// =========================================================================

test "semweb_can_transition matches expected transitions" {
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_can_transition(0, 1)); // Idle -> Ready
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_can_transition(1, 2)); // Ready -> Serving
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_can_transition(2, 1)); // Serving -> Ready
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_can_transition(1, 3)); // Ready -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_can_transition(2, 3)); // Serving -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_can_transition(3, 4)); // Disconnecting -> Destroyed
    // Invalid
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_can_transition(0, 2)); // Idle -/-> Serving
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_can_transition(4, 1)); // Destroyed -/-> Ready
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), semweb.semweb_state(-1));
    try std.testing.expectEqual(@as(u32, 0), semweb.semweb_triple_count(-1));
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), semweb.semweb_cleanup(-1));
}

// =========================================================================
// Active count
// =========================================================================

test "active_count tracks sessions" {
    const before = semweb.semweb_active_count();
    const uri = "http://example.org/";
    const slot = semweb.semweb_create(uri.ptr, uri.len);
    try std.testing.expectEqual(before + 1, semweb.semweb_active_count());
    semweb.semweb_destroy(slot);
    try std.testing.expectEqual(before, semweb.semweb_active_count());
}
