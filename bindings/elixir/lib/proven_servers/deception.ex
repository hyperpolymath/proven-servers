# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Deception do
  @moduledoc """
  Deception Platform types for the proven-servers ABI.
  
  Formally verified cyber deception types.
  Mirrors the Idris2 module `DeceptionABI.Types`.
  
  - `DecoyType` -- Deception decoy types.
  - `TriggerEvent` -- Decoy trigger events.
  - `AlertPriority` -- Deception alert priority.
  - `DecoyState` -- Decoy lifecycle states.
  - `ResponseAction` -- Deception response actions.
  - `ServerState` -- Deception server states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # DecoyType (tags 0-5)
  # ===========================================================================

  @typedoc """
  DecoyType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type decoy_type :: :service | :credential | :file | :network | :token | :breadcrumb

  @decoy_type_tags %{
    service: 0,
    credential: 1,
    file: 2,
    network: 3,
    token: 4,
    breadcrumb: 5,
  }

  @tag_to_decoy_type Map.new(@decoy_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DecoyType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Deception.decoy_type_from_tag(0)
      {:ok, :service}
  """
  @spec decoy_type_from_tag(non_neg_integer()) :: {:ok, decoy_type()} | :error
  def decoy_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_decoy_type, tag)}
  end

  def decoy_type_from_tag(_tag), do: :error

  @doc """
  Encode a `DecoyType` to the C-ABI tag value.
  """
  @spec decoy_type_to_tag(decoy_type()) :: non_neg_integer()
  def decoy_type_to_tag(val) when is_map_key(@decoy_type_tags, val) do
    Map.fetch!(@decoy_type_tags, val)
  end

  @doc """
  All `DecoyType` variants in tag order.
  """
  @spec all_decoy_types() :: [decoy_type()]
  def all_decoy_types, do: [:service, :credential, :file, :network, :token, :breadcrumb]

  # ===========================================================================
  # TriggerEvent (tags 0-5)
  # ===========================================================================

  @typedoc """
  TriggerEvent types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type trigger_event :: :access | :login | :read | :write | :execute | :scan

  @trigger_event_tags %{
    access: 0,
    login: 1,
    read: 2,
    write: 3,
    execute: 4,
    scan: 5,
  }

  @tag_to_trigger_event Map.new(@trigger_event_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TriggerEvent` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Deception.trigger_event_from_tag(0)
      {:ok, :access}
  """
  @spec trigger_event_from_tag(non_neg_integer()) :: {:ok, trigger_event()} | :error
  def trigger_event_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_trigger_event, tag)}
  end

  def trigger_event_from_tag(_tag), do: :error

  @doc """
  Encode a `TriggerEvent` to the C-ABI tag value.
  """
  @spec trigger_event_to_tag(trigger_event()) :: non_neg_integer()
  def trigger_event_to_tag(val) when is_map_key(@trigger_event_tags, val) do
    Map.fetch!(@trigger_event_tags, val)
  end

  @doc """
  All `TriggerEvent` variants in tag order.
  """
  @spec all_trigger_events() :: [trigger_event()]
  def all_trigger_events, do: [:access, :login, :read, :write, :execute, :scan]

  # ===========================================================================
  # AlertPriority (tags 0-3)
  # ===========================================================================

  @typedoc """
  AlertPriority types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type alert_priority :: :low | :medium | :high | :critical

  @alert_priority_tags %{
    low: 0,
    medium: 1,
    high: 2,
    critical: 3,
  }

  @tag_to_alert_priority Map.new(@alert_priority_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AlertPriority` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Deception.alert_priority_from_tag(0)
      {:ok, :low}
  """
  @spec alert_priority_from_tag(non_neg_integer()) :: {:ok, alert_priority()} | :error
  def alert_priority_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_alert_priority, tag)}
  end

  def alert_priority_from_tag(_tag), do: :error

  @doc """
  Encode a `AlertPriority` to the C-ABI tag value.
  """
  @spec alert_priority_to_tag(alert_priority()) :: non_neg_integer()
  def alert_priority_to_tag(val) when is_map_key(@alert_priority_tags, val) do
    Map.fetch!(@alert_priority_tags, val)
  end

  @doc """
  All `AlertPriority` variants in tag order.
  """
  @spec all_alert_prioritys() :: [alert_priority()]
  def all_alert_prioritys, do: [:low, :medium, :high, :critical]

  # ===========================================================================
  # DecoyState (tags 0-3)
  # ===========================================================================

  @typedoc """
  DecoyState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type decoy_state :: :active | :triggered | :disabled | :expired

  @decoy_state_tags %{
    active: 0,
    triggered: 1,
    disabled: 2,
    expired: 3,
  }

  @tag_to_decoy_state Map.new(@decoy_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DecoyState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Deception.decoy_state_from_tag(0)
      {:ok, :active}
  """
  @spec decoy_state_from_tag(non_neg_integer()) :: {:ok, decoy_state()} | :error
  def decoy_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_decoy_state, tag)}
  end

  def decoy_state_from_tag(_tag), do: :error

  @doc """
  Encode a `DecoyState` to the C-ABI tag value.
  """
  @spec decoy_state_to_tag(decoy_state()) :: non_neg_integer()
  def decoy_state_to_tag(val) when is_map_key(@decoy_state_tags, val) do
    Map.fetch!(@decoy_state_tags, val)
  end

  @doc """
  All `DecoyState` variants in tag order.
  """
  @spec all_decoy_states() :: [decoy_state()]
  def all_decoy_states, do: [:active, :triggered, :disabled, :expired]

  # ===========================================================================
  # ResponseAction (tags 0-4)
  # ===========================================================================

  @typedoc """
  ResponseAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type response_action :: :alert | :redirect | :delay | :fingerprint | :isolate

  @response_action_tags %{
    alert: 0,
    redirect: 1,
    delay: 2,
    fingerprint: 3,
    isolate: 4,
  }

  @tag_to_response_action Map.new(@response_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponseAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Deception.response_action_from_tag(0)
      {:ok, :alert}
  """
  @spec response_action_from_tag(non_neg_integer()) :: {:ok, response_action()} | :error
  def response_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_response_action, tag)}
  end

  def response_action_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponseAction` to the C-ABI tag value.
  """
  @spec response_action_to_tag(response_action()) :: non_neg_integer()
  def response_action_to_tag(val) when is_map_key(@response_action_tags, val) do
    Map.fetch!(@response_action_tags, val)
  end

  @doc """
  All `ResponseAction` variants in tag order.
  """
  @spec all_response_actions() :: [response_action()]
  def all_response_actions, do: [:alert, :redirect, :delay, :fingerprint, :isolate]

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :configured | :monitoring | :responding | :shutdown

  @server_state_tags %{
    idle: 0,
    configured: 1,
    monitoring: 2,
    responding: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Deception.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_server_state, tag)}
  end

  def server_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ServerState` to the C-ABI tag value.
  """
  @spec server_state_to_tag(server_state()) :: non_neg_integer()
  def server_state_to_tag(val) when is_map_key(@server_state_tags, val) do
    Map.fetch!(@server_state_tags, val)
  end

  @doc """
  All `ServerState` variants in tag order.
  """
  @spec all_server_states() :: [server_state()]
  def all_server_states, do: [:idle, :configured, :monitoring, :responding, :shutdown]

end
