# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Sdn do
  @moduledoc """
  SDN types for the proven-servers ABI.
  
  Formally verified SDN (Software-Defined Networking) types.
  Mirrors the Idris2 module `SdnABI.Types`.
  
  - `SdnMessageType` -- SDN/OpenFlow message types.
  - `FlowAction` -- OpenFlow flow actions.
  - `MatchField` -- OpenFlow match fields.
  - `PortState` -- SDN port states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard OpenFlow port."
  @spec sdn_port() :: non_neg_integer()
  def sdn_port, do: 6653

  # ===========================================================================
  # SdnMessageType (tags 0-11)
  # ===========================================================================

  @typedoc """
  SdnMessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type sdn_message_type ::
          :hello
          | :error
          | :echo_request
          | :echo_reply
          | :features_request
          | :features_reply
          | :flow_mod
          | :packet_in
          | :packet_out
          | :port_status
          | :barrier_request
          | :barrier_reply

  @sdn_message_type_tags %{
    hello: 0,
    error: 1,
    echo_request: 2,
    echo_reply: 3,
    features_request: 4,
    features_reply: 5,
    flow_mod: 6,
    packet_in: 7,
    packet_out: 8,
    port_status: 9,
    barrier_request: 10,
    barrier_reply: 11,
  }

  @tag_to_sdn_message_type Map.new(@sdn_message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SdnMessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sdn.sdn_message_type_from_tag(0)
      {:ok, :hello}
  """
  @spec sdn_message_type_from_tag(non_neg_integer()) :: {:ok, sdn_message_type()} | :error
  def sdn_message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_sdn_message_type, tag)}
  end

  def sdn_message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `SdnMessageType` to the C-ABI tag value.
  """
  @spec sdn_message_type_to_tag(sdn_message_type()) :: non_neg_integer()
  def sdn_message_type_to_tag(val) when is_map_key(@sdn_message_type_tags, val) do
    Map.fetch!(@sdn_message_type_tags, val)
  end

  @doc """
  All `SdnMessageType` variants in tag order.
  """
  @spec all_sdn_message_types() :: [sdn_message_type()]
  def all_sdn_message_types do
    [
      :hello, :error, :echo_request, :echo_reply, :features_request,
      :features_reply, :flow_mod, :packet_in, :packet_out, :port_status,
      :barrier_request, :barrier_reply
    ]
  end

  # ===========================================================================
  # FlowAction (tags 0-6)
  # ===========================================================================

  @typedoc """
  FlowAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type flow_action ::
          :output
          | :set_field
          | :drop
          | :push_vlan
          | :pop_vlan
          | :set_queue
          | :group

  @flow_action_tags %{
    output: 0,
    set_field: 1,
    drop: 2,
    push_vlan: 3,
    pop_vlan: 4,
    set_queue: 5,
    group: 6,
  }

  @tag_to_flow_action Map.new(@flow_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FlowAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sdn.flow_action_from_tag(0)
      {:ok, :output}
  """
  @spec flow_action_from_tag(non_neg_integer()) :: {:ok, flow_action()} | :error
  def flow_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_flow_action, tag)}
  end

  def flow_action_from_tag(_tag), do: :error

  @doc """
  Encode a `FlowAction` to the C-ABI tag value.
  """
  @spec flow_action_to_tag(flow_action()) :: non_neg_integer()
  def flow_action_to_tag(val) when is_map_key(@flow_action_tags, val) do
    Map.fetch!(@flow_action_tags, val)
  end

  @doc """
  All `FlowAction` variants in tag order.
  """
  @spec all_flow_actions() :: [flow_action()]
  def all_flow_actions, do: [:output, :set_field, :drop, :push_vlan, :pop_vlan, :set_queue, :group]

  # ===========================================================================
  # MatchField (tags 0-10)
  # ===========================================================================

  @typedoc """
  MatchField types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type match_field ::
          :in_port
          | :eth_dst
          | :eth_src
          | :eth_type
          | :vlan_id
          | :ip_src
          | :ip_dst
          | :tcp_src
          | :tcp_dst
          | :udp_src
          | :udp_dst

  @match_field_tags %{
    in_port: 0,
    eth_dst: 1,
    eth_src: 2,
    eth_type: 3,
    vlan_id: 4,
    ip_src: 5,
    ip_dst: 6,
    tcp_src: 7,
    tcp_dst: 8,
    udp_src: 9,
    udp_dst: 10,
  }

  @tag_to_match_field Map.new(@match_field_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MatchField` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sdn.match_field_from_tag(0)
      {:ok, :in_port}
  """
  @spec match_field_from_tag(non_neg_integer()) :: {:ok, match_field()} | :error
  def match_field_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_match_field, tag)}
  end

  def match_field_from_tag(_tag), do: :error

  @doc """
  Encode a `MatchField` to the C-ABI tag value.
  """
  @spec match_field_to_tag(match_field()) :: non_neg_integer()
  def match_field_to_tag(val) when is_map_key(@match_field_tags, val) do
    Map.fetch!(@match_field_tags, val)
  end

  @doc """
  All `MatchField` variants in tag order.
  """
  @spec all_match_fields() :: [match_field()]
  def all_match_fields do
    [
      :in_port, :eth_dst, :eth_src, :eth_type, :vlan_id, :ip_src, :ip_dst,
      :tcp_src, :tcp_dst, :udp_src, :udp_dst
    ]
  end

  # ===========================================================================
  # PortState (tags 0-2)
  # ===========================================================================

  @typedoc """
  PortState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type port_state :: :up | :down | :blocked

  @port_state_tags %{
    up: 0,
    down: 1,
    blocked: 2,
  }

  @tag_to_port_state Map.new(@port_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PortState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sdn.port_state_from_tag(0)
      {:ok, :up}
  """
  @spec port_state_from_tag(non_neg_integer()) :: {:ok, port_state()} | :error
  def port_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_port_state, tag)}
  end

  def port_state_from_tag(_tag), do: :error

  @doc """
  Encode a `PortState` to the C-ABI tag value.
  """
  @spec port_state_to_tag(port_state()) :: non_neg_integer()
  def port_state_to_tag(val) when is_map_key(@port_state_tags, val) do
    Map.fetch!(@port_state_tags, val)
  end

  @doc """
  All `PortState` variants in tag order.
  """
  @spec all_port_states() :: [port_state()]
  def all_port_states, do: [:up, :down, :blocked]

end
