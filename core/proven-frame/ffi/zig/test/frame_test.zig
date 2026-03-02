// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Integration tests for proven-frame FFI.
//
// Verifies that the Zig state machine enforcement works correctly:
//   - ABI version is correct
//   - Parser creation with various strategies
//   - Feed lifecycle (AwaitingHeader -> AwaitingPayload -> Complete)
//   - Direct completion for line-delimited strategies
//   - Frame emission from Complete state
//   - Reset lifecycle (Complete/Failed -> AwaitingHeader)
//   - Size limit enforcement
//   - Invalid transition rejection
//   - Null handle safety
//
// These tests exercise the same invariants that the Idris2 ABI proves
// at compile time, confirming that the runtime implementation honours
// the formal specification.

const std = @import("std");
const frame = @import("frame");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ========================================================================
// ABI version
// ========================================================================

test "ABI version matches" {
    try expectEqual(@as(u32, 1), frame.frame_abi_version());
}

// ========================================================================
// Parser creation
// ========================================================================

test "create line-delimited parser" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err);
    try expect(p != null);
    try expectEqual(frame.FrameError.none, err);
    try expectEqual(frame.FrameState.awaiting_header, frame.frame_parser_state(p));

    frame.frame_parser_destroy(p);
}

test "create length-prefixed parser" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.length_prefixed, .crlf, .big_endian_32, 65536, &err).?;
    try expectEqual(frame.FrameStrategy.length_prefixed, p.strategy);
    try expectEqual(frame.LengthEncoding.big_endian_32, p.length_enc);

    frame.frame_parser_destroy(p);
}

test "create HTTP frame parser" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.http_frame, .crlf, .big_endian_16, 1048576, &err).?;
    try expectEqual(frame.FrameStrategy.http_frame, p.strategy);

    frame.frame_parser_destroy(p);
}

test "max size is capped" {
    var err: frame.FrameError = .none;
    // Request 100MB -- should be capped to MAX_FRAME_SIZE (16MB).
    const p = frame.frame_parser_create(.raw_bytes, .lf, .big_endian_16, 100_000_000, &err).?;
    try expectEqual(@as(u32, 16777216), p.max_size);

    frame.frame_parser_destroy(p);
}

// ========================================================================
// Line-delimited lifecycle: feed -> complete (direct)
// ========================================================================

test "line-delimited: feed completes directly" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err).?;

    // Feed data -- line-delimited completes on first feed (skeleton).
    const feed_err = frame.frame_feed(p, null, 42);
    try expectEqual(frame.FrameError.none, feed_err);
    try expectEqual(frame.FrameState.complete, frame.frame_parser_state(p));

    // Emit the frame.
    var out_len: u32 = 0;
    const emit_err = frame.frame_emit(p, null, &out_len);
    try expectEqual(frame.FrameError.none, emit_err);
    try expectEqual(@as(u32, 42), out_len);

    frame.frame_parser_destroy(p);
}

test "raw-bytes: feed completes directly" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.raw_bytes, .lf, .big_endian_16, 8192, &err).?;

    const feed_err = frame.frame_feed(p, null, 100);
    try expectEqual(frame.FrameError.none, feed_err);
    try expectEqual(frame.FrameState.complete, frame.frame_parser_state(p));

    frame.frame_parser_destroy(p);
}

// ========================================================================
// Two-phase lifecycle: feed header -> feed payload -> complete
// ========================================================================

test "length-prefixed: two-phase parsing" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.length_prefixed, .crlf, .big_endian_32, 65536, &err).?;

    // Feed header data -- transitions to AwaitingPayload.
    const feed1_err = frame.frame_feed(p, null, 4);
    try expectEqual(frame.FrameError.none, feed1_err);
    try expectEqual(frame.FrameState.awaiting_payload, frame.frame_parser_state(p));

    // Feed payload data -- transitions to Complete.
    const feed2_err = frame.frame_feed(p, null, 256);
    try expectEqual(frame.FrameError.none, feed2_err);
    try expectEqual(frame.FrameState.complete, frame.frame_parser_state(p));

    // Emit.
    var out_len: u32 = 0;
    const emit_err = frame.frame_emit(p, null, &out_len);
    try expectEqual(frame.FrameError.none, emit_err);
    try expectEqual(@as(u32, 260), out_len); // 4 (header) + 256 (payload)

    frame.frame_parser_destroy(p);
}

test "HTTP frame: two-phase parsing" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.http_frame, .crlf, .big_endian_16, 1048576, &err).?;

    // Feed headers.
    const feed1_err = frame.frame_feed(p, null, 128);
    try expectEqual(frame.FrameError.none, feed1_err);
    try expectEqual(frame.FrameState.awaiting_payload, frame.frame_parser_state(p));

    // Feed body.
    const feed2_err = frame.frame_feed(p, null, 512);
    try expectEqual(frame.FrameError.none, feed2_err);
    try expectEqual(frame.FrameState.complete, frame.frame_parser_state(p));

    frame.frame_parser_destroy(p);
}

// ========================================================================
// Reset lifecycle
// ========================================================================

test "reset from Complete to AwaitingHeader" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err).?;

    _ = frame.frame_feed(p, null, 10);
    try expectEqual(frame.FrameState.complete, frame.frame_parser_state(p));

    const reset_err = frame.frame_reset(p);
    try expectEqual(frame.FrameError.none, reset_err);
    try expectEqual(frame.FrameState.awaiting_header, frame.frame_parser_state(p));
    try expectEqual(@as(u32, 0), p.bytes_fed);

    frame.frame_parser_destroy(p);
}

test "reset from Failed to AwaitingHeader" {
    var err: frame.FrameError = .none;
    // Create with tiny max_size so feeding triggers oversized failure.
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 10, &err).?;

    // Feed too much data -- triggers oversized -> Failed.
    const feed_err = frame.frame_feed(p, null, 100);
    try expectEqual(frame.FrameError.oversized, feed_err);
    try expectEqual(frame.FrameState.failed, frame.frame_parser_state(p));

    // Reset from Failed.
    const reset_err = frame.frame_reset(p);
    try expectEqual(frame.FrameError.none, reset_err);
    try expectEqual(frame.FrameState.awaiting_header, frame.frame_parser_state(p));

    frame.frame_parser_destroy(p);
}

test "multi-frame: parse, emit, reset, parse again" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err).?;

    // First frame.
    _ = frame.frame_feed(p, null, 50);
    var out_len: u32 = 0;
    _ = frame.frame_emit(p, null, &out_len);
    try expectEqual(@as(u32, 50), out_len);

    // Reset.
    _ = frame.frame_reset(p);

    // Second frame.
    _ = frame.frame_feed(p, null, 75);
    _ = frame.frame_emit(p, null, &out_len);
    try expectEqual(@as(u32, 75), out_len);

    frame.frame_parser_destroy(p);
}

// ========================================================================
// Size limit enforcement
// ========================================================================

test "oversized frame triggers failure" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.length_prefixed, .crlf, .big_endian_32, 100, &err).?;

    const feed_err = frame.frame_feed(p, null, 200);
    try expectEqual(frame.FrameError.oversized, feed_err);
    try expectEqual(frame.FrameState.failed, frame.frame_parser_state(p));

    frame.frame_parser_destroy(p);
}

// ========================================================================
// Invalid transitions
// ========================================================================

test "cannot feed when Complete" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err).?;
    _ = frame.frame_feed(p, null, 10);

    const feed2_err = frame.frame_feed(p, null, 10);
    try expectEqual(frame.FrameError.encoding_error, feed2_err);

    frame.frame_parser_destroy(p);
}

test "cannot feed when Failed" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 5, &err).?;
    _ = frame.frame_feed(p, null, 100); // Triggers oversized -> Failed.

    const feed2_err = frame.frame_feed(p, null, 1);
    try expectEqual(frame.FrameError.encoding_error, feed2_err);

    frame.frame_parser_destroy(p);
}

test "cannot emit when AwaitingHeader" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err).?;

    var out_len: u32 = 0;
    const emit_err = frame.frame_emit(p, null, &out_len);
    try expectEqual(frame.FrameError.incomplete, emit_err);

    frame.frame_parser_destroy(p);
}

test "cannot emit when AwaitingPayload" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.length_prefixed, .crlf, .big_endian_32, 65536, &err).?;
    _ = frame.frame_feed(p, null, 4); // AwaitingPayload.

    var out_len: u32 = 0;
    const emit_err = frame.frame_emit(p, null, &out_len);
    try expectEqual(frame.FrameError.incomplete, emit_err);

    frame.frame_parser_destroy(p);
}

test "cannot reset when AwaitingHeader" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.line_delimited, .lf, .big_endian_16, 4096, &err).?;

    const reset_err = frame.frame_reset(p);
    try expectEqual(frame.FrameError.encoding_error, reset_err);

    frame.frame_parser_destroy(p);
}

test "cannot reset when AwaitingPayload" {
    var err: frame.FrameError = .none;
    const p = frame.frame_parser_create(.length_prefixed, .crlf, .big_endian_32, 65536, &err).?;
    _ = frame.frame_feed(p, null, 4); // AwaitingPayload.

    const reset_err = frame.frame_reset(p);
    try expectEqual(frame.FrameError.encoding_error, reset_err);

    frame.frame_parser_destroy(p);
}

// ========================================================================
// Null handle safety
// ========================================================================

test "null handle safety" {
    try expectEqual(frame.FrameState.failed, frame.frame_parser_state(null));
    try expectEqual(frame.FrameError.malformed_header, frame.frame_feed(null, null, 0));
    try expectEqual(frame.FrameError.malformed_header, frame.frame_reset(null));

    var out_len: u32 = 0;
    try expectEqual(frame.FrameError.malformed_header, frame.frame_emit(null, null, &out_len));
}

test "destroy null handle is no-op" {
    frame.frame_parser_destroy(null);
}

// ========================================================================
// Enum tag value consistency
// ========================================================================

test "FrameStrategy enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(frame.FrameStrategy.line_delimited));
    try expectEqual(@as(u8, 1), @intFromEnum(frame.FrameStrategy.length_prefixed));
    try expectEqual(@as(u8, 2), @intFromEnum(frame.FrameStrategy.http_frame));
    try expectEqual(@as(u8, 3), @intFromEnum(frame.FrameStrategy.fixed_size));
    try expectEqual(@as(u8, 4), @intFromEnum(frame.FrameStrategy.chunk_encoded));
    try expectEqual(@as(u8, 5), @intFromEnum(frame.FrameStrategy.raw_bytes));
    try expectEqual(@as(u8, 6), @intFromEnum(frame.FrameStrategy.tlv_frame));
}

test "Delimiter enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(frame.Delimiter.crlf));
    try expectEqual(@as(u8, 1), @intFromEnum(frame.Delimiter.lf));
    try expectEqual(@as(u8, 2), @intFromEnum(frame.Delimiter.null_));
    try expectEqual(@as(u8, 3), @intFromEnum(frame.Delimiter.custom));
}

test "LengthEncoding enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(frame.LengthEncoding.big_endian_16));
    try expectEqual(@as(u8, 1), @intFromEnum(frame.LengthEncoding.big_endian_32));
    try expectEqual(@as(u8, 2), @intFromEnum(frame.LengthEncoding.little_endian_16));
    try expectEqual(@as(u8, 3), @intFromEnum(frame.LengthEncoding.little_endian_32));
    try expectEqual(@as(u8, 4), @intFromEnum(frame.LengthEncoding.varint));
}

test "FrameError enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(frame.FrameError.none));
    try expectEqual(@as(u8, 1), @intFromEnum(frame.FrameError.incomplete));
    try expectEqual(@as(u8, 2), @intFromEnum(frame.FrameError.oversized));
    try expectEqual(@as(u8, 3), @intFromEnum(frame.FrameError.invalid_delimiter));
    try expectEqual(@as(u8, 4), @intFromEnum(frame.FrameError.invalid_length));
    try expectEqual(@as(u8, 5), @intFromEnum(frame.FrameError.malformed_header));
    try expectEqual(@as(u8, 6), @intFromEnum(frame.FrameError.encoding_error));
}

test "FrameState enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(frame.FrameState.awaiting_header));
    try expectEqual(@as(u8, 1), @intFromEnum(frame.FrameState.awaiting_payload));
    try expectEqual(@as(u8, 2), @intFromEnum(frame.FrameState.complete));
    try expectEqual(@as(u8, 3), @intFromEnum(frame.FrameState.failed));
}
