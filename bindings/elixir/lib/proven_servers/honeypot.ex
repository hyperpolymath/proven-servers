# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Honeypot do
  @moduledoc """
  Honeypot types for the proven-servers ABI.
  
  Formally verified honeypot/deception types.
  Mirrors the Idris2 module `HoneypotABI.Types`.
  
  - `ServiceEmulation` -- Emulated service types.
  - `InteractionLevel` -- Honeypot interaction levels.
  - `HoneypotAlertSeverity` -- Honeypot alert severity levels.
  - `AttackerAction` -- Observed attacker actions.
  - `ServerState` -- Honeypot server states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ServiceEmulation (tags 0-6)
  # ===========================================================================

  @typedoc """
  ServiceEmulation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type service_emulation :: :ssh | :http | :ftp | :smtp | :telnet | :mysql | :rdp

  @service_emulation_tags %{
    ssh: 0,
    http: 1,
    ftp: 2,
    smtp: 3,
    telnet: 4,
    mysql: 5,
    rdp: 6,
  }

  @tag_to_service_emulation Map.new(@service_emulation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServiceEmulation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Honeypot.service_emulation_from_tag(0)
      {:ok, :ssh}
  """
  @spec service_emulation_from_tag(non_neg_integer()) :: {:ok, service_emulation()} | :error
  def service_emulation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_service_emulation, tag)}
  end

  def service_emulation_from_tag(_tag), do: :error

  @doc """
  Encode a `ServiceEmulation` to the C-ABI tag value.
  """
  @spec service_emulation_to_tag(service_emulation()) :: non_neg_integer()
  def service_emulation_to_tag(val) when is_map_key(@service_emulation_tags, val) do
    Map.fetch!(@service_emulation_tags, val)
  end

  @doc """
  All `ServiceEmulation` variants in tag order.
  """
  @spec all_service_emulations() :: [service_emulation()]
  def all_service_emulations, do: [:ssh, :http, :ftp, :smtp, :telnet, :mysql, :rdp]

  # ===========================================================================
  # InteractionLevel (tags 0-2)
  # ===========================================================================

  @typedoc """
  InteractionLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type interaction_level :: :low | :medium | :high

  @interaction_level_tags %{
    low: 0,
    medium: 1,
    high: 2,
  }

  @tag_to_interaction_level Map.new(@interaction_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `InteractionLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Honeypot.interaction_level_from_tag(0)
      {:ok, :low}
  """
  @spec interaction_level_from_tag(non_neg_integer()) :: {:ok, interaction_level()} | :error
  def interaction_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_interaction_level, tag)}
  end

  def interaction_level_from_tag(_tag), do: :error

  @doc """
  Encode a `InteractionLevel` to the C-ABI tag value.
  """
  @spec interaction_level_to_tag(interaction_level()) :: non_neg_integer()
  def interaction_level_to_tag(val) when is_map_key(@interaction_level_tags, val) do
    Map.fetch!(@interaction_level_tags, val)
  end

  @doc """
  All `InteractionLevel` variants in tag order.
  """
  @spec all_interaction_levels() :: [interaction_level()]
  def all_interaction_levels, do: [:low, :medium, :high]

  # ===========================================================================
  # HoneypotAlertSeverity (tags 0-4)
  # ===========================================================================

  @typedoc """
  HoneypotAlertSeverity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type honeypot_alert_severity :: :info | :as_low | :as_medium | :as_high | :critical

  @honeypot_alert_severity_tags %{
    info: 0,
    as_low: 1,
    as_medium: 2,
    as_high: 3,
    critical: 4,
  }

  @tag_to_honeypot_alert_severity Map.new(@honeypot_alert_severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HoneypotAlertSeverity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Honeypot.honeypot_alert_severity_from_tag(0)
      {:ok, :info}
  """
  @spec honeypot_alert_severity_from_tag(non_neg_integer()) :: {:ok, honeypot_alert_severity()} | :error
  def honeypot_alert_severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_honeypot_alert_severity, tag)}
  end

  def honeypot_alert_severity_from_tag(_tag), do: :error

  @doc """
  Encode a `HoneypotAlertSeverity` to the C-ABI tag value.
  """
  @spec honeypot_alert_severity_to_tag(honeypot_alert_severity()) :: non_neg_integer()
  def honeypot_alert_severity_to_tag(val) when is_map_key(@honeypot_alert_severity_tags, val) do
    Map.fetch!(@honeypot_alert_severity_tags, val)
  end

  @doc """
  All `HoneypotAlertSeverity` variants in tag order.
  """
  @spec all_honeypot_alert_severitys() :: [honeypot_alert_severity()]
  def all_honeypot_alert_severitys, do: [:info, :as_low, :as_medium, :as_high, :critical]

  # ===========================================================================
  # AttackerAction (tags 0-5)
  # ===========================================================================

  @typedoc """
  AttackerAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type attacker_action :: :scan | :brute_force | :exploit | :payload | :lateral | :exfiltration

  @attacker_action_tags %{
    scan: 0,
    brute_force: 1,
    exploit: 2,
    payload: 3,
    lateral: 4,
    exfiltration: 5,
  }

  @tag_to_attacker_action Map.new(@attacker_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AttackerAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Honeypot.attacker_action_from_tag(0)
      {:ok, :scan}
  """
  @spec attacker_action_from_tag(non_neg_integer()) :: {:ok, attacker_action()} | :error
  def attacker_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_attacker_action, tag)}
  end

  def attacker_action_from_tag(_tag), do: :error

  @doc """
  Encode a `AttackerAction` to the C-ABI tag value.
  """
  @spec attacker_action_to_tag(attacker_action()) :: non_neg_integer()
  def attacker_action_to_tag(val) when is_map_key(@attacker_action_tags, val) do
    Map.fetch!(@attacker_action_tags, val)
  end

  @doc """
  All `AttackerAction` variants in tag order.
  """
  @spec all_attacker_actions() :: [attacker_action()]
  def all_attacker_actions, do: [:scan, :brute_force, :exploit, :payload, :lateral, :exfiltration]

  # ===========================================================================
  # ServerState (tags 0-3)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :deployed | :engaged | :shutdown

  @server_state_tags %{
    idle: 0,
    deployed: 1,
    engaged: 2,
    shutdown: 3,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Honeypot.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
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
  def all_server_states, do: [:idle, :deployed, :engaged, :shutdown]

end
