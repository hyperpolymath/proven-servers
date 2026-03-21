# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Dds do
  @moduledoc """
  DDS types for the proven-servers ABI.
  
  Formally verified DDS (Data Distribution Service) types.
  Mirrors the Idris2 module `DdsABI.Types`.
  
  - `ReliabilityKind` -- DDS reliability QoS.
  - `DurabilityKind` -- DDS durability QoS.
  - `HistoryKind` -- DDS history QoS.
  - `OwnershipKind` -- DDS ownership QoS.
  - `EntityType` -- DDS entity types.
  - `ParticipantState` -- DDS participant states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard DDS discovery port."
  @spec dds_discovery_port() :: non_neg_integer()
  def dds_discovery_port, do: 7400

  # ===========================================================================
  # ReliabilityKind (tags 0-1)
  # ===========================================================================

  @typedoc """
  ReliabilityKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type reliability_kind :: :best_effort | :reliable

  @reliability_kind_tags %{
    best_effort: 0,
    reliable: 1,
  }

  @tag_to_reliability_kind Map.new(@reliability_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ReliabilityKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dds.reliability_kind_from_tag(0)
      {:ok, :best_effort}
  """
  @spec reliability_kind_from_tag(non_neg_integer()) :: {:ok, reliability_kind()} | :error
  def reliability_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_reliability_kind, tag)}
  end

  def reliability_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `ReliabilityKind` to the C-ABI tag value.
  """
  @spec reliability_kind_to_tag(reliability_kind()) :: non_neg_integer()
  def reliability_kind_to_tag(val) when is_map_key(@reliability_kind_tags, val) do
    Map.fetch!(@reliability_kind_tags, val)
  end

  @doc """
  All `ReliabilityKind` variants in tag order.
  """
  @spec all_reliability_kinds() :: [reliability_kind()]
  def all_reliability_kinds, do: [:best_effort, :reliable]

  # ===========================================================================
  # DurabilityKind (tags 0-3)
  # ===========================================================================

  @typedoc """
  DurabilityKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type durability_kind :: :transient_local | :transient | :persistent

  @durability_kind_tags %{
    transient_local: 1,
    transient: 2,
    persistent: 3,
  }

  @tag_to_durability_kind Map.new(@durability_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DurabilityKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dds.durability_kind_from_tag(0)
      {:ok, :transient_local}
  """
  @spec durability_kind_from_tag(non_neg_integer()) :: {:ok, durability_kind()} | :error
  def durability_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_durability_kind, tag)}
  end

  def durability_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `DurabilityKind` to the C-ABI tag value.
  """
  @spec durability_kind_to_tag(durability_kind()) :: non_neg_integer()
  def durability_kind_to_tag(val) when is_map_key(@durability_kind_tags, val) do
    Map.fetch!(@durability_kind_tags, val)
  end

  @doc """
  All `DurabilityKind` variants in tag order.
  """
  @spec all_durability_kinds() :: [durability_kind()]
  def all_durability_kinds, do: [:transient_local, :transient, :persistent]

  # ===========================================================================
  # HistoryKind (tags 0-1)
  # ===========================================================================

  @typedoc """
  HistoryKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type history_kind :: :keep_last | :keep_all

  @history_kind_tags %{
    keep_last: 0,
    keep_all: 1,
  }

  @tag_to_history_kind Map.new(@history_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HistoryKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dds.history_kind_from_tag(0)
      {:ok, :keep_last}
  """
  @spec history_kind_from_tag(non_neg_integer()) :: {:ok, history_kind()} | :error
  def history_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_history_kind, tag)}
  end

  def history_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `HistoryKind` to the C-ABI tag value.
  """
  @spec history_kind_to_tag(history_kind()) :: non_neg_integer()
  def history_kind_to_tag(val) when is_map_key(@history_kind_tags, val) do
    Map.fetch!(@history_kind_tags, val)
  end

  @doc """
  All `HistoryKind` variants in tag order.
  """
  @spec all_history_kinds() :: [history_kind()]
  def all_history_kinds, do: [:keep_last, :keep_all]

  # ===========================================================================
  # OwnershipKind (tags 0-1)
  # ===========================================================================

  @typedoc """
  OwnershipKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ownership_kind :: :shared | :exclusive

  @ownership_kind_tags %{
    shared: 0,
    exclusive: 1,
  }

  @tag_to_ownership_kind Map.new(@ownership_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OwnershipKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dds.ownership_kind_from_tag(0)
      {:ok, :shared}
  """
  @spec ownership_kind_from_tag(non_neg_integer()) :: {:ok, ownership_kind()} | :error
  def ownership_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_ownership_kind, tag)}
  end

  def ownership_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `OwnershipKind` to the C-ABI tag value.
  """
  @spec ownership_kind_to_tag(ownership_kind()) :: non_neg_integer()
  def ownership_kind_to_tag(val) when is_map_key(@ownership_kind_tags, val) do
    Map.fetch!(@ownership_kind_tags, val)
  end

  @doc """
  All `OwnershipKind` variants in tag order.
  """
  @spec all_ownership_kinds() :: [ownership_kind()]
  def all_ownership_kinds, do: [:shared, :exclusive]

  # ===========================================================================
  # EntityType (tags 0-5)
  # ===========================================================================

  @typedoc """
  EntityType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type entity_type ::
          :participant
          | :publisher
          | :subscriber
          | :topic
          | :data_writer
          | :data_reader

  @entity_type_tags %{
    participant: 0,
    publisher: 1,
    subscriber: 2,
    topic: 3,
    data_writer: 4,
    data_reader: 5,
  }

  @tag_to_entity_type Map.new(@entity_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EntityType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dds.entity_type_from_tag(0)
      {:ok, :participant}
  """
  @spec entity_type_from_tag(non_neg_integer()) :: {:ok, entity_type()} | :error
  def entity_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_entity_type, tag)}
  end

  def entity_type_from_tag(_tag), do: :error

  @doc """
  Encode a `EntityType` to the C-ABI tag value.
  """
  @spec entity_type_to_tag(entity_type()) :: non_neg_integer()
  def entity_type_to_tag(val) when is_map_key(@entity_type_tags, val) do
    Map.fetch!(@entity_type_tags, val)
  end

  @doc """
  All `EntityType` variants in tag order.
  """
  @spec all_entity_types() :: [entity_type()]
  def all_entity_types do
    [
      :participant, :publisher, :subscriber, :topic, :data_writer, :data_reader,
    ]
  end

  # ===========================================================================
  # ParticipantState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ParticipantState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type participant_state :: :idle | :joined | :publishing | :subscribing | :leaving

  @participant_state_tags %{
    idle: 0,
    joined: 1,
    publishing: 2,
    subscribing: 3,
    leaving: 4,
  }

  @tag_to_participant_state Map.new(@participant_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ParticipantState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dds.participant_state_from_tag(0)
      {:ok, :idle}
  """
  @spec participant_state_from_tag(non_neg_integer()) :: {:ok, participant_state()} | :error
  def participant_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_participant_state, tag)}
  end

  def participant_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ParticipantState` to the C-ABI tag value.
  """
  @spec participant_state_to_tag(participant_state()) :: non_neg_integer()
  def participant_state_to_tag(val) when is_map_key(@participant_state_tags, val) do
    Map.fetch!(@participant_state_tags, val)
  end

  @doc """
  All `ParticipantState` variants in tag order.
  """
  @spec all_participant_states() :: [participant_state()]
  def all_participant_states, do: [:idle, :joined, :publishing, :subscribing, :leaving]

end
