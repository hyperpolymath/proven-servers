/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * mqtt.h -- C-ABI header for proven-mqtt.
 * Generated from MQTTABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_MQTT_H
#define PROVEN_MQTT_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- PacketType (15 constructors, tags 0-14) ------------------------------ */
#define MQTT_PKT_CONNECT      0
#define MQTT_PKT_CONNACK      1
#define MQTT_PKT_PUBLISH      2
#define MQTT_PKT_PUBACK       3
#define MQTT_PKT_PUBREC       4
#define MQTT_PKT_PUBREL       5
#define MQTT_PKT_PUBCOMP      6
#define MQTT_PKT_SUBSCRIBE    7
#define MQTT_PKT_SUBACK       8
#define MQTT_PKT_UNSUBSCRIBE  9
#define MQTT_PKT_UNSUBACK     10
#define MQTT_PKT_PINGREQ      11
#define MQTT_PKT_PINGRESP     12
#define MQTT_PKT_DISCONNECT   13
#define MQTT_PKT_AUTH         14

/* -- QoS (3 constructors, tags 0-2) -------------------------------------- */
#define MQTT_QOS_AT_MOST_ONCE   0
#define MQTT_QOS_AT_LEAST_ONCE  1
#define MQTT_QOS_EXACTLY_ONCE   2

/* -- ConnAckCode (6 constructors, tags 0-5) ------------------------------- */
#define MQTT_CONNACK_ACCEPTED             0
#define MQTT_CONNACK_UNACCEPTABLE_PROTO   1
#define MQTT_CONNACK_ID_REJECTED          2
#define MQTT_CONNACK_SERVER_UNAVAILABLE   3
#define MQTT_CONNACK_BAD_CREDENTIALS      4
#define MQTT_CONNACK_NOT_AUTHORISED       5

/* -- MQTTVersion (2 constructors, tags 0-1) ------------------------------- */
#define MQTT_VERSION_311  0
#define MQTT_VERSION_50   1

/* -- BrokerState (5 constructors, tags 0-4) ------------------------------- */
#define MQTT_STATE_IDLE           0
#define MQTT_STATE_CONNECTED      1
#define MQTT_STATE_SUBSCRIBED     2
#define MQTT_STATE_PUBLISHING     3
#define MQTT_STATE_DISCONNECTING  4

/* -- QoSDeliveryState (7 constructors, tags 0-6) -------------------------- */
#define MQTT_QD_IDLE              0
#define MQTT_QD_AWAITING_PUBACK   1
#define MQTT_QD_AWAITING_PUBREC   2
#define MQTT_QD_AWAITING_PUBREL   3
#define MQTT_QD_AWAITING_PUBCOMP  4
#define MQTT_QD_COMPLETE          5
#define MQTT_QD_FAILED            6

/* -- PropertyType (10 constructors, tags 0-9) ----------------------------- */
#define MQTT_PROP_SESSION_EXPIRY_INTERVAL  0
#define MQTT_PROP_RECEIVE_MAXIMUM          1
#define MQTT_PROP_MAXIMUM_QOS              2
#define MQTT_PROP_RETAIN_AVAILABLE         3
#define MQTT_PROP_MAXIMUM_PACKET_SIZE      4
#define MQTT_PROP_TOPIC_ALIAS_MAXIMUM      5
#define MQTT_PROP_WILDCARD_SUB_AVAILABLE   6
#define MQTT_PROP_SUB_ID_AVAILABLE         7
#define MQTT_PROP_SHARED_SUB_AVAILABLE     8
#define MQTT_PROP_SERVER_KEEP_ALIVE        9

/* -- PacketDirection (3 constructors, tags 0-2) --------------------------- */
#define MQTT_DIR_CLIENT_TO_SERVER  0
#define MQTT_DIR_SERVER_TO_CLIENT  1
#define MQTT_DIR_BIDIRECTIONAL     2

/* -- SubAckCode (4 constructors, tags 0-3) -------------------------------- */
#define MQTT_SUBACK_GRANTED_QOS0  0
#define MQTT_SUBACK_GRANTED_QOS1  1
#define MQTT_SUBACK_GRANTED_QOS2  2
#define MQTT_SUBACK_FAILURE       3

/* -- ABI ------------------------------------------------------------------ */
uint32_t mqtt_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      mqtt_create(uint8_t version, uint8_t clean_session, uint16_t keep_alive);
void     mqtt_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  mqtt_state(int slot);
uint8_t  mqtt_version(int slot);
uint8_t  mqtt_can_publish(int slot);
uint8_t  mqtt_can_subscribe(int slot);
uint32_t mqtt_subscription_count(int slot);

/* -- Subscribe / Unsubscribe ---------------------------------------------- */
uint8_t  mqtt_subscribe(int slot, const uint8_t *topic_ptr, uint32_t topic_len, uint8_t qos);
uint8_t  mqtt_unsubscribe(int slot, const uint8_t *topic_ptr, uint32_t topic_len);

/* -- Publish -------------------------------------------------------------- */
uint8_t  mqtt_publish(int slot, const uint8_t *topic_ptr, uint32_t topic_len,
                      const uint8_t *payload_ptr, uint32_t payload_len,
                      uint8_t qos, uint8_t retain, uint16_t packet_id);

/* -- QoS acknowledgement flow --------------------------------------------- */
uint8_t  mqtt_puback(int slot, uint16_t packet_id);
uint8_t  mqtt_pubrec(int slot, uint16_t packet_id);
uint8_t  mqtt_pubrel(int slot, uint16_t packet_id);
uint8_t  mqtt_pubcomp(int slot, uint16_t packet_id);
uint8_t  mqtt_qos_state(int slot, uint16_t packet_id);

/* -- Disconnect / Cleanup ------------------------------------------------- */
uint8_t  mqtt_disconnect(int slot);
uint8_t  mqtt_cleanup(int slot);

/* -- Retained messages ---------------------------------------------------- */
uint32_t mqtt_retained_count(void);

/* -- Stateless transition tables ------------------------------------------ */
uint8_t  mqtt_can_transition(uint8_t from, uint8_t to);
uint8_t  mqtt_qos_can_transition(uint8_t qos_level, uint8_t from, uint8_t to);
uint8_t  mqtt_topic_matches(const uint8_t *topic_ptr, uint32_t topic_len,
                            const uint8_t *filter_ptr, uint32_t filter_len);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_MQTT_H */
