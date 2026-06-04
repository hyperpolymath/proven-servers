# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Configmgmt do
  @moduledoc """
  Configuration Management types for the proven-servers ABI.
  
  Formally verified configuration management types.
  Mirrors the Idris2 module `ConfigmgmtABI.Types`.
  
  - `ResourceType` -- Managed resource types.
  - `ResourceState` -- Desired resource states.
  - `ChangeAction` -- Configuration change actions.
  - `DriftStatus` -- Configuration drift status.
  - `ApplyMode` -- Configuration apply modes.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ResourceType (tags 0-8)
  # ===========================================================================

  @typedoc """
  ResourceType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type resource_type ::
          :file
          | :package
          | :service
          | :user
          | :group
          | :cron
          | :mount
          | :firewall
          | :registry

  @resource_type_tags %{
    file: 0,
    package: 1,
    service: 2,
    user: 3,
    group: 4,
    cron: 5,
    mount: 6,
    firewall: 7,
    registry: 8,
  }

  @tag_to_resource_type Map.new(@resource_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResourceType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Configmgmt.resource_type_from_tag(0)
      {:ok, :file}
  """
  @spec resource_type_from_tag(non_neg_integer()) :: {:ok, resource_type()} | :error
  def resource_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_resource_type, tag)}
  end

  def resource_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ResourceType` to the C-ABI tag value.
  """
  @spec resource_type_to_tag(resource_type()) :: non_neg_integer()
  def resource_type_to_tag(val) when is_map_key(@resource_type_tags, val) do
    Map.fetch!(@resource_type_tags, val)
  end

  @doc """
  All `ResourceType` variants in tag order.
  """
  @spec all_resource_types() :: [resource_type()]
  def all_resource_types do
    [
      :file, :package, :service, :user, :group, :cron, :mount, :firewall,
      :registry
    ]
  end

  # ===========================================================================
  # ResourceState (tags 0-5)
  # ===========================================================================

  @typedoc """
  ResourceState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type resource_state :: :present | :absent | :running | :stopped | :enabled | :disabled

  @resource_state_tags %{
    present: 0,
    absent: 1,
    running: 2,
    stopped: 3,
    enabled: 4,
    disabled: 5,
  }

  @tag_to_resource_state Map.new(@resource_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResourceState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Configmgmt.resource_state_from_tag(0)
      {:ok, :present}
  """
  @spec resource_state_from_tag(non_neg_integer()) :: {:ok, resource_state()} | :error
  def resource_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_resource_state, tag)}
  end

  def resource_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ResourceState` to the C-ABI tag value.
  """
  @spec resource_state_to_tag(resource_state()) :: non_neg_integer()
  def resource_state_to_tag(val) when is_map_key(@resource_state_tags, val) do
    Map.fetch!(@resource_state_tags, val)
  end

  @doc """
  All `ResourceState` variants in tag order.
  """
  @spec all_resource_states() :: [resource_state()]
  def all_resource_states, do: [:present, :absent, :running, :stopped, :enabled, :disabled]

  # ===========================================================================
  # ChangeAction (tags 0-5)
  # ===========================================================================

  @typedoc """
  ChangeAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type change_action :: :create | :modify | :delete | :restart | :reload | :skip

  @change_action_tags %{
    create: 0,
    modify: 1,
    delete: 2,
    restart: 3,
    reload: 4,
    skip: 5,
  }

  @tag_to_change_action Map.new(@change_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ChangeAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Configmgmt.change_action_from_tag(0)
      {:ok, :create}
  """
  @spec change_action_from_tag(non_neg_integer()) :: {:ok, change_action()} | :error
  def change_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_change_action, tag)}
  end

  def change_action_from_tag(_tag), do: :error

  @doc """
  Encode a `ChangeAction` to the C-ABI tag value.
  """
  @spec change_action_to_tag(change_action()) :: non_neg_integer()
  def change_action_to_tag(val) when is_map_key(@change_action_tags, val) do
    Map.fetch!(@change_action_tags, val)
  end

  @doc """
  All `ChangeAction` variants in tag order.
  """
  @spec all_change_actions() :: [change_action()]
  def all_change_actions, do: [:create, :modify, :delete, :restart, :reload, :skip]

  # ===========================================================================
  # DriftStatus (tags 0-3)
  # ===========================================================================

  @typedoc """
  DriftStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type drift_status :: :in_sync | :drifted | :d_unknown | :unmanaged

  @drift_status_tags %{
    in_sync: 0,
    drifted: 1,
    d_unknown: 2,
    unmanaged: 3,
  }

  @tag_to_drift_status Map.new(@drift_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DriftStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Configmgmt.drift_status_from_tag(0)
      {:ok, :in_sync}
  """
  @spec drift_status_from_tag(non_neg_integer()) :: {:ok, drift_status()} | :error
  def drift_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_drift_status, tag)}
  end

  def drift_status_from_tag(_tag), do: :error

  @doc """
  Encode a `DriftStatus` to the C-ABI tag value.
  """
  @spec drift_status_to_tag(drift_status()) :: non_neg_integer()
  def drift_status_to_tag(val) when is_map_key(@drift_status_tags, val) do
    Map.fetch!(@drift_status_tags, val)
  end

  @doc """
  All `DriftStatus` variants in tag order.
  """
  @spec all_drift_statuss() :: [drift_status()]
  def all_drift_statuss, do: [:in_sync, :drifted, :d_unknown, :unmanaged]

  # ===========================================================================
  # ApplyMode (tags 0-2)
  # ===========================================================================

  @typedoc """
  ApplyMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type apply_mode :: :enforce | :dry_run | :audit

  @apply_mode_tags %{
    enforce: 0,
    dry_run: 1,
    audit: 2,
  }

  @tag_to_apply_mode Map.new(@apply_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ApplyMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Configmgmt.apply_mode_from_tag(0)
      {:ok, :enforce}
  """
  @spec apply_mode_from_tag(non_neg_integer()) :: {:ok, apply_mode()} | :error
  def apply_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_apply_mode, tag)}
  end

  def apply_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `ApplyMode` to the C-ABI tag value.
  """
  @spec apply_mode_to_tag(apply_mode()) :: non_neg_integer()
  def apply_mode_to_tag(val) when is_map_key(@apply_mode_tags, val) do
    Map.fetch!(@apply_mode_tags, val)
  end

  @doc """
  All `ApplyMode` variants in tag order.
  """
  @spec all_apply_modes() :: [apply_mode()]
  def all_apply_modes, do: [:enforce, :dry_run, :audit]

end
