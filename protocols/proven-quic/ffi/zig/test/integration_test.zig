// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-quic FFI.
//
// Covers: ABI version, enum tag parity, the RFC 9000 varint codec
// (published vectors + round-trip + bounds), stream-ID classification and
// access rules, the frame-in-packet table, and the connection/stream state
// machines, plus invalid-slot safety.

const std = @import("std");
const quic = @import("quic");

// =========================================================================
// ABI + enum encodings
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), quic.quic_abi_version());
}

test "enum tags match QuicABI.Types.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(quic.Endpoint.client));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(quic.Endpoint.server));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(quic.StreamKind.server_uni));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(quic.ConnState.closed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(quic.SendState.reset_recvd));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(quic.RecvState.reset_read));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(quic.PacketType.one_rtt));
}

// =========================================================================
// Variable-length integers (RFC 9000 Section 16 / Appendix A.1)
// =========================================================================

fn expectEncoding(value: u64, expected: []const u8) !void {
    var buf: [8]u8 = undefined;
    const n = quic.quic_varint_encode(value, &buf, buf.len);
    try std.testing.expectEqual(@as(i32, @intCast(expected.len)), n);
    try std.testing.expectEqualSlices(u8, expected, buf[0..@intCast(n)]);

    var decoded: u64 = 0;
    const c = quic.quic_varint_decode(&buf, @intCast(n), &decoded);
    try std.testing.expectEqual(n, c);
    try std.testing.expectEqual(value, decoded);
}

test "varint matches the RFC 9000 published vectors" {
    try expectEncoding(151288809941952652, &[_]u8{ 0xc2, 0x19, 0x7c, 0x5e, 0xff, 0x14, 0xe8, 0x8c });
    try expectEncoding(494878333, &[_]u8{ 0x9d, 0x7f, 0x3e, 0x7d });
    try expectEncoding(15293, &[_]u8{ 0x7b, 0xbd });
    try expectEncoding(37, &[_]u8{0x25});
}

test "varint picks the minimal length at boundaries" {
    try std.testing.expectEqual(@as(i32, 1), quic.quic_varint_len(63));
    try std.testing.expectEqual(@as(i32, 2), quic.quic_varint_len(64));
    try std.testing.expectEqual(@as(i32, 2), quic.quic_varint_len(16383));
    try std.testing.expectEqual(@as(i32, 4), quic.quic_varint_len(16384));
    try std.testing.expectEqual(@as(i32, 4), quic.quic_varint_len(1073741823));
    try std.testing.expectEqual(@as(i32, 8), quic.quic_varint_len(1073741824));
    // 2^62 is out of range.
    try std.testing.expectEqual(@as(i32, -1), quic.quic_varint_len((@as(u64, 1) << 62)));
}

test "varint rejects short buffers" {
    var small: [1]u8 = undefined;
    try std.testing.expectEqual(@as(i32, -1), quic.quic_varint_encode(16384, &small, small.len));
    // A 4-byte-prefixed buffer truncated to 2 bytes cannot decode.
    const truncated = [_]u8{ 0x80, 0x00 };
    var v: u64 = 0;
    try std.testing.expectEqual(@as(i32, -1), quic.quic_varint_decode(&truncated, truncated.len, &v));
}

// =========================================================================
// Stream identity + access rules
// =========================================================================

test "stream ID classification (RFC 9000 2.1)" {
    try std.testing.expectEqual(@as(u8, 0), quic.quic_stream_code(0)); // client bidi
    try std.testing.expectEqual(@as(u8, 1), quic.quic_stream_code(1)); // server bidi
    try std.testing.expectEqual(@as(u8, 2), quic.quic_stream_code(2)); // client uni
    try std.testing.expectEqual(@as(u8, 3), quic.quic_stream_code(3)); // server uni
    try std.testing.expectEqual(@as(u8, 0), quic.quic_stream_code(4)); // wraps: client bidi

    try std.testing.expectEqual(@as(u8, 1), quic.quic_stream_initiator(3)); // server
    try std.testing.expectEqual(@as(u8, 1), quic.quic_stream_is_uni(3));
    try std.testing.expectEqual(@as(u8, 0), quic.quic_stream_is_uni(1)); // bidi
}

test "access rules match Quic.Streams proofs" {
    // client cannot send on server-uni (code 3); server-uni client CAN receive.
    try std.testing.expectEqual(@as(u8, 0), quic.quic_can_send(0, 3));
    try std.testing.expectEqual(@as(u8, 1), quic.quic_can_receive(0, 3));
    // server cannot send on client-uni (code 2).
    try std.testing.expectEqual(@as(u8, 0), quic.quic_can_send(1, 2));
    // both endpoints send+receive on bidi (codes 0,1).
    try std.testing.expectEqual(@as(u8, 1), quic.quic_can_send(0, 0));
    try std.testing.expectEqual(@as(u8, 1), quic.quic_can_send(1, 0));
    try std.testing.expectEqual(@as(u8, 1), quic.quic_can_receive(0, 1));
    // the initiator of a uni stream cannot receive on it.
    try std.testing.expectEqual(@as(u8, 0), quic.quic_can_receive(0, 2)); // client, client-uni
}

// =========================================================================
// Frame-in-packet table (RFC 9000 12.4)
// =========================================================================

test "frame_allowed matches Quic.Frames pinned facts" {
    const STREAM: u8 = 7;
    const ACK: u8 = 2;
    const CRYPTO: u8 = 5;
    const HANDSHAKE_DONE: u8 = 19;
    const PADDING: u8 = 0;
    const INITIAL: u8 = 0;
    const ZERO_RTT: u8 = 1;
    const RETRY: u8 = 3;
    const ONE_RTT: u8 = 5;

    try std.testing.expectEqual(@as(u8, 0), quic.quic_frame_allowed(STREAM, INITIAL));
    try std.testing.expectEqual(@as(u8, 1), quic.quic_frame_allowed(STREAM, ONE_RTT));
    try std.testing.expectEqual(@as(u8, 0), quic.quic_frame_allowed(ACK, ZERO_RTT));
    try std.testing.expectEqual(@as(u8, 1), quic.quic_frame_allowed(CRYPTO, INITIAL));
    try std.testing.expectEqual(@as(u8, 0), quic.quic_frame_allowed(HANDSHAKE_DONE, INITIAL));
    try std.testing.expectEqual(@as(u8, 1), quic.quic_frame_allowed(PADDING, INITIAL));
    try std.testing.expectEqual(@as(u8, 0), quic.quic_frame_allowed(CRYPTO, RETRY)); // no frames in Retry
}

// =========================================================================
// Connection + stream state machines
// =========================================================================

test "connection lifecycle walks the legal path and rejects illegal moves" {
    const slot = quic.quic_create(0); // client
    defer quic.quic_destroy(slot);
    try std.testing.expect(slot >= 0);
    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_state(slot)); // Initial

    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_transition(slot, 1)); // -> Handshaking
    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_transition(slot, 2)); // -> Connected
    try std.testing.expectEqual(@as(u8, 1), quic.quic_conn_transition(slot, 0)); // Connected -/-> Initial
    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_transition(slot, 3)); // -> Closing
    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_transition(slot, 5)); // -> Closed
    try std.testing.expectEqual(@as(u8, 1), quic.quic_conn_transition(slot, 2)); // Closed is terminal
}

test "bidirectional stream owns both halves; sending state machine runs" {
    const slot = quic.quic_create(0); // client
    defer quic.quic_destroy(slot);
    const sid = quic.quic_open_stream(slot, 0); // client-bidi
    try std.testing.expect(sid >= 0);
    const i: u32 = @intCast(sid);

    try std.testing.expectEqual(@as(u8, 0), quic.quic_send_state(slot, i)); // Ready
    try std.testing.expectEqual(@as(u8, 0), quic.quic_recv_state(slot, i)); // Recv

    try std.testing.expectEqual(@as(u8, 0), quic.quic_send_transition(slot, i, 1)); // Ready->Send
    try std.testing.expectEqual(@as(u8, 0), quic.quic_send_transition(slot, i, 2)); // Send->DataSent
    try std.testing.expectEqual(@as(u8, 0), quic.quic_send_transition(slot, i, 3)); // DataSent->DataRecvd
    try std.testing.expectEqual(@as(u8, 1), quic.quic_send_transition(slot, i, 4)); // DataRecvd terminal
}

test "receiving state machine runs and rejects illegal jumps" {
    const slot = quic.quic_create(1); // server
    defer quic.quic_destroy(slot);
    const sid = quic.quic_open_stream(slot, 0); // client-bidi: server has both halves
    const i: u32 = @intCast(sid);

    // Recv -> DataRecvd is illegal (must pass through SizeKnown).
    try std.testing.expectEqual(@as(u8, 1), quic.quic_recv_transition(slot, i, 2));
    try std.testing.expectEqual(@as(u8, 0), quic.quic_recv_transition(slot, i, 1)); // Recv->SizeKnown
    try std.testing.expectEqual(@as(u8, 0), quic.quic_recv_transition(slot, i, 2)); // ->DataRecvd
    try std.testing.expectEqual(@as(u8, 0), quic.quic_recv_transition(slot, i, 3)); // ->DataRead
}

test "unidirectional stream exposes only the owned half" {
    const slot = quic.quic_create(0); // client
    defer quic.quic_destroy(slot);
    // client opens a client-uni stream (code 2): it has the sending half only.
    const sid = quic.quic_open_stream(slot, 2);
    const i: u32 = @intCast(sid);
    try std.testing.expectEqual(@as(u8, 0), quic.quic_send_transition(slot, i, 1)); // send half works
    try std.testing.expectEqual(@as(u8, 1), quic.quic_recv_transition(slot, i, 1)); // no recv half
}

test "stateless transition tables match the GADTs" {
    try std.testing.expectEqual(@as(u8, 1), quic.quic_conn_can_transition(1, 2)); // Handshaking->Connected
    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_can_transition(5, 2)); // Closed terminal
    try std.testing.expectEqual(@as(u8, 1), quic.quic_send_can_transition(2, 4)); // DataSent->ResetSent
    try std.testing.expectEqual(@as(u8, 0), quic.quic_send_can_transition(3, 4)); // DataRecvd terminal
    try std.testing.expectEqual(@as(u8, 1), quic.quic_recv_can_transition(0, 4)); // Recv->ResetRecvd
    try std.testing.expectEqual(@as(u8, 0), quic.quic_recv_can_transition(3, 2)); // DataRead terminal
}

// =========================================================================
// Safety
// =========================================================================

test "operations are safe on invalid slots / inputs" {
    try std.testing.expectEqual(@as(c_int, -1), quic.quic_create(9)); // bad endpoint
    try std.testing.expectEqual(@as(u8, 0), quic.quic_conn_state(-1)); // initial fallback
    try std.testing.expectEqual(@as(u8, 1), quic.quic_conn_transition(-1, 1));
    try std.testing.expectEqual(@as(i32, -1), quic.quic_open_stream(-1, 0));
    try std.testing.expectEqual(@as(u8, 0), quic.quic_can_send(0, 9)); // bad code
}
