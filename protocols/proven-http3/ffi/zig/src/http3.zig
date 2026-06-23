// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// http3.zig -- Zig FFI engine for proven-http3 (RFC 9114 structural core).
//
// Provides: HTTP/3 frame-header parsing (two leading QUIC varints), frame
// and unidirectional-stream classification, the frame-vs-stream rules, and a
// mutex-protected pool of request streams running the request-stream
// frame-sequence state machine (HEADERS -> DATA* -> trailing HEADERS).
//
// Out of scope (a full implementation adds these around this core): QPACK
// field compression, the SETTINGS exchange, server push, and HTTP semantics.
//
// Enum values cross the C ABI as u8 tags matching Http3ABI.Types.idr.

const std = @import("std");

// =========================================================================
// Enums (tags must match Http3ABI.Types.idr)
// =========================================================================

pub const H3Frame = enum(u8) {
    data = 0,
    headers = 1,
    cancel_push = 2,
    settings = 3,
    push_promise = 4,
    go_away = 5,
    max_push_id = 6,
};

pub const H3StreamType = enum(u8) {
    control = 0,
    push = 1,
    qpack_encoder = 2,
    qpack_decoder = 3,
};

pub const ReqState = enum(u8) {
    init = 0,
    req_headers = 1,
    data = 2,
    trailers = 3,
    done = 4,
};

// =========================================================================
// Variable-length integer decode (RFC 9000 Section 16) — frame headers use
// QUIC varints. (Same codec as proven-quic; duplicated to keep this engine
// self-contained.)
// =========================================================================

fn varintDecode(in: [*]const u8, len: usize, out_value: *u64) i32 {
    if (len == 0) return -1;
    const prefix: u3 = @intCast(in[0] >> 6);
    const n: usize = @as(usize, 1) << prefix;
    if (len < n) return -1;
    var v: u64 = in[0] & 0x3f;
    var i: usize = 1;
    while (i < n) : (i += 1) v = (v << 8) | in[i];
    out_value.* = v;
    return @intCast(n);
}

/// ABI version. Must match Http3ABI.Foreign.abiVersion.
pub export fn http3_abi_version() callconv(.c) u32 {
    return 1;
}

/// Parse an HTTP/3 frame header: a type varint followed by a length varint.
/// Writes both and returns total bytes consumed, or -1 on a short buffer.
pub export fn http3_parse_frame_header(
    in: [*]const u8,
    len: usize,
    out_type: *u64,
    out_len: *u64,
) callconv(.c) i32 {
    var t: u64 = 0;
    const c1 = varintDecode(in, len, &t);
    if (c1 < 0) return -1;
    const off: usize = @intCast(c1);
    var l: u64 = 0;
    const c2 = varintDecode(in + off, len - off, &l);
    if (c2 < 0) return -1;
    out_type.* = t;
    out_len.* = l;
    return c1 + c2;
}

// =========================================================================
// Frame and stream classification (RFC 9114 Sections 6.2, 7.2)
// =========================================================================

/// Map an on-the-wire frame type code to an H3Frame tag, or -1 if reserved /
/// unknown (a receiver ignores unknown frame types).
pub export fn http3_frame_tag_from_wire(code: u64) callconv(.c) i32 {
    return switch (code) {
        0x00 => 0,
        0x01 => 1,
        0x03 => 2,
        0x04 => 3,
        0x05 => 4,
        0x07 => 5,
        0x0d => 6,
        else => -1,
    };
}

/// Map an H3Frame tag back to its wire type code, or -1 if out of range.
pub export fn http3_frame_wire_from_tag(tag: u8) callconv(.c) i64 {
    return switch (tag) {
        0 => 0x00,
        1 => 0x01,
        2 => 0x03,
        3 => 0x04,
        4 => 0x05,
        5 => 0x07,
        6 => 0x0d,
        else => -1,
    };
}

/// Map a unidirectional stream type code to an H3StreamType tag, or -1.
pub export fn http3_stream_tag_from_wire(code: u64) callconv(.c) i32 {
    return switch (code) {
        0x00 => 0,
        0x01 => 1,
        0x02 => 2,
        0x03 => 3,
        else => -1,
    };
}

/// Whether a frame (by tag) may appear on the control stream.
pub export fn http3_allowed_on_control(frame_tag: u8) callconv(.c) u8 {
    return switch (frame_tag) {
        2, 3, 5, 6 => 1, // CANCEL_PUSH, SETTINGS, GOAWAY, MAX_PUSH_ID
        else => 0,
    };
}

/// Whether a frame (by tag) may appear on a request/push stream.
pub export fn http3_allowed_on_request(frame_tag: u8) callconv(.c) u8 {
    return switch (frame_tag) {
        0, 1, 4 => 1, // DATA, HEADERS, PUSH_PROMISE
        else => 0,
    };
}

// =========================================================================
// Request-stream state machine (RFC 9114 Section 4.1)
// =========================================================================

/// Mirrors Http3.Request.validateReqTransition.
pub export fn http3_req_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Init -> HeadersReceived
    if (from == 1 and to == 2) return 1; // Headers -> Data
    if (from == 2 and to == 2) return 1; // Data -> Data (more body)
    if (from == 1 and to == 3) return 1; // Headers -> Trailers
    if (from == 2 and to == 3) return 1; // Data -> Trailers
    if (from == 1 and to == 4) return 1; // Headers -> Done
    if (from == 2 and to == 4) return 1; // Data -> Done
    if (from == 3 and to == 4) return 1; // Trailers -> Done
    return 0;
}

/// Target state when frame `frame_tag` arrives in state `state`, or -1 if the
/// frame is illegal there. Only DATA/HEADERS drive the message sequence.
fn reqTarget(state: u8, frame_tag: u8) i32 {
    if (frame_tag == 1) { // HEADERS
        return switch (state) {
            0 => 1, // request headers
            1 => 3, // trailers (after headers, empty body)
            2 => 3, // trailers (after body)
            else => -1,
        };
    } else if (frame_tag == 0) { // DATA
        return switch (state) {
            1 => 2, // first body frame
            2 => 2, // more body
            else => -1,
        };
    }
    return -1;
}

const MAX_REQS: usize = 256;

const Req = struct {
    active: bool,
    state: ReqState,
};

var reqs: [MAX_REQS]Req = [_]Req{.{ .active = false, .state = .init }} ** MAX_REQS;
var mutex: std.Thread.Mutex = .{};

fn validReq(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_REQS) return null;
    const idx: usize = @intCast(slot);
    if (!reqs[idx].active) return null;
    return idx;
}

/// Create a request-stream tracker in the Init state. Returns slot or -1.
pub export fn http3_req_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    for (&reqs, 0..) |*r, i| {
        if (!r.active) {
            r.active = true;
            r.state = .init;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn http3_req_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_REQS) return;
    reqs[@intCast(slot)] = .{ .active = false, .state = .init };
}

pub export fn http3_req_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validReq(slot) orelse return 0;
    return @intFromEnum(reqs[idx].state);
}

/// Apply a frame (by tag) to the request stream. Returns 0 if the frame is
/// valid in the current state, 1 otherwise.
pub export fn http3_req_feed(slot: c_int, frame_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validReq(slot) orelse return 1;
    const target = reqTarget(@intFromEnum(reqs[idx].state), frame_tag);
    if (target < 0) return 1;
    reqs[idx].state = @enumFromInt(@as(u8, @intCast(target)));
    return 0;
}

/// End the stream. Legal once headers have been seen; moves to Done.
/// Returns 0 on success, 1 if the stream cannot legally end here.
pub export fn http3_req_finish(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validReq(slot) orelse return 1;
    const s = @intFromEnum(reqs[idx].state);
    if (http3_req_can_transition(s, 4) == 0) return 1;
    reqs[idx].state = .done;
    return 0;
}
