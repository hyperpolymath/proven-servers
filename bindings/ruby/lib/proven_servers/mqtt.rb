# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Ruby bindings for the proven-mqtt Zig FFI.
#
# Wraps the C-ABI functions for MQTT session lifecycle, publish/subscribe,
# QoS handshake, and topic matching.

# frozen_string_literal: true

require "ffi"

module ProvenServers
  # MQTT broker protocol bindings matching the Idris2 ABI.
  #
  # @example
  #   ProvenServers::Mqtt.with_context do |ctx|
  #     ctx.subscribe("sensors/temperature", ProvenServers::Mqtt::QoS::AT_LEAST_ONCE)
  #     ctx.publish("sensors/temperature", payload, ProvenServers::Mqtt::QoS::AT_LEAST_ONCE)
  #     ctx.disconnect
  #   end
  module Mqtt
    extend FFI::Library

    FFILoader.load_protocol_library(self, "mqtt")

    # MQTT session states matching Idris2 ABI tags.
    module SessionState
      IDLE         = 0
      CONNECTED    = 1
      DISCONNECTED = 2
    end

    # MQTT protocol versions matching Idris2 ABI tags.
    module MqttVersion
      V3_1_1 = 0
      V5_0   = 1
    end

    # MQTT QoS levels matching Idris2 ABI tags.
    module QoS
      AT_MOST_ONCE  = 0
      AT_LEAST_ONCE = 1
      EXACTLY_ONCE  = 2
    end

    # FFI function declarations.
    attach_function :mqtt_create,              [:uint8, :uint8, :uint16], :int
    attach_function :mqtt_destroy,             [:int], :void
    attach_function :mqtt_state,               [:int], :uint8
    attach_function :mqtt_version,             [:int], :uint8
    attach_function :mqtt_can_publish,         [:int], :uint8
    attach_function :mqtt_can_subscribe,       [:int], :uint8
    attach_function :mqtt_subscription_count,  [:int], :uint32
    attach_function :mqtt_subscribe,           [:int, :pointer, :uint32, :uint8], :uint8
    attach_function :mqtt_unsubscribe,         [:int, :pointer, :uint32], :uint8
    attach_function :mqtt_publish,             [:int, :pointer, :uint32, :pointer, :uint32, :uint8, :uint8, :uint16], :uint8
    attach_function :mqtt_puback,              [:int, :uint16], :uint8
    attach_function :mqtt_pubrec,              [:int, :uint16], :uint8
    attach_function :mqtt_pubrel,              [:int, :uint16], :uint8
    attach_function :mqtt_pubcomp,             [:int, :uint16], :uint8
    attach_function :mqtt_qos_state,           [:int, :uint16], :uint8
    attach_function :mqtt_disconnect,          [:int], :uint8
    attach_function :mqtt_cleanup,             [:int], :uint8
    attach_function :mqtt_abi_version,         [], :uint32
    attach_function :mqtt_retained_count,      [], :uint32
    attach_function :mqtt_can_transition,      [:uint8, :uint8], :uint8
    attach_function :mqtt_qos_can_transition,  [:uint8, :uint8, :uint8], :uint8
    attach_function :mqtt_topic_matches,       [:pointer, :uint32, :pointer, :uint32], :uint8

    # MQTT session context wrapping a Zig FFI slot.
    class Context
      attr_reader :slot

      def initialize(slot)
        @slot = slot
        @destroyed = false
      end

      # @param version [Integer] MqttVersion tag (default: V3_1_1)
      # @param clean_session [Boolean] (default: true)
      # @param keep_alive [Integer] keep-alive interval in seconds (default: 60)
      # @return [Context]
      def self.create(version: MqttVersion::V3_1_1, clean_session: true, keep_alive: 60)
        slot = ProvenServers.check_slot(
          Mqtt.mqtt_create(version, clean_session ? 1 : 0, keep_alive)
        )
        new(slot)
      end

      # @return [void]
      def destroy
        return if @destroyed

        Mqtt.mqtt_destroy(@slot)
        @destroyed = true
      end

      # @return [Integer, nil] SessionState tag
      def state
        tag = Mqtt.mqtt_state(@slot)
        tag <= 2 ? tag : nil
      end

      # @return [Integer] MqttVersion tag
      def version         = Mqtt.mqtt_version(@slot)
      # @return [Boolean]
      def can_publish?    = Mqtt.mqtt_can_publish(@slot) == 1
      # @return [Boolean]
      def can_subscribe?  = Mqtt.mqtt_can_subscribe(@slot) == 1
      # @return [Integer]
      def subscription_count = Mqtt.mqtt_subscription_count(@slot)

      # Subscribe to a topic.
      #
      # @param topic [String] the topic filter
      # @param qos [Integer] QoS tag
      # @return [void]
      def subscribe(topic, qos)
        data = FFI::MemoryPointer.from_string(topic)
        ProvenServers.check_status(Mqtt.mqtt_subscribe(@slot, data, topic.bytesize, qos))
      end

      # Unsubscribe from a topic.
      #
      # @param topic [String] the topic filter
      # @return [void]
      def unsubscribe(topic)
        data = FFI::MemoryPointer.from_string(topic)
        ProvenServers.check_status(Mqtt.mqtt_unsubscribe(@slot, data, topic.bytesize))
      end

      # Publish a message to a topic.
      #
      # @param topic [String]
      # @param payload [String] message payload bytes
      # @param qos [Integer] QoS tag
      # @param retain [Boolean] (default: false)
      # @param packet_id [Integer] (default: 0)
      # @return [void]
      def publish(topic, payload, qos, retain: false, packet_id: 0)
        t = FFI::MemoryPointer.from_string(topic)
        p_buf = FFI::MemoryPointer.from_string(payload)
        ProvenServers.check_status(
          Mqtt.mqtt_publish(
            @slot, t, topic.bytesize, p_buf, payload.bytesize,
            qos, retain ? 1 : 0, packet_id
          )
        )
      end

      # @param packet_id [Integer] @return [void]
      def puback(packet_id)  = ProvenServers.check_status(Mqtt.mqtt_puback(@slot, packet_id))
      # @param packet_id [Integer] @return [void]
      def pubrec(packet_id)  = ProvenServers.check_status(Mqtt.mqtt_pubrec(@slot, packet_id))
      # @param packet_id [Integer] @return [void]
      def pubrel(packet_id)  = ProvenServers.check_status(Mqtt.mqtt_pubrel(@slot, packet_id))
      # @param packet_id [Integer] @return [void]
      def pubcomp(packet_id) = ProvenServers.check_status(Mqtt.mqtt_pubcomp(@slot, packet_id))

      # @param packet_id [Integer] @return [Integer] QoS state
      def qos_state(packet_id) = Mqtt.mqtt_qos_state(@slot, packet_id)

      # @return [void]
      def disconnect = ProvenServers.check_status(Mqtt.mqtt_disconnect(@slot))
      # @return [void]
      def cleanup    = ProvenServers.check_status(Mqtt.mqtt_cleanup(@slot))
    end

    # @yield [Context]
    # @return [Object]
    def self.with_context(version: MqttVersion::V3_1_1, clean_session: true, keep_alive: 60)
      ctx = Context.create(version: version, clean_session: clean_session, keep_alive: keep_alive)
      begin
        yield ctx
      ensure
        ctx.destroy
      end
    end

    # @return [Integer]
    def self.abi_version = mqtt_abi_version
    # @return [Integer]
    def self.retained_count = mqtt_retained_count
    # @param from [Integer] @param to [Integer] @return [Boolean]
    def self.can_transition?(from, to) = mqtt_can_transition(from, to) == 1
    # @param qos_level [Integer] @param from [Integer] @param to [Integer] @return [Boolean]
    def self.qos_can_transition?(qos_level, from, to) = mqtt_qos_can_transition(qos_level, from, to) == 1

    # Check if a topic matches a subscription filter (MQTT wildcards).
    #
    # @param filter [String]
    # @param topic [String]
    # @return [Boolean]
    def self.topic_matches?(filter, topic)
      f = FFI::MemoryPointer.from_string(filter)
      t = FFI::MemoryPointer.from_string(topic)
      mqtt_topic_matches(f, filter.bytesize, t, topic.bytesize) == 1
    end
  end
end
