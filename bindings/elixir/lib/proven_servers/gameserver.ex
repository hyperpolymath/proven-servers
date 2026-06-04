# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Gameserver do
  @moduledoc """
  Game Server types for the proven-servers ABI.
  
  Formally verified game server types.
  Mirrors the Idris2 module `GameserverABI.Types`.
  
  - `SessionType` -- Game session types.
  - `PlayerState` -- Game player states.
  - `MatchState` -- Game match states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # SessionType (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_type :: :lobby | :match | :practice | :spectator | :tournament

  @session_type_tags %{
    lobby: 0,
    match: 1,
    practice: 2,
    spectator: 3,
    tournament: 4,
  }

  @tag_to_session_type Map.new(@session_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Gameserver.session_type_from_tag(0)
      {:ok, :lobby}
  """
  @spec session_type_from_tag(non_neg_integer()) :: {:ok, session_type()} | :error
  def session_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_type, tag)}
  end

  def session_type_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionType` to the C-ABI tag value.
  """
  @spec session_type_to_tag(session_type()) :: non_neg_integer()
  def session_type_to_tag(val) when is_map_key(@session_type_tags, val) do
    Map.fetch!(@session_type_tags, val)
  end

  @doc """
  All `SessionType` variants in tag order.
  """
  @spec all_session_types() :: [session_type()]
  def all_session_types, do: [:lobby, :match, :practice, :spectator, :tournament]

  # ===========================================================================
  # PlayerState (tags 0-5)
  # ===========================================================================

  @typedoc """
  PlayerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type player_state :: :idle | :queuing | :loading | :playing | :spectating | :disconnected

  @player_state_tags %{
    idle: 0,
    queuing: 1,
    loading: 2,
    playing: 3,
    spectating: 4,
    disconnected: 5,
  }

  @tag_to_player_state Map.new(@player_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PlayerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Gameserver.player_state_from_tag(0)
      {:ok, :idle}
  """
  @spec player_state_from_tag(non_neg_integer()) :: {:ok, player_state()} | :error
  def player_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_player_state, tag)}
  end

  def player_state_from_tag(_tag), do: :error

  @doc """
  Encode a `PlayerState` to the C-ABI tag value.
  """
  @spec player_state_to_tag(player_state()) :: non_neg_integer()
  def player_state_to_tag(val) when is_map_key(@player_state_tags, val) do
    Map.fetch!(@player_state_tags, val)
  end

  @doc """
  All `PlayerState` variants in tag order.
  """
  @spec all_player_states() :: [player_state()]
  def all_player_states, do: [:idle, :queuing, :loading, :playing, :spectating, :disconnected]

  # ===========================================================================
  # MatchState (tags 0-5)
  # ===========================================================================

  @typedoc """
  MatchState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type match_state :: :waiting | :starting | :in_progress | :paused | :ending | :complete

  @match_state_tags %{
    waiting: 0,
    starting: 1,
    in_progress: 2,
    paused: 3,
    ending: 4,
    complete: 5,
  }

  @tag_to_match_state Map.new(@match_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MatchState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Gameserver.match_state_from_tag(0)
      {:ok, :waiting}
  """
  @spec match_state_from_tag(non_neg_integer()) :: {:ok, match_state()} | :error
  def match_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_match_state, tag)}
  end

  def match_state_from_tag(_tag), do: :error

  @doc """
  Encode a `MatchState` to the C-ABI tag value.
  """
  @spec match_state_to_tag(match_state()) :: non_neg_integer()
  def match_state_to_tag(val) when is_map_key(@match_state_tags, val) do
    Map.fetch!(@match_state_tags, val)
  end

  @doc """
  All `MatchState` variants in tag order.
  """
  @spec all_match_states() :: [match_state()]
  def all_match_states, do: [:waiting, :starting, :in_progress, :paused, :ending, :complete]

end
