/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * grpc.h -- C-ABI header for proven-grpc.
 * Generated from GRPCABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_GRPC_H
#define PROVEN_GRPC_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- FrameType (9 constructors, tags 0-8) --------------------------------- */
#define GRPC_FRAME_DATA          0
#define GRPC_FRAME_HEADERS       1
#define GRPC_FRAME_RST_STREAM    2
#define GRPC_FRAME_SETTINGS      3
#define GRPC_FRAME_PUSH_PROMISE  4
#define GRPC_FRAME_PING          5
#define GRPC_FRAME_GOAWAY        6
#define GRPC_FRAME_WINDOW_UPDATE 7
#define GRPC_FRAME_CONTINUATION  8

/* -- StreamState (6 constructors, tags 0-5) ------------------------------- */
#define GRPC_STREAM_IDLE               0
#define GRPC_STREAM_OPEN               1
#define GRPC_STREAM_HALF_CLOSED_LOCAL  2
#define GRPC_STREAM_HALF_CLOSED_REMOTE 3
#define GRPC_STREAM_CLOSED             4
#define GRPC_STREAM_RESERVED           5

/* -- StatusCode (17 constructors, tags 0-16) ------------------------------ */
#define GRPC_STATUS_OK                  0
#define GRPC_STATUS_CANCELLED           1
#define GRPC_STATUS_UNKNOWN             2
#define GRPC_STATUS_INVALID_ARGUMENT    3
#define GRPC_STATUS_DEADLINE_EXCEEDED   4
#define GRPC_STATUS_NOT_FOUND           5
#define GRPC_STATUS_ALREADY_EXISTS      6
#define GRPC_STATUS_PERMISSION_DENIED   7
#define GRPC_STATUS_RESOURCE_EXHAUSTED  8
#define GRPC_STATUS_FAILED_PRECONDITION 9
#define GRPC_STATUS_ABORTED             10
#define GRPC_STATUS_OUT_OF_RANGE        11
#define GRPC_STATUS_UNIMPLEMENTED       12
#define GRPC_STATUS_INTERNAL            13
#define GRPC_STATUS_UNAVAILABLE         14
#define GRPC_STATUS_DATA_LOSS           15
#define GRPC_STATUS_UNAUTHENTICATED     16
#define GRPC_STATUS_NONE                255

/* -- Compression (5 constructors, tags 0-4) ------------------------------- */
#define GRPC_COMPRESS_IDENTITY 0
#define GRPC_COMPRESS_GZIP     1
#define GRPC_COMPRESS_DEFLATE  2
#define GRPC_COMPRESS_SNAPPY   3
#define GRPC_COMPRESS_ZSTD     4

/* -- StreamType (4 constructors, tags 0-3) -------------------------------- */
#define GRPC_STREAM_TYPE_UNARY            0
#define GRPC_STREAM_TYPE_SERVER_STREAMING 1
#define GRPC_STREAM_TYPE_CLIENT_STREAMING 2
#define GRPC_STREAM_TYPE_BIDI_STREAMING   3

/* -- ContentType (2 constructors, tags 0-1) ------------------------------- */
#define GRPC_CONTENT_PROTOBUF 0
#define GRPC_CONTENT_JSON     1

/* -- ABI ------------------------------------------------------------------ */
uint32_t grpc_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      grpc_create(uint8_t compression);
void     grpc_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  grpc_stream_state(int slot);
uint8_t  grpc_compression(int slot);
uint8_t  grpc_status_code(int slot);
uint8_t  grpc_set_status(int slot, uint8_t status);
uint32_t grpc_stream_id(int slot);

/* -- Stream transitions --------------------------------------------------- */
uint8_t grpc_send_headers(int slot);
uint8_t grpc_local_end_stream(int slot);
uint8_t grpc_remote_end_stream(int slot);
uint8_t grpc_reset_stream(int slot, uint8_t status);
uint8_t grpc_close_half_local(int slot);
uint8_t grpc_close_half_remote(int slot);
uint8_t grpc_push_promise(int slot);
uint8_t grpc_reserved_to_half(int slot);

/* -- Capability queries --------------------------------------------------- */
uint8_t grpc_can_send(int slot);
uint8_t grpc_can_receive(int slot);

/* -- Flow control --------------------------------------------------------- */
int32_t grpc_send_window(int slot);
int32_t grpc_recv_window(int slot);
uint8_t grpc_update_send_window(int slot, int32_t delta);
uint8_t grpc_update_recv_window(int slot, int32_t delta);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t grpc_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_GRPC_H */
