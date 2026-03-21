// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file mqtt.hpp
/// @brief C++ bindings for proven-mqtt (MQTT broker protocol).
///
/// RAII wrapper. Session lifecycle: Idle -> Connected -> Disconnected.
/// Supports QoS 0/1/2 delivery state machines and topic matching.

#ifndef PROVEN_MQTT_HPP
#define PROVEN_MQTT_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>
#include <string_view>

extern "C" {
    uint32_t mqtt_abi_version();
    int mqtt_create(uint8_t version, uint8_t clean_session, uint16_t keep_alive);
    void mqtt_destroy(int slot);
    uint8_t mqtt_state(int slot);
    uint8_t mqtt_version(int slot);
    uint8_t mqtt_can_publish(int slot);
    uint8_t mqtt_can_subscribe(int slot);
    uint32_t mqtt_subscription_count(int slot);
    uint8_t mqtt_subscribe(int slot, const uint8_t* topic_ptr, uint32_t topic_len, uint8_t qos);
    uint8_t mqtt_unsubscribe(int slot, const uint8_t* topic_ptr, uint32_t topic_len);
    uint8_t mqtt_publish(int slot, const uint8_t* topic_ptr, uint32_t topic_len, const uint8_t* payload_ptr, uint32_t payload_len, uint8_t qos, uint8_t retain, uint16_t packet_id);
    uint8_t mqtt_puback(int slot, uint16_t packet_id);
    uint8_t mqtt_pubrec(int slot, uint16_t packet_id);
    uint8_t mqtt_pubrel(int slot, uint16_t packet_id);
    uint8_t mqtt_pubcomp(int slot, uint16_t packet_id);
    uint8_t mqtt_qos_state(int slot, uint16_t packet_id);
    uint8_t mqtt_disconnect(int slot);
    uint8_t mqtt_cleanup(int slot);
    uint32_t mqtt_retained_count();
    uint8_t mqtt_can_transition(uint8_t from, uint8_t to);
    uint8_t mqtt_qos_can_transition(uint8_t qos_level, uint8_t from, uint8_t to);
    uint8_t mqtt_topic_matches(const uint8_t* filter_ptr, uint32_t filter_len, const uint8_t* topic_ptr, uint32_t topic_len);
}

namespace proven {

/// @brief MQTT session state.
enum class MqttSessionState : uint8_t {
    Idle = 0, Connected = 1, Disconnected = 2
};

/// @brief MQTT Quality of Service level.
enum class MqttQoS : uint8_t {
    AtMostOnce = 0, AtLeastOnce = 1, ExactlyOnce = 2
};

/// @brief MQTT protocol version.
enum class MqttVersion : uint8_t {
    V311 = 0, V50 = 1
};

/// @brief RAII wrapper for an MQTT context slot.
class MqttContext {
public:
    /// @param version MQTT protocol version.
    /// @param clean_session Whether to start a clean session.
    /// @param keep_alive Keep-alive interval in seconds.
    MqttContext(MqttVersion version, bool clean_session, uint16_t keep_alive)
        : slot_(ProvenError::check_slot(mqtt_create(
            static_cast<uint8_t>(version),
            clean_session ? 1 : 0,
            keep_alive))) {}

    ~MqttContext() { if (slot_ >= 0) mqtt_destroy(slot_); }

    MqttContext(const MqttContext&) = delete;
    MqttContext& operator=(const MqttContext&) = delete;
    MqttContext(MqttContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    MqttContext& operator=(MqttContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) mqtt_destroy(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<MqttSessionState> state() const {
        uint8_t t = mqtt_state(slot_); return t <= 2 ? std::optional{static_cast<MqttSessionState>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t version() const { return mqtt_version(slot_); }
    [[nodiscard]] bool can_publish() const { return mqtt_can_publish(slot_) == 1; }
    [[nodiscard]] bool can_subscribe() const { return mqtt_can_subscribe(slot_) == 1; }
    [[nodiscard]] uint32_t subscription_count() const { return mqtt_subscription_count(slot_); }

    void subscribe(std::string_view topic, MqttQoS qos) {
        ProvenError::check_status(mqtt_subscribe(slot_,
            reinterpret_cast<const uint8_t*>(topic.data()),
            static_cast<uint32_t>(topic.size()),
            static_cast<uint8_t>(qos)));
    }

    void unsubscribe(std::string_view topic) {
        ProvenError::check_status(mqtt_unsubscribe(slot_,
            reinterpret_cast<const uint8_t*>(topic.data()),
            static_cast<uint32_t>(topic.size())));
    }

    void publish(std::string_view topic, const uint8_t* payload, uint32_t payload_len,
                 MqttQoS qos, bool retain, uint16_t packet_id) {
        ProvenError::check_status(mqtt_publish(slot_,
            reinterpret_cast<const uint8_t*>(topic.data()),
            static_cast<uint32_t>(topic.size()),
            payload, payload_len,
            static_cast<uint8_t>(qos),
            retain ? 1 : 0, packet_id));
    }

    void puback(uint16_t packet_id) { ProvenError::check_status(mqtt_puback(slot_, packet_id)); }
    void pubrec(uint16_t packet_id) { ProvenError::check_status(mqtt_pubrec(slot_, packet_id)); }
    void pubrel(uint16_t packet_id) { ProvenError::check_status(mqtt_pubrel(slot_, packet_id)); }
    void pubcomp(uint16_t packet_id) { ProvenError::check_status(mqtt_pubcomp(slot_, packet_id)); }

    [[nodiscard]] uint8_t qos_state(uint16_t packet_id) const { return mqtt_qos_state(slot_, packet_id); }

    void disconnect() { ProvenError::check_status(mqtt_disconnect(slot_)); }
    void cleanup() { ProvenError::check_status(mqtt_cleanup(slot_)); }

    /// @brief Get the global retained message count.
    static uint32_t retained_count() { return mqtt_retained_count(); }

    static bool can_transition(MqttSessionState from, MqttSessionState to) {
        return mqtt_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static bool qos_can_transition(MqttQoS qos, uint8_t from, uint8_t to) {
        return mqtt_qos_can_transition(static_cast<uint8_t>(qos), from, to) == 1;
    }

    /// @brief Check if a topic matches a subscription filter (supports +/# wildcards).
    static bool topic_matches(std::string_view filter, std::string_view topic) {
        return mqtt_topic_matches(
            reinterpret_cast<const uint8_t*>(filter.data()),
            static_cast<uint32_t>(filter.size()),
            reinterpret_cast<const uint8_t*>(topic.data()),
            static_cast<uint32_t>(topic.size())) == 1;
    }

    static uint32_t abi_version() { return mqtt_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_MQTT_HPP
