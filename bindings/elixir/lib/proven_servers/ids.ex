# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Ids do
  @moduledoc """
  Intrusion Detection System types for the proven-servers ABI.
  
  Formally verified IDS types.
  Mirrors the Idris2 module `IdsABI.Types`.
  
  - `AlertSeverity` -- Alert severity levels.
  - `DetectionMethod` -- Intrusion detection methods.
  - `IdsProtocol` -- Monitored network protocols.
  - `IdsAction` -- IDS response actions.
  - `Direction` -- Traffic direction.
  - `ThreatLevel` -- Threat assessment levels.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # AlertSeverity (tags 0-3)
  # ===========================================================================

  @typedoc """
  AlertSeverity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type alert_severity :: :low | :medium | :high | :critical

  @alert_severity_tags %{
    low: 0,
    medium: 1,
    high: 2,
    critical: 3,
  }

  @tag_to_alert_severity Map.new(@alert_severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AlertSeverity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ids.alert_severity_from_tag(0)
      {:ok, :low}
  """
  @spec alert_severity_from_tag(non_neg_integer()) :: {:ok, alert_severity()} | :error
  def alert_severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_alert_severity, tag)}
  end

  def alert_severity_from_tag(_tag), do: :error

  @doc """
  Encode a `AlertSeverity` to the C-ABI tag value.
  """
  @spec alert_severity_to_tag(alert_severity()) :: non_neg_integer()
  def alert_severity_to_tag(val) when is_map_key(@alert_severity_tags, val) do
    Map.fetch!(@alert_severity_tags, val)
  end

  @doc """
  All `AlertSeverity` variants in tag order.
  """
  @spec all_alert_severitys() :: [alert_severity()]
  def all_alert_severitys, do: [:low, :medium, :high, :critical]

  # ===========================================================================
  # DetectionMethod (tags 0-3)
  # ===========================================================================

  @typedoc """
  DetectionMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type detection_method :: :signature | :anomaly | :stateful | :heuristic

  @detection_method_tags %{
    signature: 0,
    anomaly: 1,
    stateful: 2,
    heuristic: 3,
  }

  @tag_to_detection_method Map.new(@detection_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DetectionMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ids.detection_method_from_tag(0)
      {:ok, :signature}
  """
  @spec detection_method_from_tag(non_neg_integer()) :: {:ok, detection_method()} | :error
  def detection_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_detection_method, tag)}
  end

  def detection_method_from_tag(_tag), do: :error

  @doc """
  Encode a `DetectionMethod` to the C-ABI tag value.
  """
  @spec detection_method_to_tag(detection_method()) :: non_neg_integer()
  def detection_method_to_tag(val) when is_map_key(@detection_method_tags, val) do
    Map.fetch!(@detection_method_tags, val)
  end

  @doc """
  All `DetectionMethod` variants in tag order.
  """
  @spec all_detection_methods() :: [detection_method()]
  def all_detection_methods, do: [:signature, :anomaly, :stateful, :heuristic]

  # ===========================================================================
  # IdsProtocol (tags 0-6)
  # ===========================================================================

  @typedoc """
  IdsProtocol types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ids_protocol :: :tcp | :udp | :icmp | :dns | :http | :tls | :ssh

  @ids_protocol_tags %{
    tcp: 0,
    udp: 1,
    icmp: 2,
    dns: 3,
    http: 4,
    tls: 5,
    ssh: 6,
  }

  @tag_to_ids_protocol Map.new(@ids_protocol_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IdsProtocol` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ids.ids_protocol_from_tag(0)
      {:ok, :tcp}
  """
  @spec ids_protocol_from_tag(non_neg_integer()) :: {:ok, ids_protocol()} | :error
  def ids_protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_ids_protocol, tag)}
  end

  def ids_protocol_from_tag(_tag), do: :error

  @doc """
  Encode a `IdsProtocol` to the C-ABI tag value.
  """
  @spec ids_protocol_to_tag(ids_protocol()) :: non_neg_integer()
  def ids_protocol_to_tag(val) when is_map_key(@ids_protocol_tags, val) do
    Map.fetch!(@ids_protocol_tags, val)
  end

  @doc """
  All `IdsProtocol` variants in tag order.
  """
  @spec all_ids_protocols() :: [ids_protocol()]
  def all_ids_protocols, do: [:tcp, :udp, :icmp, :dns, :http, :tls, :ssh]

  # ===========================================================================
  # IdsAction (tags 0-4)
  # ===========================================================================

  @typedoc """
  IdsAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ids_action :: :alert | :drop | :log | :block | :pass

  @ids_action_tags %{
    alert: 0,
    drop: 1,
    log: 2,
    block: 3,
    pass: 4,
  }

  @tag_to_ids_action Map.new(@ids_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IdsAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ids.ids_action_from_tag(0)
      {:ok, :alert}
  """
  @spec ids_action_from_tag(non_neg_integer()) :: {:ok, ids_action()} | :error
  def ids_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_ids_action, tag)}
  end

  def ids_action_from_tag(_tag), do: :error

  @doc """
  Encode a `IdsAction` to the C-ABI tag value.
  """
  @spec ids_action_to_tag(ids_action()) :: non_neg_integer()
  def ids_action_to_tag(val) when is_map_key(@ids_action_tags, val) do
    Map.fetch!(@ids_action_tags, val)
  end

  @doc """
  All `IdsAction` variants in tag order.
  """
  @spec all_ids_actions() :: [ids_action()]
  def all_ids_actions, do: [:alert, :drop, :log, :block, :pass]

  # ===========================================================================
  # Direction (tags 0-2)
  # ===========================================================================

  @typedoc """
  Direction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type direction :: :inbound | :outbound | :both

  @direction_tags %{
    inbound: 0,
    outbound: 1,
    both: 2,
  }

  @tag_to_direction Map.new(@direction_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Direction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ids.direction_from_tag(0)
      {:ok, :inbound}
  """
  @spec direction_from_tag(non_neg_integer()) :: {:ok, direction()} | :error
  def direction_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_direction, tag)}
  end

  def direction_from_tag(_tag), do: :error

  @doc """
  Encode a `Direction` to the C-ABI tag value.
  """
  @spec direction_to_tag(direction()) :: non_neg_integer()
  def direction_to_tag(val) when is_map_key(@direction_tags, val) do
    Map.fetch!(@direction_tags, val)
  end

  @doc """
  All `Direction` variants in tag order.
  """
  @spec all_directions() :: [direction()]
  def all_directions, do: [:inbound, :outbound, :both]

  # ===========================================================================
  # ThreatLevel (tags 0-4)
  # ===========================================================================

  @typedoc """
  ThreatLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type threat_level :: :info | :low | :medium | :high | :critical

  @threat_level_tags %{
    info: 0,
    low: 1,
    medium: 2,
    high: 3,
    critical: 4,
  }

  @tag_to_threat_level Map.new(@threat_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ThreatLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ids.threat_level_from_tag(0)
      {:ok, :info}
  """
  @spec threat_level_from_tag(non_neg_integer()) :: {:ok, threat_level()} | :error
  def threat_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_threat_level, tag)}
  end

  def threat_level_from_tag(_tag), do: :error

  @doc """
  Encode a `ThreatLevel` to the C-ABI tag value.
  """
  @spec threat_level_to_tag(threat_level()) :: non_neg_integer()
  def threat_level_to_tag(val) when is_map_key(@threat_level_tags, val) do
    Map.fetch!(@threat_level_tags, val)
  end

  @doc """
  All `ThreatLevel` variants in tag order.
  """
  @spec all_threat_levels() :: [threat_level()]
  def all_threat_levels, do: [:info, :low, :medium, :high, :critical]

end
