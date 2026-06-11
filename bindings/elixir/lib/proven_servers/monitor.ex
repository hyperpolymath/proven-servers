# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Monitor do
  @moduledoc """
  Monitor types for the proven-servers ABI.
  
  Formally verified monitoring/uptime types.
  Mirrors the Idris2 module `MonitorABI.Types`.
  
  - `CheckType` -- Monitor check types.
  - `Status` -- Monitor status values.
  - `AlertChannel` -- Alert notification channels.
  - `Severity` -- Monitor severity levels.
  - `CheckState` -- Monitor check execution states.
  - `MonitorState` -- Monitor service states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # CheckType (tags 0-10)
  # ===========================================================================

  @typedoc """
  CheckType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type check_type ::
          :http
          | :tcp
          | :udp
          | :icmp
          | :dns
          | :certificate
          | :disk
          | :cpu
          | :memory
          | :process
          | :custom

  @check_type_tags %{
    http: 0,
    tcp: 1,
    udp: 2,
    icmp: 3,
    dns: 4,
    certificate: 5,
    disk: 6,
    cpu: 7,
    memory: 8,
    process: 9,
    custom: 10,
  }

  @tag_to_check_type Map.new(@check_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CheckType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Monitor.check_type_from_tag(0)
      {:ok, :http}
  """
  @spec check_type_from_tag(non_neg_integer()) :: {:ok, check_type()} | :error
  def check_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_check_type, tag)}
  end

  def check_type_from_tag(_tag), do: :error

  @doc """
  Encode a `CheckType` to the C-ABI tag value.
  """
  @spec check_type_to_tag(check_type()) :: non_neg_integer()
  def check_type_to_tag(val) when is_map_key(@check_type_tags, val) do
    Map.fetch!(@check_type_tags, val)
  end

  @doc """
  All `CheckType` variants in tag order.
  """
  @spec all_check_types() :: [check_type()]
  def all_check_types do
    [
      :http, :tcp, :udp, :icmp, :dns, :certificate, :disk, :cpu, :memory,
      :process, :custom
    ]
  end

  # ===========================================================================
  # Status (tags 0-4)
  # ===========================================================================

  @typedoc """
  Status types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type status :: :up | :down | :degraded | :unknown | :maintenance

  @status_tags %{
    up: 0,
    down: 1,
    degraded: 2,
    unknown: 3,
    maintenance: 4,
  }

  @tag_to_status Map.new(@status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Status` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Monitor.status_from_tag(0)
      {:ok, :up}
  """
  @spec status_from_tag(non_neg_integer()) :: {:ok, status()} | :error
  def status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_status, tag)}
  end

  def status_from_tag(_tag), do: :error

  @doc """
  Encode a `Status` to the C-ABI tag value.
  """
  @spec status_to_tag(status()) :: non_neg_integer()
  def status_to_tag(val) when is_map_key(@status_tags, val) do
    Map.fetch!(@status_tags, val)
  end

  @doc """
  All `Status` variants in tag order.
  """
  @spec all_statuss() :: [status()]
  def all_statuss, do: [:up, :down, :degraded, :unknown, :maintenance]

  # ===========================================================================
  # AlertChannel (tags 0-4)
  # ===========================================================================

  @typedoc """
  AlertChannel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type alert_channel :: :email | :sms | :webhook | :slack | :pager_duty

  @alert_channel_tags %{
    email: 0,
    sms: 1,
    webhook: 2,
    slack: 3,
    pager_duty: 4,
  }

  @tag_to_alert_channel Map.new(@alert_channel_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AlertChannel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Monitor.alert_channel_from_tag(0)
      {:ok, :email}
  """
  @spec alert_channel_from_tag(non_neg_integer()) :: {:ok, alert_channel()} | :error
  def alert_channel_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_alert_channel, tag)}
  end

  def alert_channel_from_tag(_tag), do: :error

  @doc """
  Encode a `AlertChannel` to the C-ABI tag value.
  """
  @spec alert_channel_to_tag(alert_channel()) :: non_neg_integer()
  def alert_channel_to_tag(val) when is_map_key(@alert_channel_tags, val) do
    Map.fetch!(@alert_channel_tags, val)
  end

  @doc """
  All `AlertChannel` variants in tag order.
  """
  @spec all_alert_channels() :: [alert_channel()]
  def all_alert_channels, do: [:email, :sms, :webhook, :slack, :pager_duty]

  # ===========================================================================
  # Severity (tags 0-3)
  # ===========================================================================

  @typedoc """
  Severity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type severity :: :info | :warning | :error | :critical

  @severity_tags %{
    info: 0,
    warning: 1,
    error: 2,
    critical: 3,
  }

  @tag_to_severity Map.new(@severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Severity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Monitor.severity_from_tag(0)
      {:ok, :info}
  """
  @spec severity_from_tag(non_neg_integer()) :: {:ok, severity()} | :error
  def severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_severity, tag)}
  end

  def severity_from_tag(_tag), do: :error

  @doc """
  Encode a `Severity` to the C-ABI tag value.
  """
  @spec severity_to_tag(severity()) :: non_neg_integer()
  def severity_to_tag(val) when is_map_key(@severity_tags, val) do
    Map.fetch!(@severity_tags, val)
  end

  @doc """
  All `Severity` variants in tag order.
  """
  @spec all_severitys() :: [severity()]
  def all_severitys, do: [:info, :warning, :error, :critical]

  # ===========================================================================
  # CheckState (tags 0-5)
  # ===========================================================================

  @typedoc """
  CheckState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type check_state :: :pending | :running | :passed | :failed | :timeout | :cs_error

  @check_state_tags %{
    pending: 0,
    running: 1,
    passed: 2,
    failed: 3,
    timeout: 4,
    cs_error: 5,
  }

  @tag_to_check_state Map.new(@check_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CheckState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Monitor.check_state_from_tag(0)
      {:ok, :pending}
  """
  @spec check_state_from_tag(non_neg_integer()) :: {:ok, check_state()} | :error
  def check_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_check_state, tag)}
  end

  def check_state_from_tag(_tag), do: :error

  @doc """
  Encode a `CheckState` to the C-ABI tag value.
  """
  @spec check_state_to_tag(check_state()) :: non_neg_integer()
  def check_state_to_tag(val) when is_map_key(@check_state_tags, val) do
    Map.fetch!(@check_state_tags, val)
  end

  @doc """
  All `CheckState` variants in tag order.
  """
  @spec all_check_states() :: [check_state()]
  def all_check_states, do: [:pending, :running, :passed, :failed, :timeout, :cs_error]

  # ===========================================================================
  # MonitorState (tags 0-5)
  # ===========================================================================

  @typedoc """
  MonitorState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type monitor_state :: :idle | :configured | :running | :mon_paused | :alerting | :shutdown

  @monitor_state_tags %{
    idle: 0,
    configured: 1,
    running: 2,
    mon_paused: 3,
    alerting: 4,
    shutdown: 5,
  }

  @tag_to_monitor_state Map.new(@monitor_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MonitorState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Monitor.monitor_state_from_tag(0)
      {:ok, :idle}
  """
  @spec monitor_state_from_tag(non_neg_integer()) :: {:ok, monitor_state()} | :error
  def monitor_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_monitor_state, tag)}
  end

  def monitor_state_from_tag(_tag), do: :error

  @doc """
  Encode a `MonitorState` to the C-ABI tag value.
  """
  @spec monitor_state_to_tag(monitor_state()) :: non_neg_integer()
  def monitor_state_to_tag(val) when is_map_key(@monitor_state_tags, val) do
    Map.fetch!(@monitor_state_tags, val)
  end

  @doc """
  All `MonitorState` variants in tag order.
  """
  @spec all_monitor_states() :: [monitor_state()]
  def all_monitor_states, do: [:idle, :configured, :running, :mon_paused, :alerting, :shutdown]

end
