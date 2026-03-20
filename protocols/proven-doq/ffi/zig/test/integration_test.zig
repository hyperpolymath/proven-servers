// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-doq FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Server lifecycle (create/destroy)
//   - Stream management (open/close/count)
//   - Query handling with stream validation
//   - Shutdown / Cleanup (drain/cleanup)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const doq = @import("doq");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), doq.doq_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "StreamType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doq.StreamType.unidirectional));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doq.StreamType.bidirectional));
}

test "ErrorCode encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doq.ErrorCode.no_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doq.ErrorCode.internal_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(doq.ErrorCode.excessive_load));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(doq.ErrorCode.protocol_error));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(doq.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(doq.ServerState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(doq.ServerState.listening));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(doq.ServerState.processing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(doq.ServerState.shutdown));
}

// =========================================================================
// Server lifecycle
// =========================================================================

test "create returns valid slot in Bound state" {
    const slot = doq.doq_create(8853);
    try std.testing.expect(slot >= 0);
    defer doq.doq_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), doq.doq_state(slot)); // Bound
}

test "create rejects port 0" {
    const slot = doq.doq_create(0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    doq.doq_destroy(-1);
    doq.doq_destroy(999);
}

// =========================================================================
// Stream management
// =========================================================================

test "open_stream transitions Bound -> Listening" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), doq.doq_open_stream(slot, 1)); // bidirectional
    try std.testing.expectEqual(@as(u8, 2), doq.doq_state(slot)); // Listening
    try std.testing.expectEqual(@as(u32, 1), doq.doq_stream_count(slot));
}

test "open_stream rejects invalid stream type" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), doq.doq_open_stream(slot, 99));
}

test "close_stream last stream transitions Listening -> Bound" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    try std.testing.expectEqual(@as(u8, 2), doq.doq_state(slot));

    // Stream ID is 1 (first assigned)
    try std.testing.expectEqual(@as(u8, 0), doq.doq_close_stream(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), doq.doq_state(slot)); // Bound
    try std.testing.expectEqual(@as(u32, 0), doq.doq_stream_count(slot));
}

test "close_stream rejects invalid stream_id" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    try std.testing.expectEqual(@as(u8, 1), doq.doq_close_stream(slot, 9999));
}

test "multiple streams stay in Listening" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 0); // unidirectional
    _ = doq.doq_open_stream(slot, 1); // bidirectional
    _ = doq.doq_open_stream(slot, 1); // another bidirectional
    try std.testing.expectEqual(@as(u8, 2), doq.doq_state(slot));
    try std.testing.expectEqual(@as(u32, 3), doq.doq_stream_count(slot));
}

// =========================================================================
// Query handling
// =========================================================================

test "handle_query succeeds on valid stream" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    const query = "dns-query-data";
    try std.testing.expectEqual(@as(u8, 0), doq.doq_handle_query(
        slot, 1, query.ptr, query.len,
    )); // 0 = no_error
}

test "handle_query transitions Listening -> Processing" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    const query = "dns-query-data";
    _ = doq.doq_handle_query(slot, 1, query.ptr, query.len);
    try std.testing.expectEqual(@as(u8, 3), doq.doq_state(slot)); // Processing
}

test "handle_query rejects invalid stream_id" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    const query = "dns-query-data";
    try std.testing.expectEqual(@as(u8, 3), doq.doq_handle_query(
        slot, 9999, query.ptr, query.len,
    )); // 3 = protocol_error
}

test "handle_query tracks queries handled" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    const query = "query";
    _ = doq.doq_handle_query(slot, 1, query.ptr, query.len);
    _ = doq.doq_handle_query(slot, 1, query.ptr, query.len);

    try std.testing.expectEqual(@as(u64, 2), doq.doq_queries_handled(slot));
}

test "can_serve returns 1 from Listening" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_serve(slot));
}

test "can_serve returns 0 from Bound" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), doq.doq_can_serve(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "drain transitions Bound -> Shutdown" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), doq.doq_drain(slot));
    try std.testing.expectEqual(@as(u8, 4), doq.doq_state(slot));
}

test "drain transitions Listening -> Shutdown" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    try std.testing.expectEqual(@as(u8, 0), doq.doq_drain(slot));
    try std.testing.expectEqual(@as(u8, 4), doq.doq_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_drain(slot);
    try std.testing.expectEqual(@as(u8, 0), doq.doq_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), doq.doq_state(slot)); // Idle
}

test "cleanup clears streams" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_open_stream(slot, 1);
    _ = doq.doq_open_stream(slot, 0);

    _ = doq.doq_drain(slot);
    _ = doq.doq_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), doq.doq_stream_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), doq.doq_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "doq_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(0, 1)); // Idle -> Bound
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(1, 2)); // Bound -> Listening
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(2, 2)); // Listening -> Listening
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(2, 1)); // Listening -> Bound
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(2, 3)); // Listening -> Processing
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(3, 3)); // Processing -> Processing
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(3, 2)); // Processing -> Listening

    // Shutdown edges
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(1, 4)); // Bound -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(2, 4)); // Listening -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(3, 4)); // Processing -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), doq.doq_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), doq.doq_can_transition(0, 2)); // Idle -/-> Listening
    try std.testing.expectEqual(@as(u8, 0), doq.doq_can_transition(0, 3)); // Idle -/-> Processing
    try std.testing.expectEqual(@as(u8, 0), doq.doq_can_transition(4, 1)); // Shutdown -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), doq.doq_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), doq.doq_state(-1));
    try std.testing.expectEqual(@as(u8, 0), doq.doq_can_serve(-1));
    try std.testing.expectEqual(@as(u32, 0), doq.doq_stream_count(-1));
    try std.testing.expectEqual(@as(u64, 0), doq.doq_queries_handled(-1));
    try std.testing.expectEqual(@as(u8, 1), doq.doq_drain(-1));
    try std.testing.expectEqual(@as(u8, 1), doq.doq_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot open stream from Idle" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    _ = doq.doq_drain(slot);
    _ = doq.doq_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), doq.doq_open_stream(slot, 1));
}

test "cannot handle query from Bound" {
    const slot = doq.doq_create(8853);
    defer doq.doq_destroy(slot);

    const query = "dns-query";
    const result = doq.doq_handle_query(slot, 1, query.ptr, query.len);
    try std.testing.expect(result != 0); // should not succeed (no_error = 0)
}
