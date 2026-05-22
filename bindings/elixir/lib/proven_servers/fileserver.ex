# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Fileserver do
  @moduledoc """
  File Server types for the proven-servers ABI.
  
  Formally verified file server types.
  Mirrors the Idris2 module `FileserverABI.Types`.
  
  - `FileOperation` -- File server operations.
  - `FileType` -- File types.
  - `FilePermission` -- POSIX file permissions.
  - `LockType` -- File lock types.
  - `FileErrorCode` -- File server error codes.
  - `SessionState` -- File server session states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # FileOperation (tags 0-9)
  # ===========================================================================

  @typedoc """
  FileOperation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type file_operation ::
          :read
          | :write
          | :create
          | :delete
          | :rename
          | :list
          | :stat
          | :lock
          | :unlock
          | :watch

  @file_operation_tags %{
    read: 0,
    write: 1,
    create: 2,
    delete: 3,
    rename: 4,
    list: 5,
    stat: 6,
    lock: 7,
    unlock: 8,
    watch: 9,
  }

  @tag_to_file_operation Map.new(@file_operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FileOperation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Fileserver.file_operation_from_tag(0)
      {:ok, :read}
  """
  @spec file_operation_from_tag(non_neg_integer()) :: {:ok, file_operation()} | :error
  def file_operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_file_operation, tag)}
  end

  def file_operation_from_tag(_tag), do: :error

  @doc """
  Encode a `FileOperation` to the C-ABI tag value.
  """
  @spec file_operation_to_tag(file_operation()) :: non_neg_integer()
  def file_operation_to_tag(val) when is_map_key(@file_operation_tags, val) do
    Map.fetch!(@file_operation_tags, val)
  end

  @doc """
  All `FileOperation` variants in tag order.
  """
  @spec all_file_operations() :: [file_operation()]
  def all_file_operations do
    [
      :read, :write, :create, :delete, :rename, :list, :stat, :lock,
      :unlock, :watch
    ]
  end

  # ===========================================================================
  # FileType (tags 0-6)
  # ===========================================================================

  @typedoc """
  FileType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type file_type ::
          :regular
          | :directory
          | :symlink
          | :block_device
          | :char_device
          | :fifo
          | :socket

  @file_type_tags %{
    regular: 0,
    directory: 1,
    symlink: 2,
    block_device: 3,
    char_device: 4,
    fifo: 5,
    socket: 6,
  }

  @tag_to_file_type Map.new(@file_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FileType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Fileserver.file_type_from_tag(0)
      {:ok, :regular}
  """
  @spec file_type_from_tag(non_neg_integer()) :: {:ok, file_type()} | :error
  def file_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_file_type, tag)}
  end

  def file_type_from_tag(_tag), do: :error

  @doc """
  Encode a `FileType` to the C-ABI tag value.
  """
  @spec file_type_to_tag(file_type()) :: non_neg_integer()
  def file_type_to_tag(val) when is_map_key(@file_type_tags, val) do
    Map.fetch!(@file_type_tags, val)
  end

  @doc """
  All `FileType` variants in tag order.
  """
  @spec all_file_types() :: [file_type()]
  def all_file_types do
    [
      :regular, :directory, :symlink, :block_device, :char_device, :fifo,
      :socket
    ]
  end

  # ===========================================================================
  # FilePermission (tags 0-8)
  # ===========================================================================

  @typedoc """
  FilePermission types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type file_permission ::
          :owner_read
          | :owner_write
          | :owner_execute
          | :group_read
          | :group_write
          | :group_execute
          | :other_read
          | :other_write
          | :other_execute

  @file_permission_tags %{
    owner_read: 0,
    owner_write: 1,
    owner_execute: 2,
    group_read: 3,
    group_write: 4,
    group_execute: 5,
    other_read: 6,
    other_write: 7,
    other_execute: 8,
  }

  @tag_to_file_permission Map.new(@file_permission_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FilePermission` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Fileserver.file_permission_from_tag(0)
      {:ok, :owner_read}
  """
  @spec file_permission_from_tag(non_neg_integer()) :: {:ok, file_permission()} | :error
  def file_permission_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_file_permission, tag)}
  end

  def file_permission_from_tag(_tag), do: :error

  @doc """
  Encode a `FilePermission` to the C-ABI tag value.
  """
  @spec file_permission_to_tag(file_permission()) :: non_neg_integer()
  def file_permission_to_tag(val) when is_map_key(@file_permission_tags, val) do
    Map.fetch!(@file_permission_tags, val)
  end

  @doc """
  All `FilePermission` variants in tag order.
  """
  @spec all_file_permissions() :: [file_permission()]
  def all_file_permissions do
    [
      :owner_read, :owner_write, :owner_execute, :group_read, :group_write,
      :group_execute, :other_read, :other_write, :other_execute
    ]
  end

  # ===========================================================================
  # LockType (tags 0-3)
  # ===========================================================================

  @typedoc """
  LockType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lock_type :: :shared | :exclusive | :advisory | :mandatory

  @lock_type_tags %{
    shared: 0,
    exclusive: 1,
    advisory: 2,
    mandatory: 3,
  }

  @tag_to_lock_type Map.new(@lock_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LockType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Fileserver.lock_type_from_tag(0)
      {:ok, :shared}
  """
  @spec lock_type_from_tag(non_neg_integer()) :: {:ok, lock_type()} | :error
  def lock_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_lock_type, tag)}
  end

  def lock_type_from_tag(_tag), do: :error

  @doc """
  Encode a `LockType` to the C-ABI tag value.
  """
  @spec lock_type_to_tag(lock_type()) :: non_neg_integer()
  def lock_type_to_tag(val) when is_map_key(@lock_type_tags, val) do
    Map.fetch!(@lock_type_tags, val)
  end

  @doc """
  All `LockType` variants in tag order.
  """
  @spec all_lock_types() :: [lock_type()]
  def all_lock_types, do: [:shared, :exclusive, :advisory, :mandatory]

  # ===========================================================================
  # FileErrorCode (tags 0-9)
  # ===========================================================================

  @typedoc """
  FileErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type file_error_code ::
          :not_found
          | :permission_denied
          | :already_exists
          | :not_empty
          | :is_directory
          | :not_directory
          | :no_space
          | :read_only
          | :locked
          | :io_error

  @file_error_code_tags %{
    not_found: 0,
    permission_denied: 1,
    already_exists: 2,
    not_empty: 3,
    is_directory: 4,
    not_directory: 5,
    no_space: 6,
    read_only: 7,
    locked: 8,
    io_error: 9,
  }

  @tag_to_file_error_code Map.new(@file_error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FileErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Fileserver.file_error_code_from_tag(0)
      {:ok, :not_found}
  """
  @spec file_error_code_from_tag(non_neg_integer()) :: {:ok, file_error_code()} | :error
  def file_error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_file_error_code, tag)}
  end

  def file_error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `FileErrorCode` to the C-ABI tag value.
  """
  @spec file_error_code_to_tag(file_error_code()) :: non_neg_integer()
  def file_error_code_to_tag(val) when is_map_key(@file_error_code_tags, val) do
    Map.fetch!(@file_error_code_tags, val)
  end

  @doc """
  All `FileErrorCode` variants in tag order.
  """
  @spec all_file_error_codes() :: [file_error_code()]
  def all_file_error_codes do
    [
      :not_found, :permission_denied, :already_exists, :not_empty, :is_directory,
      :not_directory, :no_space, :read_only, :locked, :io_error
    ]
  end

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :connected | :operating | :fs_locked | :disconnecting

  @session_state_tags %{
    idle: 0,
    connected: 1,
    operating: 2,
    fs_locked: 3,
    disconnecting: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Fileserver.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end

  def session_state_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionState` to the C-ABI tag value.
  """
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(val) when is_map_key(@session_state_tags, val) do
    Map.fetch!(@session_state_tags, val)
  end

  @doc """
  All `SessionState` variants in tag order.
  """
  @spec all_session_states() :: [session_state()]
  def all_session_states, do: [:idle, :connected, :operating, :fs_locked, :disconnecting]

end
