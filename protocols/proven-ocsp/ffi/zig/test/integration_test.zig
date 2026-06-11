// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ocsp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Responder lifecycle (create/destroy)
//   - Certificate status cache (set/query/respond)
//   - Hash algorithm selection
//   - Request/response lifecycle (Ready -> Processing -> Ready)
//   - Close / Cleanup transitions
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ocsp = @import("ocsp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ocsp.ocsp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "CertStatus encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ocsp.CertStatus.good));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ocsp.CertStatus.revoked));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ocsp.CertStatus.unknown));
}

test "ResponseStatus encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ocsp.ResponseStatus.successful));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ocsp.ResponseStatus.malformed_request));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ocsp.ResponseStatus.internal_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ocsp.ResponseStatus.try_later));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ocsp.ResponseStatus.sig_required));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ocsp.ResponseStatus.unauthorized));
}

test "HashAlgorithm encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ocsp.HashAlgorithm.sha1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ocsp.HashAlgorithm.sha256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ocsp.HashAlgorithm.sha384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ocsp.HashAlgorithm.sha512));
}

test "ResponderState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ocsp.ResponderState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ocsp.ResponderState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ocsp.ResponderState.processing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ocsp.ResponderState.signing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ocsp.ResponderState.closing));
}

// =========================================================================
// Responder lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const ca = "Example CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1); // SHA-256
    try std.testing.expect(slot >= 0);
    defer ocsp.ocsp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_state(slot)); // Ready
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_is_ready(slot));
}

test "create rejects empty CA name" {
    const ca = "x";
    const slot = ocsp.ocsp_create(ca.ptr, 0, 1);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid hash algorithm" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    ocsp.ocsp_destroy(-1);
    ocsp.ocsp_destroy(999);
}

// =========================================================================
// Certificate status cache
// =========================================================================

test "set_cert_status populates cache" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "ABC123";
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 0)); // Good
    try std.testing.expectEqual(@as(u32, 1), ocsp.ocsp_cache_count(slot));
}

test "set_cert_status updates existing entry" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "DEF456";
    _ = ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 0); // Good
    _ = ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 1); // Revoked
    try std.testing.expectEqual(@as(u32, 1), ocsp.ocsp_cache_count(slot)); // Still 1
}

test "set_cert_status rejects invalid status" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "BAD";
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 99));
}

// =========================================================================
// Query / Response lifecycle
// =========================================================================

test "query transitions Ready -> Processing" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "CERT001";
    _ = ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 0);

    const nonce = "nonce123";
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_query(slot, serial.ptr, serial.len, nonce.ptr, nonce.len));
    try std.testing.expectEqual(@as(u8, 2), ocsp.ocsp_state(slot)); // Processing
}

test "respond returns cached status and transitions to Ready" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "CERT002";
    _ = ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 1); // Revoked

    const nonce = "n";
    _ = ocsp.ocsp_query(slot, serial.ptr, serial.len, nonce.ptr, nonce.len);
    const result = ocsp.ocsp_respond(slot);
    try std.testing.expectEqual(@as(u8, 1), result); // Revoked
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_state(slot)); // Back to Ready
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_get_response_status(slot)); // Successful
}

test "respond returns Unknown for uncached serial" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "UNKNOWN";
    const nonce = "n";
    _ = ocsp.ocsp_query(slot, serial.ptr, serial.len, nonce.ptr, nonce.len);
    try std.testing.expectEqual(@as(u8, 2), ocsp.ocsp_respond(slot)); // Unknown
}

test "query rejects from Processing state" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "S1";
    const nonce = "n";
    _ = ocsp.ocsp_query(slot, serial.ptr, serial.len, nonce.ptr, nonce.len);
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_query(slot, serial.ptr, serial.len, nonce.ptr, nonce.len));
}

// =========================================================================
// Hash algorithm selection
// =========================================================================

test "set_hash_algorithm succeeds in Ready state" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_set_hash_algorithm(slot, 3)); // SHA-512
}

test "set_hash_algorithm rejects invalid algorithm" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_set_hash_algorithm(slot, 99));
}

// =========================================================================
// Close / Cleanup
// =========================================================================

test "close transitions Ready -> Closing" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_close(slot));
    try std.testing.expectEqual(@as(u8, 4), ocsp.ocsp_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    _ = ocsp.ocsp_close(slot);
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_state(slot)); // Idle
}

test "cleanup clears cache" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    const serial = "C1";
    _ = ocsp.ocsp_set_cert_status(slot, serial.ptr, serial.len, 0);
    _ = ocsp.ocsp_close(slot);
    _ = ocsp.ocsp_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), ocsp.ocsp_cache_count(slot));
}

test "cleanup rejected from non-Closing state" {
    const ca = "Test CA";
    const slot = ocsp.ocsp_create(ca.ptr, ca.len, 1);
    defer ocsp.ocsp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "ocsp_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(0, 1)); // Idle -> Ready
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(1, 2)); // Ready -> Processing
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(2, 3)); // Processing -> Signing
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(3, 1)); // Signing -> Ready
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(1, 4)); // Ready -> Closing
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(2, 4)); // Processing -> Closing
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_can_transition(4, 0)); // Closing -> Idle

    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_can_transition(0, 2)); // Idle -/-> Processing
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_can_transition(4, 1)); // Closing -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_can_transition(0, 4)); // Idle -/-> Closing
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_state(-1));
    try std.testing.expectEqual(@as(u8, 0), ocsp.ocsp_is_ready(-1));
    try std.testing.expectEqual(@as(u32, 0), ocsp.ocsp_cache_count(-1));
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_close(-1));
    try std.testing.expectEqual(@as(u8, 1), ocsp.ocsp_cleanup(-1));
}
