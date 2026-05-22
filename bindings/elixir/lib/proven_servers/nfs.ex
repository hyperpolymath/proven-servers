# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Nfs do
  @moduledoc """
  NFS (Network File System) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `NFSABI.Types` and its type definitions:
  - `Operation` — NFS operations (15 constructors, tags 0-14)
  - `FileType`  — NFS file types (7 constructors, tags 0-6)
  - `Status`    — NFS status codes (14 constructors, tags 0-13)
  - `NfsState`  — NFS server lifecycle (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard NFS port (RFC 7530)."
  @spec nfs_port() :: non_neg_integer()
  def nfs_port, do: 2049

  # ===========================================================================
  # Operation (tags 0-14)
  # ===========================================================================

  @typedoc """
  Operation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type operation ::
          :access
          | :close
          | :commit
          | :create
          | :get_attr
          | :link
          | :lock
          | :lookup
          | :open
          | :read
          | :read_dir
          | :remove
          | :rename
          | :set_attr
          | :write

  @operation_tags %{
    access: 0,
    close: 1,
    commit: 2,
    create: 3,
    get_attr: 4,
    link: 5,
    lock: 6,
    lookup: 7,
    open: 8,
    read: 9,
    read_dir: 10,
    remove: 11,
    rename: 12,
    set_attr: 13,
    write: 14,
  }

  @tag_to_operation Map.new(@operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Operation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..14, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nfs.operation_from_tag(0)
      {:ok, :access}
  """
  @spec operation_from_tag(non_neg_integer()) :: {:ok, operation()} | :error
  def operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 14 do
    {:ok, Map.fetch!(@tag_to_operation, tag)}
  end

  def operation_from_tag(_tag), do: :error

  @doc """
  Encode a `Operation` to the C-ABI tag value.
  """
  @spec operation_to_tag(operation()) :: non_neg_integer()
  def operation_to_tag(val) when is_map_key(@operation_tags, val) do
    Map.fetch!(@operation_tags, val)
  end

  @doc """
  All `Operation` variants in tag order.
  """
  @spec all_operations() :: [operation()]
  def all_operations do
    [
      :access, :close, :commit, :create, :get_attr, :link, :lock, :lookup,
      :open, :read, :read_dir, :remove, :rename, :set_attr, :write
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this operation modifies the filesystem.
  """
  @spec is_write?(operation()) :: boolean()
  def is_write?(val) when val in [:create, :link, :remove, :rename, :set_attr, :write, :commit], do: true
  def is_write?(_val), do: false

  @doc """
  Whether this operation is read-only.
  """
  @spec is_read?(operation()) :: boolean()
  def is_read?(val) when val in [:access, :get_attr, :lookup, :read, :read_dir], do: true
  def is_read?(_val), do: false

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
          | :block_device
          | :char_device
          | :link
          | :socket
          | :fifo

  @file_type_tags %{
    regular: 0,
    directory: 1,
    block_device: 2,
    char_device: 3,
    link: 4,
    socket: 5,
    fifo: 6,
  }

  @tag_to_file_type Map.new(@file_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FileType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nfs.file_type_from_tag(0)
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
      :regular, :directory, :block_device, :char_device, :link, :socket,
      :fifo
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this file type is a regular data file.
  """
  @spec is_regular?(file_type()) :: boolean()
  def is_regular?(val) when val in [:regular], do: true
  def is_regular?(_val), do: false

  @doc """
  Whether this file type is a special device node.
  """
  @spec is_device?(file_type()) :: boolean()
  def is_device?(val) when val in [:block_device, :char_device], do: true
  def is_device?(_val), do: false

  # ===========================================================================
  # Status (tags 0-13)
  # ===========================================================================

  @typedoc """
  Status types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type status ::
          :ok
          | :perm
          | :no_ent
          | :io
          | :nx_io
          | :access
          | :exist
          | :not_dir
          | :is_dir
          | :f_big
          | :no_spc
          | :r_ofs
          | :not_empty
          | :stale

  @status_tags %{
    ok: 0,
    perm: 1,
    no_ent: 2,
    io: 3,
    nx_io: 4,
    access: 5,
    exist: 6,
    not_dir: 7,
    is_dir: 8,
    f_big: 9,
    no_spc: 10,
    r_ofs: 11,
    not_empty: 12,
    stale: 13,
  }

  @tag_to_status Map.new(@status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Status` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..13, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nfs.status_from_tag(0)
      {:ok, :ok}
  """
  @spec status_from_tag(non_neg_integer()) :: {:ok, status()} | :error
  def status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 13 do
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
  def all_statuss do
    [
      :ok, :perm, :no_ent, :io, :nx_io, :access, :exist, :not_dir, :is_dir,
      :f_big, :no_spc, :r_ofs, :not_empty, :stale
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this status indicates success.
  """
  @spec is_ok?(status()) :: boolean()
  def is_ok?(val) when val in [:ok], do: true
  def is_ok?(_val), do: false

  @doc """
  Whether this error relates to access control.
  """
  @spec is_access_error?(status()) :: boolean()
  def is_access_error?(val) when val in [:perm, :access, :r_ofs], do: true
  def is_access_error?(_val), do: false

  @doc """
  Whether this error is likely transient and retryable.
  """
  @spec is_retryable?(status()) :: boolean()
  def is_retryable?(val) when val in [:io, :nx_io, :stale], do: true
  def is_retryable?(_val), do: false

  # ===========================================================================
  # NfsState (tags 0-5)
  # ===========================================================================

  @typedoc """
  NfsState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type nfs_state :: :idle | :mounted | :file_open | :locked | :busy | :unmounting

  @nfs_state_tags %{
    idle: 0,
    mounted: 1,
    file_open: 2,
    locked: 3,
    busy: 4,
    unmounting: 5,
  }

  @tag_to_nfs_state Map.new(@nfs_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NfsState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Nfs.nfs_state_from_tag(0)
      {:ok, :idle}
  """
  @spec nfs_state_from_tag(non_neg_integer()) :: {:ok, nfs_state()} | :error
  def nfs_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_nfs_state, tag)}
  end

  def nfs_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NfsState` to the C-ABI tag value.
  """
  @spec nfs_state_to_tag(nfs_state()) :: non_neg_integer()
  def nfs_state_to_tag(val) when is_map_key(@nfs_state_tags, val) do
    Map.fetch!(@nfs_state_tags, val)
  end

  @doc """
  All `NfsState` variants in tag order.
  """
  @spec all_nfs_states() :: [nfs_state()]
  def all_nfs_states, do: [:idle, :mounted, :file_open, :locked, :busy, :unmounting]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the NFS mount is active.
  """
  @spec is_mounted?(nfs_state()) :: boolean()
  def is_mounted?(val) when val in [:idle, :unmounting], do: false
  def is_mounted?(_val), do: true

end
