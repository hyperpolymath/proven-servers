// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// quic.zig -- Zig FFI engine for proven-quic (RFC 9000 transport core).
//
// Provides the parts of QUIC whose correctness is structural:
//   - the variable-length-integer codec (RFC 9000 Section 16)
//   - stream-ID classification + access rules (Sections 2.1, 3)
//   - the frame-in-packet table (Section 12.4)
//   - a mutex-protected pool of connections, each with a stream table that
//     runs the sending/receiving state machines (Sections 3.1, 3.2) and the
//     connection lifecycle (Sections 9-10)
//
// Out of scope (a real stack would add these around this core): TLS 1.3,
// packet protection, congestion control, loss recovery, flow control.
//
// Enum values cross the C ABI as u8 tags matching QuicABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (tags must match QuicABI.Types.idr)
// =========================================================================

pub const Endpoint = enum(u8) { client = 0, server = 1 };
pub const Direction = enum(u8) { bidi = 0, uni = 1 };
pub const StreamKind = enum(u8) { client_bidi = 0, server_bidi = 1, client_uni = 2, server_uni = 3 };
pub const ConnState = enum(u8) { initial = 0, handshaking = 1, connected = 2, closing = 3, draining = 4, closed = 5 };
pub const SendState = enum(u8) { ready = 0, send = 1, data_sent = 2, data_recvd = 3, reset_sent = 4, reset_recvd = 5 };
pub const RecvState = enum(u8) { recv = 0, size_known = 1, data_recvd = 2, data_read = 3, reset_recvd = 4, reset_read = 5 };
pub const PacketType = enum(u8) { initial = 0, zero_rtt = 1, handshake = 2, retry = 3, version_negotiation = 4, one_rtt = 5 };

// =========================================================================
// Variable-length integers (RFC 9000 Section 16)
// =========================================================================

const VARINT_MAX: u64 = (@as(u64, 1) << 62) - 1;

/// Number of bytes needed to encode `value` (1/2/4/8), or -1 if too large.
pub export fn quic_varint_len(value: u64) callconv(.c) i32 {
    if (value < (1 << 6)) return 1;
    if (value < (1 << 14)) return 2;
    if (value < (1 << 30)) return 4;
    if (value <= VARINT_MAX) return 8;
    return -1;
}

/// Encode `value` into `out`; returns bytes written (1/2/4/8) or -1.
pub export fn quic_varint_encode(value: u64, out: [*]u8, cap: usize) callconv(.c) i32 {
    const n = quic_varint_len(value);
    if (n < 0) return -1;
    const un: usize = @intCast(n);
    if (cap < un) return -1;
    var i: usize = 0;
    while (i < un) : (i += 1) {
        out[un - 1 - i] = @truncate(value >> @intCast(8 * i));
    }
    const prefix: u8 = switch (un) {
        1 => 0x00,
        2 => 0x40,
        4 => 0x80,
        else => 0xC0,
    };
    out[0] |= prefix;
    return n;
}

/// Decode a varint from `in`; writes the value and returns bytes consumed
/// (1/2/4/8) or -1 if the buffer is too short.
pub export fn quic_varint_decode(in: [*]const u8, len: usize, out_value: *u64) callconv(.c) i32 {
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

// =========================================================================
// Stream identity and access rules (RFC 9000 Sections 2.1, 3)
// =========================================================================

/// Low two bits of a stream ID: the StreamKind tag (0-3).
pub export fn quic_stream_code(id: u64) callconv(.c) u8 {
    return @intCast(id & 0x3);
}

/// Initiating endpoint of a stream ID (0 = client, 1 = server).
pub export fn quic_stream_initiator(id: u64) callconv(.c) u8 {
    return @intCast(id & 0x1);
}

/// 1 if the stream ID denotes a unidirectional stream.
pub export fn quic_stream_is_uni(id: u64) callconv(.c) u8 {
    return @intCast((id >> 1) & 0x1);
}

fn codeInitiator(code: u8) u8 {
    return code & 0x1;
}
fn codeIsUni(code: u8) u8 {
    return (code >> 1) & 0x1;
}

/// Whether `endpoint` may send on a stream of the given 2-bit kind code.
pub export fn quic_can_send(endpoint: u8, stream_code: u8) callconv(.c) u8 {
    if (stream_code > 3 or endpoint > 1) return 0;
    if (codeIsUni(stream_code) == 0) return 1; // bidirectional
    return if (endpoint == codeInitiator(stream_code)) 1 else 0;
}

/// Whether `endpoint` may receive on a stream of the given 2-bit kind code.
pub export fn quic_can_receive(endpoint: u8, stream_code: u8) callconv(.c) u8 {
    if (stream_code > 3 or endpoint > 1) return 0;
    if (codeIsUni(stream_code) == 0) return 1; // bidirectional
    return if (endpoint != codeInitiator(stream_code)) 1 else 0;
}

// =========================================================================
// Frame-in-packet table (RFC 9000 Section 12.4)
// =========================================================================

/// 1 iff a frame of tag `frame` may appear in a packet of tag `packet`.
pub export fn quic_frame_allowed(frame: u8, packet: u8) callconv(.c) u8 {
    if (frame > 19 or packet > 5) return 0;
    if (packet == 3 or packet == 4) return 0; // Retry, VersionNegotiation: no frames
    return switch (frame) {
        0, 1 => 1, // PADDING, PING: any frame-carrying packet
        2, 5 => if (packet == 0 or packet == 2 or packet == 5) 1 else 0, // ACK, CRYPTO: I/H/1
        18 => 1, // CONNECTION_CLOSE (0x1c): any frame-carrying packet
        6, 17, 19 => if (packet == 5) 1 else 0, // NEW_TOKEN, PATH_RESPONSE, HANDSHAKE_DONE: 1-RTT
        else => if (packet == 1 or packet == 5) 1 else 0, // stream/flow/cid: 0-RTT, 1-RTT
    };
}

// =========================================================================
// Stateless transition tables (mirror Quic.Transitions)
// =========================================================================

pub export fn quic_conn_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Initial -> Handshaking
    if (from == 1 and to == 2) return 1; // Handshaking -> Connected
    if (from == 1 and to == 3) return 1; // Handshaking -> Closing
    if (from == 1 and to == 4) return 1; // Handshaking -> Draining
    if (from == 2 and to == 3) return 1; // Connected -> Closing
    if (from == 2 and to == 4) return 1; // Connected -> Draining
    if (from == 3 and to == 4) return 1; // Closing -> Draining
    if (from == 3 and to == 5) return 1; // Closing -> Closed
    if (from == 4 and to == 5) return 1; // Draining -> Closed
    return 0;
}

pub export fn quic_send_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Ready -> Send
    if (from == 1 and to == 2) return 1; // Send -> DataSent
    if (from == 2 and to == 3) return 1; // DataSent -> DataRecvd
    if (from == 0 and to == 4) return 1; // Ready -> ResetSent
    if (from == 1 and to == 4) return 1; // Send -> ResetSent
    if (from == 2 and to == 4) return 1; // DataSent -> ResetSent
    if (from == 4 and to == 5) return 1; // ResetSent -> ResetRecvd
    return 0;
}

pub export fn quic_recv_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Recv -> SizeKnown
    if (from == 1 and to == 2) return 1; // SizeKnown -> DataRecvd
    if (from == 2 and to == 3) return 1; // DataRecvd -> DataRead
    if (from == 0 and to == 4) return 1; // Recv -> ResetRecvd
    if (from == 1 and to == 4) return 1; // SizeKnown -> ResetRecvd
    if (from == 4 and to == 5) return 1; // ResetRecvd -> ResetRead
    return 0;
}

// =========================================================================
// Connection pool
// =========================================================================

const MAX_CONNS: usize = 64;
const MAX_STREAMS: usize = 256;

const Stream = struct {
    active: bool,
    kind: StreamKind,
    has_send: bool,
    has_recv: bool,
    send: SendState,
    recv: RecvState,
};

const empty_stream: Stream = .{
    .active = false,
    .kind = .client_bidi,
    .has_send = false,
    .has_recv = false,
    .send = .ready,
    .recv = .recv,
};

const Conn = struct {
    active: bool,
    endpoint: Endpoint,
    state: ConnState,
    streams: [MAX_STREAMS]Stream,
    stream_count: u32,
};

const empty_conn: Conn = .{
    .active = false,
    .endpoint = .client,
    .state = .initial,
    .streams = [_]Stream{empty_stream} ** MAX_STREAMS,
    .stream_count = 0,
};

var conns: [MAX_CONNS]Conn = [_]Conn{empty_conn} ** MAX_CONNS;
var mutex: std.Thread.Mutex = .{};

fn validConn(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONNS) return null;
    const idx: usize = @intCast(slot);
    if (!conns[idx].active) return null;
    return idx;
}

/// ABI version. Must match QuicABI.Foreign.abiVersion.
pub export fn quic_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new connection for `endpoint` (0 client, 1 server) in the
/// Initial state. Returns slot (>=0) or -1.
pub export fn quic_create(endpoint: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (endpoint > 1) return -1;
    for (&conns, 0..) |*c, i| {
        if (!c.active) {
            c.* = empty_conn;
            c.endpoint = @enumFromInt(endpoint);
            c.state = .initial;
            c.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn quic_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONNS) return;
    conns[@intCast(slot)] = empty_conn;
}

pub export fn quic_conn_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validConn(slot) orelse return @intFromEnum(ConnState.initial);
    return @intFromEnum(conns[idx].state);
}

/// Attempt a connection transition. Returns 0 on success, 1 if illegal.
pub export fn quic_conn_transition(slot: c_int, to: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validConn(slot) orelse return 1;
    if (to > 5) return 1;
    if (quic_conn_can_transition(@intFromEnum(conns[idx].state), to) == 0) return 1;
    conns[idx].state = @enumFromInt(to);
    return 0;
}

/// Open a stream of the given kind code (0-3). Initialises only the halves
/// this endpoint owns. Returns the stream index (>=0) or -1.
pub export fn quic_open_stream(slot: c_int, stream_code: u8) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validConn(slot) orelse return -1;
    if (stream_code > 3) return -1;
    var c = &conns[idx];
    if (c.stream_count >= MAX_STREAMS) return -1;

    const ep: u8 = @intFromEnum(c.endpoint);
    const i: usize = c.stream_count;
    var s = &c.streams[i];
    s.* = empty_stream;
    s.kind = @enumFromInt(stream_code);
    s.has_send = quic_can_send(ep, stream_code) == 1;
    s.has_recv = quic_can_receive(ep, stream_code) == 1;
    s.send = .ready;
    s.recv = .recv;
    s.active = true;
    c.stream_count += 1;
    return @intCast(i);
}

pub export fn quic_send_state(slot: c_int, idx: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ci = validConn(slot) orelse return 0;
    if (idx >= conns[ci].stream_count) return 0;
    return @intFromEnum(conns[ci].streams[idx].send);
}

pub export fn quic_recv_state(slot: c_int, idx: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ci = validConn(slot) orelse return 0;
    if (idx >= conns[ci].stream_count) return 0;
    return @intFromEnum(conns[ci].streams[idx].recv);
}

/// Transition a stream's sending part. Returns 0 on success, 1 if the stream
/// has no sending part for this endpoint or the move is illegal.
pub export fn quic_send_transition(slot: c_int, idx: u32, to: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ci = validConn(slot) orelse return 1;
    if (idx >= conns[ci].stream_count or to > 5) return 1;
    var s = &conns[ci].streams[idx];
    if (!s.has_send) return 1;
    if (quic_send_can_transition(@intFromEnum(s.send), to) == 0) return 1;
    s.send = @enumFromInt(to);
    return 0;
}

/// Transition a stream's receiving part. Returns 0 on success, 1 otherwise.
pub export fn quic_recv_transition(slot: c_int, idx: u32, to: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ci = validConn(slot) orelse return 1;
    if (idx >= conns[ci].stream_count or to > 5) return 1;
    var s = &conns[ci].streams[idx];
    if (!s.has_recv) return 1;
    if (quic_recv_can_transition(@intFromEnum(s.recv), to) == 0) return 1;
    s.recv = @enumFromInt(to);
    return 0;
}
