# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Container do
  @moduledoc """
  Container Runtime types for the proven-servers ABI.
  
  Formally verified container runtime types.
  Mirrors the Idris2 module `ContainerABI.Types`.
  
  - `ContainerState` -- Container lifecycle states.
  - `ContainerOperation` -- Container operations.
  - `NetworkMode` -- Container network modes.
  - `VolumeType` -- Container volume types.
  - `RestartPolicy` -- Container restart policies.
  - `HealthStatus` -- Container health check status.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ContainerState (tags 0-6)
  # ===========================================================================

  @typedoc """
  ContainerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type container_state ::
          :creating
          | :running
          | :paused
          | :restarting
          | :stopped
          | :removing
          | :dead

  @container_state_tags %{
    creating: 0,
    running: 1,
    paused: 2,
    restarting: 3,
    stopped: 4,
    removing: 5,
    dead: 6,
  }

  @tag_to_container_state Map.new(@container_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContainerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Container.container_state_from_tag(0)
      {:ok, :creating}
  """
  @spec container_state_from_tag(non_neg_integer()) :: {:ok, container_state()} | :error
  def container_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_container_state, tag)}
  end

  def container_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ContainerState` to the C-ABI tag value.
  """
  @spec container_state_to_tag(container_state()) :: non_neg_integer()
  def container_state_to_tag(val) when is_map_key(@container_state_tags, val) do
    Map.fetch!(@container_state_tags, val)
  end

  @doc """
  All `ContainerState` variants in tag order.
  """
  @spec all_container_states() :: [container_state()]
  def all_container_states, do: [:creating, :running, :paused, :restarting, :stopped, :removing, :dead]

  # ===========================================================================
  # ContainerOperation (tags 0-10)
  # ===========================================================================

  @typedoc """
  ContainerOperation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type container_operation ::
          :create
          | :start
          | :stop
          | :restart
          | :pause
          | :unpause
          | :kill
          | :remove
          | :exec
          | :logs
          | :inspect

  @container_operation_tags %{
    create: 0,
    start: 1,
    stop: 2,
    restart: 3,
    pause: 4,
    unpause: 5,
    kill: 6,
    remove: 7,
    exec: 8,
    logs: 9,
    inspect: 10,
  }

  @tag_to_container_operation Map.new(@container_operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContainerOperation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Container.container_operation_from_tag(0)
      {:ok, :create}
  """
  @spec container_operation_from_tag(non_neg_integer()) :: {:ok, container_operation()} | :error
  def container_operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_container_operation, tag)}
  end

  def container_operation_from_tag(_tag), do: :error

  @doc """
  Encode a `ContainerOperation` to the C-ABI tag value.
  """
  @spec container_operation_to_tag(container_operation()) :: non_neg_integer()
  def container_operation_to_tag(val) when is_map_key(@container_operation_tags, val) do
    Map.fetch!(@container_operation_tags, val)
  end

  @doc """
  All `ContainerOperation` variants in tag order.
  """
  @spec all_container_operations() :: [container_operation()]
  def all_container_operations do
    [
      :create, :start, :stop, :restart, :pause, :unpause, :kill, :remove,
      :exec, :logs, :inspect
    ]
  end

  # ===========================================================================
  # NetworkMode (tags 0-4)
  # ===========================================================================

  @typedoc """
  NetworkMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type network_mode :: :bridge | :host | :none | :overlay | :macvlan

  @network_mode_tags %{
    bridge: 0,
    host: 1,
    none: 2,
    overlay: 3,
    macvlan: 4,
  }

  @tag_to_network_mode Map.new(@network_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NetworkMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Container.network_mode_from_tag(0)
      {:ok, :bridge}
  """
  @spec network_mode_from_tag(non_neg_integer()) :: {:ok, network_mode()} | :error
  def network_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_network_mode, tag)}
  end

  def network_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `NetworkMode` to the C-ABI tag value.
  """
  @spec network_mode_to_tag(network_mode()) :: non_neg_integer()
  def network_mode_to_tag(val) when is_map_key(@network_mode_tags, val) do
    Map.fetch!(@network_mode_tags, val)
  end

  @doc """
  All `NetworkMode` variants in tag order.
  """
  @spec all_network_modes() :: [network_mode()]
  def all_network_modes, do: [:bridge, :host, :none, :overlay, :macvlan]

  # ===========================================================================
  # VolumeType (tags 0-2)
  # ===========================================================================

  @typedoc """
  VolumeType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type volume_type :: :bind | :named | :tmpfs

  @volume_type_tags %{
    bind: 0,
    named: 1,
    tmpfs: 2,
  }

  @tag_to_volume_type Map.new(@volume_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `VolumeType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Container.volume_type_from_tag(0)
      {:ok, :bind}
  """
  @spec volume_type_from_tag(non_neg_integer()) :: {:ok, volume_type()} | :error
  def volume_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_volume_type, tag)}
  end

  def volume_type_from_tag(_tag), do: :error

  @doc """
  Encode a `VolumeType` to the C-ABI tag value.
  """
  @spec volume_type_to_tag(volume_type()) :: non_neg_integer()
  def volume_type_to_tag(val) when is_map_key(@volume_type_tags, val) do
    Map.fetch!(@volume_type_tags, val)
  end

  @doc """
  All `VolumeType` variants in tag order.
  """
  @spec all_volume_types() :: [volume_type()]
  def all_volume_types, do: [:bind, :named, :tmpfs]

  # ===========================================================================
  # RestartPolicy (tags 0-3)
  # ===========================================================================

  @typedoc """
  RestartPolicy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type restart_policy :: :no | :always | :on_failure | :unless_stopped

  @restart_policy_tags %{
    no: 0,
    always: 1,
    on_failure: 2,
    unless_stopped: 3,
  }

  @tag_to_restart_policy Map.new(@restart_policy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RestartPolicy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Container.restart_policy_from_tag(0)
      {:ok, :no}
  """
  @spec restart_policy_from_tag(non_neg_integer()) :: {:ok, restart_policy()} | :error
  def restart_policy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_restart_policy, tag)}
  end

  def restart_policy_from_tag(_tag), do: :error

  @doc """
  Encode a `RestartPolicy` to the C-ABI tag value.
  """
  @spec restart_policy_to_tag(restart_policy()) :: non_neg_integer()
  def restart_policy_to_tag(val) when is_map_key(@restart_policy_tags, val) do
    Map.fetch!(@restart_policy_tags, val)
  end

  @doc """
  All `RestartPolicy` variants in tag order.
  """
  @spec all_restart_policys() :: [restart_policy()]
  def all_restart_policys, do: [:no, :always, :on_failure, :unless_stopped]

  # ===========================================================================
  # HealthStatus (tags 0-3)
  # ===========================================================================

  @typedoc """
  HealthStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type health_status :: :starting | :healthy | :unhealthy | :no_check

  @health_status_tags %{
    starting: 0,
    healthy: 1,
    unhealthy: 2,
    no_check: 3,
  }

  @tag_to_health_status Map.new(@health_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HealthStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Container.health_status_from_tag(0)
      {:ok, :starting}
  """
  @spec health_status_from_tag(non_neg_integer()) :: {:ok, health_status()} | :error
  def health_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_health_status, tag)}
  end

  def health_status_from_tag(_tag), do: :error

  @doc """
  Encode a `HealthStatus` to the C-ABI tag value.
  """
  @spec health_status_to_tag(health_status()) :: non_neg_integer()
  def health_status_to_tag(val) when is_map_key(@health_status_tags, val) do
    Map.fetch!(@health_status_tags, val)
  end

  @doc """
  All `HealthStatus` variants in tag order.
  """
  @spec all_health_statuss() :: [health_status()]
  def all_health_statuss, do: [:starting, :healthy, :unhealthy, :no_check]

end
