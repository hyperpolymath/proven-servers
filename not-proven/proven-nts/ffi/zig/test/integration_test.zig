// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-nts FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - AEAD negotiation (Handshaking -> Negotiating -> Established)
//   - Cookie management (add/count)
//   - Close / Cleanup transitions
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const nts = @import("nts");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), nts.nts_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "RecordType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nts.RecordType.end_of_message));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nts.RecordType.next_protocol));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nts.RecordType.err));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nts.RecordType.warning));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nts.RecordType.aead_algorithm));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nts.RecordType.cookie));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(nts.RecordType.cookie_placeholder));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(nts.RecordType.ntske_server));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(nts.RecordType.ntske_port));
}

test "ErrorCode encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nts.ErrorCode.unrecognized_critical));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nts.ErrorCode.bad_request));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nts.ErrorCode.internal_error));
}

test "AEADAlgorithm encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nts.AEADAlgorithm.aead_aes_128_gcm));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nts.AEADAlgorithm.aead_aes_256_gcm));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nts.AEADAlgorithm.aead_aes_siv_cmac_256));
}

test "HandshakeState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nts.HandshakeState.initial));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nts.HandshakeState.negotiating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nts.HandshakeState.established));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nts.HandshakeState.failed));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nts.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nts.SessionState.handshaking));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nts.SessionState.negotiating));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nts.SessionState.established));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nts.SessionState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Handshaking state" {
    const server = "time.example.com";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    try std.testing.expect(slot >= 0);
    defer nts.nts_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), nts.nts_state(slot)); // Handshaking
}

test "create rejects empty server name" {
    const server = "x";
    const slot = nts.nts_create(server.ptr, 0, 4460);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    nts.nts_destroy(-1);
    nts.nts_destroy(999);
}

// =========================================================================
// AEAD negotiation
// =========================================================================

test "negotiate transitions Handshaking -> Negotiating" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), nts.nts_negotiate(slot, 0)); // AES-128-GCM
    try std.testing.expectEqual(@as(u8, 2), nts.nts_state(slot)); // Negotiating
}

test "negotiate rejects invalid AEAD algorithm" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nts.nts_negotiate(slot, 99));
}

test "accept transitions Negotiating -> Established" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 1); // AES-256-GCM
    try std.testing.expectEqual(@as(u8, 0), nts.nts_accept(slot));
    try std.testing.expectEqual(@as(u8, 3), nts.nts_state(slot)); // Established
    try std.testing.expectEqual(@as(u8, 1), nts.nts_is_established(slot));
}

test "get_aead returns negotiated algorithm" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 2); // AES-SIV-CMAC-256
    _ = nts.nts_accept(slot);
    try std.testing.expectEqual(@as(u8, 2), nts.nts_get_aead(slot));
}

// =========================================================================
// Cookie management
// =========================================================================

test "add_cookie stores cookies in Established state" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 0);
    _ = nts.nts_accept(slot);

    const cookie = "cookie-data-1234";
    try std.testing.expectEqual(@as(u8, 0), nts.nts_add_cookie(slot, cookie.ptr, cookie.len));
    try std.testing.expectEqual(@as(u32, 1), nts.nts_cookie_count(slot));

    const cookie2 = "cookie-data-5678";
    _ = nts.nts_add_cookie(slot, cookie2.ptr, cookie2.len);
    try std.testing.expectEqual(@as(u32, 2), nts.nts_cookie_count(slot));
}

test "add_cookie rejects from Handshaking state" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    const cookie = "data";
    try std.testing.expectEqual(@as(u8, 1), nts.nts_add_cookie(slot, cookie.ptr, cookie.len));
}

// =========================================================================
// Close / Cleanup
// =========================================================================

test "close transitions Established -> Closing" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 0);
    _ = nts.nts_accept(slot);
    try std.testing.expectEqual(@as(u8, 0), nts.nts_close(slot));
    try std.testing.expectEqual(@as(u8, 4), nts.nts_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 0);
    _ = nts.nts_accept(slot);
    _ = nts.nts_close(slot);
    try std.testing.expectEqual(@as(u8, 0), nts.nts_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), nts.nts_state(slot)); // Idle
}

test "cleanup clears cookies" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 0);
    _ = nts.nts_accept(slot);
    const cookie = "data";
    _ = nts.nts_add_cookie(slot, cookie.ptr, cookie.len);
    try std.testing.expectEqual(@as(u32, 1), nts.nts_cookie_count(slot));

    _ = nts.nts_close(slot);
    _ = nts.nts_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), nts.nts_cookie_count(slot));
}

test "cleanup rejected from non-Closing state" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nts.nts_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "nts_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(0, 1)); // Idle -> Handshaking
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(1, 2)); // Handshaking -> Negotiating
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(2, 3)); // Negotiating -> Established

    // Close edges
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(1, 4)); // Handshaking -> Closing
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(2, 4)); // Negotiating -> Closing
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(3, 4)); // Established -> Closing
    try std.testing.expectEqual(@as(u8, 1), nts.nts_can_transition(4, 0)); // Closing -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), nts.nts_can_transition(0, 2)); // Idle -/-> Negotiating
    try std.testing.expectEqual(@as(u8, 0), nts.nts_can_transition(0, 3)); // Idle -/-> Established
    try std.testing.expectEqual(@as(u8, 0), nts.nts_can_transition(4, 1)); // Closing -/-> Handshaking
    try std.testing.expectEqual(@as(u8, 0), nts.nts_can_transition(3, 1)); // Established -/-> Handshaking
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot negotiate from Established" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    _ = nts.nts_negotiate(slot, 0);
    _ = nts.nts_accept(slot);
    try std.testing.expectEqual(@as(u8, 1), nts.nts_negotiate(slot, 1));
}

test "cannot accept from Handshaking" {
    const server = "nts.example.org";
    const slot = nts.nts_create(server.ptr, server.len, 4460);
    defer nts.nts_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nts.nts_accept(slot));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), nts.nts_state(-1));
    try std.testing.expectEqual(@as(u8, 0), nts.nts_is_established(-1));
    try std.testing.expectEqual(@as(u32, 0), nts.nts_cookie_count(-1));
    try std.testing.expectEqual(@as(u8, 1), nts.nts_close(-1));
    try std.testing.expectEqual(@as(u8, 1), nts.nts_cleanup(-1));
}

// =========================================================================
// Error helper
// =========================================================================

test "error_for_state returns InternalError for Closing" {
    try std.testing.expectEqual(@as(u8, 2), nts.nts_error_for_state(4));
    try std.testing.expectEqual(@as(u8, 0), nts.nts_error_for_state(0));
}
