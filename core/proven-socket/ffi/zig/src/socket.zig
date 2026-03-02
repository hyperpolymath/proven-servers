// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proven-socket FFI -- Zig implementation of the socket ABI.
//
// This module enforces at runtime the state machine transitions that
// the Idris2 ABI proves at compile time.  Together they guarantee that:
//   - Sockets must be bound before listening
//   - Only listening sockets can accept connections
//   - Only connected sockets can send/recv data
//   - Only unbound sockets can be bound or connected (client mode)
//   - Closed and error-state sockets reject all operations
//
// This is a SKELETON implementation -- it enforces the state machine
// and type contracts but does not contain actual OS socket syscalls.
// Real implementations would wrap POSIX/Windows socket APIs behind
// this interface.
//
// Enum tag values MUST match:
//   - Idris2 Layout.idr  (src/SocketABI/Layout.idr)
//   - C header            (generated/abi/socket.h)

const std = @import("std");

// ========================================================================
// ABI constants
// ========================================================================

/// ABI version.  Must match PROVEN_SOCKET_ABI_VERSION in the C header
/// and abiVersion in SocketABI.Foreign.
pub const ABI_VERSION: u32 = 1;

/// Default TCP listen backlog size.  Matches Socket.defaultBacklog.
pub const DEFAULT_BACKLOG: u32 = 128;

/// Maximum simultaneous connections.  Matches Socket.maxConnections.
pub const MAX_CONNECTIONS: u32 = 65535;

// ========================================================================
// Enum types -- tag values match C header and Idris2 Layout.idr exactly
// ========================================================================

/// Socket address family / domain.
/// Tags: IPv4=0, IPv6=1, Unix=2.
pub const SocketDomain = enum(u8) {
    ipv4 = 0,
    ipv6 = 1,
    unix = 2,
};

/// Socket communication semantics.
/// Tags: Stream=0, Datagram=1, SeqPacket=2, Raw=3.
pub const SocketType = enum(u8) {
    stream = 0,
    datagram = 1,
    seq_packet = 2,
    raw = 3,
};

/// Socket lifecycle state.
/// Tags: Unbound=0, Bound=1, Listening=2, Connected=3, Closed=4, Error=5.
pub const SocketState = enum(u8) {
    unbound = 0,
    bound = 1,
    listening = 2,
    connected = 3,
    closed = 4,
    err = 5,
};

/// Socket operation kind.
/// Tags: Bind=0, Listen=1, Accept=2, Connect=3, Send=4, Recv=5, Close=6, Shutdown=7.
pub const SocketOp = enum(u8) {
    bind = 0,
    listen = 1,
    accept = 2,
    connect = 3,
    send = 4,
    recv = 5,
    close = 6,
    shutdown = 7,
};

/// Shutdown direction.
/// Tags: Read=0, Write=1, Both=2.
pub const ShutdownMode = enum(u8) {
    read = 0,
    write = 1,
    both = 2,
};

/// Socket error category.
/// Tags: None=0, AddressInUse=1, ConnectionRefused=2, ConnectionReset=3,
///       TimedOut=4, HostUnreachable=5, NetworkUnreachable=6,
///       PermissionDenied=7, InvalidAddress=8, AlreadyConnected=9,
///       NotConnected=10.
/// Tag 0 (none) has no Idris2 constructor -- it represents success.
pub const SocketError = enum(u8) {
    none = 0,
    address_in_use = 1,
    connection_refused = 2,
    connection_reset = 3,
    timed_out = 4,
    host_unreachable = 5,
    network_unreachable = 6,
    permission_denied = 7,
    invalid_address = 8,
    already_connected = 9,
    not_connected = 10,
};

// ========================================================================
// Opaque handle type
// ========================================================================

/// Socket handle.
/// Tracks socket domain, type, and lifecycle state.
/// Backend-specific context (file descriptor, TLS state, buffers, etc.)
/// would be added by real implementations; this skeleton tracks state only.
pub const SocketHandle = struct {
    /// Current lifecycle state of this socket.
    state: SocketState,
    /// Address family this socket was created with.
    domain: SocketDomain,
    /// Communication semantics of this socket.
    socket_type: SocketType,
    /// Port this socket is bound to (0 if unbound).
    port: u16,
};

// ========================================================================
// Allocator
// ========================================================================

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ========================================================================
// Exported C ABI functions
// ========================================================================

/// Return ABI version for compatibility checking.
pub export fn socket_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Create a new socket.
///
/// State machine: creates a new handle in Unbound state.
/// On allocation failure, returns null and sets err to permission_denied.
///
/// Parameters:
///   domain -- SocketDomain tag (0-2)
///   stype  -- SocketType tag (0-3)
///   err    -- pointer to receive the error code
///
/// Returns: non-null handle on success, null on failure.
pub export fn socket_create(
    domain: SocketDomain,
    stype: SocketType,
    err: *SocketError,
) callconv(.c) ?*SocketHandle {
    const handle = allocator.create(SocketHandle) catch {
        err.* = SocketError.permission_denied;
        return null;
    };

    handle.* = SocketHandle{
        .state = SocketState.unbound,
        .domain = domain,
        .socket_type = stype,
        .port = 0,
    };

    err.* = SocketError.none;
    return handle;
}

/// Bind a socket to a local address and port.
///
/// State machine: Unbound -> Bound.
/// Returns address_in_use if socket is not in Unbound state.
///
/// Parameters:
///   h    -- socket handle
///   addr -- address string (unused in skeleton)
///   port -- port number
///
/// Returns: SocketError.none on success, or an error code.
pub export fn socket_bind(
    h: ?*SocketHandle,
    addr: ?[*:0]const u8,
    port: u16,
) callconv(.c) SocketError {
    const handle = h orelse return SocketError.invalid_address;
    _ = addr;

    switch (handle.state) {
        .unbound => {
            handle.state = SocketState.bound;
            handle.port = port;
            return SocketError.none;
        },
        else => return SocketError.address_in_use,
    }
}

/// Start listening for incoming connections.
///
/// State machine: Bound -> Listening.
/// Returns not_connected if socket is not in Bound state.
/// Backlog is capped at DEFAULT_BACKLOG (128).
///
/// Parameters:
///   h       -- socket handle
///   backlog -- maximum pending connections
///
/// Returns: SocketError.none on success, or an error code.
pub export fn socket_listen(
    h: ?*SocketHandle,
    backlog: u32,
) callconv(.c) SocketError {
    const handle = h orelse return SocketError.not_connected;
    _ = backlog;

    switch (handle.state) {
        .bound => {
            handle.state = SocketState.listening;
            return SocketError.none;
        },
        else => return SocketError.not_connected,
    }
}

/// Accept an incoming connection.
///
/// State machine: creates a new handle in Connected state.
/// The listening socket remains in Listening state.
/// Returns null if socket is not in Listening state.
///
/// Parameters:
///   h   -- listening socket handle
///   err -- pointer to receive the error code
///
/// Returns: new connected handle on success, null on failure.
pub export fn socket_accept(
    h: ?*SocketHandle,
    err: *SocketError,
) callconv(.c) ?*SocketHandle {
    const handle = h orelse {
        err.* = SocketError.not_connected;
        return null;
    };

    switch (handle.state) {
        .listening => {
            const accepted = allocator.create(SocketHandle) catch {
                err.* = SocketError.connection_refused;
                return null;
            };

            accepted.* = SocketHandle{
                .state = SocketState.connected,
                .domain = handle.domain,
                .socket_type = handle.socket_type,
                .port = handle.port,
            };

            err.* = SocketError.none;
            return accepted;
        },
        else => {
            err.* = SocketError.not_connected;
            return null;
        },
    }
}

/// Connect to a remote address (client mode).
///
/// State machine: Unbound -> Connected.
/// Returns already_connected if not in Unbound state.
///
/// Parameters:
///   h    -- socket handle
///   addr -- remote address string (unused in skeleton)
///   port -- remote port
///
/// Returns: SocketError.none on success, or an error code.
pub export fn socket_connect(
    h: ?*SocketHandle,
    addr: ?[*:0]const u8,
    port: u16,
) callconv(.c) SocketError {
    const handle = h orelse return SocketError.invalid_address;
    _ = addr;

    switch (handle.state) {
        .unbound => {
            handle.state = SocketState.connected;
            handle.port = port;
            return SocketError.none;
        },
        .connected => return SocketError.already_connected,
        else => return SocketError.not_connected,
    }
}

/// Send data on a connected socket.
///
/// State machine: requires Connected state (CanSendRecv).
/// On success, *sent is set to len (skeleton sends all bytes).
///
/// Parameters:
///   h    -- socket handle
///   buf  -- data buffer (unused in skeleton)
///   len  -- number of bytes to send
///   sent -- pointer to receive bytes actually sent
///
/// Returns: SocketError.none on success, or an error code.
pub export fn socket_send(
    h: ?*SocketHandle,
    buf: ?*const anyopaque,
    len: u32,
    sent: *u32,
) callconv(.c) SocketError {
    const handle = h orelse return SocketError.not_connected;
    _ = buf;

    switch (handle.state) {
        .connected => {
            sent.* = len; // Skeleton: pretend all bytes sent.
            return SocketError.none;
        },
        else => return SocketError.not_connected,
    }
}

/// Receive data from a connected socket.
///
/// State machine: requires Connected state (CanSendRecv).
/// On success, *received is set to 0 (skeleton has no real data).
///
/// Parameters:
///   h        -- socket handle
///   buf      -- receive buffer (unused in skeleton)
///   len      -- buffer capacity
///   received -- pointer to receive bytes actually read
///
/// Returns: SocketError.none on success, or an error code.
pub export fn socket_recv(
    h: ?*SocketHandle,
    buf: ?*anyopaque,
    len: u32,
    received: *u32,
) callconv(.c) SocketError {
    const handle = h orelse return SocketError.not_connected;
    _ = buf;
    _ = len;

    switch (handle.state) {
        .connected => {
            received.* = 0; // Skeleton: no real data.
            return SocketError.none;
        },
        else => return SocketError.not_connected,
    }
}

/// Shut down part of a connected socket.
///
/// State machine: requires Connected state.
/// The socket remains Connected after shutdown (but some directions
/// are no longer usable; the skeleton does not track this).
///
/// Parameters:
///   h    -- socket handle
///   mode -- ShutdownMode tag (0-2)
///
/// Returns: SocketError.none on success, or an error code.
pub export fn socket_shutdown(
    h: ?*SocketHandle,
    mode: ShutdownMode,
) callconv(.c) SocketError {
    const handle = h orelse return SocketError.not_connected;
    _ = mode;

    switch (handle.state) {
        .connected => return SocketError.none,
        else => return SocketError.not_connected,
    }
}

/// Close and free a socket handle.
///
/// Transitions: any state -> Closed, then frees memory.
/// Safe to call with null (no-op).
pub export fn socket_close(h: ?*SocketHandle) callconv(.c) void {
    const handle = h orelse return;
    handle.state = SocketState.closed;
    allocator.destroy(handle);
}

/// Get the current socket state.
///
/// Returns SocketState.closed if h is null.
pub export fn socket_state(h: ?*const SocketHandle) callconv(.c) SocketState {
    const handle = h orelse return SocketState.closed;
    return handle.state;
}
