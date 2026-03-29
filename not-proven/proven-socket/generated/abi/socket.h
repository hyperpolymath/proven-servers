/*
 * SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * proven-socket ABI -- Generated from Idris2 type definitions.
 * DO NOT EDIT -- regenerate from src/abi/ if types change.
 *
 * ABI Version: 1
 *
 * This header defines the C-ABI-compatible interface between the Idris2
 * type-safe ABI layer and the Zig FFI implementation.  All enum tag values
 * here MUST match the Idris2 Layout.idr encodings and the Zig enum values
 * in ffi/zig/src/socket.zig exactly.
 *
 * Type tag consistency map:
 *
 *   SocketDomain:  Idris2 Layout.idr tags 0-2   = C defines 0-2   = Zig enum 0-2
 *   SocketType:    Idris2 Layout.idr tags 0-3   = C defines 0-3   = Zig enum 0-3
 *   SocketState:   Idris2 Layout.idr tags 0-5   = C defines 0-5   = Zig enum 0-5
 *   SocketOp:      Idris2 Layout.idr tags 0-7   = C defines 0-7   = Zig enum 0-7
 *   ShutdownMode:  Idris2 Layout.idr tags 0-2   = C defines 0-2   = Zig enum 0-2
 *   SocketError:   Idris2 Layout.idr tags 1-10  = C defines 0-10  = Zig enum 0-10
 *                  (tag 0 = SOCKET_ERR_NONE, no Idris2 constructor)
 */

#ifndef PROVEN_SOCKET_H
#define PROVEN_SOCKET_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- ABI version ---- */
#define PROVEN_SOCKET_ABI_VERSION 1

/* ---- SocketDomain (1 byte, tags 0-2) ---- */
typedef uint8_t socket_domain_t;
#define SOCKET_DOMAIN_IPV4 0
#define SOCKET_DOMAIN_IPV6 1
#define SOCKET_DOMAIN_UNIX 2

/* ---- SocketType (1 byte, tags 0-3) ---- */
typedef uint8_t socket_type_t;
#define SOCKET_TYPE_STREAM    0
#define SOCKET_TYPE_DATAGRAM  1
#define SOCKET_TYPE_SEQPACKET 2
#define SOCKET_TYPE_RAW       3

/* ---- SocketState (1 byte, tags 0-5) ---- */
typedef uint8_t socket_state_t;
#define SOCKET_STATE_UNBOUND   0
#define SOCKET_STATE_BOUND     1
#define SOCKET_STATE_LISTENING 2
#define SOCKET_STATE_CONNECTED 3
#define SOCKET_STATE_CLOSED    4
#define SOCKET_STATE_ERROR     5

/* ---- SocketOp (1 byte, tags 0-7) ---- */
typedef uint8_t socket_op_t;
#define SOCKET_OP_BIND     0
#define SOCKET_OP_LISTEN   1
#define SOCKET_OP_ACCEPT   2
#define SOCKET_OP_CONNECT  3
#define SOCKET_OP_SEND     4
#define SOCKET_OP_RECV     5
#define SOCKET_OP_CLOSE    6
#define SOCKET_OP_SHUTDOWN 7

/* ---- ShutdownMode (1 byte, tags 0-2) ---- */
typedef uint8_t socket_shutdown_t;
#define SOCKET_SHUTDOWN_READ  0
#define SOCKET_SHUTDOWN_WRITE 1
#define SOCKET_SHUTDOWN_BOTH  2

/* ---- SocketError (1 byte, tags 0-10; 0 = no error) ---- */
typedef uint8_t socket_error_t;
#define SOCKET_ERR_NONE                0
#define SOCKET_ERR_ADDRESS_IN_USE      1
#define SOCKET_ERR_CONNECTION_REFUSED  2
#define SOCKET_ERR_CONNECTION_RESET    3
#define SOCKET_ERR_TIMED_OUT           4
#define SOCKET_ERR_HOST_UNREACHABLE    5
#define SOCKET_ERR_NETWORK_UNREACHABLE 6
#define SOCKET_ERR_PERMISSION_DENIED   7
#define SOCKET_ERR_INVALID_ADDRESS     8
#define SOCKET_ERR_ALREADY_CONNECTED   9
#define SOCKET_ERR_NOT_CONNECTED       10

/* ---- Opaque handles ---- */
typedef struct socket_handle socket_handle_t;

/* ---- Constants (must match Socket.idr) ---- */
#define SOCKET_DEFAULT_BACKLOG   128
#define SOCKET_MAX_CONNECTIONS   65535

/* ---- Functions ---- */

/** Return ABI version.  Must equal PROVEN_SOCKET_ABI_VERSION. */
uint32_t socket_abi_version(void);

/**
 * Create a new socket.
 * domain must be a valid SocketDomain tag (0-2).
 * type must be a valid SocketType tag (0-3).
 * Returns NULL on failure; sets *err to the error code.
 * On success, the socket is in UNBOUND state.
 */
socket_handle_t *socket_create(socket_domain_t domain, socket_type_t type,
                               socket_error_t *err);

/**
 * Bind a socket to a local address and port.
 * Valid only when the socket is in UNBOUND state.
 * Returns SOCKET_ERR_NONE on success, or an error code.
 */
socket_error_t socket_bind(socket_handle_t *h, const char *addr,
                           uint16_t port);

/**
 * Start listening for incoming connections.
 * Valid only when the socket is in BOUND state.
 * backlog is capped at SOCKET_DEFAULT_BACKLOG (128).
 * Returns SOCKET_ERR_NONE on success, or an error code.
 */
socket_error_t socket_listen(socket_handle_t *h, uint32_t backlog);

/**
 * Accept an incoming connection on a listening socket.
 * Valid only when the socket is in LISTENING state.
 * Returns NULL on failure; sets *err to the error code.
 * On success, returns a new handle in CONNECTED state.
 */
socket_handle_t *socket_accept(socket_handle_t *h, socket_error_t *err);

/**
 * Connect to a remote address.
 * Valid only when the socket is in UNBOUND state (client mode).
 * Returns SOCKET_ERR_NONE on success, or an error code.
 */
socket_error_t socket_connect(socket_handle_t *h, const char *addr,
                              uint16_t port);

/**
 * Send data on a connected socket.
 * Valid only when the socket is in CONNECTED state (CanSendRecv).
 * On success, *sent is set to the number of bytes sent.
 * Returns SOCKET_ERR_NONE on success, or an error code.
 */
socket_error_t socket_send(socket_handle_t *h, const void *buf,
                           uint32_t len, uint32_t *sent);

/**
 * Receive data from a connected socket.
 * Valid only when the socket is in CONNECTED state (CanSendRecv).
 * On success, *received is set to the number of bytes received.
 * Returns SOCKET_ERR_NONE on success, or an error code.
 */
socket_error_t socket_recv(socket_handle_t *h, void *buf,
                           uint32_t len, uint32_t *received);

/**
 * Shut down part of a connected socket.
 * mode must be a valid ShutdownMode tag (0-2).
 * Returns SOCKET_ERR_NONE on success, or an error code.
 */
socket_error_t socket_shutdown(socket_handle_t *h, socket_shutdown_t mode);

/**
 * Close and free a socket handle.
 * Transitions the socket to CLOSED state and frees memory.
 * Safe to call with NULL (no-op).
 */
void socket_close(socket_handle_t *h);

/**
 * Get the current socket state.
 * Returns SOCKET_STATE_CLOSED if h is NULL.
 */
socket_state_t socket_state(const socket_handle_t *h);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_SOCKET_H */
