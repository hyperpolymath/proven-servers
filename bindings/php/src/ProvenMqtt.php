<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PHP bindings for the proven-mqtt Zig FFI.

declare(strict_types=1);

namespace ProvenServers;

/** MQTT session states matching Idris2 ABI tags. */
enum MqttSessionState: int
{
    case Idle         = 0;
    case Connected    = 1;
    case Disconnected = 2;
}

/** MQTT protocol versions matching Idris2 ABI tags. */
enum MqttVersion: int
{
    case V3_1_1 = 0;
    case V5_0   = 1;
}

/** MQTT QoS levels matching Idris2 ABI tags. */
enum MqttQoS: int
{
    case AtMostOnce  = 0;
    case AtLeastOnce = 1;
    case ExactlyOnce = 2;
}

/**
 * MQTT session context wrapping a Zig FFI slot.
 */
final class ProvenMqtt
{
    private const CDEF = <<<'CDEF'
    int mqtt_create(uint8_t version, uint8_t clean_session, uint16_t keep_alive);
    void mqtt_destroy(int slot);
    uint8_t mqtt_state(int slot);
    uint8_t mqtt_version(int slot);
    uint8_t mqtt_can_publish(int slot);
    uint8_t mqtt_can_subscribe(int slot);
    uint32_t mqtt_subscription_count(int slot);
    uint8_t mqtt_subscribe(int slot, const uint8_t *topic, uint32_t topic_len, uint8_t qos);
    uint8_t mqtt_unsubscribe(int slot, const uint8_t *topic, uint32_t topic_len);
    uint8_t mqtt_publish(int slot, const uint8_t *topic, uint32_t topic_len, const uint8_t *payload, uint32_t payload_len, uint8_t qos, uint8_t retain, uint16_t packet_id);
    uint8_t mqtt_puback(int slot, uint16_t packet_id);
    uint8_t mqtt_pubrec(int slot, uint16_t packet_id);
    uint8_t mqtt_pubrel(int slot, uint16_t packet_id);
    uint8_t mqtt_pubcomp(int slot, uint16_t packet_id);
    uint8_t mqtt_qos_state(int slot, uint16_t packet_id);
    uint8_t mqtt_disconnect(int slot);
    uint8_t mqtt_cleanup(int slot);
    uint32_t mqtt_abi_version(void);
    uint32_t mqtt_retained_count(void);
    uint8_t mqtt_can_transition(uint8_t from, uint8_t to);
    uint8_t mqtt_qos_can_transition(uint8_t qos_level, uint8_t from, uint8_t to);
    uint8_t mqtt_topic_matches(const uint8_t *filter, uint32_t filter_len, const uint8_t *topic, uint32_t topic_len);
    CDEF;

    private static ?\FFI $ffi = null;
    private int $slot;
    private bool $destroyed = false;

    private function __construct(int $slot) { $this->slot = $slot; }

    private static function ffi(): \FFI
    {
        if (self::$ffi === null) {
            self::$ffi = ProvenServers::loadLibrary('mqtt', self::CDEF);
        }
        return self::$ffi;
    }

    /** @throws ProvenError */
    public static function create(
        MqttVersion $version = MqttVersion::V3_1_1,
        bool $cleanSession = true,
        int $keepAlive = 60,
    ): self {
        return new self(ProvenError::checkSlot(
            self::ffi()->mqtt_create($version->value, $cleanSession ? 1 : 0, $keepAlive)
        ));
    }

    public function destroy(): void
    {
        if (!$this->destroyed) {
            self::ffi()->mqtt_destroy($this->slot);
            $this->destroyed = true;
        }
    }

    public function state(): ?MqttSessionState
    {
        $tag = self::ffi()->mqtt_state($this->slot);
        return $tag <= 2 ? MqttSessionState::from($tag) : null;
    }

    public function version(): int { return self::ffi()->mqtt_version($this->slot); }
    public function canPublish(): bool { return self::ffi()->mqtt_can_publish($this->slot) === 1; }
    public function canSubscribe(): bool { return self::ffi()->mqtt_can_subscribe($this->slot) === 1; }
    public function subscriptionCount(): int { return self::ffi()->mqtt_subscription_count($this->slot); }

    /** @throws ProvenError */
    public function subscribe(string $topic, MqttQoS $qos): void
    {
        ProvenError::checkStatus(self::ffi()->mqtt_subscribe($this->slot, $topic, strlen($topic), $qos->value));
    }

    /** @throws ProvenError */
    public function unsubscribe(string $topic): void
    {
        ProvenError::checkStatus(self::ffi()->mqtt_unsubscribe($this->slot, $topic, strlen($topic)));
    }

    /** @throws ProvenError */
    public function publish(string $topic, string $payload, MqttQoS $qos, bool $retain = false, int $packetId = 0): void
    {
        ProvenError::checkStatus(self::ffi()->mqtt_publish(
            $this->slot, $topic, strlen($topic), $payload, strlen($payload),
            $qos->value, $retain ? 1 : 0, $packetId
        ));
    }

    /** @throws ProvenError */
    public function puback(int $packetId): void { ProvenError::checkStatus(self::ffi()->mqtt_puback($this->slot, $packetId)); }
    /** @throws ProvenError */
    public function pubrec(int $packetId): void { ProvenError::checkStatus(self::ffi()->mqtt_pubrec($this->slot, $packetId)); }
    /** @throws ProvenError */
    public function pubrel(int $packetId): void { ProvenError::checkStatus(self::ffi()->mqtt_pubrel($this->slot, $packetId)); }
    /** @throws ProvenError */
    public function pubcomp(int $packetId): void { ProvenError::checkStatus(self::ffi()->mqtt_pubcomp($this->slot, $packetId)); }

    public function qosState(int $packetId): int { return self::ffi()->mqtt_qos_state($this->slot, $packetId); }

    /** @throws ProvenError */
    public function disconnect(): void { ProvenError::checkStatus(self::ffi()->mqtt_disconnect($this->slot)); }
    /** @throws ProvenError */
    public function cleanup(): void { ProvenError::checkStatus(self::ffi()->mqtt_cleanup($this->slot)); }

    public static function abiVersion(): int { return self::ffi()->mqtt_abi_version(); }
    public static function retainedCount(): int { return self::ffi()->mqtt_retained_count(); }
    public static function canTransition(MqttSessionState $from, MqttSessionState $to): bool
    {
        return self::ffi()->mqtt_can_transition($from->value, $to->value) === 1;
    }
    public static function qosCanTransition(MqttQoS $qosLevel, int $from, int $to): bool
    {
        return self::ffi()->mqtt_qos_can_transition($qosLevel->value, $from, $to) === 1;
    }

    /** Check if a topic matches a subscription filter (MQTT wildcards). */
    public static function topicMatches(string $filter, string $topic): bool
    {
        return self::ffi()->mqtt_topic_matches($filter, strlen($filter), $topic, strlen($topic)) === 1;
    }
}
