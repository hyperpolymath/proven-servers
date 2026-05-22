# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Siem do
  @moduledoc """
  SIEM types for the proven-servers ABI.
  
  Formally verified SIEM (Security Information and Event Management) types.
  Mirrors the Idris2 module `SiemABI.Types`.
  
  - `EventSeverity` -- Security event severity.
  - `EventCategory` -- Security event categories.
  - `CorrelationRule` -- Event correlation rule types.
  - `AlertState` -- SIEM alert states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # EventSeverity (tags 0-4)
  # ===========================================================================

  @typedoc """
  EventSeverity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type event_severity :: :info | :low | :medium | :high | :critical

  @event_severity_tags %{
    info: 0,
    low: 1,
    medium: 2,
    high: 3,
    critical: 4,
  }

  @tag_to_event_severity Map.new(@event_severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EventSeverity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Siem.event_severity_from_tag(0)
      {:ok, :info}
  """
  @spec event_severity_from_tag(non_neg_integer()) :: {:ok, event_severity()} | :error
  def event_severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_event_severity, tag)}
  end

  def event_severity_from_tag(_tag), do: :error

  @doc """
  Encode a `EventSeverity` to the C-ABI tag value.
  """
  @spec event_severity_to_tag(event_severity()) :: non_neg_integer()
  def event_severity_to_tag(val) when is_map_key(@event_severity_tags, val) do
    Map.fetch!(@event_severity_tags, val)
  end

  @doc """
  All `EventSeverity` variants in tag order.
  """
  @spec all_event_severitys() :: [event_severity()]
  def all_event_severitys, do: [:info, :low, :medium, :high, :critical]

  # ===========================================================================
  # EventCategory (tags 0-6)
  # ===========================================================================

  @typedoc """
  EventCategory types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type event_category ::
          :authentication
          | :network_traffic
          | :file_activity
          | :process_execution
          | :policy_violation
          | :malware
          | :data_exfiltration

  @event_category_tags %{
    authentication: 0,
    network_traffic: 1,
    file_activity: 2,
    process_execution: 3,
    policy_violation: 4,
    malware: 5,
    data_exfiltration: 6,
  }

  @tag_to_event_category Map.new(@event_category_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EventCategory` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Siem.event_category_from_tag(0)
      {:ok, :authentication}
  """
  @spec event_category_from_tag(non_neg_integer()) :: {:ok, event_category()} | :error
  def event_category_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_event_category, tag)}
  end

  def event_category_from_tag(_tag), do: :error

  @doc """
  Encode a `EventCategory` to the C-ABI tag value.
  """
  @spec event_category_to_tag(event_category()) :: non_neg_integer()
  def event_category_to_tag(val) when is_map_key(@event_category_tags, val) do
    Map.fetch!(@event_category_tags, val)
  end

  @doc """
  All `EventCategory` variants in tag order.
  """
  @spec all_event_categorys() :: [event_category()]
  def all_event_categorys do
    [
      :authentication, :network_traffic, :file_activity, :process_execution,
      :policy_violation, :malware, :data_exfiltration
    ]
  end

  # ===========================================================================
  # CorrelationRule (tags 0-4)
  # ===========================================================================

  @typedoc """
  CorrelationRule types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type correlation_rule :: :threshold | :sequence | :aggregation | :absence | :statistical

  @correlation_rule_tags %{
    threshold: 0,
    sequence: 1,
    aggregation: 2,
    absence: 3,
    statistical: 4,
  }

  @tag_to_correlation_rule Map.new(@correlation_rule_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CorrelationRule` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Siem.correlation_rule_from_tag(0)
      {:ok, :threshold}
  """
  @spec correlation_rule_from_tag(non_neg_integer()) :: {:ok, correlation_rule()} | :error
  def correlation_rule_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_correlation_rule, tag)}
  end

  def correlation_rule_from_tag(_tag), do: :error

  @doc """
  Encode a `CorrelationRule` to the C-ABI tag value.
  """
  @spec correlation_rule_to_tag(correlation_rule()) :: non_neg_integer()
  def correlation_rule_to_tag(val) when is_map_key(@correlation_rule_tags, val) do
    Map.fetch!(@correlation_rule_tags, val)
  end

  @doc """
  All `CorrelationRule` variants in tag order.
  """
  @spec all_correlation_rules() :: [correlation_rule()]
  def all_correlation_rules, do: [:threshold, :sequence, :aggregation, :absence, :statistical]

  # ===========================================================================
  # AlertState (tags 0-4)
  # ===========================================================================

  @typedoc """
  AlertState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type alert_state :: :new | :acknowledged | :in_progress | :resolved | :false_positive

  @alert_state_tags %{
    new: 0,
    acknowledged: 1,
    in_progress: 2,
    resolved: 3,
    false_positive: 4,
  }

  @tag_to_alert_state Map.new(@alert_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AlertState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Siem.alert_state_from_tag(0)
      {:ok, :new}
  """
  @spec alert_state_from_tag(non_neg_integer()) :: {:ok, alert_state()} | :error
  def alert_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_alert_state, tag)}
  end

  def alert_state_from_tag(_tag), do: :error

  @doc """
  Encode a `AlertState` to the C-ABI tag value.
  """
  @spec alert_state_to_tag(alert_state()) :: non_neg_integer()
  def alert_state_to_tag(val) when is_map_key(@alert_state_tags, val) do
    Map.fetch!(@alert_state_tags, val)
  end

  @doc """
  All `AlertState` variants in tag order.
  """
  @spec all_alert_states() :: [alert_state()]
  def all_alert_states, do: [:new, :acknowledged, :in_progress, :resolved, :false_positive]

end
