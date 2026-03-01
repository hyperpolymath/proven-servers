/*
 * SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * proven-dbconn ABI -- Generated from Idris2 type definitions.
 * DO NOT EDIT -- regenerate from src/abi/ if types change.
 *
 * ABI Version: 1
 *
 * This header defines the C-ABI-compatible interface between the Idris2
 * type-safe ABI layer and the Zig FFI implementation.  All enum tag values
 * here MUST match the Idris2 Layout.idr encodings and the Zig enum values
 * in ffi/zig/src/dbconn.zig exactly.
 *
 * Type tag consistency map:
 *
 *   ConnState:      Idris2 Layout.idr tags 0-3  = C defines 0-3  = Zig enum 0-3
 *   IsolationLevel: Idris2 Layout.idr tags 0-4  = C defines 0-4  = Zig enum 0-4
 *   ParamType:      Idris2 Layout.idr tags 0-7  = C defines 0-7  = Zig enum 0-7
 *   QueryResult:    Idris2 Layout.idr tags 0-3  = C defines 0-3  = Zig enum 0-3
 *   ConnError:      Idris2 Layout.idr tags 1-8  = C defines 0-8  = Zig enum 0-8
 *                   (tag 0 = DBCONN_ERR_NONE, no Idris2 constructor)
 *   PoolState:      Idris2 Layout.idr tags 0-3  = C defines 0-3  = Zig enum 0-3
 */

#ifndef PROVEN_DBCONN_H
#define PROVEN_DBCONN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- ABI version ---- */
#define PROVEN_DBCONN_ABI_VERSION 1

/* ---- ConnState (1 byte, tags 0-3) ---- */
typedef uint8_t dbconn_state_t;
#define DBCONN_STATE_DISCONNECTED   0
#define DBCONN_STATE_CONNECTED      1
#define DBCONN_STATE_IN_TRANSACTION 2
#define DBCONN_STATE_FAILED         3

/* ---- IsolationLevel (1 byte, tags 0-4) ---- */
typedef uint8_t dbconn_isolation_t;
#define DBCONN_ISO_READ_UNCOMMITTED 0
#define DBCONN_ISO_READ_COMMITTED   1
#define DBCONN_ISO_REPEATABLE_READ  2
#define DBCONN_ISO_SERIALIZABLE     3
#define DBCONN_ISO_SNAPSHOT         4

/* ---- ParamType (1 byte, tags 0-7) ---- */
typedef uint8_t dbconn_param_type_t;
#define DBCONN_PARAM_TEXT      0
#define DBCONN_PARAM_INT       1
#define DBCONN_PARAM_FLOAT     2
#define DBCONN_PARAM_BOOL      3
#define DBCONN_PARAM_NULL      4
#define DBCONN_PARAM_BYTES     5
#define DBCONN_PARAM_TIMESTAMP 6
#define DBCONN_PARAM_UUID      7

/* ---- QueryResult (1 byte, tags 0-3) ---- */
typedef uint8_t dbconn_query_result_t;
#define DBCONN_RESULT_SET       0
#define DBCONN_RESULT_ROW_COUNT 1
#define DBCONN_RESULT_EMPTY     2
#define DBCONN_RESULT_ERROR     3

/* ---- ConnError (1 byte, tags 0-8; 0 = no error) ---- */
typedef uint8_t dbconn_error_t;
#define DBCONN_ERR_NONE                  0
#define DBCONN_ERR_CONNECTION_REFUSED    1
#define DBCONN_ERR_AUTHENTICATION_FAILED 2
#define DBCONN_ERR_QUERY_ERROR           3
#define DBCONN_ERR_TRANSACTION_ERROR     4
#define DBCONN_ERR_TIMEOUT               5
#define DBCONN_ERR_POOL_EXHAUSTED        6
#define DBCONN_ERR_PROTOCOL_ERROR        7
#define DBCONN_ERR_TLS_REQUIRED          8

/* ---- PoolState (1 byte, tags 0-3) ---- */
typedef uint8_t dbconn_pool_state_t;
#define DBCONN_POOL_IDLE     0
#define DBCONN_POOL_ACTIVE   1
#define DBCONN_POOL_DRAINING 2
#define DBCONN_POOL_CLOSED   3

/* ---- Opaque handles ---- */
typedef struct dbconn_handle  dbconn_handle_t;
typedef struct dbconn_pool    dbconn_pool_t;
typedef struct dbconn_stmt    dbconn_stmt_t;

/* ---- Constants (must match DBConn.idr) ---- */
#define DBCONN_DEFAULT_PORT     5432
#define DBCONN_MAX_POOL_SIZE    100
#define DBCONN_QUERY_TIMEOUT    30
#define DBCONN_MAX_PARAM_COUNT  65535

/* ---- Functions ---- */

/** Return ABI version.  Must equal PROVEN_DBCONN_ABI_VERSION. */
uint32_t dbconn_abi_version(void);

/**
 * Connect to a database.
 * Returns NULL on failure; sets *err to the error code.
 * On success, *err is set to DBCONN_ERR_NONE and the returned handle
 * is in state DBCONN_STATE_CONNECTED.
 */
dbconn_handle_t *dbconn_connect(const char *host, uint16_t port,
                                uint8_t require_tls, dbconn_error_t *err);

/**
 * Disconnect and free a connection handle.
 * Valid only when the handle is in CONNECTED or IN_TRANSACTION state.
 * Returns DBCONN_ERR_NONE on success, or an error code.
 */
dbconn_error_t dbconn_disconnect(dbconn_handle_t *h);

/**
 * Get the current connection state.
 * Returns DBCONN_STATE_DISCONNECTED if h is NULL.
 */
dbconn_state_t dbconn_state(const dbconn_handle_t *h);

/**
 * Begin a transaction with the given isolation level.
 * Valid only when the handle is in CONNECTED state.
 * Returns DBCONN_ERR_NONE on success, or an error code.
 */
dbconn_error_t dbconn_begin_tx(dbconn_handle_t *h, dbconn_isolation_t iso);

/**
 * Commit the current transaction.
 * Valid only when the handle is in IN_TRANSACTION state.
 * Returns DBCONN_ERR_NONE on success, or an error code.
 */
dbconn_error_t dbconn_commit(dbconn_handle_t *h);

/**
 * Rollback the current transaction.
 * Valid only when the handle is in IN_TRANSACTION state.
 * Returns DBCONN_ERR_NONE on success, or an error code.
 */
dbconn_error_t dbconn_rollback(dbconn_handle_t *h);

/**
 * Prepare a parameterised statement.
 * Valid only when the handle is in CONNECTED or IN_TRANSACTION state
 * (the CanQuery states).
 * Returns NULL on failure; sets *err to the error code.
 */
dbconn_stmt_t *dbconn_prepare(dbconn_handle_t *h, const char *sql,
                              uint32_t sql_len, dbconn_error_t *err);

/**
 * Bind a typed parameter to a prepared statement.
 * typ must be a valid ParamType tag (0-7).
 * Returns DBCONN_ERR_NONE on success, or an error code.
 */
dbconn_error_t dbconn_bind_param(dbconn_stmt_t *s, uint16_t index,
                                 dbconn_param_type_t typ,
                                 const void *value, uint32_t value_len);

/**
 * Execute a prepared statement.
 * Returns a QueryResult tag.  Sets *err on failure.
 */
dbconn_query_result_t dbconn_execute(dbconn_stmt_t *s, dbconn_error_t *err);

/**
 * Free a prepared statement.
 * Safe to call with NULL (no-op).
 */
void dbconn_stmt_free(dbconn_stmt_t *s);

/**
 * Create a connection pool.
 * max_connections is capped at DBCONN_MAX_POOL_SIZE (100).
 * Returns NULL on allocation failure.
 */
dbconn_pool_t *dbconn_pool_create(uint16_t max_connections);

/**
 * Get the pool state.
 * Returns DBCONN_POOL_CLOSED if p is NULL.
 */
dbconn_pool_state_t dbconn_pool_state(const dbconn_pool_t *p);

/**
 * Drain and destroy a pool.
 * Safe to call with NULL (no-op).
 */
void dbconn_pool_destroy(dbconn_pool_t *p);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_DBCONN_H */
