/* SPDX-License-Identifier: PMPL-1.0-or-later */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * storageconn.h — C ABI header for proven-storageconn.
 * AUTO-GENERATED from Idris2 ABI definitions.  DO NOT EDIT.
 * ABI version: 1
 */

#ifndef PROVEN_STORAGECONN_H
#define PROVEN_STORAGECONN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* StorageOp (8 variants, tags 0-7) */
typedef uint8_t storageconn_op_t;
#define STORAGECONN_OP_PUT_OBJECT     0
#define STORAGECONN_OP_GET_OBJECT     1
#define STORAGECONN_OP_DELETE_OBJECT  2
#define STORAGECONN_OP_LIST_OBJECTS   3
#define STORAGECONN_OP_HEAD_OBJECT    4
#define STORAGECONN_OP_COPY_OBJECT    5
#define STORAGECONN_OP_CREATE_BUCKET  6
#define STORAGECONN_OP_DELETE_BUCKET  7

/* StorageState (5 variants, tags 0-4) */
typedef uint8_t storageconn_state_t;
#define STORAGECONN_STATE_DISCONNECTED  0
#define STORAGECONN_STATE_CONNECTED     1
#define STORAGECONN_STATE_UPLOADING     2
#define STORAGECONN_STATE_DOWNLOADING   3
#define STORAGECONN_STATE_FAILED        4

/* ObjectStatus (5 variants, tags 0-4) */
typedef uint8_t storageconn_object_status_t;
#define STORAGECONN_OBJ_EXISTS    0
#define STORAGECONN_OBJ_NOT_FOUND 1
#define STORAGECONN_OBJ_ARCHIVED  2
#define STORAGECONN_OBJ_DELETED   3
#define STORAGECONN_OBJ_PENDING   4

/* StorageError (8 variants, tags 1-8; 0 = no error) */
typedef uint8_t storageconn_error_t;
#define STORAGECONN_ERR_NONE                    0
#define STORAGECONN_ERR_BUCKET_NOT_FOUND        1
#define STORAGECONN_ERR_OBJECT_NOT_FOUND        2
#define STORAGECONN_ERR_ACCESS_DENIED           3
#define STORAGECONN_ERR_QUOTA_EXCEEDED          4
#define STORAGECONN_ERR_INTEGRITY_CHECK_FAILED  5
#define STORAGECONN_ERR_UPLOAD_INCOMPLETE       6
#define STORAGECONN_ERR_PATH_TRAVERSAL          7
#define STORAGECONN_ERR_TLS_REQUIRED            8

/* IntegrityCheck (5 variants, tags 0-4) */
typedef uint8_t storageconn_integrity_t;
#define STORAGECONN_INTEGRITY_SHA256  0
#define STORAGECONN_INTEGRITY_SHA384  1
#define STORAGECONN_INTEGRITY_SHA512  2
#define STORAGECONN_INTEGRITY_BLAKE3  3
#define STORAGECONN_INTEGRITY_NONE    4

/* Opaque handle type */
typedef struct storageconn_handle  storageconn_handle_t;

/* Constants */
#define STORAGECONN_MAX_OBJECT_SIZE       5368709120ULL  /* 5 GiB */
#define STORAGECONN_MAX_KEY_LENGTH        1024
#define STORAGECONN_MAX_BUCKET_NAME_LEN   63

/* Function declarations */
uint32_t storageconn_abi_version(void);
storageconn_handle_t *storageconn_connect(const char *endpoint, uint16_t port,
                                          uint8_t require_tls,
                                          storageconn_error_t *err);
storageconn_error_t storageconn_disconnect(storageconn_handle_t *h);
storageconn_state_t storageconn_state(const storageconn_handle_t *h);
storageconn_error_t storageconn_put(storageconn_handle_t *h,
                                    const char *bucket, uint32_t bucket_len,
                                    const char *key, uint32_t key_len,
                                    const void *body, uint32_t body_len,
                                    storageconn_integrity_t integrity);
storageconn_error_t storageconn_get(storageconn_handle_t *h,
                                    const char *bucket, uint32_t bucket_len,
                                    const char *key, uint32_t key_len,
                                    void *buf, uint32_t buf_cap,
                                    uint32_t *buf_len);
storageconn_error_t storageconn_delete(storageconn_handle_t *h,
                                       const char *bucket, uint32_t bucket_len,
                                       const char *key, uint32_t key_len);
storageconn_object_status_t storageconn_head(storageconn_handle_t *h,
                                             const char *bucket, uint32_t bucket_len,
                                             const char *key, uint32_t key_len);
storageconn_error_t storageconn_reset(storageconn_handle_t *h);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_STORAGECONN_H */
