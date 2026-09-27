// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-odns FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - HPKE key exchange (KeyExchange -> Ready)
//   - Query/response lifecycle (Ready -> Processing -> Ready)
//   - Role and format queries
//   - Query counter
//   - Close / Cleanup transitions
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const odns = @import("odns");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), odns.odns_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Role encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(odns.Role.client));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(odns.Role.proxy));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(odns.Role.target));
}

test "MessageType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(odns.MessageType.query));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(odns.MessageType.response));
}

test "ErrorReason encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(odns.ErrorReason.proxy_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(odns.ErrorReason.target_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(odns.ErrorReason.decryption_failed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(odns.ErrorReason.invalid_config));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(odns.ErrorReason.payload_too_large));
}

test "EncapsulationFormat encoding matches Types.idr (1 tag)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(odns.EncapsulationFormat.hpke));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(odns.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(odns.SessionState.key_exchange));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(odns.SessionState.ready));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(odns.SessionState.processing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(odns.SessionState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in KeyExchange state" {
    const config = "odns-config-data";
    const slot = odns.odns_create(0, config.ptr, config.len); // Client role
    try std.testing.expect(slot >= 0);
    defer odns.odns_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), odns.odns_state(slot)); // KeyExchange
}

test "create with Proxy role" {
    const config = "proxy-cfg";
    const slot = odns.odns_create(1, config.ptr, config.len); // Proxy
    try std.testing.expect(slot >= 0);
    defer odns.odns_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), odns.odns_get_role(slot)); // Proxy
}

test "create with Target role" {
    const config = "target-cfg";
    const slot = odns.odns_create(2, config.ptr, config.len); // Target
    try std.testing.expect(slot >= 0);
    defer odns.odns_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), odns.odns_get_role(slot)); // Target
}

test "create rejects invalid role" {
    const config = "cfg";
    const slot = odns.odns_create(99, config.ptr, config.len);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects empty config" {
    const config = "x";
    const slot = odns.odns_create(0, config.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    odns.odns_destroy(-1);
    odns.odns_destroy(999);
}

// =========================================================================
// Key exchange
// =========================================================================

test "key_exchange fails closed without HPKE and leaves session unready" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    const pubkey = "not-a-validated-hpke-key";
    try std.testing.expectEqual(@as(u8, 1), odns.odns_key_exchange(slot, pubkey.ptr, pubkey.len));
    try std.testing.expectEqual(@as(u8, 1), odns.odns_state(slot)); // KeyExchange
    try std.testing.expectEqual(@as(u8, 0), odns.odns_is_ready(slot));
}

test "key_exchange rejects empty pubkey" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    const pubkey = "x";
    try std.testing.expectEqual(@as(u8, 1), odns.odns_key_exchange(slot, pubkey.ptr, 0));
}

// =========================================================================
// Query / Response lifecycle
// =========================================================================

test "query submission fails closed when no encrypted session can be established" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    const pubkey = "key";
    const query = "query";
    _ = odns.odns_key_exchange(slot, pubkey.ptr, pubkey.len);
    try std.testing.expectEqual(@as(u8, 1), odns.odns_submit_query(slot, query.ptr, query.len));
    try std.testing.expectEqual(@as(u8, 1), odns.odns_state(slot)); // remains KeyExchange
}

test "response retrieval fails closed without a processed encrypted query" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), odns.odns_get_response(slot));
    try std.testing.expectEqual(@as(u32, 0), odns.odns_query_count(slot));
}

test "rejected operations never increment query_count" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    const pubkey = "key";
    const query = "q1";
    _ = odns.odns_key_exchange(slot, pubkey.ptr, pubkey.len);
    _ = odns.odns_submit_query(slot, query.ptr, query.len);
    _ = odns.odns_get_response(slot);
    try std.testing.expectEqual(@as(u32, 0), odns.odns_query_count(slot));
}

test "get_format returns HPKE" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), odns.odns_get_format(slot)); // HPKE
}

// =========================================================================
// Close / Cleanup
// =========================================================================

test "close transitions KeyExchange -> Closing" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), odns.odns_close(slot));
    try std.testing.expectEqual(@as(u8, 4), odns.odns_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    _ = odns.odns_close(slot);
    try std.testing.expectEqual(@as(u8, 0), odns.odns_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), odns.odns_state(slot)); // Idle
}

test "cleanup resets query count" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    const pubkey = "key";
    _ = odns.odns_key_exchange(slot, pubkey.ptr, pubkey.len);
    const query = "q";
    _ = odns.odns_submit_query(slot, query.ptr, query.len);
    _ = odns.odns_get_response(slot);
    _ = odns.odns_close(slot);
    _ = odns.odns_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), odns.odns_query_count(slot));
}

test "cleanup rejected from non-Closing state" {
    const config = "cfg";
    const slot = odns.odns_create(0, config.ptr, config.len);
    defer odns.odns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), odns.odns_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "odns_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(0, 1)); // Idle -> KeyExchange
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(1, 2)); // KeyExchange -> Ready
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(2, 3)); // Ready -> Processing
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(3, 2)); // Processing -> Ready

    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(1, 4)); // KeyExchange -> Closing
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(2, 4)); // Ready -> Closing
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(3, 4)); // Processing -> Closing
    try std.testing.expectEqual(@as(u8, 1), odns.odns_can_transition(4, 0)); // Closing -> Idle

    try std.testing.expectEqual(@as(u8, 0), odns.odns_can_transition(0, 2)); // Idle -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), odns.odns_can_transition(4, 2)); // Closing -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), odns.odns_can_transition(0, 3)); // Idle -/-> Processing
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), odns.odns_state(-1));
    try std.testing.expectEqual(@as(u8, 0), odns.odns_is_ready(-1));
    try std.testing.expectEqual(@as(u32, 0), odns.odns_query_count(-1));
    try std.testing.expectEqual(@as(u8, 1), odns.odns_close(-1));
    try std.testing.expectEqual(@as(u8, 1), odns.odns_cleanup(-1));
}
