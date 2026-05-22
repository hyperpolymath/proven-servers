# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Pop3 do
  @moduledoc """
  POP3 protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `POP3ABI.Types` and its type definitions:
  - `Command`   — POP3 commands (11 constructors, tags 0-10)
  - `State`     — POP3 session state machine (3 constructors, tags 0-2)
  - `Response`  — POP3 response indicators (2 constructors, tags 0-1)
  - `Pop3Error` — FFI error codes (6 constructors, tags 0-5)
  
  The state machine mirrors the formally verified transitions from the
  Idris2 source. All discriminant values match the ABI tag definitions.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard POP3 port (RFC 1939)."
  @spec pop3_port() :: non_neg_integer()
  def pop3_port, do: 110

  @doc "Standard POP3S (POP3 over TLS) port."
  @spec pop3_s_port() :: non_neg_integer()
  def pop3_s_port, do: 995

  # ===========================================================================
  # Command (tags 0-10)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command ::
          :user
          | :pass
          | :stat
          | :list
          | :retr
          | :dele
          | :noop
          | :rset
          | :quit
          | :top
          | :uidl

  @command_tags %{
    user: 0,
    pass: 1,
    stat: 2,
    list: 3,
    retr: 4,
    dele: 5,
    noop: 6,
    rset: 7,
    quit: 8,
    top: 9,
    uidl: 10,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pop3.command_from_tag(0)
      {:ok, :user}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
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
      :user, :pass, :stat, :list, :retr, :dele, :noop, :rset, :quit,
      :top, :uidl
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The POP3 command name string.
        match self {

  The minimum POP3 state required to issue this command.
        match self {

  Whether this command modifies mailbox state.
  """
  @spec is_write?(command()) :: boolean()
  def is_write?(val) when val in [:dele, :rset], do: true
  def is_write?(_val), do: false

  # ===========================================================================
  # State (tags 0-2)
  # ===========================================================================

  @typedoc """
  State types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type state :: :authorization | :transaction | :update

  @state_tags %{
    authorization: 0,
    transaction: 1,
    update: 2,
  }

  @tag_to_state Map.new(@state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `State` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pop3.state_from_tag(0)
      {:ok, :authorization}
  """
  @spec state_from_tag(non_neg_integer()) :: {:ok, state()} | :error
  def state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
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
  def all_states, do: [:authorization, :transaction, :update]

  @doc """
  Validate whether a `State` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_state_transition(state(), state()) :: boolean()
  def validate_state_transition(:authorization, :transaction), do: true
  def validate_state_transition(:transaction, :update), do: true
  def validate_state_transition(_from, _to), do: false

  # ===========================================================================
  # Response (tags 0-1)
  # ===========================================================================

  @typedoc """
  Response types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type response :: :ok | :err

  @response_tags %{
    ok: 0,
    err: 1,
  }

  @tag_to_response Map.new(@response_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Response` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pop3.response_from_tag(0)
      {:ok, :ok}
  """
  @spec response_from_tag(non_neg_integer()) :: {:ok, response()} | :error
  def response_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_response, tag)}
  end

  def response_from_tag(_tag), do: :error

  @doc """
  Encode a `Response` to the C-ABI tag value.
  """
  @spec response_to_tag(response()) :: non_neg_integer()
  def response_to_tag(val) when is_map_key(@response_tags, val) do
    Map.fetch!(@response_tags, val)
  end

  @doc """
  All `Response` variants in tag order.
  """
  @spec all_responses() :: [response()]
  def all_responses, do: [:ok, :err]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this response indicates success.
  """
  @spec response_is_success?(response()) :: boolean()
  def response_is_success?(val) when val in [:ok], do: true
  def response_is_success?(_val), do: false

  # ===========================================================================
  # Pop3Error (tags 0-5)
  # ===========================================================================

  @typedoc """
  Pop3Error types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type pop3_error ::
          :ok
          | :invalid_slot
          | :not_active
          | :invalid_transition
          | :invalid_command
          | :auth_failed

  @pop3_error_tags %{
    ok: 0,
    invalid_slot: 1,
    not_active: 2,
    invalid_transition: 3,
    invalid_command: 4,
    auth_failed: 5,
  }

  @tag_to_pop3_error Map.new(@pop3_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Pop3Error` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Pop3.pop3_error_from_tag(0)
      {:ok, :ok}
  """
  @spec pop3_error_from_tag(non_neg_integer()) :: {:ok, pop3_error()} | :error
  def pop3_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_pop3_error, tag)}
  end

  def pop3_error_from_tag(_tag), do: :error

  @doc """
  Encode a `Pop3Error` to the C-ABI tag value.
  """
  @spec pop3_error_to_tag(pop3_error()) :: non_neg_integer()
  def pop3_error_to_tag(val) when is_map_key(@pop3_error_tags, val) do
    Map.fetch!(@pop3_error_tags, val)
  end

  @doc """
  All `Pop3Error` variants in tag order.
  """
  @spec all_pop3_errors() :: [pop3_error()]
  def all_pop3_errors do
    [
      :ok, :invalid_slot, :not_active, :invalid_transition, :invalid_command,
      :auth_failed
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error code indicates success.
  """
  @spec pop3_error_is_success?(pop3_error()) :: boolean()
  def pop3_error_is_success?(val) when val in [:ok], do: true
  def pop3_error_is_success?(_val), do: false

end
