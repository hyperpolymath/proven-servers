// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-http3 FFI.
//
// Covers: ABI version, enum tag parity, frame-header parsing, frame/stream
// wire-code classification, the frame-vs-stream rules, and the request-stream
// frame-sequence state machine (legal sequence + illegal orderings).

const std = @import("std");
const h3 = @import("http3");

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), h3.http3_abi_version());
}

test "enum tags match Http3ABI.Types.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(h3.H3Frame.data));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(h3.H3Frame.max_push_id));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(h3.H3StreamType.qpack_decoder));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(h3.ReqState.done));
}

// =========================================================================
// Frame-header parsing + classification
// =========================================================================

test "parse_frame_header decodes the two leading varints" {
    // HEADERS frame (type 0x01), length 0x25 (37) — both one-byte varints.
    const buf = [_]u8{ 0x01, 0x25 };
    var ftype: u64 = 0;
    var flen: u64 = 0;
    const consumed = h3.http3_parse_frame_header(&buf, buf.len, &ftype, &flen);
    try std.testing.expectEqual(@as(i32, 2), consumed);
    try std.testing.expectEqual(@as(u64, 1), ftype);
    try std.testing.expectEqual(@as(u64, 37), flen);
    try std.testing.expectEqual(@as(i32, 1), h3.http3_frame_tag_from_wire(ftype)); // HEADERS tag
}

test "frame header parsing handles a multi-byte length varint" {
    // DATA frame (type 0x00), length 15293 (two-byte varint 0x7b 0xbd).
    const buf = [_]u8{ 0x00, 0x7b, 0xbd };
    var ftype: u64 = 0;
    var flen: u64 = 0;
    const consumed = h3.http3_parse_frame_header(&buf, buf.len, &ftype, &flen);
    try std.testing.expectEqual(@as(i32, 3), consumed);
    try std.testing.expectEqual(@as(u64, 0), ftype);
    try std.testing.expectEqual(@as(u64, 15293), flen);
}

test "frame wire codes round-trip and reject unknowns" {
    // tags 0..6 -> wire -> tag
    var tag: u8 = 0;
    while (tag <= 6) : (tag += 1) {
        const wire = h3.http3_frame_wire_from_tag(tag);
        try std.testing.expect(wire >= 0);
        try std.testing.expectEqual(@as(i32, @intCast(tag)), h3.http3_frame_tag_from_wire(@intCast(wire)));
    }
    // 0x02 and 0x06 are reserved/unused in HTTP/3 -> no tag.
    try std.testing.expectEqual(@as(i32, -1), h3.http3_frame_tag_from_wire(0x02));
    try std.testing.expectEqual(@as(i32, -1), h3.http3_frame_tag_from_wire(0x06));
}

test "stream type wire codes classify correctly" {
    try std.testing.expectEqual(@as(i32, 0), h3.http3_stream_tag_from_wire(0)); // control
    try std.testing.expectEqual(@as(i32, 2), h3.http3_stream_tag_from_wire(2)); // qpack encoder
    try std.testing.expectEqual(@as(i32, -1), h3.http3_stream_tag_from_wire(9));
}

// =========================================================================
// Frame-vs-stream rules (RFC 9114 7.2)
// =========================================================================

test "frame-vs-stream rules match Http3.Frames" {
    const DATA: u8 = 0;
    const HEADERS: u8 = 1;
    const SETTINGS: u8 = 3;
    const GOAWAY: u8 = 5;

    try std.testing.expectEqual(@as(u8, 1), h3.http3_allowed_on_control(SETTINGS));
    try std.testing.expectEqual(@as(u8, 1), h3.http3_allowed_on_control(GOAWAY));
    try std.testing.expectEqual(@as(u8, 0), h3.http3_allowed_on_control(DATA));

    try std.testing.expectEqual(@as(u8, 1), h3.http3_allowed_on_request(HEADERS));
    try std.testing.expectEqual(@as(u8, 1), h3.http3_allowed_on_request(DATA));
    try std.testing.expectEqual(@as(u8, 0), h3.http3_allowed_on_request(SETTINGS));
}

// =========================================================================
// Request-stream state machine (RFC 9114 4.1)
// =========================================================================

test "a legal request frame sequence is accepted" {
    const slot = h3.http3_req_create();
    defer h3.http3_req_destroy(slot);
    try std.testing.expect(slot >= 0);
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_state(slot)); // Init

    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_feed(slot, 1)); // HEADERS
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_state(slot)); // HeadersReceived
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_feed(slot, 0)); // DATA
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_feed(slot, 0)); // more DATA
    try std.testing.expectEqual(@as(u8, 2), h3.http3_req_state(slot)); // DataFlowing
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_feed(slot, 1)); // trailing HEADERS
    try std.testing.expectEqual(@as(u8, 3), h3.http3_req_state(slot)); // Trailers
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_finish(slot)); // -> Done
    try std.testing.expectEqual(@as(u8, 4), h3.http3_req_state(slot));
}

test "DATA before HEADERS is rejected" {
    const slot = h3.http3_req_create();
    defer h3.http3_req_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_feed(slot, 0)); // DATA in Init -> illegal
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_state(slot)); // unchanged
}

test "DATA after trailers is rejected" {
    const slot = h3.http3_req_create();
    defer h3.http3_req_destroy(slot);
    _ = h3.http3_req_feed(slot, 1); // HEADERS
    _ = h3.http3_req_feed(slot, 1); // trailing HEADERS -> Trailers
    try std.testing.expectEqual(@as(u8, 3), h3.http3_req_state(slot));
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_feed(slot, 0)); // DATA -> illegal
}

test "a stream cannot finish before headers" {
    const slot = h3.http3_req_create();
    defer h3.http3_req_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_finish(slot)); // Init -> Done illegal
}

test "req_can_transition mirrors the GADT" {
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_can_transition(0, 1)); // Init->Headers
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_can_transition(2, 2)); // Data->Data
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_can_transition(0, 2)); // Init->Data illegal
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_can_transition(3, 2)); // Trailers->Data illegal
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_can_transition(4, 1)); // Done terminal
}

test "operations are safe on invalid slots" {
    try std.testing.expectEqual(@as(u8, 0), h3.http3_req_state(-1));
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_feed(-1, 1));
    try std.testing.expectEqual(@as(u8, 1), h3.http3_req_finish(999));
    var t: u64 = 0;
    var l: u64 = 0;
    const empty = [_]u8{};
    try std.testing.expectEqual(@as(i32, -1), h3.http3_parse_frame_header(&empty, 0, &t, &l));
}
