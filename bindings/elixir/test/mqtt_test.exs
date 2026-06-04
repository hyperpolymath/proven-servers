# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.MqttTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Mqtt

  alias ProvenServers.Mqtt

  describe "QoS roundtrip" do
    test "all codes 0..2 roundtrip" do
      for code <- 0..2 do
        {:ok, qos} = Mqtt.qos_from_code(code)
        assert Mqtt.qos_to_code(qos) == code
      end
    end

    test "reserved value 3 rejected" do
      assert Mqtt.qos_from_code(3) == :error
    end
  end

  describe "QoS ack requirements" do
    test "at_most_once requires no ack" do
      refute Mqtt.qos_requires_ack?(:at_most_once)
      assert Mqtt.ack_packet_count(:at_most_once) == 0
    end

    test "at_least_once requires 1 ack" do
      assert Mqtt.qos_requires_ack?(:at_least_once)
      assert Mqtt.ack_packet_count(:at_least_once) == 1
    end

    test "exactly_once requires 3 acks" do
      assert Mqtt.qos_requires_ack?(:exactly_once)
      assert Mqtt.ack_packet_count(:exactly_once) == 3
    end
  end

  describe "QoS negotiation" do
    test "effective QoS is minimum" do
      assert Mqtt.effective_qos(:exactly_once, :at_least_once) == :at_least_once
      assert Mqtt.effective_qos(:at_most_once, :exactly_once) == :at_most_once
    end

    test "delivery QoS is minimum" do
      assert Mqtt.delivery_qos(:exactly_once, :at_most_once) == :at_most_once
    end
  end

  describe "SubAckCode roundtrip" do
    test "all codes roundtrip" do
      codes = [{0x00, :granted_qos0}, {0x01, :granted_qos1}, {0x02, :granted_qos2}, {0x80, :failure}]

      for {byte, expected} <- codes do
        assert {:ok, ^expected} = Mqtt.sub_ack_from_byte(byte)
        assert Mqtt.sub_ack_to_byte(expected) == byte
      end
    end

    test "sub_ack_to_qos" do
      assert Mqtt.sub_ack_to_qos(:granted_qos0) == {:ok, :at_most_once}
      assert Mqtt.sub_ack_to_qos(:granted_qos1) == {:ok, :at_least_once}
      assert Mqtt.sub_ack_to_qos(:granted_qos2) == {:ok, :exactly_once}
      assert Mqtt.sub_ack_to_qos(:failure) == :error
    end
  end

  describe "packet type roundtrip" do
    test "all codes 1..15 roundtrip" do
      for code <- 1..15 do
        {:ok, pt} = Mqtt.packet_type_from_code(code)
        assert Mqtt.packet_type_to_code(pt) == code
      end
    end

    test "reserved code 0 rejected" do
      assert Mqtt.packet_type_from_code(0) == :error
    end

    test "code 16 rejected" do
      assert Mqtt.packet_type_from_code(16) == :error
    end
  end

  describe "packet direction" do
    test "client-to-server packets" do
      assert Mqtt.packet_direction(:connect) == :client_to_server
      assert Mqtt.packet_direction(:subscribe) == :client_to_server
    end

    test "server-to-client packets" do
      assert Mqtt.packet_direction(:connack) == :server_to_client
      assert Mqtt.packet_direction(:suback) == :server_to_client
    end

    test "bidirectional packets" do
      assert Mqtt.packet_direction(:publish) == :bidirectional
    end
  end

  describe "packet id requirement" do
    test "packets requiring id" do
      assert Mqtt.requires_packet_id?(:puback)
      assert Mqtt.requires_packet_id?(:subscribe)
    end

    test "packets not requiring id" do
      refute Mqtt.requires_packet_id?(:connect)
      refute Mqtt.requires_packet_id?(:publish)
      refute Mqtt.requires_packet_id?(:auth)
    end
  end
end
