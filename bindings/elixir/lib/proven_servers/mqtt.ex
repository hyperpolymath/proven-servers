# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Mqtt do
  @moduledoc """
  MQTT protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `MQTT.QoS` — quality of service levels (MQTT 3.1.1 Section 4.3)
    * `MQTT.PacketType` — control packet types (MQTT 3.1.1 Section 2.2)

  All numeric encodings match the MQTT 3.1.1 specification wire values.

  ## QoS Negotiation

  The `effective_qos/2` and `delivery_qos/2` functions model the QoS
  downgrade rules from MQTT 3.1.1 Sections 3.8.4 and 3.3.1.2 respectively.
  The effective QoS is always the minimum of the two inputs.
  """

  # ===========================================================================
  # QoS (MQTT.QoS, MQTT 3.1.1 Section 4.3)
  # ===========================================================================

  @typedoc """
  MQTT Quality of Service levels.

  Matches the `QoS` type in `MQTT.QoS`.
  Values are the 2-bit QoS wire codes.

    * `:at_most_once` — QoS 0: fire and forget
    * `:at_least_once` — QoS 1: PUBACK required
    * `:exactly_once` — QoS 2: PUBREC/PUBREL/PUBCOMP handshake
  """
  @type qos :: :at_most_once | :at_least_once | :exactly_once

  @qos_codes %{at_most_once: 0, at_least_once: 1, exactly_once: 2}
  @code_to_qos Map.new(@qos_codes, fn {k, v} -> {v, k} end)

  @doc """
  Decode from a 2-bit numeric code.

  Returns `:error` for the reserved value 3 and any invalid input.
  Matches `qosFromCode` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.qos_from_code(0)
      {:ok, :at_most_once}

      iex> ProvenServers.Mqtt.qos_from_code(3)
      :error
  """
  @spec qos_from_code(non_neg_integer()) :: {:ok, qos()} | :error
  def qos_from_code(code) when is_integer(code) and code >= 0 and code <= 2 do
    {:ok, Map.fetch!(@code_to_qos, code)}
  end

  def qos_from_code(_code), do: :error

  @doc """
  Convert to the 2-bit numeric code.

  Matches `qosCode` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.qos_to_code(:exactly_once)
      2
  """
  @spec qos_to_code(qos()) :: non_neg_integer()
  def qos_to_code(qos) when is_map_key(@qos_codes, qos) do
    Map.fetch!(@qos_codes, qos)
  end

  @doc """
  Whether this QoS level requires acknowledgement from the receiver.

  QoS 0 is fire-and-forget; QoS 1 and 2 require ack flows.
  Matches `requiresAck` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.qos_requires_ack?(:at_most_once)
      false

      iex> ProvenServers.Mqtt.qos_requires_ack?(:exactly_once)
      true
  """
  @spec qos_requires_ack?(qos()) :: boolean()
  def qos_requires_ack?(:at_most_once), do: false
  def qos_requires_ack?(_qos), do: true

  @doc """
  The number of acknowledgement packets needed to complete a QoS flow.

  QoS 0: 0 (fire and forget)
  QoS 1: 1 (PUBACK)
  QoS 2: 3 (PUBREC, PUBREL, PUBCOMP)
  Matches `ackPacketCount` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.ack_packet_count(:at_most_once)
      0

      iex> ProvenServers.Mqtt.ack_packet_count(:exactly_once)
      3
  """
  @spec ack_packet_count(qos()) :: non_neg_integer()
  def ack_packet_count(:at_most_once), do: 0
  def ack_packet_count(:at_least_once), do: 1
  def ack_packet_count(:exactly_once), do: 3

  @doc """
  Determine the effective QoS for a subscription.

  MQTT 3.1.1 Section 3.8.4: the effective QoS is the minimum of
  the requested and granted levels.
  Matches `effectiveQoS` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.effective_qos(:exactly_once, :at_least_once)
      :at_least_once

      iex> ProvenServers.Mqtt.effective_qos(:at_most_once, :exactly_once)
      :at_most_once
  """
  @spec effective_qos(qos(), qos()) :: qos()
  def effective_qos(requested, granted) do
    min_code = min(qos_to_code(requested), qos_to_code(granted))
    {:ok, result} = qos_from_code(min_code)
    result
  end

  @doc """
  Determine the QoS for delivering a message to a subscriber.

  MQTT 3.1.1 Section 3.3.1.2: the delivery QoS is the minimum of
  the message QoS and the subscription's maximum QoS.
  Matches `deliveryQoS` in `MQTT.QoS`.
  """
  @spec delivery_qos(qos(), qos()) :: qos()
  def delivery_qos(message_qos, subscription_max) do
    effective_qos(message_qos, subscription_max)
  end

  # ===========================================================================
  # SUBACK Return Code (MQTT.QoS.SubAckCode)
  # ===========================================================================

  @typedoc """
  SUBACK return code for a single topic subscription.

  MQTT 3.1.1 Section 3.9.3.
  Matches `SubAckCode` in `MQTT.QoS`.
  """
  @type sub_ack_code :: :granted_qos0 | :granted_qos1 | :granted_qos2 | :failure

  @sub_ack_bytes %{granted_qos0: 0x00, granted_qos1: 0x01, granted_qos2: 0x02, failure: 0x80}
  @byte_to_sub_ack Map.new(@sub_ack_bytes, fn {k, v} -> {v, k} end)

  @doc """
  Decode from a byte value.

  Matches `subAckCodeFromByte` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.sub_ack_from_byte(0x00)
      {:ok, :granted_qos0}

      iex> ProvenServers.Mqtt.sub_ack_from_byte(0x80)
      {:ok, :failure}
  """
  @spec sub_ack_from_byte(non_neg_integer()) :: {:ok, sub_ack_code()} | :error
  def sub_ack_from_byte(byte) when is_integer(byte) do
    case Map.fetch(@byte_to_sub_ack, byte) do
      {:ok, _code} = result -> result
      :error -> :error
    end
  end

  @doc """
  Convert to the byte value.
  """
  @spec sub_ack_to_byte(sub_ack_code()) :: non_neg_integer()
  def sub_ack_to_byte(code) when is_map_key(@sub_ack_bytes, code) do
    Map.fetch!(@sub_ack_bytes, code)
  end

  @doc """
  Convert a granted QoS code to the corresponding QoS level.

  Returns `:error` for `:failure`.
  Matches `subAckToQoS` in `MQTT.QoS`.

  ## Examples

      iex> ProvenServers.Mqtt.sub_ack_to_qos(:granted_qos0)
      {:ok, :at_most_once}

      iex> ProvenServers.Mqtt.sub_ack_to_qos(:failure)
      :error
  """
  @spec sub_ack_to_qos(sub_ack_code()) :: {:ok, qos()} | :error
  def sub_ack_to_qos(:granted_qos0), do: {:ok, :at_most_once}
  def sub_ack_to_qos(:granted_qos1), do: {:ok, :at_least_once}
  def sub_ack_to_qos(:granted_qos2), do: {:ok, :exactly_once}
  def sub_ack_to_qos(:failure), do: :error

  # ===========================================================================
  # Packet Type (MQTT.PacketType, MQTT 3.1.1 Section 2.2)
  # ===========================================================================

  @typedoc """
  MQTT control packet types (MQTT 3.1.1 Section 2.2.1).

  Each value corresponds to a 4-bit type code in the fixed header.
  Matches the `PacketType` type in `MQTT.PacketType`.
  """
  @type packet_type ::
          :connect
          | :connack
          | :publish
          | :puback
          | :pubrec
          | :pubrel
          | :pubcomp
          | :subscribe
          | :suback
          | :unsubscribe
          | :unsuback
          | :pingreq
          | :pingresp
          | :disconnect
          | :auth

  @packet_type_codes %{
    connect: 1,
    connack: 2,
    publish: 3,
    puback: 4,
    pubrec: 5,
    pubrel: 6,
    pubcomp: 7,
    subscribe: 8,
    suback: 9,
    unsubscribe: 10,
    unsuback: 11,
    pingreq: 12,
    pingresp: 13,
    disconnect: 14,
    auth: 15
  }

  @code_to_packet_type Map.new(@packet_type_codes, fn {k, v} -> {v, k} end)

  @doc """
  Decode from a 4-bit numeric code.

  Returns `:error` for the reserved code 0.
  Matches `packetTypeFromCode` in `MQTT.PacketType`.

  ## Examples

      iex> ProvenServers.Mqtt.packet_type_from_code(1)
      {:ok, :connect}

      iex> ProvenServers.Mqtt.packet_type_from_code(0)
      :error
  """
  @spec packet_type_from_code(non_neg_integer()) :: {:ok, packet_type()} | :error
  def packet_type_from_code(code) when is_integer(code) and code >= 1 and code <= 15 do
    {:ok, Map.fetch!(@code_to_packet_type, code)}
  end

  def packet_type_from_code(_code), do: :error

  @doc """
  Convert to the 4-bit numeric code.

  Matches `packetTypeCode` in `MQTT.PacketType`.

  ## Examples

      iex> ProvenServers.Mqtt.packet_type_to_code(:publish)
      3
  """
  @spec packet_type_to_code(packet_type()) :: non_neg_integer()
  def packet_type_to_code(pt) when is_map_key(@packet_type_codes, pt) do
    Map.fetch!(@packet_type_codes, pt)
  end

  # ===========================================================================
  # Packet Direction (MQTT.PacketType.PacketDirection)
  # ===========================================================================

  @typedoc """
  Direction of an MQTT packet: client-to-server, server-to-client, or both.

  Matches `PacketDirection` in `MQTT.PacketType`.
  """
  @type packet_direction :: :client_to_server | :server_to_client | :bidirectional

  @doc """
  Determine the allowed direction for a packet type.

  Matches `packetDirection` in `MQTT.PacketType`.

  ## Examples

      iex> ProvenServers.Mqtt.packet_direction(:connect)
      :client_to_server

      iex> ProvenServers.Mqtt.packet_direction(:connack)
      :server_to_client

      iex> ProvenServers.Mqtt.packet_direction(:publish)
      :bidirectional
  """
  @spec packet_direction(packet_type()) :: packet_direction()
  def packet_direction(pt)
      when pt in [:connect, :subscribe, :unsubscribe, :pingreq, :disconnect],
      do: :client_to_server

  def packet_direction(pt) when pt in [:connack, :suback, :unsuback, :pingresp],
    do: :server_to_client

  def packet_direction(pt)
      when pt in [:publish, :puback, :pubrec, :pubrel, :pubcomp, :auth],
      do: :bidirectional

  @doc """
  Check whether a packet type requires a packet identifier.

  Matches `requiresPacketId` in `MQTT.PacketType`.

  ## Examples

      iex> ProvenServers.Mqtt.requires_packet_id?(:subscribe)
      true

      iex> ProvenServers.Mqtt.requires_packet_id?(:connect)
      false
  """
  @spec requires_packet_id?(packet_type()) :: boolean()
  def requires_packet_id?(pt)
      when pt in [:puback, :pubrec, :pubrel, :pubcomp, :subscribe, :suback, :unsubscribe, :unsuback],
      do: true

  def requires_packet_id?(_pt), do: false
end
