# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Netconf do
  @moduledoc """
  NETCONF types for the proven-servers ABI.
  
  Formally verified NETCONF types (RFC 6241).
  Mirrors the Idris2 module `NetconfABI.Types`.
  
  - `NetconfOperation` -- NETCONF operations.
  - `Datastore` -- NETCONF datastores.
  - `EditOperation` -- NETCONF edit operations.
  - `NetconfErrorType` -- NETCONF error types.
  - `ErrorSeverity` -- NETCONF error severity.
  - `NetconfState` -- NETCONF session states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard NETCONF SSH port."
  @spec netconf_port() :: non_neg_integer()
  def netconf_port, do: 830

  # ===========================================================================
  # NetconfOperation (tags 0-11)
  # ===========================================================================

  @typedoc """
  NetconfOperation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type netconf_operation ::
          :get
          | :get_config
          | :edit_config
          | :copy_config
          | :delete_config
          | :lock
          | :unlock
          | :close_session
          | :kill_session
          | :commit
          | :validate
          | :discard_changes

  @netconf_operation_tags %{
    get: 0,
    get_config: 1,
    edit_config: 2,
    copy_config: 3,
    delete_config: 4,
    lock: 5,
    unlock: 6,
    close_session: 7,
    kill_session: 8,
    commit: 9,
    validate: 10,
    discard_changes: 11,
  }

  @tag_to_netconf_operation Map.new(@netconf_operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NetconfOperation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Netconf.netconf_operation_from_tag(0)
      {:ok, :get}
  """
  @spec netconf_operation_from_tag(non_neg_integer()) :: {:ok, netconf_operation()} | :error
  def netconf_operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_netconf_operation, tag)}
  end

  def netconf_operation_from_tag(_tag), do: :error

  @doc """
  Encode a `NetconfOperation` to the C-ABI tag value.
  """
  @spec netconf_operation_to_tag(netconf_operation()) :: non_neg_integer()
  def netconf_operation_to_tag(val) when is_map_key(@netconf_operation_tags, val) do
    Map.fetch!(@netconf_operation_tags, val)
  end

  @doc """
  All `NetconfOperation` variants in tag order.
  """
  @spec all_netconf_operations() :: [netconf_operation()]
  def all_netconf_operations do
    [
      :get, :get_config, :edit_config, :copy_config, :delete_config,
      :lock, :unlock, :close_session, :kill_session, :commit, :validate,
      :discard_changes
    ]
  end

  # ===========================================================================
  # Datastore (tags 0-2)
  # ===========================================================================

  @typedoc """
  Datastore types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type datastore :: :running | :startup | :candidate

  @datastore_tags %{
    running: 0,
    startup: 1,
    candidate: 2,
  }

  @tag_to_datastore Map.new(@datastore_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Datastore` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Netconf.datastore_from_tag(0)
      {:ok, :running}
  """
  @spec datastore_from_tag(non_neg_integer()) :: {:ok, datastore()} | :error
  def datastore_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_datastore, tag)}
  end

  def datastore_from_tag(_tag), do: :error

  @doc """
  Encode a `Datastore` to the C-ABI tag value.
  """
  @spec datastore_to_tag(datastore()) :: non_neg_integer()
  def datastore_to_tag(val) when is_map_key(@datastore_tags, val) do
    Map.fetch!(@datastore_tags, val)
  end

  @doc """
  All `Datastore` variants in tag order.
  """
  @spec all_datastores() :: [datastore()]
  def all_datastores, do: [:running, :startup, :candidate]

  # ===========================================================================
  # EditOperation (tags 0-4)
  # ===========================================================================

  @typedoc """
  EditOperation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type edit_operation :: :merge | :replace | :create | :delete | :remove

  @edit_operation_tags %{
    merge: 0,
    replace: 1,
    create: 2,
    delete: 3,
    remove: 4,
  }

  @tag_to_edit_operation Map.new(@edit_operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EditOperation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Netconf.edit_operation_from_tag(0)
      {:ok, :merge}
  """
  @spec edit_operation_from_tag(non_neg_integer()) :: {:ok, edit_operation()} | :error
  def edit_operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_edit_operation, tag)}
  end

  def edit_operation_from_tag(_tag), do: :error

  @doc """
  Encode a `EditOperation` to the C-ABI tag value.
  """
  @spec edit_operation_to_tag(edit_operation()) :: non_neg_integer()
  def edit_operation_to_tag(val) when is_map_key(@edit_operation_tags, val) do
    Map.fetch!(@edit_operation_tags, val)
  end

  @doc """
  All `EditOperation` variants in tag order.
  """
  @spec all_edit_operations() :: [edit_operation()]
  def all_edit_operations, do: [:merge, :replace, :create, :delete, :remove]

  # ===========================================================================
  # NetconfErrorType (tags 0-3)
  # ===========================================================================

  @typedoc """
  NetconfErrorType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type netconf_error_type :: :transport | :rpc | :protocol | :application

  @netconf_error_type_tags %{
    transport: 0,
    rpc: 1,
    protocol: 2,
    application: 3,
  }

  @tag_to_netconf_error_type Map.new(@netconf_error_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NetconfErrorType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Netconf.netconf_error_type_from_tag(0)
      {:ok, :transport}
  """
  @spec netconf_error_type_from_tag(non_neg_integer()) :: {:ok, netconf_error_type()} | :error
  def netconf_error_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_netconf_error_type, tag)}
  end

  def netconf_error_type_from_tag(_tag), do: :error

  @doc """
  Encode a `NetconfErrorType` to the C-ABI tag value.
  """
  @spec netconf_error_type_to_tag(netconf_error_type()) :: non_neg_integer()
  def netconf_error_type_to_tag(val) when is_map_key(@netconf_error_type_tags, val) do
    Map.fetch!(@netconf_error_type_tags, val)
  end

  @doc """
  All `NetconfErrorType` variants in tag order.
  """
  @spec all_netconf_error_types() :: [netconf_error_type()]
  def all_netconf_error_types, do: [:transport, :rpc, :protocol, :application]

  # ===========================================================================
  # ErrorSeverity (tags 0-1)
  # ===========================================================================

  @typedoc """
  ErrorSeverity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_severity :: :error | :warning

  @error_severity_tags %{
    error: 0,
    warning: 1,
  }

  @tag_to_error_severity Map.new(@error_severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorSeverity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Netconf.error_severity_from_tag(0)
      {:ok, :error}
  """
  @spec error_severity_from_tag(non_neg_integer()) :: {:ok, error_severity()} | :error
  def error_severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_error_severity, tag)}
  end

  def error_severity_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorSeverity` to the C-ABI tag value.
  """
  @spec error_severity_to_tag(error_severity()) :: non_neg_integer()
  def error_severity_to_tag(val) when is_map_key(@error_severity_tags, val) do
    Map.fetch!(@error_severity_tags, val)
  end

  @doc """
  All `ErrorSeverity` variants in tag order.
  """
  @spec all_error_severitys() :: [error_severity()]
  def all_error_severitys, do: [:error, :warning]

  # ===========================================================================
  # NetconfState (tags 0-5)
  # ===========================================================================

  @typedoc """
  NetconfState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type netconf_state :: :idle | :connected | :locked | :editing | :closing | :terminated

  @netconf_state_tags %{
    idle: 0,
    connected: 1,
    locked: 2,
    editing: 3,
    closing: 4,
    terminated: 5,
  }

  @tag_to_netconf_state Map.new(@netconf_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NetconfState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Netconf.netconf_state_from_tag(0)
      {:ok, :idle}
  """
  @spec netconf_state_from_tag(non_neg_integer()) :: {:ok, netconf_state()} | :error
  def netconf_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_netconf_state, tag)}
  end

  def netconf_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NetconfState` to the C-ABI tag value.
  """
  @spec netconf_state_to_tag(netconf_state()) :: non_neg_integer()
  def netconf_state_to_tag(val) when is_map_key(@netconf_state_tags, val) do
    Map.fetch!(@netconf_state_tags, val)
  end

  @doc """
  All `NetconfState` variants in tag order.
  """
  @spec all_netconf_states() :: [netconf_state()]
  def all_netconf_states, do: [:idle, :connected, :locked, :editing, :closing, :terminated]

end
