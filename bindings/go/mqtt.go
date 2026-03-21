// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// MQTT protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig.
// Lifecycle: create -> connect -> subscribe/publish -> disconnect -> destroy.
package proven

/*
#cgo LDFLAGS: -lproven_mqtt
#include <stdint.h>

extern uint32_t mqtt_abi_version();
extern int mqtt_create(uint8_t version, uint8_t clean_session, uint16_t keep_alive);
extern void mqtt_destroy(int slot);
extern uint8_t mqtt_state(int slot);
extern uint8_t mqtt_version(int slot);
extern uint8_t mqtt_can_publish(int slot);
extern uint8_t mqtt_can_subscribe(int slot);
extern uint32_t mqtt_subscription_count(int slot);
extern uint8_t mqtt_subscribe(int slot, const uint8_t *topic_ptr, uint32_t topic_len, uint8_t qos);
extern uint8_t mqtt_unsubscribe(int slot, const uint8_t *topic_ptr, uint32_t topic_len);
extern uint8_t mqtt_publish(int slot, const uint8_t *topic_ptr, uint32_t topic_len, const uint8_t *payload_ptr, uint32_t payload_len, uint8_t qos, uint8_t retain, uint16_t packet_id);
extern uint8_t mqtt_puback(int slot, uint16_t packet_id);
extern uint8_t mqtt_pubrec(int slot, uint16_t packet_id);
extern uint8_t mqtt_pubrel(int slot, uint16_t packet_id);
extern uint8_t mqtt_pubcomp(int slot, uint16_t packet_id);
extern uint8_t mqtt_qos_state(int slot, uint16_t packet_id);
extern uint8_t mqtt_disconnect(int slot);
extern uint8_t mqtt_cleanup(int slot);
extern uint32_t mqtt_retained_count();
extern uint8_t mqtt_can_transition(uint8_t from, uint8_t to);
extern uint8_t mqtt_qos_can_transition(uint8_t qos_level, uint8_t from, uint8_t to);
extern uint8_t mqtt_topic_matches(const uint8_t *filter_ptr, uint32_t filter_len, const uint8_t *topic_ptr, uint32_t topic_len);
*/
import "C"
import "unsafe"

// MqttSessionState represents the MQTT broker session state.
// Tags match the Zig FFI.
type MqttSessionState uint8

const (
	MqttIdle         MqttSessionState = iota // Client connected, CONNECT not yet received
	MqttConnected                            // CONNECT received, session active
	MqttDisconnected                         // Client disconnected cleanly
)

// MqttQoS represents the MQTT quality of service level.
type MqttQoS uint8

const (
	MqttQoS0 MqttQoS = iota // At most once
	MqttQoS1                 // At least once
	MqttQoS2                 // Exactly once
)

// MqttVersion represents the MQTT protocol version.
type MqttVersion uint8

const (
	Mqtt311 MqttVersion = iota // MQTT 3.1.1
	Mqtt50                     // MQTT 5.0
)

// MqttContext wraps a slot in the proven-mqtt context pool.
type MqttContext struct {
	slot C.int
}

// MqttABIVersion returns the ABI version.
func MqttABIVersion() uint32 {
	return uint32(C.mqtt_abi_version())
}

// MqttCreate allocates a new MQTT session.
// version: Mqtt311=0, Mqtt50=1. cleanSession: start clean. keepAlive: seconds.
func MqttCreate(version MqttVersion, cleanSession bool, keepAlive uint16) (*MqttContext, error) {
	var cs C.uint8_t
	if cleanSession {
		cs = 1
	}
	slot := C.mqtt_create(C.uint8_t(version), cs, C.uint16_t(keepAlive))
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &MqttContext{slot: C.int(s)}, nil
}

// Close releases the MQTT context slot.
func (ctx *MqttContext) Close() {
	C.mqtt_destroy(ctx.slot)
}

// State returns the current session state.
func (ctx *MqttContext) State() (MqttSessionState, bool) {
	tag := C.mqtt_state(ctx.slot)
	if tag > 2 {
		return 0, false
	}
	return MqttSessionState(tag), true
}

// Version returns the MQTT protocol version tag.
func (ctx *MqttContext) Version() uint8 {
	return uint8(C.mqtt_version(ctx.slot))
}

// CanPublish checks if the session can publish messages.
func (ctx *MqttContext) CanPublish() bool {
	return C.mqtt_can_publish(ctx.slot) == 1
}

// CanSubscribe checks if the session can subscribe to topics.
func (ctx *MqttContext) CanSubscribe() bool {
	return C.mqtt_can_subscribe(ctx.slot) == 1
}

// SubscriptionCount returns the number of active subscriptions.
func (ctx *MqttContext) SubscriptionCount() uint32 {
	return uint32(C.mqtt_subscription_count(ctx.slot))
}

// Subscribe subscribes to a topic with the given QoS level.
func (ctx *MqttContext) Subscribe(topic string, qos MqttQoS) error {
	b := []byte(topic)
	return statusError(C.mqtt_subscribe(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&b[0])), C.uint32_t(len(b)), C.uint8_t(qos)))
}

// Unsubscribe unsubscribes from a topic.
func (ctx *MqttContext) Unsubscribe(topic string) error {
	b := []byte(topic)
	return statusError(C.mqtt_unsubscribe(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&b[0])), C.uint32_t(len(b))))
}

// Publish publishes a message to a topic.
func (ctx *MqttContext) Publish(topic string, payload []byte, qos MqttQoS, retain bool, packetID uint16) error {
	tb := []byte(topic)
	var retainByte C.uint8_t
	if retain {
		retainByte = 1
	}
	var pp *C.uint8_t
	if len(payload) > 0 {
		pp = (*C.uint8_t)(unsafe.Pointer(&payload[0]))
	}
	return statusError(C.mqtt_publish(
		ctx.slot,
		(*C.uint8_t)(unsafe.Pointer(&tb[0])), C.uint32_t(len(tb)),
		pp, C.uint32_t(len(payload)),
		C.uint8_t(qos), retainByte, C.uint16_t(packetID),
	))
}

// Puback acknowledges a QoS 1 publish (PUBACK).
func (ctx *MqttContext) Puback(packetID uint16) error {
	return statusError(C.mqtt_puback(ctx.slot, C.uint16_t(packetID)))
}

// Pubrec handles QoS 2 step 1: publish received (PUBREC).
func (ctx *MqttContext) Pubrec(packetID uint16) error {
	return statusError(C.mqtt_pubrec(ctx.slot, C.uint16_t(packetID)))
}

// Pubrel handles QoS 2 step 2: publish release (PUBREL).
func (ctx *MqttContext) Pubrel(packetID uint16) error {
	return statusError(C.mqtt_pubrel(ctx.slot, C.uint16_t(packetID)))
}

// Pubcomp handles QoS 2 step 3: publish complete (PUBCOMP).
func (ctx *MqttContext) Pubcomp(packetID uint16) error {
	return statusError(C.mqtt_pubcomp(ctx.slot, C.uint16_t(packetID)))
}

// QoSState returns the QoS delivery state for a packet ID (ABI tag).
func (ctx *MqttContext) QoSState(packetID uint16) uint8 {
	return uint8(C.mqtt_qos_state(ctx.slot, C.uint16_t(packetID)))
}

// Disconnect disconnects the session cleanly.
func (ctx *MqttContext) Disconnect() error {
	return statusError(C.mqtt_disconnect(ctx.slot))
}

// Cleanup cleans up session resources (subscriptions, QoS state).
func (ctx *MqttContext) Cleanup() error {
	return statusError(C.mqtt_cleanup(ctx.slot))
}

// MqttRetainedCount returns the global retained message count.
func MqttRetainedCount() uint32 {
	return uint32(C.mqtt_retained_count())
}

// MqttCanTransition checks whether a session state transition is valid.
func MqttCanTransition(from, to MqttSessionState) bool {
	return C.mqtt_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}

// MqttQoSCanTransition checks whether a QoS delivery state transition is valid.
func MqttQoSCanTransition(qosLevel MqttQoS, from, to uint8) bool {
	return C.mqtt_qos_can_transition(C.uint8_t(qosLevel), C.uint8_t(from), C.uint8_t(to)) == 1
}

// MqttTopicMatches checks if a topic matches a subscription filter.
// Supports MQTT wildcards: + (single level), # (multi level).
func MqttTopicMatches(filter, topic string) bool {
	fb := []byte(filter)
	tb := []byte(topic)
	return C.mqtt_topic_matches(
		(*C.uint8_t)(unsafe.Pointer(&fb[0])), C.uint32_t(len(fb)),
		(*C.uint8_t)(unsafe.Pointer(&tb[0])), C.uint32_t(len(tb)),
	) == 1
}
