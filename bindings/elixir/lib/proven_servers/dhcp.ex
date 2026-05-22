# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Dhcp do
  @moduledoc """
  DHCP protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `DhcpABI.Types` and its type definitions:
  - `MessageType`    — DHCP message types (8 constructors, tags 0-7)
  - `OptionCode`     — DHCP option codes (8 constructors, tags 0-7)
  - `HardwareType`   — Hardware address types (4 constructors, tags 0-3)
  - `DhcpState`      — Server state machine (6 constructors, tags 0-5)
  - `LeaseState`     — Lease lifecycle (6 constructors, tags 0-5)
  - `RelaySubOption` — Relay agent sub-options (2 constructors, tags 0-1)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard DHCP server port (RFC 2131)."
  @spec dhcp_server_port() :: non_neg_integer()
  def dhcp_server_port, do: 67

  @doc "Standard DHCP client port (RFC 2131)."
  @spec dhcp_client_port() :: non_neg_integer()
  def dhcp_client_port, do: 68

  # ===========================================================================
  # MessageType (tags 0-7)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type ::
          :discover
          | :offer
          | :request
          | :ack
          | :nak
          | :release
          | :inform
          | :decline

  @message_type_tags %{
    discover: 0,
    offer: 1,
    request: 2,
    ack: 3,
    nak: 4,
    release: 5,
    inform: 6,
    decline: 7,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dhcp.message_type_from_tag(0)
      {:ok, :discover}
  """
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_message_type, tag)}
  end

  def message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MessageType` to the C-ABI tag value.
  """
  @spec message_type_to_tag(message_type()) :: non_neg_integer()
  def message_type_to_tag(val) when is_map_key(@message_type_tags, val) do
    Map.fetch!(@message_type_tags, val)
  end

  @doc """
  All `MessageType` variants in tag order.
  """
  @spec all_message_types() :: [message_type()]
  def all_message_types, do: [:discover, :offer, :request, :ack, :nak, :release, :inform, :decline]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this message is sent by a client.
  """
  @spec is_client_message?(message_type()) :: boolean()
  def is_client_message?(val) when val in [:discover, :request, :release, :inform, :decline], do: true
  def is_client_message?(_val), do: false

  @doc """
  Whether this message is sent by a server.
  """
  @spec is_server_message?(message_type()) :: boolean()
  def is_server_message?(val) when val in [:offer, :ack, :nak], do: true
  def is_server_message?(_val), do: false

  # ===========================================================================
  # OptionCode (tags 0-7)
  # ===========================================================================

  @typedoc """
  OptionCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type option_code ::
          :subnet_mask
          | :router
          | :dns
          | :domain_name
          | :lease_time
          | :server_id
          | :requested_ip
          | :msg_type

  @option_code_tags %{
    subnet_mask: 0,
    router: 1,
    dns: 2,
    domain_name: 3,
    lease_time: 4,
    server_id: 5,
    requested_ip: 6,
    msg_type: 7,
  }

  @tag_to_option_code Map.new(@option_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OptionCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dhcp.option_code_from_tag(0)
      {:ok, :subnet_mask}
  """
  @spec option_code_from_tag(non_neg_integer()) :: {:ok, option_code()} | :error
  def option_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_option_code, tag)}
  end

  def option_code_from_tag(_tag), do: :error

  @doc """
  Encode a `OptionCode` to the C-ABI tag value.
  """
  @spec option_code_to_tag(option_code()) :: non_neg_integer()
  def option_code_to_tag(val) when is_map_key(@option_code_tags, val) do
    Map.fetch!(@option_code_tags, val)
  end

  @doc """
  All `OptionCode` variants in tag order.
  """
  @spec all_option_codes() :: [option_code()]
  def all_option_codes do
    [
      :subnet_mask, :router, :dns, :domain_name, :lease_time, :server_id,
      :requested_ip, :msg_type
    ]
  end

  # ===========================================================================
  # HardwareType (tags 0-3)
  # ===========================================================================

  @typedoc """
  HardwareType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hardware_type :: :ethernet | :ieee802 | :arcnet | :frame_relay

  @hardware_type_tags %{
    ethernet: 0,
    ieee802: 1,
    arcnet: 2,
    frame_relay: 3,
  }

  @tag_to_hardware_type Map.new(@hardware_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HardwareType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dhcp.hardware_type_from_tag(0)
      {:ok, :ethernet}
  """
  @spec hardware_type_from_tag(non_neg_integer()) :: {:ok, hardware_type()} | :error
  def hardware_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_hardware_type, tag)}
  end

  def hardware_type_from_tag(_tag), do: :error

  @doc """
  Encode a `HardwareType` to the C-ABI tag value.
  """
  @spec hardware_type_to_tag(hardware_type()) :: non_neg_integer()
  def hardware_type_to_tag(val) when is_map_key(@hardware_type_tags, val) do
    Map.fetch!(@hardware_type_tags, val)
  end

  @doc """
  All `HardwareType` variants in tag order.
  """
  @spec all_hardware_types() :: [hardware_type()]
  def all_hardware_types, do: [:ethernet, :ieee802, :arcnet, :frame_relay]

  # ===========================================================================
  # DhcpState (tags 0-5)
  # ===========================================================================

  @typedoc """
  DhcpState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type dhcp_state ::
          :idle
          | :discover_received
          | :offer_sent
          | :request_received
          | :ack_sent
          | :nak_sent

  @dhcp_state_tags %{
    idle: 0,
    discover_received: 1,
    offer_sent: 2,
    request_received: 3,
    ack_sent: 4,
    nak_sent: 5,
  }

  @tag_to_dhcp_state Map.new(@dhcp_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DhcpState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dhcp.dhcp_state_from_tag(0)
      {:ok, :idle}
  """
  @spec dhcp_state_from_tag(non_neg_integer()) :: {:ok, dhcp_state()} | :error
  def dhcp_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_dhcp_state, tag)}
  end

  def dhcp_state_from_tag(_tag), do: :error

  @doc """
  Encode a `DhcpState` to the C-ABI tag value.
  """
  @spec dhcp_state_to_tag(dhcp_state()) :: non_neg_integer()
  def dhcp_state_to_tag(val) when is_map_key(@dhcp_state_tags, val) do
    Map.fetch!(@dhcp_state_tags, val)
  end

  @doc """
  All `DhcpState` variants in tag order.
  """
  @spec all_dhcp_states() :: [dhcp_state()]
  def all_dhcp_states do
    [
      :idle, :discover_received, :offer_sent, :request_received, :ack_sent,
      :nak_sent
    ]
  end

  @doc """
  Validate whether a `DhcpState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_dhcp_state_transition(dhcp_state(), dhcp_state()) :: boolean()
  def validate_dhcp_state_transition(:idle, :discover_received), do: true
  def validate_dhcp_state_transition(:discover_received, :offer_sent), do: true
  def validate_dhcp_state_transition(:offer_sent, :request_received), do: true
  def validate_dhcp_state_transition(:request_received, :ack_sent), do: true
  def validate_dhcp_state_transition(:request_received, :nak_sent), do: true
  def validate_dhcp_state_transition(:ack_sent, :idle), do: true
  def validate_dhcp_state_transition(:nak_sent, :idle), do: true
  def validate_dhcp_state_transition(_from, _to), do: false

  # ===========================================================================
  # LeaseState (tags 0-5)
  # ===========================================================================

  @typedoc """
  LeaseState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lease_state :: :available | :offered | :bound | :renewing | :rebinding | :expired

  @lease_state_tags %{
    available: 0,
    offered: 1,
    bound: 2,
    renewing: 3,
    rebinding: 4,
    expired: 5,
  }

  @tag_to_lease_state Map.new(@lease_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LeaseState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dhcp.lease_state_from_tag(0)
      {:ok, :available}
  """
  @spec lease_state_from_tag(non_neg_integer()) :: {:ok, lease_state()} | :error
  def lease_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_lease_state, tag)}
  end

  def lease_state_from_tag(_tag), do: :error

  @doc """
  Encode a `LeaseState` to the C-ABI tag value.
  """
  @spec lease_state_to_tag(lease_state()) :: non_neg_integer()
  def lease_state_to_tag(val) when is_map_key(@lease_state_tags, val) do
    Map.fetch!(@lease_state_tags, val)
  end

  @doc """
  All `LeaseState` variants in tag order.
  """
  @spec all_lease_states() :: [lease_state()]
  def all_lease_states, do: [:available, :offered, :bound, :renewing, :rebinding, :expired]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this state means the address is in use.
  """
  @spec is_active?(lease_state()) :: boolean()
  def is_active?(val) when val in [:bound, :renewing, :rebinding], do: true
  def is_active?(_val), do: false

  # ===========================================================================
  # RelaySubOption (tags 0-1)
  # ===========================================================================

  @typedoc """
  RelaySubOption types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type relay_sub_option :: :circuit_id | :remote_id

  @relay_sub_option_tags %{
    circuit_id: 0,
    remote_id: 1,
  }

  @tag_to_relay_sub_option Map.new(@relay_sub_option_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RelaySubOption` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dhcp.relay_sub_option_from_tag(0)
      {:ok, :circuit_id}
  """
  @spec relay_sub_option_from_tag(non_neg_integer()) :: {:ok, relay_sub_option()} | :error
  def relay_sub_option_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_relay_sub_option, tag)}
  end

  def relay_sub_option_from_tag(_tag), do: :error

  @doc """
  Encode a `RelaySubOption` to the C-ABI tag value.
  """
  @spec relay_sub_option_to_tag(relay_sub_option()) :: non_neg_integer()
  def relay_sub_option_to_tag(val) when is_map_key(@relay_sub_option_tags, val) do
    Map.fetch!(@relay_sub_option_tags, val)
  end

  @doc """
  All `RelaySubOption` variants in tag order.
  """
  @spec all_relay_sub_options() :: [relay_sub_option()]
  def all_relay_sub_options, do: [:circuit_id, :remote_id]

end
