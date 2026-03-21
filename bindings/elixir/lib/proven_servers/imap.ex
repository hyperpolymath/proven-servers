# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Imap do
  @moduledoc """
  IMAP protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `IMAPABI.Types` and its type definitions:
  - `Command`  — IMAP commands (14 constructors, tags 0-13)
  - `State`    — IMAP session state machine (4 constructors, tags 0-3)
  - `Flag`     — message flags (6 constructors, tags 0-5)
  
  The state machine includes formally verified valid transitions from
  the Idris2 `ValidStateTransition` indexed type, translated to a
  validation function here.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard IMAP port (RFC 3501)."
  @spec imap_port() :: non_neg_integer()
  def imap_port, do: 143

  @doc "Standard IMAPS (IMAP over TLS) port."
  @spec imaps_port() :: non_neg_integer()
  def imaps_port, do: 993

  # ===========================================================================
  # Command (tags 0-13)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command ::
          :login
          | :logout
          | :select
          | :examine
          | :create
          | :delete
          | :rename
          | :list
          | :fetch
          | :store
          | :search
          | :copy
          | :noop
          | :capability

  @command_tags %{
    login: 0,
    logout: 1,
    select: 2,
    examine: 3,
    create: 4,
    delete: 5,
    rename: 6,
    list: 7,
    fetch: 8,
    store: 9,
    search: 10,
    copy: 11,
    noop: 12,
    capability: 13,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..13, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Imap.command_from_tag(0)
      {:ok, :login}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 13 do
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
      :login, :logout, :select, :examine, :create, :delete, :rename,
      :list, :fetch, :store, :search, :copy, :noop, :capability
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The IMAP command name string.
        match self {

  The minimum IMAP state required to issue this command.
        match self {

  Whether this command modifies mailbox or message state.
  """
  @spec is_write?(command()) :: boolean()
  def is_write?(val) when val in [:create, :delete, :rename, :store, :copy], do: true
  def is_write?(_val), do: false

  # ===========================================================================
  # State (tags 0-3)
  # ===========================================================================

  @typedoc """
  State types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type state :: :not_authenticated | :authenticated | :selected | :logout

  @state_tags %{
    not_authenticated: 0,
    authenticated: 1,
    selected: 2,
    logout: 3,
  }

  @tag_to_state Map.new(@state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `State` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Imap.state_from_tag(0)
      {:ok, :not_authenticated}
  """
  @spec state_from_tag(non_neg_integer()) :: {:ok, state()} | :error
  def state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_state, tag)}
  end

  def state_from_tag(_tag), do: :error

  @doc """
  Encode a `State` to the C-ABI tag value.
  """
  @spec state_to_tag(state()) :: non_neg_integer()
  def state_to_tag(val) when is_map_key(@state_tags, val) do
    Map.fetch!(@state_tags, val)
  end

  @doc """
  All `State` variants in tag order.
  """
  @spec all_states() :: [state()]
  def all_states, do: [:not_authenticated, :authenticated, :selected, :logout]

  @doc """
  Validate whether a `State` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_state_transition(state(), state()) :: boolean()
  def validate_state_transition(:not_authenticated, :authenticated), do: true
  def validate_state_transition(:authenticated, :selected), do: true
  def validate_state_transition(:selected, :authenticated), do: true
  def validate_state_transition(:not_authenticated, :logout), do: true
  def validate_state_transition(:authenticated, :logout), do: true
  def validate_state_transition(:selected, :logout), do: true
  def validate_state_transition(_from, _to), do: false

  # ===========================================================================
  # Flag (tags 0-5)
  # ===========================================================================

  @typedoc """
  Flag types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type flag :: :seen | :answered | :flagged | :deleted | :draft | :recent

  @flag_tags %{
    seen: 0,
    answered: 1,
    flagged: 2,
    deleted: 3,
    draft: 4,
    recent: 5,
  }

  @tag_to_flag Map.new(@flag_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Flag` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Imap.flag_from_tag(0)
      {:ok, :seen}
  """
  @spec flag_from_tag(non_neg_integer()) :: {:ok, flag()} | :error
  def flag_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_flag, tag)}
  end

  def flag_from_tag(_tag), do: :error

  @doc """
  Encode a `Flag` to the C-ABI tag value.
  """
  @spec flag_to_tag(flag()) :: non_neg_integer()
  def flag_to_tag(val) when is_map_key(@flag_tags, val) do
    Map.fetch!(@flag_tags, val)
  end

  @doc """
  All `Flag` variants in tag order.
  """
  @spec all_flags() :: [flag()]
  def all_flags, do: [:seen, :answered, :flagged, :deleted, :draft, :recent]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The IMAP flag string including the backslash prefix.
        match self {

  Whether this flag can be set by clients.
  The \Recent flag is server-managed and cannot be set by clients.
  """
  @spec is_client_settable?(flag()) :: boolean()
  def is_client_settable?(val) when val in [:recent], do: false
  def is_client_settable?(_val), do: true

end
