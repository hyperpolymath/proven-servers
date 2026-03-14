// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// grpc_test.zig -- Integration tests for proven-grpc FFI.

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

test "FrameType encoding matches Layout.idr (9 tags)" {
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

test "StreamState encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.StreamState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.StreamState.open));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.StreamState.half_closed_local));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.StreamState.half_closed_remote));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.StreamState.closed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(grpc.StreamState.reserved));
}

test "StatusCode encoding matches Layout.idr (17 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.StatusCode.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.StatusCode.cancelled));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.StatusCode.deadline_exceeded));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(grpc.StatusCode.resource_exhausted));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(grpc.StatusCode.internal));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(grpc.StatusCode.data_loss));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(grpc.StatusCode.unauthenticated));
}

test "Compression encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.Compression.identity));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.Compression.gzip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.Compression.deflate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.Compression.snappy));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(grpc.Compression.zstd));
}

test "StreamType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.StreamType.unary));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.StreamType.server_streaming));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(grpc.StreamType.client_streaming));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(grpc.StreamType.bidi_streaming));
}

test "ContentType encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(grpc.ContentType.protobuf));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(grpc.ContentType.json));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = grpc.grpc_create(0); // Identity compression
    try std.testing.expect(slot >= 0);
    defer grpc.grpc_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_stream_state(slot)); // idle
}

test "create with gzip compression" {
    const slot = grpc.grpc_create(1); // Gzip
    try std.testing.expect(slot >= 0);
    defer grpc.grpc_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_compression(slot)); // gzip
}

test "create with snappy compression" {
    const slot = grpc.grpc_create(3); // Snappy
    try std.testing.expect(slot >= 0);
    defer grpc.grpc_destroy(slot);
    try std.testing.expectEqual(@as(u8, 3), grpc.grpc_compression(slot)); // snappy
}

test "create rejects invalid compression" {
    try std.testing.expectEqual(@as(c_int, -1), grpc.grpc_create(99));
}

test "destroy is safe with invalid slot" {
    grpc.grpc_destroy(-1);
    grpc.grpc_destroy(999);
}

test "stream_id is assigned and odd" {
    const slot = grpc.grpc_create(0);
    try std.testing.expect(slot >= 0);
    defer grpc.grpc_destroy(slot);
    const sid = grpc.grpc_stream_id(slot);
    try std.testing.expect(sid % 2 == 1); // client-initiated = odd
}

// =========================================================================
// Full stream lifecycle: Idle -> Open -> HalfClosedLocal -> Closed
// =========================================================================

test "full lifecycle: Idle -> Open -> HalfClosedLocal -> Closed" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Idle -> Open (HEADERS)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_send_headers(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_stream_state(slot)); // open

    // Open -> HalfClosedLocal (local END_STREAM)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_local_end_stream(slot));
    try std.testing.expectEqual(@as(u8, 2), grpc.grpc_stream_state(slot)); // half_closed_local

    // HalfClosedLocal -> Closed
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_close_half_local(slot));
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(slot)); // closed
}

// =========================================================================
// Full stream lifecycle: Idle -> Open -> HalfClosedRemote -> Closed
// =========================================================================

test "full lifecycle: Idle -> Open -> HalfClosedRemote -> Closed" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Idle -> Open
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_send_headers(slot));

    // Open -> HalfClosedRemote (remote END_STREAM)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_remote_end_stream(slot));
    try std.testing.expectEqual(@as(u8, 3), grpc.grpc_stream_state(slot)); // half_closed_remote

    // HalfClosedRemote -> Closed
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_close_half_remote(slot));
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(slot)); // closed
}

// =========================================================================
// RST_STREAM from various states
// =========================================================================

test "reset_stream from Open" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot); // -> Open
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_reset_stream(slot, 2)); // unknown
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(slot)); // closed
    try std.testing.expectEqual(@as(u8, 2), grpc.grpc_status_code(slot)); // unknown
}

test "reset_stream from HalfClosedLocal" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot); // -> Open
    _ = grpc.grpc_local_end_stream(slot); // -> HalfClosedLocal
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_reset_stream(slot, 1)); // cancelled
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(slot)); // closed
}

test "reset_stream from Reserved" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_push_promise(slot); // -> Reserved
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_reset_stream(slot, 7)); // permission_denied
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(slot)); // closed
}

test "cannot reset_stream from Idle" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_reset_stream(slot, 0)); // rejected
}

test "cannot reset_stream from Closed" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot);
    _ = grpc.grpc_reset_stream(slot, 0); // -> Closed
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_reset_stream(slot, 0)); // rejected
}

// =========================================================================
// PUSH_PROMISE path: Idle -> Reserved -> HalfClosedRemote -> Closed
// =========================================================================

test "push promise lifecycle" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Idle -> Reserved
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_push_promise(slot));
    try std.testing.expectEqual(@as(u8, 5), grpc.grpc_stream_state(slot)); // reserved

    // Reserved -> HalfClosedRemote
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_reserved_to_half(slot));
    try std.testing.expectEqual(@as(u8, 3), grpc.grpc_stream_state(slot)); // half_closed_remote

    // HalfClosedRemote -> Closed
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_close_half_remote(slot));
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(slot)); // closed
}

// =========================================================================
// can_send / can_receive capability checks
// =========================================================================

test "can_send only true for Open and HalfClosedRemote" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Idle — cannot send
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_send(slot));

    // Open — can send
    _ = grpc.grpc_send_headers(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_send(slot));

    // HalfClosedRemote — can still send (local direction open)
    _ = grpc.grpc_remote_end_stream(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_send(slot));
}

test "can_send false for HalfClosedLocal" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot);
    _ = grpc.grpc_local_end_stream(slot);
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_send(slot));
}

test "can_receive only true for Open and HalfClosedLocal" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Idle — cannot receive
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_receive(slot));

    // Open — can receive
    _ = grpc.grpc_send_headers(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_receive(slot));

    // HalfClosedLocal — can still receive (remote direction open)
    _ = grpc.grpc_local_end_stream(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_receive(slot));
}

test "can_receive false for HalfClosedRemote" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot);
    _ = grpc.grpc_remote_end_stream(slot);
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_receive(slot));
}

// =========================================================================
// Invalid transitions (impossibility proofs)
// =========================================================================

test "cannot leave Closed state" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot);
    _ = grpc.grpc_reset_stream(slot, 0); // -> Closed

    // All transitions from Closed should be rejected
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_send_headers(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_local_end_stream(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_remote_end_stream(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_reset_stream(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_close_half_local(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_close_half_remote(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_push_promise(slot));
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_reserved_to_half(slot));
}

test "cannot skip Idle to HalfClosedLocal" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    // Must go through Open first
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_local_end_stream(slot));
}

test "cannot send headers from Open (already opened)" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    _ = grpc.grpc_send_headers(slot); // -> Open
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_send_headers(slot)); // rejected
}

// =========================================================================
// gRPC status code recording
// =========================================================================

test "set_status records code" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Initially no status
    try std.testing.expectEqual(@as(u8, 255), grpc.grpc_status_code(slot));

    // Record Ok
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_set_status(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_status_code(slot));

    // Record DataLoss (15)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_set_status(slot, 15));
    try std.testing.expectEqual(@as(u8, 15), grpc.grpc_status_code(slot));
}

test "set_status rejects invalid tag" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_set_status(slot, 99));
}

// =========================================================================
// Flow control windows
// =========================================================================

test "initial window size is 65535" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    try std.testing.expectEqual(@as(i32, 65535), grpc.grpc_send_window(slot));
    try std.testing.expectEqual(@as(i32, 65535), grpc.grpc_recv_window(slot));
}

test "update_send_window adjusts correctly" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Simulate sending 1000 bytes (negative delta)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_update_send_window(slot, -1000));
    try std.testing.expectEqual(@as(i32, 64535), grpc.grpc_send_window(slot));

    // Simulate receiving WINDOW_UPDATE for 5000 bytes
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_update_send_window(slot, 5000));
    try std.testing.expectEqual(@as(i32, 69535), grpc.grpc_send_window(slot));
}

test "update_recv_window adjusts correctly" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);

    // Simulate receiving 2000 bytes (negative delta)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_update_recv_window(slot, -2000));
    try std.testing.expectEqual(@as(i32, 63535), grpc.grpc_recv_window(slot));

    // Simulate sending WINDOW_UPDATE for 10000 bytes
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_update_recv_window(slot, 10000));
    try std.testing.expectEqual(@as(i32, 73535), grpc.grpc_recv_window(slot));
}

test "window overflow rejected" {
    const slot = grpc.grpc_create(0);
    defer grpc.grpc_destroy(slot);
    // Try to overflow: current is 65535, add max i32
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_update_send_window(slot, 2147483647));
}

test "flow control queries safe on invalid slot" {
    try std.testing.expectEqual(@as(i32, -1), grpc.grpc_send_window(-1));
    try std.testing.expectEqual(@as(i32, -1), grpc.grpc_recv_window(-1));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "grpc_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(0, 1)); // Idle -> Open
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(1, 2)); // Open -> HCL
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(1, 3)); // Open -> HCR
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(1, 4)); // Open -> Closed
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(2, 4)); // HCL -> Closed
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(3, 4)); // HCR -> Closed
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(0, 5)); // Idle -> Reserved
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(5, 3)); // Reserved -> HCR
    try std.testing.expectEqual(@as(u8, 1), grpc.grpc_can_transition(5, 4)); // Reserved -> Closed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(4, 0)); // Closed -> Idle (terminal!)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(4, 1)); // Closed -> Open (terminal!)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(0, 2)); // Idle -> HCL (skip!)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(2, 1)); // HCL -> Open (backwards!)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(5, 1)); // Reserved -> Open (wrong path!)
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_transition(3, 2)); // HCR -> HCL (invalid!)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), grpc.grpc_stream_state(-1));   // closed fallback
    try std.testing.expectEqual(@as(u8, 255), grpc.grpc_compression(-1));
    try std.testing.expectEqual(@as(u8, 255), grpc.grpc_status_code(-1));
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_send(-1));
    try std.testing.expectEqual(@as(u8, 0), grpc.grpc_can_receive(-1));
    try std.testing.expectEqual(@as(u32, 0), grpc.grpc_stream_id(-1));
}

// =========================================================================
// Slot exhaustion
// =========================================================================

test "pool exhaustion returns -1" {
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    // Fill all 64 slots
    for (&slots) |*s| {
        s.* = grpc.grpc_create(0);
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| grpc.grpc_destroy(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), grpc.grpc_create(0));
}
