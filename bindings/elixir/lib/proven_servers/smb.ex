# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Smb do
  @moduledoc """
  SMB (Server Message Block) protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `SMBABI.Types` and its type definitions:
  - `Command`      — SMB2/3 commands (16 constructors, tags 0-15)
  - `Dialect`      — SMB protocol dialects (5 constructors, tags 0-4)
  - `ShareType`    — SMB share types (3 constructors, tags 0-2)
  - `SessionState` — SMB session lifecycle (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard SMB port (TCP)."
  @spec smb_port() :: non_neg_integer()
  def smb_port, do: 445

  @doc "Legacy NetBIOS over TCP port (used by older SMB implementations)."
  @spec smb_netbios_port() :: non_neg_integer()
  def smb_netbios_port, do: 139

  # ===========================================================================
  # Command (tags 0-15)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command ::
          :negotiate
          | :session_setup
          | :logoff
          | :tree_connect
          | :tree_disconnect
          | :create
          | :close
          | :read
          | :write
          | :lock
          | :ioctl
          | :cancel
          | :query_directory
          | :change_notify
          | :query_info
          | :set_info

  @command_tags %{
    negotiate: 0,
    session_setup: 1,
    logoff: 2,
    tree_connect: 3,
    tree_disconnect: 4,
    create: 5,
    close: 6,
    read: 7,
    write: 8,
    lock: 9,
    ioctl: 10,
    cancel: 11,
    query_directory: 12,
    change_notify: 13,
    query_info: 14,
    set_info: 15,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..15, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Smb.command_from_tag(0)
      {:ok, :negotiate}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 15 do
    {:ok, Map.fetch!(@tag_to_command, tag)}
  end

  def command_from_tag(_tag), do: :error

  @doc """
  Encode a `Command` to the C-ABI tag value.
  """
  @spec command_to_tag(command()) :: non_neg_integer()
  def command_to_tag(val) when is_map_key(@command_tags, val) do
    Map.fetch!(@command_tags, val)
  end

  @doc """
  All `Command` variants in tag order.
  """
  @spec all_commands() :: [command()]
  def all_commands do
    [
      :negotiate, :session_setup, :logoff, :tree_connect, :tree_disconnect,
      :create, :close, :read, :write, :lock, :ioctl, :cancel, :query_directory,
      :change_notify, :query_info, :set_info
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this command is a session/connection management operation.
  """
  @spec is_session_management?(command()) :: boolean()
  def is_session_management?(val) when val in [:negotiate, :session_setup, :logoff, :tree_connect, :tree_disconnect], do: true
  def is_session_management?(_val), do: false

  @doc """
  Whether this command operates on file data.
  """
  @spec is_file_io?(command()) :: boolean()
  def is_file_io?(val) when val in [:read, :write, :lock, :ioctl], do: true
  def is_file_io?(_val), do: false

  @doc """
  Whether this command modifies server state.
  """
  @spec is_write?(command()) :: boolean()
  def is_write?(val) when val in [:create, :write, :set_info, :lock], do: true
  def is_write?(_val), do: false

  # ===========================================================================
  # Dialect (tags 0-4)
  # ===========================================================================

  @typedoc """
  Dialect types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type dialect :: :smb2_0_2 | :smb2_1 | :smb3_0 | :smb3_0_2 | :smb3_1_1

  @dialect_tags %{
    smb2_0_2: 0,
    smb2_1: 1,
    smb3_0: 2,
    smb3_0_2: 3,
    smb3_1_1: 4,
  }

  @tag_to_dialect Map.new(@dialect_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Dialect` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Smb.dialect_from_tag(0)
      {:ok, :smb2_0_2}
  """
  @spec dialect_from_tag(non_neg_integer()) :: {:ok, dialect()} | :error
  def dialect_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_dialect, tag)}
  end

  def dialect_from_tag(_tag), do: :error

  @doc """
  Encode a `Dialect` to the C-ABI tag value.
  """
  @spec dialect_to_tag(dialect()) :: non_neg_integer()
  def dialect_to_tag(val) when is_map_key(@dialect_tags, val) do
    Map.fetch!(@dialect_tags, val)
  end

  @doc """
  All `Dialect` variants in tag order.
  """
  @spec all_dialects() :: [dialect()]
  def all_dialects, do: [:smb2_0_2, :smb2_1, :smb3_0, :smb3_0_2, :smb3_1_1]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this dialect supports encryption.
  """
  @spec supports_encryption?(dialect()) :: boolean()
  def supports_encryption?(val) when val in [:smb3_0, :smb3_0_2, :smb3_1_1], do: true
  def supports_encryption?(_val), do: false

  @doc """
  Whether this is an SMB3 dialect.
  """
  @spec is_smb3?(dialect()) :: boolean()
  def is_smb3?(val) when val in [:smb3_0, :smb3_0_2, :smb3_1_1], do: true
  def is_smb3?(_val), do: false

  # ===========================================================================
  # ShareType (tags 0-2)
  # ===========================================================================

  @typedoc """
  ShareType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type share_type :: :disk | :pipe | :print

  @share_type_tags %{
    disk: 0,
    pipe: 1,
    print: 2,
  }

  @tag_to_share_type Map.new(@share_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ShareType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Smb.share_type_from_tag(0)
      {:ok, :disk}
  """
  @spec share_type_from_tag(non_neg_integer()) :: {:ok, share_type()} | :error
  def share_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_share_type, tag)}
  end

  def share_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ShareType` to the C-ABI tag value.
  """
  @spec share_type_to_tag(share_type()) :: non_neg_integer()
  def share_type_to_tag(val) when is_map_key(@share_type_tags, val) do
    Map.fetch!(@share_type_tags, val)
  end

  @doc """
  All `ShareType` variants in tag order.
  """
  @spec all_share_types() :: [share_type()]
  def all_share_types, do: [:disk, :pipe, :print]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this share provides file system access.
  """
  @spec is_filesystem?(share_type()) :: boolean()
  def is_filesystem?(val) when val in [:disk], do: true
  def is_filesystem?(_val), do: false

  # ===========================================================================
  # SessionState (tags 0-5)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state ::
          :idle
          | :negotiated
          | :authenticated
          | :tree_connected
          | :file_open
          | :disconnecting

  @session_state_tags %{
    idle: 0,
    negotiated: 1,
    authenticated: 2,
    tree_connected: 3,
    file_open: 4,
    disconnecting: 5,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Smb.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
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
  def all_session_states do
    [
      :idle, :negotiated, :authenticated, :tree_connected, :file_open,
      :disconnecting
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the session is authenticated (can perform operations).
  """
  @spec is_authenticated?(session_state()) :: boolean()
  def is_authenticated?(val) when val in [:authenticated, :tree_connected, :file_open], do: true
  def is_authenticated?(_val), do: false

  @doc """
  Whether file operations are possible.
  """
  @spec can_do_file_io?(session_state()) :: boolean()
  def can_do_file_io?(val) when val in [:file_open], do: true
  def can_do_file_io?(_val), do: false

end
