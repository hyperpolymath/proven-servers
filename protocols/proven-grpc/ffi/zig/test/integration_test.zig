// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-grpc FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const grpc = @import("grpc");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), grpc.grpc_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "FrameType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.FrameType.data));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.FrameType.headers));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.FrameType.rst_stream));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.FrameType.settings));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.FrameType.push_promise));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(grpc.FrameType.ping));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(grpc.FrameType.goaway));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(grpc.FrameType.window_update));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(grpc.FrameType.continuation));
}

test "StreamState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.StreamState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.StreamState.open));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.StreamState.half_closed_local));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.StreamState.half_closed_remote));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.StreamState.closed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(grpc.StreamState.reserved));
}

test "StatusCode encoding matches Types.idr (17 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.StatusCode.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.StatusCode.cancelled));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.StatusCode.unknown));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.StatusCode.invalid_argument));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.StatusCode.deadline_exceeded));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(grpc.StatusCode.not_found));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(grpc.StatusCode.already_exists));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(grpc.StatusCode.permission_denied));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(grpc.StatusCode.resource_exhausted));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(grpc.StatusCode.failed_precondition));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(grpc.StatusCode.aborted));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(grpc.StatusCode.out_of_range));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(grpc.StatusCode.unimplemented));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(grpc.StatusCode.internal));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(grpc.StatusCode.unavailable));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(grpc.StatusCode.data_loss));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(grpc.StatusCode.unauthenticated));
}

test "Compression encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.Compression.identity));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.Compression.gzip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.Compression.deflate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.Compression.snappy));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.Compression.zstd));
}

test "StreamType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.StreamType.unary));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.StreamType.server_streaming));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.StreamType.client_streaming));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.StreamType.bidi_streaming));
}

test "ContentType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.ContentType.protobuf));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.ContentType.json));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = grpc.grpc_create(0);
    try std.testing.expect(slot >= 0);
    defer grpc.grpc_destroy(slot);
    const state = grpc.grpc_stream_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    grpc.grpc_destroy(-1);
    grpc.grpc_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = grpc.grpc_stream_state(-1);
}

