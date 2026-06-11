# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Mdns do
  @moduledoc """
  mDNS types for the proven-servers ABI.
  
  Formally verified mDNS (multicast DNS, RFC 6762) types.
  Mirrors the Idris2 module `MdnsABI.Types`.
  
  - `MdnsRecordType` -- mDNS record types.
  - `QueryType` -- mDNS query types.
  - `ConflictAction` -- mDNS conflict resolution actions.
  - `ServiceFlag` -- mDNS service flags.
  - `ResponderState` -- mDNS responder states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard mDNS port."
  @spec mdns_port() :: non_neg_integer()
  def mdns_port, do: 5353

  # ===========================================================================
  # MdnsRecordType (tags 0-4)
  # ===========================================================================

  @typedoc """
  MdnsRecordType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mdns_record_type :: :a | :aaaa | :ptr | :srv | :txt

  @mdns_record_type_tags %{
    a: 0,
    aaaa: 1,
    ptr: 2,
    srv: 3,
    txt: 4,
  }

  @tag_to_mdns_record_type Map.new(@mdns_record_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MdnsRecordType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mdns.mdns_record_type_from_tag(0)
      {:ok, :a}
  """
  @spec mdns_record_type_from_tag(non_neg_integer()) :: {:ok, mdns_record_type()} | :error
  def mdns_record_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_mdns_record_type, tag)}
  end

  def mdns_record_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MdnsRecordType` to the C-ABI tag value.
  """
  @spec mdns_record_type_to_tag(mdns_record_type()) :: non_neg_integer()
  def mdns_record_type_to_tag(val) when is_map_key(@mdns_record_type_tags, val) do
    Map.fetch!(@mdns_record_type_tags, val)
  end

  @doc """
  All `MdnsRecordType` variants in tag order.
  """
  @spec all_mdns_record_types() :: [mdns_record_type()]
  def all_mdns_record_types, do: [:a, :aaaa, :ptr, :srv, :txt]

  # ===========================================================================
  # QueryType (tags 0-2)
  # ===========================================================================

  @typedoc """
  QueryType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type query_type :: :standard | :one_shot | :continuous

  @query_type_tags %{
    standard: 0,
    one_shot: 1,
    continuous: 2,
  }

  @tag_to_query_type Map.new(@query_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `QueryType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mdns.query_type_from_tag(0)
      {:ok, :standard}
  """
  @spec query_type_from_tag(non_neg_integer()) :: {:ok, query_type()} | :error
  def query_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_query_type, tag)}
  end

  def query_type_from_tag(_tag), do: :error

  @doc """
  Encode a `QueryType` to the C-ABI tag value.
  """
  @spec query_type_to_tag(query_type()) :: non_neg_integer()
  def query_type_to_tag(val) when is_map_key(@query_type_tags, val) do
    Map.fetch!(@query_type_tags, val)
  end

  @doc """
  All `QueryType` variants in tag order.
  """
  @spec all_query_types() :: [query_type()]
  def all_query_types, do: [:standard, :one_shot, :continuous]

  # ===========================================================================
  # ConflictAction (tags 0-2)
  # ===========================================================================

  @typedoc """
  ConflictAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type conflict_action :: :probe | :defend | :withdraw

  @conflict_action_tags %{
    probe: 0,
    defend: 1,
    withdraw: 2,
  }

  @tag_to_conflict_action Map.new(@conflict_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ConflictAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mdns.conflict_action_from_tag(0)
      {:ok, :probe}
  """
  @spec conflict_action_from_tag(non_neg_integer()) :: {:ok, conflict_action()} | :error
  def conflict_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_conflict_action, tag)}
  end

  def conflict_action_from_tag(_tag), do: :error

  @doc """
  Encode a `ConflictAction` to the C-ABI tag value.
  """
  @spec conflict_action_to_tag(conflict_action()) :: non_neg_integer()
  def conflict_action_to_tag(val) when is_map_key(@conflict_action_tags, val) do
    Map.fetch!(@conflict_action_tags, val)
  end

  @doc """
  All `ConflictAction` variants in tag order.
  """
  @spec all_conflict_actions() :: [conflict_action()]
  def all_conflict_actions, do: [:probe, :defend, :withdraw]

  # ===========================================================================
  # ServiceFlag (tags 0-1)
  # ===========================================================================

  @typedoc """
  ServiceFlag types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type service_flag :: :unique | :shared

  @service_flag_tags %{
    unique: 0,
    shared: 1,
  }

  @tag_to_service_flag Map.new(@service_flag_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServiceFlag` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mdns.service_flag_from_tag(0)
      {:ok, :unique}
  """
  @spec service_flag_from_tag(non_neg_integer()) :: {:ok, service_flag()} | :error
  def service_flag_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_service_flag, tag)}
  end

  def service_flag_from_tag(_tag), do: :error

  @doc """
  Encode a `ServiceFlag` to the C-ABI tag value.
  """
  @spec service_flag_to_tag(service_flag()) :: non_neg_integer()
  def service_flag_to_tag(val) when is_map_key(@service_flag_tags, val) do
    Map.fetch!(@service_flag_tags, val)
  end

  @doc """
  All `ServiceFlag` variants in tag order.
  """
  @spec all_service_flags() :: [service_flag()]
  def all_service_flags, do: [:unique, :shared]

  # ===========================================================================
  # ResponderState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ResponderState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type responder_state :: :idle | :probing | :announcing | :running | :shutting_down

  @responder_state_tags %{
    idle: 0,
    probing: 1,
    announcing: 2,
    running: 3,
    shutting_down: 4,
  }

  @tag_to_responder_state Map.new(@responder_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponderState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mdns.responder_state_from_tag(0)
      {:ok, :idle}
  """
  @spec responder_state_from_tag(non_neg_integer()) :: {:ok, responder_state()} | :error
  def responder_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_responder_state, tag)}
  end

  def responder_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponderState` to the C-ABI tag value.
  """
  @spec responder_state_to_tag(responder_state()) :: non_neg_integer()
  def responder_state_to_tag(val) when is_map_key(@responder_state_tags, val) do
    Map.fetch!(@responder_state_tags, val)
  end

  @doc """
  All `ResponderState` variants in tag order.
  """
  @spec all_responder_states() :: [responder_state()]
  def all_responder_states, do: [:idle, :probing, :announcing, :running, :shutting_down]

end
