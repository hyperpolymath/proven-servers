/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * wire.h — C-ABI header for proven-wire.
 * Generated from WireABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_WIRE_H
#define PROVEN_WIRE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ── Endianness (4 constructors, tags 0-3) ───────────────────────────── */
#define WIRE_BIG_ENDIAN    0
#define WIRE_LITTLE_ENDIAN 1
#define WIRE_NETWORK_ORDER 2
#define WIRE_HOST_ORDER    3

/* ── WireType (16 constructors, tags 0-15) ───────────────────────────── */
#define WIRE_TYPE_UINT8       0
#define WIRE_TYPE_UINT16      1
#define WIRE_TYPE_UINT32      2
#define WIRE_TYPE_UINT64      3
#define WIRE_TYPE_INT8        4
#define WIRE_TYPE_INT16       5
#define WIRE_TYPE_INT32       6
#define WIRE_TYPE_INT64       7
#define WIRE_TYPE_FLOAT32     8
#define WIRE_TYPE_FLOAT64     9
#define WIRE_TYPE_BOOL        10
#define WIRE_TYPE_UTF8STRING  11
#define WIRE_TYPE_BYTES       12
#define WIRE_TYPE_OPTIONAL    13
#define WIRE_TYPE_SEQUENCE    14
#define WIRE_TYPE_RECORD      15

/* ── EncodeError (6 constructors, tags 0-5) ──────────────────────────── */
#define WIRE_ENC_OVERFLOW      0
#define WIRE_ENC_UNDERFLOW     1
#define WIRE_ENC_INVALID_UTF8  2
#define WIRE_ENC_BUFFER_FULL   3
#define WIRE_ENC_FIELD_MISSING 4
#define WIRE_ENC_TYPE_MISMATCH 5
#define WIRE_ENC_OK            255

/* ── DecodeError (6 constructors, tags 0-5) ──────────────────────────── */
#define WIRE_DEC_UNEXPECTED_EOF      0
#define WIRE_DEC_INVALID_TAG         1
#define WIRE_DEC_INVALID_LENGTH      2
#define WIRE_DEC_MALFORMED_DATA      3
#define WIRE_DEC_UNSUPPORTED_VERSION 4
#define WIRE_DEC_CHECKSUM_MISMATCH   5
#define WIRE_DEC_OK                  255

/* ── Codec (3 constructors, tags 0-2) ────────────────────────────────── */
#define WIRE_CODEC_ENCODE    0
#define WIRE_CODEC_DECODE    1
#define WIRE_CODEC_ROUNDTRIP 2

/* ── CodecState (5 constructors, tags 0-4) ───────────────────────────── */
#define WIRE_STATE_IDLE     0
#define WIRE_STATE_ENCODING 1
#define WIRE_STATE_DECODING 2
#define WIRE_STATE_COMPLETE 3
#define WIRE_STATE_FAILED   4

/* ── ABI ─────────────────────────────────────────────────────────────── */
uint32_t wire_abi_version(void);

/* ── Lifecycle ───────────────────────────────────────────────────────── */
int      wire_create(uint8_t endianness);
void     wire_destroy(int slot);

/* ── State ───────────────────────────────────────────────────────────── */
uint8_t  wire_state(int slot);
uint8_t  wire_last_error(int slot);
uint32_t wire_bytes_written(int slot);

/* ── Transitions ─────────────────────────────────────────────────────── */
uint8_t wire_begin_encode(int slot);
uint8_t wire_begin_decode(int slot);
uint8_t wire_finalize(int slot);
uint8_t wire_fail(int slot, uint8_t err_tag);
uint8_t wire_reset(int slot);

/* ── Encode ──────────────────────────────────────────────────────────── */
uint8_t wire_encode_u8(int slot, uint8_t val);
uint8_t wire_encode_u16(int slot, uint16_t val);
uint8_t wire_encode_u32(int slot, uint32_t val);
uint8_t wire_encode_u64(int slot, uint64_t val);

/* ── Decode ──────────────────────────────────────────────────────────── */
uint8_t wire_decode_u8(int slot, uint8_t *out);
uint8_t wire_decode_u16(int slot, uint16_t *out);
uint8_t wire_decode_u32(int slot, uint32_t *out);
uint8_t wire_decode_u64(int slot, uint64_t *out);

/* ── Stateless queries ───────────────────────────────────────────────── */
uint8_t wire_type_byte_size(uint8_t wtype);
uint8_t wire_is_fixed_size(uint8_t wtype);
uint8_t wire_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_WIRE_H */
