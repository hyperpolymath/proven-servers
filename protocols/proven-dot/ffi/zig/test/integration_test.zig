// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-dot FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Server lifecycle (create/destroy)
//   - Session management (accept/close/count)
//   - Query handling with session validation
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const dot = @import("dot");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), dot.dot_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PaddingStrategy encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dot.PaddingStrategy.no_padding));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dot.PaddingStrategy.block_padding));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dot.PaddingStrategy.random_padding));
}

test "ErrorReason encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dot.ErrorReason.handshake_failed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dot.ErrorReason.certificate_invalid));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dot.ErrorReason.timeout));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dot.ErrorReason.upstream_error));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dot.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dot.ServerState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dot.ServerState.listening));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dot.ServerState.processing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dot.ServerState.shutdown));
}

// =========================================================================
// Server lifecycle
// =========================================================================

test "create returns valid slot in Bound state" {
    const slot = dot.dot_create(853, 0); // port 853, no padding
    try std.testing.expect(slot >= 0);
    defer dot.dot_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), dot.dot_state(slot)); // Bound
}

test "create rejects port 0" {
    const slot = dot.dot_create(0, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid padding" {
    const slot = dot.dot_create(853, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    dot.dot_destroy(-1);
    dot.dot_destroy(999);
}

// =========================================================================
// Session management
// =========================================================================

test "accept_session transitions Bound -> Listening" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), dot.dot_accept_session(slot));
    try std.testing.expectEqual(@as(u8, 2), dot.dot_state(slot)); // Listening
    try std.testing.expectEqual(@as(u32, 1), dot.dot_session_count(slot));
}

test "close_session last session transitions Listening -> Bound" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    try std.testing.expectEqual(@as(u8, 2), dot.dot_state(slot));

    // Session ID is 1 (first assigned)
    try std.testing.expectEqual(@as(u8, 0), dot.dot_close_session(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), dot.dot_state(slot)); // Bound
    try std.testing.expectEqual(@as(u32, 0), dot.dot_session_count(slot));
}

test "close_session rejects invalid session_id" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    try std.testing.expectEqual(@as(u8, 1), dot.dot_close_session(slot, 9999));
}

test "multiple sessions stay in Listening" {
    const slot = dot.dot_create(853, 1); // block padding
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    _ = dot.dot_accept_session(slot);
    _ = dot.dot_accept_session(slot);
    try std.testing.expectEqual(@as(u8, 2), dot.dot_state(slot));
    try std.testing.expectEqual(@as(u32, 3), dot.dot_session_count(slot));
}

// =========================================================================
// Query handling
// =========================================================================

test "handle_query succeeds on valid session" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    const query = "dns-query-over-tls";
    try std.testing.expectEqual(@as(u8, 0xFF), dot.dot_handle_query(
        slot, 1, query.ptr, query.len,
    )); // 0xFF = success
}

test "handle_query transitions Listening -> Processing" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    const query = "dns-query";
    _ = dot.dot_handle_query(slot, 1, query.ptr, query.len);
    try std.testing.expectEqual(@as(u8, 3), dot.dot_state(slot)); // Processing
}

test "handle_query rejects invalid session_id" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    const query = "dns-query";
    try std.testing.expectEqual(@as(u8, 3), dot.dot_handle_query(
        slot, 9999, query.ptr, query.len,
    )); // 3 = upstream_error
}

test "handle_query tracks queries handled" {
    const slot = dot.dot_create(853, 2); // random padding
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    const query = "query";
    _ = dot.dot_handle_query(slot, 1, query.ptr, query.len);
    _ = dot.dot_handle_query(slot, 1, query.ptr, query.len);
    _ = dot.dot_handle_query(slot, 1, query.ptr, query.len);

    try std.testing.expectEqual(@as(u64, 3), dot.dot_queries_handled(slot));
}

test "can_serve returns 1 from Listening" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_serve(slot));
}

test "can_serve returns 0 from Bound" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), dot.dot_can_serve(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Bound -> Shutdown" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), dot.dot_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), dot.dot_state(slot));
}

test "shutdown transitions Listening -> Shutdown" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    try std.testing.expectEqual(@as(u8, 0), dot.dot_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), dot.dot_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), dot.dot_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), dot.dot_state(slot)); // Idle
}

test "cleanup clears sessions" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_accept_session(slot);
    _ = dot.dot_accept_session(slot);

    _ = dot.dot_shutdown(slot);
    _ = dot.dot_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), dot.dot_session_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), dot.dot_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "dot_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(0, 1)); // Idle -> Bound
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(1, 2)); // Bound -> Listening
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(2, 2)); // Listening -> Listening
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(2, 1)); // Listening -> Bound
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(2, 3)); // Listening -> Processing
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(3, 3)); // Processing -> Processing
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(3, 2)); // Processing -> Listening

    // Shutdown edges
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(1, 4)); // Bound -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(2, 4)); // Listening -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(3, 4)); // Processing -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), dot.dot_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), dot.dot_can_transition(0, 2)); // Idle -/-> Listening
    try std.testing.expectEqual(@as(u8, 0), dot.dot_can_transition(0, 3)); // Idle -/-> Processing
    try std.testing.expectEqual(@as(u8, 0), dot.dot_can_transition(4, 1)); // Shutdown -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), dot.dot_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), dot.dot_state(-1));
    try std.testing.expectEqual(@as(u8, 0), dot.dot_can_serve(-1));
    try std.testing.expectEqual(@as(u32, 0), dot.dot_session_count(-1));
    try std.testing.expectEqual(@as(u64, 0), dot.dot_queries_handled(-1));
    try std.testing.expectEqual(@as(u8, 1), dot.dot_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), dot.dot_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot accept session from Idle" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    _ = dot.dot_shutdown(slot);
    _ = dot.dot_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), dot.dot_accept_session(slot));
}

test "cannot handle query from Bound" {
    const slot = dot.dot_create(853, 0);
    defer dot.dot_destroy(slot);

    const query = "dns-query";
    const result = dot.dot_handle_query(slot, 1, query.ptr, query.len);
    try std.testing.expect(result != 0xFF); // should not succeed
}
