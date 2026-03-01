/* SPDX-License-Identifier: PMPL-1.0-or-later */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * cacheconn.h — C ABI header for proven-cacheconn.
 *
 * AUTO-GENERATED from Idris2 ABI definitions.  DO NOT EDIT.
 *
 * Tag values MUST match:
 *   - Idris2:  src/CacheConnABI/Layout.idr
 *   - Zig:     ffi/zig/src/cacheconn.zig
 *
 * ABI version: 1
 */

#ifndef PROVEN_CACHECONN_H
#define PROVEN_CACHECONN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* CacheOp (8 variants, tags 0-7) */
typedef uint8_t cacheconn_op_t;
#define CACHECONN_OP_GET        0
#define CACHECONN_OP_SET        1
#define CACHECONN_OP_DELETE     2
#define CACHECONN_OP_EXISTS     3
#define CACHECONN_OP_EXPIRE     4
#define CACHECONN_OP_INCREMENT  5
#define CACHECONN_OP_DECREMENT  6
#define CACHECONN_OP_FLUSH      7

/* CacheResult (6 variants, tags 0-5) */
typedef uint8_t cacheconn_result_t;
#define CACHECONN_RESULT_HIT      0
#define CACHECONN_RESULT_MISS     1
#define CACHECONN_RESULT_STORED   2
#define CACHECONN_RESULT_DELETED  3
#define CACHECONN_RESULT_EXPIRED  4
#define CACHECONN_RESULT_ERROR    5

/* EvictionPolicy (6 variants, tags 0-5) */
typedef uint8_t cacheconn_eviction_t;
#define CACHECONN_EVICT_LRU          0
#define CACHECONN_EVICT_LFU          1
#define CACHECONN_EVICT_FIFO         2
#define CACHECONN_EVICT_TTL_BASED    3
#define CACHECONN_EVICT_RANDOM       4
#define CACHECONN_EVICT_NO_EVICTION  5

/* CacheState (4 variants, tags 0-3) */
typedef uint8_t cacheconn_state_t;
#define CACHECONN_STATE_DISCONNECTED  0
#define CACHECONN_STATE_CONNECTED     1
#define CACHECONN_STATE_DEGRADED      2
#define CACHECONN_STATE_FAILED        3

/* CacheError (6 variants, tags 1-6; 0 = no error) */
typedef uint8_t cacheconn_error_t;
#define CACHECONN_ERR_NONE                 0
#define CACHECONN_ERR_CONNECTION_LOST      1
#define CACHECONN_ERR_KEY_NOT_FOUND        2
#define CACHECONN_ERR_VALUE_TOO_LARGE      3
#define CACHECONN_ERR_CAPACITY_EXCEEDED    4
#define CACHECONN_ERR_SERIALIZATION_ERROR  5
#define CACHECONN_ERR_TIMEOUT              6

/* Opaque handle types */
typedef struct cacheconn_handle  cacheconn_handle_t;

/* Constants (must match Idris2 CacheConn module) */
#define CACHECONN_DEFAULT_TTL     3600     /* seconds (1 hour) */
#define CACHECONN_MAX_KEY_LENGTH  512      /* bytes */
#define CACHECONN_MAX_VALUE_SIZE  1048576  /* bytes (1 MiB) */

/* Function declarations */
uint32_t cacheconn_abi_version(void);
cacheconn_handle_t *cacheconn_connect(const char *host, uint16_t port,
                                      cacheconn_eviction_t policy,
                                      cacheconn_error_t *err);
cacheconn_error_t cacheconn_disconnect(cacheconn_handle_t *h);
cacheconn_state_t cacheconn_state(const cacheconn_handle_t *h);
cacheconn_result_t cacheconn_get(cacheconn_handle_t *h,
                                 const void *key, uint32_t key_len,
                                 void *val_buf, uint32_t val_cap,
                                 uint32_t *val_len);
cacheconn_result_t cacheconn_set(cacheconn_handle_t *h,
                                 const void *key, uint32_t key_len,
                                 const void *val, uint32_t val_len,
                                 uint32_t ttl);
cacheconn_result_t cacheconn_delete(cacheconn_handle_t *h,
                                    const void *key, uint32_t key_len);
cacheconn_result_t cacheconn_exists(cacheconn_handle_t *h,
                                    const void *key, uint32_t key_len);
cacheconn_error_t cacheconn_flush(cacheconn_handle_t *h);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_CACHECONN_H */
