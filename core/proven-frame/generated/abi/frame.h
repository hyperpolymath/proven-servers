/*
 * SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * proven-frame ABI -- Generated from Idris2 type definitions.
 * DO NOT EDIT -- regenerate from src/abi/ if types change.
 *
 * ABI Version: 1
 *
 * This header defines the C-ABI-compatible interface between the Idris2
 * type-safe ABI layer and the Zig FFI implementation.  All enum tag values
 * here MUST match the Idris2 Layout.idr encodings and the Zig enum values
 * in ffi/zig/src/frame.zig exactly.
 *
 * Type tag consistency map:
 *
 *   FrameStrategy:   Idris2 Layout.idr tags 0-6  = C defines 0-6  = Zig enum 0-6
 *   Delimiter:       Idris2 Layout.idr tags 0-3  = C defines 0-3  = Zig enum 0-3
 *   LengthEncoding:  Idris2 Layout.idr tags 0-4  = C defines 0-4  = Zig enum 0-4
 *   FrameError:      Idris2 Layout.idr tags 1-6  = C defines 0-6  = Zig enum 0-6
 *                    (tag 0 = FRAME_ERR_NONE, no Idris2 constructor)
 *   FrameState:      Idris2 Layout.idr tags 0-3  = C defines 0-3  = Zig enum 0-3
 */

#ifndef PROVEN_FRAME_H
#define PROVEN_FRAME_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- ABI version ---- */
#define PROVEN_FRAME_ABI_VERSION 1

/* ---- FrameStrategy (1 byte, tags 0-6) ---- */
typedef uint8_t frame_strategy_t;
#define FRAME_STRATEGY_LINE_DELIMITED  0
#define FRAME_STRATEGY_LENGTH_PREFIXED 1
#define FRAME_STRATEGY_HTTP_FRAME      2
#define FRAME_STRATEGY_FIXED_SIZE      3
#define FRAME_STRATEGY_CHUNK_ENCODED   4
#define FRAME_STRATEGY_RAW_BYTES       5
#define FRAME_STRATEGY_TLV_FRAME       6

/* ---- Delimiter (1 byte, tags 0-3) ---- */
typedef uint8_t frame_delimiter_t;
#define FRAME_DELIM_CRLF   0
#define FRAME_DELIM_LF     1
#define FRAME_DELIM_NULL   2
#define FRAME_DELIM_CUSTOM 3

/* ---- LengthEncoding (1 byte, tags 0-4) ---- */
typedef uint8_t frame_length_enc_t;
#define FRAME_LEN_BIG_ENDIAN_16    0
#define FRAME_LEN_BIG_ENDIAN_32    1
#define FRAME_LEN_LITTLE_ENDIAN_16 2
#define FRAME_LEN_LITTLE_ENDIAN_32 3
#define FRAME_LEN_VARINT           4

/* ---- FrameError (1 byte, tags 0-6; 0 = no error) ---- */
typedef uint8_t frame_error_t;
#define FRAME_ERR_NONE              0
#define FRAME_ERR_INCOMPLETE        1
#define FRAME_ERR_OVERSIZED         2
#define FRAME_ERR_INVALID_DELIMITER 3
#define FRAME_ERR_INVALID_LENGTH    4
#define FRAME_ERR_MALFORMED_HEADER  5
#define FRAME_ERR_ENCODING_ERROR    6

/* ---- FrameState (1 byte, tags 0-3) ---- */
typedef uint8_t frame_state_t;
#define FRAME_STATE_AWAITING_HEADER  0
#define FRAME_STATE_AWAITING_PAYLOAD 1
#define FRAME_STATE_COMPLETE         2
#define FRAME_STATE_FAILED           3

/* ---- Opaque handles ---- */
typedef struct frame_parser frame_parser_t;

/* ---- Constants (must match Frame.idr) ---- */
#define FRAME_MAX_FRAME_SIZE     16777216
#define FRAME_DEFAULT_BUFFER_SIZE 8192

/* ---- Functions ---- */

/** Return ABI version.  Must equal PROVEN_FRAME_ABI_VERSION. */
uint32_t frame_abi_version(void);

/**
 * Create a new frame parser.
 * strategy must be a valid FrameStrategy tag (0-6).
 * delimiter is used only for LINE_DELIMITED strategy (0-3).
 * length_enc is used only for LENGTH_PREFIXED strategy (0-4).
 * max_size is the maximum frame size (capped at FRAME_MAX_FRAME_SIZE).
 * Returns NULL on failure; sets *err to the error code.
 * On success, the parser is in AWAITING_HEADER state.
 */
frame_parser_t *frame_parser_create(frame_strategy_t strategy,
                                    frame_delimiter_t delimiter,
                                    frame_length_enc_t length_enc,
                                    uint32_t max_size,
                                    frame_error_t *err);

/**
 * Get the current parser state.
 * Returns FRAME_STATE_FAILED if p is NULL.
 */
frame_state_t frame_parser_state(const frame_parser_t *p);

/**
 * Feed data into the parser.
 * Valid only when the parser is in AWAITING_HEADER or AWAITING_PAYLOAD
 * state (the CanDecode states).
 * May transition the parser to a new state depending on the data.
 * Returns FRAME_ERR_NONE on success, or an error code.
 */
frame_error_t frame_feed(frame_parser_t *p, const void *buf, uint32_t len);

/**
 * Emit the assembled frame.
 * Valid only when the parser is in COMPLETE state (CanEmit).
 * Copies the frame data to out_buf and sets *out_len to the frame size.
 * Returns FRAME_ERR_NONE on success, or an error code.
 */
frame_error_t frame_emit(frame_parser_t *p, void *out_buf, uint32_t *out_len);

/**
 * Reset the parser to AWAITING_HEADER state.
 * Valid only when the parser is in COMPLETE or FAILED state (CanReset).
 * Returns FRAME_ERR_NONE on success, or an error code.
 */
frame_error_t frame_reset(frame_parser_t *p);

/**
 * Destroy a frame parser and free its memory.
 * Safe to call with NULL (no-op).
 */
void frame_parser_destroy(frame_parser_t *p);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_FRAME_H */
