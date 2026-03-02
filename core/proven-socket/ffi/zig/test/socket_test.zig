// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Integration tests for proven-socket FFI.
//
// Verifies that the Zig state machine enforcement works correctly:
//   - ABI version is correct
//   - Socket creation (all domain/type combinations)
//   - Bind lifecycle (Unbound -> Bound)
//   - Listen lifecycle (Bound -> Listening)
//   - Accept lifecycle (Listening -> new Connected)
//   - Connect lifecycle (Unbound -> Connected, client mode)
//   - Send/recv on connected sockets
//   - Shutdown on connected sockets
//   - Invalid transition rejection
//   - Null handle safety
//
// These tests exercise the same invariants that the Idris2 ABI proves
// at compile time, confirming that the runtime implementation honours
// the formal specification.

const std = @import("std");
const socket = @import("socket");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ========================================================================
// ABI version
// ========================================================================

test "ABI version matches" {
    try expectEqual(@as(u32, 1), socket.socket_abi_version());
}

// ========================================================================
// Socket creation
// ========================================================================

test "create IPv4 stream socket" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err);
    try expect(h != null);
    try expectEqual(socket.SocketError.none, err);
    try expectEqual(socket.SocketState.unbound, socket.socket_state(h));

    socket.socket_close(h);
}

test "create IPv6 datagram socket" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv6, .datagram, &err).?;
    try expectEqual(socket.SocketDomain.ipv6, h.domain);
    try expectEqual(socket.SocketType.datagram, h.socket_type);

    socket.socket_close(h);
}

test "create Unix seqpacket socket" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.unix, .seq_packet, &err).?;
    try expectEqual(socket.SocketDomain.unix, h.domain);
    try expectEqual(socket.SocketType.seq_packet, h.socket_type);

    socket.socket_close(h);
}

// ========================================================================
// Server lifecycle: bind -> listen -> accept
// ========================================================================

test "server lifecycle: bind, listen, accept" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;

    // Bind.
    const bind_err = socket.socket_bind(h, null, 8080);
    try expectEqual(socket.SocketError.none, bind_err);
    try expectEqual(socket.SocketState.bound, socket.socket_state(h));
    try expectEqual(@as(u16, 8080), h.port);

    // Listen.
    const listen_err = socket.socket_listen(h, 128);
    try expectEqual(socket.SocketError.none, listen_err);
    try expectEqual(socket.SocketState.listening, socket.socket_state(h));

    // Accept (produces a new connected socket).
    const accepted = socket.socket_accept(h, &err);
    try expect(accepted != null);
    try expectEqual(socket.SocketError.none, err);
    try expectEqual(socket.SocketState.connected, socket.socket_state(accepted));

    // Original socket is still listening.
    try expectEqual(socket.SocketState.listening, socket.socket_state(h));

    socket.socket_close(accepted);
    socket.socket_close(h);
}

// ========================================================================
// Client lifecycle: connect -> send/recv -> close
// ========================================================================

test "client lifecycle: connect, send, recv, close" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;

    // Connect (client mode: Unbound -> Connected).
    const conn_err = socket.socket_connect(h, null, 443);
    try expectEqual(socket.SocketError.none, conn_err);
    try expectEqual(socket.SocketState.connected, socket.socket_state(h));

    // Send.
    var sent: u32 = 0;
    const send_err = socket.socket_send(h, null, 100, &sent);
    try expectEqual(socket.SocketError.none, send_err);
    try expectEqual(@as(u32, 100), sent);

    // Recv.
    var received: u32 = 0;
    const recv_err = socket.socket_recv(h, null, 1024, &received);
    try expectEqual(socket.SocketError.none, recv_err);
    try expectEqual(@as(u32, 0), received); // Skeleton returns 0.

    // Close.
    socket.socket_close(h);
}

// ========================================================================
// Shutdown
// ========================================================================

test "shutdown connected socket" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;
    _ = socket.socket_connect(h, null, 80);

    const shut_err = socket.socket_shutdown(h, .both);
    try expectEqual(socket.SocketError.none, shut_err);
    // Socket remains connected after shutdown in the skeleton.
    try expectEqual(socket.SocketState.connected, socket.socket_state(h));

    socket.socket_close(h);
}

// ========================================================================
// Invalid transitions
// ========================================================================

test "cannot bind when already bound" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;
    _ = socket.socket_bind(h, null, 8080);

    const bind2_err = socket.socket_bind(h, null, 9090);
    try expectEqual(socket.SocketError.address_in_use, bind2_err);

    socket.socket_close(h);
}

test "cannot listen when unbound" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;

    const listen_err = socket.socket_listen(h, 128);
    try expectEqual(socket.SocketError.not_connected, listen_err);

    socket.socket_close(h);
}

test "cannot accept when not listening" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;
    _ = socket.socket_bind(h, null, 8080);

    const accepted = socket.socket_accept(h, &err);
    try expect(accepted == null);
    try expectEqual(socket.SocketError.not_connected, err);

    socket.socket_close(h);
}

test "cannot connect when already connected" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;
    _ = socket.socket_connect(h, null, 443);

    const conn2_err = socket.socket_connect(h, null, 80);
    try expectEqual(socket.SocketError.already_connected, conn2_err);

    socket.socket_close(h);
}

test "cannot send when not connected" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;

    var sent: u32 = 0;
    const send_err = socket.socket_send(h, null, 100, &sent);
    try expectEqual(socket.SocketError.not_connected, send_err);

    socket.socket_close(h);
}

test "cannot recv when not connected" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;

    var received: u32 = 0;
    const recv_err = socket.socket_recv(h, null, 1024, &received);
    try expectEqual(socket.SocketError.not_connected, recv_err);

    socket.socket_close(h);
}

test "cannot shutdown when not connected" {
    var err: socket.SocketError = .none;
    const h = socket.socket_create(.ipv4, .stream, &err).?;

    const shut_err = socket.socket_shutdown(h, .read);
    try expectEqual(socket.SocketError.not_connected, shut_err);

    socket.socket_close(h);
}

// ========================================================================
// Null handle safety
// ========================================================================

test "null handle safety" {
    try expectEqual(socket.SocketState.closed, socket.socket_state(null));
    try expectEqual(socket.SocketError.invalid_address, socket.socket_bind(null, null, 0));
    try expectEqual(socket.SocketError.not_connected, socket.socket_listen(null, 0));
    try expectEqual(socket.SocketError.not_connected, socket.socket_connect(null, null, 0));
    try expectEqual(socket.SocketError.not_connected, socket.socket_shutdown(null, .both));

    var sent: u32 = 0;
    try expectEqual(socket.SocketError.not_connected, socket.socket_send(null, null, 0, &sent));

    var received: u32 = 0;
    try expectEqual(socket.SocketError.not_connected, socket.socket_recv(null, null, 0, &received));

    var err: socket.SocketError = .none;
    try expect(socket.socket_accept(null, &err) == null);
    try expectEqual(socket.SocketError.not_connected, err);
}

test "close null handle is no-op" {
    socket.socket_close(null);
}

// ========================================================================
// Enum tag value consistency
// ========================================================================

test "SocketDomain enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(socket.SocketDomain.ipv4));
    try expectEqual(@as(u8, 1), @intFromEnum(socket.SocketDomain.ipv6));
    try expectEqual(@as(u8, 2), @intFromEnum(socket.SocketDomain.unix));
}

test "SocketType enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(socket.SocketType.stream));
    try expectEqual(@as(u8, 1), @intFromEnum(socket.SocketType.datagram));
    try expectEqual(@as(u8, 2), @intFromEnum(socket.SocketType.seq_packet));
    try expectEqual(@as(u8, 3), @intFromEnum(socket.SocketType.raw));
}

test "SocketState enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(socket.SocketState.unbound));
    try expectEqual(@as(u8, 1), @intFromEnum(socket.SocketState.bound));
    try expectEqual(@as(u8, 2), @intFromEnum(socket.SocketState.listening));
    try expectEqual(@as(u8, 3), @intFromEnum(socket.SocketState.connected));
    try expectEqual(@as(u8, 4), @intFromEnum(socket.SocketState.closed));
    try expectEqual(@as(u8, 5), @intFromEnum(socket.SocketState.err));
}

test "SocketOp enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(socket.SocketOp.bind));
    try expectEqual(@as(u8, 1), @intFromEnum(socket.SocketOp.listen));
    try expectEqual(@as(u8, 2), @intFromEnum(socket.SocketOp.accept));
    try expectEqual(@as(u8, 3), @intFromEnum(socket.SocketOp.connect));
    try expectEqual(@as(u8, 4), @intFromEnum(socket.SocketOp.send));
    try expectEqual(@as(u8, 5), @intFromEnum(socket.SocketOp.recv));
    try expectEqual(@as(u8, 6), @intFromEnum(socket.SocketOp.close));
    try expectEqual(@as(u8, 7), @intFromEnum(socket.SocketOp.shutdown));
}

test "ShutdownMode enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(socket.ShutdownMode.read));
    try expectEqual(@as(u8, 1), @intFromEnum(socket.ShutdownMode.write));
    try expectEqual(@as(u8, 2), @intFromEnum(socket.ShutdownMode.both));
}

test "SocketError enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(socket.SocketError.none));
    try expectEqual(@as(u8, 1), @intFromEnum(socket.SocketError.address_in_use));
    try expectEqual(@as(u8, 2), @intFromEnum(socket.SocketError.connection_refused));
    try expectEqual(@as(u8, 3), @intFromEnum(socket.SocketError.connection_reset));
    try expectEqual(@as(u8, 4), @intFromEnum(socket.SocketError.timed_out));
    try expectEqual(@as(u8, 5), @intFromEnum(socket.SocketError.host_unreachable));
    try expectEqual(@as(u8, 6), @intFromEnum(socket.SocketError.network_unreachable));
    try expectEqual(@as(u8, 7), @intFromEnum(socket.SocketError.permission_denied));
    try expectEqual(@as(u8, 8), @intFromEnum(socket.SocketError.invalid_address));
    try expectEqual(@as(u8, 9), @intFromEnum(socket.SocketError.already_connected));
    try expectEqual(@as(u8, 10), @intFromEnum(socket.SocketError.not_connected));
}
