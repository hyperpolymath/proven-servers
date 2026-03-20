/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * amqp.h -- C-ABI header for proven-amqp.
 * Generated from AMQPABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_AMQP_H
#define PROVEN_AMQP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- FrameType (4 constructors, tags 0-3) --------------------------------- */
#define AMQP_FRAME_METHOD     0
#define AMQP_FRAME_HEADER     1
#define AMQP_FRAME_BODY       2
#define AMQP_FRAME_HEARTBEAT  3

/* -- MethodClass (7 constructors, tags 0-6) ------------------------------- */
#define AMQP_CLASS_CONNECTION  0
#define AMQP_CLASS_CHANNEL     1
#define AMQP_CLASS_EXCHANGE    2
#define AMQP_CLASS_QUEUE       3
#define AMQP_CLASS_BASIC       4
#define AMQP_CLASS_TX          5
#define AMQP_CLASS_CONFIRM     6

/* -- ExchangeType (4 constructors, tags 0-3) ------------------------------ */
#define AMQP_EXCHANGE_DIRECT   0
#define AMQP_EXCHANGE_FANOUT   1
#define AMQP_EXCHANGE_TOPIC    2
#define AMQP_EXCHANGE_HEADERS  3

/* -- DeliveryMode (2 constructors, tags 0-1) ------------------------------ */
#define AMQP_DELIVERY_NON_PERSISTENT  0
#define AMQP_DELIVERY_PERSISTENT      1

/* -- ErrorSeverity (2 constructors, tags 0-1) ----------------------------- */
#define AMQP_SEVERITY_CHANNEL     0
#define AMQP_SEVERITY_CONNECTION  1

/* -- ConnectionState (5 constructors, tags 0-4) --------------------------- */
#define AMQP_CONN_IDLE         0
#define AMQP_CONN_NEGOTIATING  1
#define AMQP_CONN_TUNING_OK    2
#define AMQP_CONN_OPEN         3
#define AMQP_CONN_CLOSING      4

/* -- ChannelState (4 constructors, tags 0-3) ------------------------------ */
#define AMQP_CH_CLOSED   0
#define AMQP_CH_OPENING  1
#define AMQP_CH_OPEN     2
#define AMQP_CH_CLOSING  3

/* -- BrokerState (6 constructors, tags 0-5) ------------------------------- */
#define AMQP_STATE_IDLE           0
#define AMQP_STATE_CONNECTED      1
#define AMQP_STATE_CHANNEL_OPEN   2
#define AMQP_STATE_CONSUMING      3
#define AMQP_STATE_PUBLISHING     4
#define AMQP_STATE_DISCONNECTING  5

/* -- ABI ------------------------------------------------------------------ */
uint32_t amqp_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      amqp_create(const uint8_t *vhost_ptr, uint32_t vhost_len,
                     uint32_t frame_max, uint16_t channel_max,
                     uint16_t heartbeat);
void     amqp_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  amqp_state(int slot);
uint8_t  amqp_can_publish(int slot);
uint8_t  amqp_can_consume(int slot);

/* -- Channel management --------------------------------------------------- */
uint8_t  amqp_channel_open(int slot, uint16_t channel);
uint8_t  amqp_channel_close(int slot, uint16_t channel);
uint16_t amqp_channel_count(int slot);

/* -- Exchange / Queue / Binding ------------------------------------------- */
uint8_t  amqp_exchange_declare(int slot, uint16_t channel,
                               const uint8_t *name_ptr, uint32_t name_len,
                               uint8_t exch_type, uint8_t durable,
                               uint8_t auto_delete, uint8_t internal);

uint8_t  amqp_queue_declare(int slot, uint16_t channel,
                            const uint8_t *name_ptr, uint32_t name_len,
                            uint8_t durable, uint8_t exclusive,
                            uint8_t auto_delete);

uint8_t  amqp_queue_bind(int slot, uint16_t channel,
                         const uint8_t *queue_ptr, uint32_t queue_len,
                         const uint8_t *exchange_ptr, uint32_t exchange_len,
                         const uint8_t *routing_key_ptr, uint32_t rk_len);

/* -- Basic operations ----------------------------------------------------- */
uint8_t  amqp_basic_publish(int slot, uint16_t channel,
                            const uint8_t *exchange_ptr, uint32_t exchange_len,
                            const uint8_t *routing_key_ptr, uint32_t rk_len,
                            const uint8_t *body_ptr, uint32_t body_len,
                            uint8_t delivery_mode, uint8_t priority,
                            uint8_t mandatory);

uint8_t  amqp_basic_consume(int slot, uint16_t channel,
                            const uint8_t *queue_ptr, uint32_t queue_len,
                            const uint8_t *consumer_tag_ptr, uint32_t ct_len,
                            uint8_t no_ack, uint8_t exclusive);

uint8_t  amqp_basic_cancel(int slot, uint16_t channel,
                           const uint8_t *consumer_tag_ptr, uint32_t ct_len);

uint8_t  amqp_basic_ack(int slot, uint16_t channel,
                        uint64_t delivery_tag, uint8_t multiple);

uint8_t  amqp_basic_nack(int slot, uint16_t channel,
                         uint64_t delivery_tag, uint8_t multiple,
                         uint8_t requeue);

uint8_t  amqp_basic_reject(int slot, uint16_t channel,
                           uint64_t delivery_tag, uint8_t requeue);

uint8_t  amqp_basic_qos(int slot, uint16_t channel,
                        uint16_t prefetch_count, uint32_t prefetch_size,
                        uint8_t global);

/* -- Consumer queries ----------------------------------------------------- */
uint32_t amqp_consumer_count(int slot);

/* -- Disconnect / Cleanup ------------------------------------------------- */
uint8_t  amqp_disconnect(int slot);
uint8_t  amqp_cleanup(int slot);

/* -- Stateless transition tables ------------------------------------------ */
uint8_t  amqp_can_transition(uint8_t from, uint8_t to);
uint8_t  amqp_routing_match(const uint8_t *routing_key_ptr, uint32_t rk_len,
                            const uint8_t *pattern_ptr, uint32_t pat_len,
                            uint8_t exch_type);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_AMQP_H */
