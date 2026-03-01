/* SPDX-License-Identifier: PMPL-1.0-or-later */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * queueconn.h — C ABI header for proven-queueconn.
 * AUTO-GENERATED from Idris2 ABI definitions.  DO NOT EDIT.
 * ABI version: 1
 */

#ifndef PROVEN_QUEUECONN_H
#define PROVEN_QUEUECONN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* QueueOp (6 variants, tags 0-5) */
typedef uint8_t queueconn_op_t;
#define QUEUECONN_OP_PUBLISH      0
#define QUEUECONN_OP_SUBSCRIBE    1
#define QUEUECONN_OP_ACKNOWLEDGE  2
#define QUEUECONN_OP_REJECT       3
#define QUEUECONN_OP_PEEK         4
#define QUEUECONN_OP_PURGE        5

/* DeliveryGuarantee (3 variants, tags 0-2) */
typedef uint8_t queueconn_guarantee_t;
#define QUEUECONN_GUARANTEE_AT_MOST_ONCE   0
#define QUEUECONN_GUARANTEE_AT_LEAST_ONCE  1
#define QUEUECONN_GUARANTEE_EXACTLY_ONCE   2

/* QueueState (5 variants, tags 0-4) */
typedef uint8_t queueconn_state_t;
#define QUEUECONN_STATE_DISCONNECTED  0
#define QUEUECONN_STATE_CONNECTED     1
#define QUEUECONN_STATE_CONSUMING     2
#define QUEUECONN_STATE_PRODUCING     3
#define QUEUECONN_STATE_FAILED        4

/* MessageState (6 variants, tags 0-5) */
typedef uint8_t queueconn_msg_state_t;
#define QUEUECONN_MSG_PENDING       0
#define QUEUECONN_MSG_DELIVERED     1
#define QUEUECONN_MSG_ACKNOWLEDGED  2
#define QUEUECONN_MSG_REJECTED      3
#define QUEUECONN_MSG_DEAD_LETTERED 4
#define QUEUECONN_MSG_EXPIRED       5

/* QueueError (7 variants, tags 1-7; 0 = no error) */
typedef uint8_t queueconn_error_t;
#define QUEUECONN_ERR_NONE                 0
#define QUEUECONN_ERR_CONNECTION_LOST      1
#define QUEUECONN_ERR_QUEUE_NOT_FOUND      2
#define QUEUECONN_ERR_MESSAGE_TOO_LARGE    3
#define QUEUECONN_ERR_QUOTA_EXCEEDED       4
#define QUEUECONN_ERR_ACK_TIMEOUT          5
#define QUEUECONN_ERR_UNAUTHORIZED         6
#define QUEUECONN_ERR_SERIALIZATION_ERROR  7

/* Opaque handle types */
typedef struct queueconn_handle   queueconn_handle_t;
typedef struct queueconn_message  queueconn_message_t;

/* Constants */
#define QUEUECONN_MAX_MESSAGE_SIZE  1048576  /* bytes (1 MiB) */
#define QUEUECONN_DEFAULT_PREFETCH  10
#define QUEUECONN_ACK_TIMEOUT       30       /* seconds */

/* Function declarations */
uint32_t queueconn_abi_version(void);
queueconn_handle_t *queueconn_connect(const char *host, uint16_t port,
                                      queueconn_guarantee_t guarantee,
                                      queueconn_error_t *err);
queueconn_error_t queueconn_disconnect(queueconn_handle_t *h);
queueconn_state_t queueconn_state(const queueconn_handle_t *h);
queueconn_error_t queueconn_subscribe(queueconn_handle_t *h,
                                      const char *queue, uint32_t queue_len);
queueconn_error_t queueconn_unsubscribe(queueconn_handle_t *h);
queueconn_error_t queueconn_publish(queueconn_handle_t *h,
                                    const char *queue, uint32_t queue_len,
                                    const void *body, uint32_t body_len);
queueconn_message_t *queueconn_receive(queueconn_handle_t *h, queueconn_error_t *err);
queueconn_error_t queueconn_acknowledge(queueconn_message_t *m);
queueconn_error_t queueconn_reject(queueconn_message_t *m, uint8_t requeue);
queueconn_msg_state_t queueconn_message_state(const queueconn_message_t *m);
void queueconn_message_free(queueconn_message_t *m);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_QUEUECONN_H */
