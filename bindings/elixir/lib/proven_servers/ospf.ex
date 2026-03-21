# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Ospf do
  @moduledoc """
  OSPF protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `OSPFABI.Types` and its type definitions:
  - `PacketType`     — OSPF packet types (5 constructors, tags 0-4)
  - `NeighborState`  — OSPF neighbor state machine (8 constructors, tags 0-7)
  - `LsaType`        — LSA types (5 constructors, tags 0-4)
  - `AreaType`       — OSPF area types (4 constructors, tags 0-3)
  - `OspfError`      — FFI error codes (7 constructors, tags 0-6)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "OSPF protocol number (IP protocol 89)."
  @spec ospf_protocol() :: non_neg_integer()
  def ospf_protocol, do: 89

  # ===========================================================================
  # PacketType (tags 0-4)
  # ===========================================================================

  @typedoc """
  PacketType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type packet_type ::
          :hello
          | :database_description
          | :link_state_request
          | :link_state_update
          | :link_state_ack

  @packet_type_tags %{
    hello: 0,
    database_description: 1,
    link_state_request: 2,
    link_state_update: 3,
    link_state_ack: 4,
  }

  @tag_to_packet_type Map.new(@packet_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PacketType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ospf.packet_type_from_tag(0)
      {:ok, :hello}
  """
  @spec packet_type_from_tag(non_neg_integer()) :: {:ok, packet_type()} | :error
  def packet_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_packet_type, tag)}
  end

  def packet_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PacketType` to the C-ABI tag value.
  """
  @spec packet_type_to_tag(packet_type()) :: non_neg_integer()
  def packet_type_to_tag(val) when is_map_key(@packet_type_tags, val) do
    Map.fetch!(@packet_type_tags, val)
  end

  @doc """
  All `PacketType` variants in tag order.
  """
  @spec all_packet_types() :: [packet_type()]
  def all_packet_types do
    [
      :hello, :database_description, :link_state_request, :link_state_update,
      :link_state_ack
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this packet is part of database synchronization.
  """
  @spec is_db_sync?(packet_type()) :: boolean()
  def is_db_sync?(val) when val in [:database_description, :link_state_request, :link_state_update, :link_state_ack], do: true
  def is_db_sync?(_val), do: false

  # ===========================================================================
  # NeighborState (tags 0-7)
  # ===========================================================================

  @typedoc """
  NeighborState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type neighbor_state ::
          :down
          | :attempt
          | :init
          | :two_way
          | :ex_start
          | :exchange
          | :loading
          | :full

  @neighbor_state_tags %{
    down: 0,
    attempt: 1,
    init: 2,
    two_way: 3,
    ex_start: 4,
    exchange: 5,
    loading: 6,
    full: 7,
  }

  @tag_to_neighbor_state Map.new(@neighbor_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NeighborState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ospf.neighbor_state_from_tag(0)
      {:ok, :down}
  """
  @spec neighbor_state_from_tag(non_neg_integer()) :: {:ok, neighbor_state()} | :error
  def neighbor_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_neighbor_state, tag)}
  end

  def neighbor_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NeighborState` to the C-ABI tag value.
  """
  @spec neighbor_state_to_tag(neighbor_state()) :: non_neg_integer()
  def neighbor_state_to_tag(val) when is_map_key(@neighbor_state_tags, val) do
    Map.fetch!(@neighbor_state_tags, val)
  end

  @doc """
  All `NeighborState` variants in tag order.
  """
  @spec all_neighbor_states() :: [neighbor_state()]
  def all_neighbor_states do
    [
      :down, :attempt, :init, :two_way, :ex_start, :exchange, :loading,
      :full
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the neighbor has achieved full adjacency.
  """
  @spec is_adjacent?(neighbor_state()) :: boolean()
  def is_adjacent?(val) when val in [:full], do: true
  def is_adjacent?(_val), do: false

  @doc """
  Whether database synchronization is in progress.
  """
  @spec is_syncing?(neighbor_state()) :: boolean()
  def is_syncing?(val) when val in [:ex_start, :exchange, :loading], do: true
  def is_syncing?(_val), do: false

  @doc """
  Whether bidirectional communication exists.
  """
  @spec is_bidirectional?(neighbor_state()) :: boolean()
  def is_bidirectional?(val) when val in [:two_way, :ex_start, :exchange, :loading, :full], do: true
  def is_bidirectional?(_val), do: false

  # ===========================================================================
  # LsaType (tags 0-4)
  # ===========================================================================

  @typedoc """
  LsaType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lsa_type ::
          :router_lsa
          | :network_lsa
          | :summary_lsa
          | :asbr_summary_lsa
          | :as_external_lsa

  @lsa_type_tags %{
    router_lsa: 0,
    network_lsa: 1,
    summary_lsa: 2,
    asbr_summary_lsa: 3,
    as_external_lsa: 4,
  }

  @tag_to_lsa_type Map.new(@lsa_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LsaType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ospf.lsa_type_from_tag(0)
      {:ok, :router_lsa}
  """
  @spec lsa_type_from_tag(non_neg_integer()) :: {:ok, lsa_type()} | :error
  def lsa_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_lsa_type, tag)}
  end

  def lsa_type_from_tag(_tag), do: :error

  @doc """
  Encode a `LsaType` to the C-ABI tag value.
  """
  @spec lsa_type_to_tag(lsa_type()) :: non_neg_integer()
  def lsa_type_to_tag(val) when is_map_key(@lsa_type_tags, val) do
    Map.fetch!(@lsa_type_tags, val)
  end

  @doc """
  All `LsaType` variants in tag order.
  """
  @spec all_lsa_types() :: [lsa_type()]
  def all_lsa_types do
    [
      :router_lsa, :network_lsa, :summary_lsa, :asbr_summary_lsa, :as_external_lsa,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this LSA has area-wide scope.
  """
  @spec is_area_scope?(lsa_type()) :: boolean()
  def is_area_scope?(val) when val in [:router_lsa, :network_lsa, :summary_lsa, :asbr_summary_lsa], do: true
  def is_area_scope?(_val), do: false

  @doc """
  Whether this LSA has AS-wide scope.
  """
  @spec is_as_scope?(lsa_type()) :: boolean()
  def is_as_scope?(val) when val in [:as_external_lsa], do: true
  def is_as_scope?(_val), do: false

  # ===========================================================================
  # AreaType (tags 0-3)
  # ===========================================================================

  @typedoc """
  AreaType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type area_type :: :normal | :stub | :totally_stub | :nssa

  @area_type_tags %{
    normal: 0,
    stub: 1,
    totally_stub: 2,
    nssa: 3,
  }

  @tag_to_area_type Map.new(@area_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AreaType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ospf.area_type_from_tag(0)
      {:ok, :normal}
  """
  @spec area_type_from_tag(non_neg_integer()) :: {:ok, area_type()} | :error
  def area_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_area_type, tag)}
  end

  def area_type_from_tag(_tag), do: :error

  @doc """
  Encode a `AreaType` to the C-ABI tag value.
  """
  @spec area_type_to_tag(area_type()) :: non_neg_integer()
  def area_type_to_tag(val) when is_map_key(@area_type_tags, val) do
    Map.fetch!(@area_type_tags, val)
  end

  @doc """
  All `AreaType` variants in tag order.
  """
  @spec all_area_types() :: [area_type()]
  def all_area_types, do: [:normal, :stub, :totally_stub, :nssa]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this area type blocks external LSAs.
  """
  @spec blocks_external?(area_type()) :: boolean()
  def blocks_external?(val) when val in [:stub, :totally_stub], do: true
  def blocks_external?(_val), do: false

  # ===========================================================================
  # OspfError (tags 0-6)
  # ===========================================================================

  @typedoc """
  OspfError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ospf_error ::
          :ok
          | :invalid_slot
          | :not_active
          | :invalid_transition
          | :invalid_packet
          | :area_error
          | :flood_limit

  @ospf_error_tags %{
    ok: 0,
    invalid_slot: 1,
    not_active: 2,
    invalid_transition: 3,
    invalid_packet: 4,
    area_error: 5,
    flood_limit: 6,
  }

  @tag_to_ospf_error Map.new(@ospf_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OspfError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ospf.ospf_error_from_tag(0)
      {:ok, :ok}
  """
  @spec ospf_error_from_tag(non_neg_integer()) :: {:ok, ospf_error()} | :error
  def ospf_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_ospf_error, tag)}
  end

  def ospf_error_from_tag(_tag), do: :error

  @doc """
  Encode a `OspfError` to the C-ABI tag value.
  """
  @spec ospf_error_to_tag(ospf_error()) :: non_neg_integer()
  def ospf_error_to_tag(val) when is_map_key(@ospf_error_tags, val) do
    Map.fetch!(@ospf_error_tags, val)
  end

  @doc """
  All `OspfError` variants in tag order.
  """
  @spec all_ospf_errors() :: [ospf_error()]
  def all_ospf_errors do
    [
      :ok, :invalid_slot, :not_active, :invalid_transition, :invalid_packet,
      :area_error, :flood_limit
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error code indicates success.
  """
  @spec is_success?(ospf_error()) :: boolean()
  def is_success?(val) when val in [:ok], do: true
  def is_success?(_val), do: false

end
