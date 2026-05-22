# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Tacacs do
  @moduledoc """
  TACACS+ (Terminal Access Controller Access-Control System Plus) types
  for the proven-servers ABI.
  
  Mirrors the Idris2 module `TACACSABI.Types` and its type definitions:
  - `PacketType`    — TACACS+ packet types (3 constructors, tags 0-2)
  - `AuthenType`    — Authentication types (5 constructors, tags 0-4)
  - `AuthenAction`  — Authentication actions (3 constructors, tags 0-2)
  - `AuthenStatus`  — Authentication reply statuses (8 constructors, tags 0-7)
  - `AuthorStatus`  — Authorization reply statuses (5 constructors, tags 0-4)
  - `AcctStatus`    — Accounting reply statuses (3 constructors, tags 0-2)
  - `AcctFlag`      — Accounting record flags (3 constructors, tags 0-2)
  - `SessionState`  — TACACS+ session lifecycle (5 constructors, tags 0-4)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard TACACS+ port (RFC 8907)."
  @spec tacacs_port() :: non_neg_integer()
  def tacacs_port, do: 49

  # ===========================================================================
  # PacketType (tags 0-2)
  # ===========================================================================

  @typedoc """
  PacketType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type packet_type :: :authentication | :authorization | :accounting

  @packet_type_tags %{
    authentication: 0,
    authorization: 1,
    accounting: 2,
  }

  @tag_to_packet_type Map.new(@packet_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PacketType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.packet_type_from_tag(0)
      {:ok, :authentication}
  """
  @spec packet_type_from_tag(non_neg_integer()) :: {:ok, packet_type()} | :error
  def packet_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_packet_type, tag)}
  end

  def packet_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PacketType` to the C-ABI tag value.
  """
  @spec packet_type_to_tag(packet_type()) :: non_neg_integer()
  def packet_type_to_tag(val) when is_map_key(@packet_type_tags, val) do
    Map.fetch!(@packet_type_tags, val)
  end

  @doc """
  All `PacketType` variants in tag order.
  """
  @spec all_packet_types() :: [packet_type()]
  def all_packet_types, do: [:authentication, :authorization, :accounting]

  # ===========================================================================
  # AuthenType (tags 0-4)
  # ===========================================================================

  @typedoc """
  AuthenType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type authen_type :: :ascii | :pap | :chap | :ms_chap_v1 | :ms_chap_v2

  @authen_type_tags %{
    ascii: 0,
    pap: 1,
    chap: 2,
    ms_chap_v1: 3,
    ms_chap_v2: 4,
  }

  @tag_to_authen_type Map.new(@authen_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthenType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.authen_type_from_tag(0)
      {:ok, :ascii}
  """
  @spec authen_type_from_tag(non_neg_integer()) :: {:ok, authen_type()} | :error
  def authen_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_authen_type, tag)}
  end

  def authen_type_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthenType` to the C-ABI tag value.
  """
  @spec authen_type_to_tag(authen_type()) :: non_neg_integer()
  def authen_type_to_tag(val) when is_map_key(@authen_type_tags, val) do
    Map.fetch!(@authen_type_tags, val)
  end

  @doc """
  All `AuthenType` variants in tag order.
  """
  @spec all_authen_types() :: [authen_type()]
  def all_authen_types, do: [:ascii, :pap, :chap, :ms_chap_v1, :ms_chap_v2]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this authentication type uses challenge-response.
  """
  @spec is_challenge_response?(authen_type()) :: boolean()
  def is_challenge_response?(val) when val in [:chap, :ms_chap_v1, :ms_chap_v2], do: true
  def is_challenge_response?(_val), do: false

  @doc """
  Whether this authentication type is interactive (multi-round).
  """
  @spec is_interactive?(authen_type()) :: boolean()
  def is_interactive?(val) when val in [:ascii], do: true
  def is_interactive?(_val), do: false

  # ===========================================================================
  # AuthenAction (tags 0-2)
  # ===========================================================================

  @typedoc """
  AuthenAction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type authen_action :: :login | :change_pass | :send_auth

  @authen_action_tags %{
    login: 0,
    change_pass: 1,
    send_auth: 2,
  }

  @tag_to_authen_action Map.new(@authen_action_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthenAction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.authen_action_from_tag(0)
      {:ok, :login}
  """
  @spec authen_action_from_tag(non_neg_integer()) :: {:ok, authen_action()} | :error
  def authen_action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_authen_action, tag)}
  end

  def authen_action_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthenAction` to the C-ABI tag value.
  """
  @spec authen_action_to_tag(authen_action()) :: non_neg_integer()
  def authen_action_to_tag(val) when is_map_key(@authen_action_tags, val) do
    Map.fetch!(@authen_action_tags, val)
  end

  @doc """
  All `AuthenAction` variants in tag order.
  """
  @spec all_authen_actions() :: [authen_action()]
  def all_authen_actions, do: [:login, :change_pass, :send_auth]

  # ===========================================================================
  # AuthenStatus (tags 0-7)
  # ===========================================================================

  @typedoc """
  AuthenStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type authen_status ::
          :pass
          | :fail
          | :get_data
          | :get_user
          | :get_pass
          | :restart
          | :error
          | :follow

  @authen_status_tags %{
    pass: 0,
    fail: 1,
    get_data: 2,
    get_user: 3,
    get_pass: 4,
    restart: 5,
    error: 6,
    follow: 7,
  }

  @tag_to_authen_status Map.new(@authen_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthenStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.authen_status_from_tag(0)
      {:ok, :pass}
  """
  @spec authen_status_from_tag(non_neg_integer()) :: {:ok, authen_status()} | :error
  def authen_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_authen_status, tag)}
  end

  def authen_status_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthenStatus` to the C-ABI tag value.
  """
  @spec authen_status_to_tag(authen_status()) :: non_neg_integer()
  def authen_status_to_tag(val) when is_map_key(@authen_status_tags, val) do
    Map.fetch!(@authen_status_tags, val)
  end

  @doc """
  All `AuthenStatus` variants in tag order.
  """
  @spec all_authen_statuss() :: [authen_status()]
  def all_authen_statuss do
    [
      :pass, :fail, :get_data, :get_user, :get_pass, :restart, :error,
      :follow
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether authentication succeeded.
  """
  @spec authen_status_is_success?(authen_status()) :: boolean()
  def authen_status_is_success?(val) when val in [:pass], do: true
  def authen_status_is_success?(_val), do: false

  @doc """
  Whether the server needs more information from the client.
  """
  @spec needs_more_data?(authen_status()) :: boolean()
  def needs_more_data?(val) when val in [:get_data, :get_user, :get_pass], do: true
  def needs_more_data?(_val), do: false

  @doc """
  Whether this status indicates a terminal (final) state.
  """
  @spec is_terminal?(authen_status()) :: boolean()
  def is_terminal?(val) when val in [:pass, :fail, :error], do: true
  def is_terminal?(_val), do: false

  # ===========================================================================
  # AuthorStatus (tags 0-4)
  # ===========================================================================

  @typedoc """
  AuthorStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type author_status :: :pass_add | :pass_repl | :fail | :error | :follow

  @author_status_tags %{
    pass_add: 0,
    pass_repl: 1,
    fail: 2,
    error: 3,
    follow: 4,
  }

  @tag_to_author_status Map.new(@author_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthorStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.author_status_from_tag(0)
      {:ok, :pass_add}
  """
  @spec author_status_from_tag(non_neg_integer()) :: {:ok, author_status()} | :error
  def author_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_author_status, tag)}
  end

  def author_status_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthorStatus` to the C-ABI tag value.
  """
  @spec author_status_to_tag(author_status()) :: non_neg_integer()
  def author_status_to_tag(val) when is_map_key(@author_status_tags, val) do
    Map.fetch!(@author_status_tags, val)
  end

  @doc """
  All `AuthorStatus` variants in tag order.
  """
  @spec all_author_statuss() :: [author_status()]
  def all_author_statuss, do: [:pass_add, :pass_repl, :fail, :error, :follow]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether authorization was granted.
  """
  @spec is_authorized?(author_status()) :: boolean()
  def is_authorized?(val) when val in [:pass_add, :pass_repl], do: true
  def is_authorized?(_val), do: false

  # ===========================================================================
  # AcctStatus (tags 0-2)
  # ===========================================================================

  @typedoc """
  AcctStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type acct_status :: :success | :error | :follow

  @acct_status_tags %{
    success: 0,
    error: 1,
    follow: 2,
  }

  @tag_to_acct_status Map.new(@acct_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AcctStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.acct_status_from_tag(0)
      {:ok, :success}
  """
  @spec acct_status_from_tag(non_neg_integer()) :: {:ok, acct_status()} | :error
  def acct_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_acct_status, tag)}
  end

  def acct_status_from_tag(_tag), do: :error

  @doc """
  Encode a `AcctStatus` to the C-ABI tag value.
  """
  @spec acct_status_to_tag(acct_status()) :: non_neg_integer()
  def acct_status_to_tag(val) when is_map_key(@acct_status_tags, val) do
    Map.fetch!(@acct_status_tags, val)
  end

  @doc """
  All `AcctStatus` variants in tag order.
  """
  @spec all_acct_statuss() :: [acct_status()]
  def all_acct_statuss, do: [:success, :error, :follow]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the accounting record was accepted.
  """
  @spec acct_status_is_success?(acct_status()) :: boolean()
  def acct_status_is_success?(val) when val in [:success], do: true
  def acct_status_is_success?(_val), do: false

  # ===========================================================================
  # AcctFlag (tags 0-2)
  # ===========================================================================

  @typedoc """
  AcctFlag types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type acct_flag :: :start | :stop | :watchdog

  @acct_flag_tags %{
    start: 0,
    stop: 1,
    watchdog: 2,
  }

  @tag_to_acct_flag Map.new(@acct_flag_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AcctFlag` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.acct_flag_from_tag(0)
      {:ok, :start}
  """
  @spec acct_flag_from_tag(non_neg_integer()) :: {:ok, acct_flag()} | :error
  def acct_flag_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_acct_flag, tag)}
  end

  def acct_flag_from_tag(_tag), do: :error

  @doc """
  Encode a `AcctFlag` to the C-ABI tag value.
  """
  @spec acct_flag_to_tag(acct_flag()) :: non_neg_integer()
  def acct_flag_to_tag(val) when is_map_key(@acct_flag_tags, val) do
    Map.fetch!(@acct_flag_tags, val)
  end

  @doc """
  All `AcctFlag` variants in tag order.
  """
  @spec all_acct_flags() :: [acct_flag()]
  def all_acct_flags, do: [:start, :stop, :watchdog]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this flag marks a session boundary (start or stop).
  """
  @spec is_boundary?(acct_flag()) :: boolean()
  def is_boundary?(val) when val in [:start, :stop], do: true
  def is_boundary?(_val), do: false

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :authenticating | :authorizing | :active | :closing

  @session_state_tags %{
    idle: 0,
    authenticating: 1,
    authorizing: 2,
    active: 3,
    closing: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tacacs.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :authenticating, :authorizing, :active, :closing]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the session is in an AAA processing phase.
  """
  @spec is_processing?(session_state()) :: boolean()
  def is_processing?(val) when val in [:authenticating, :authorizing], do: true
  def is_processing?(_val), do: false

  @doc """
  Whether the session has been fully authorised and is active.
  """
  @spec is_active?(session_state()) :: boolean()
  def is_active?(val) when val in [:active], do: true
  def is_active?(_val), do: false

end
