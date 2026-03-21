# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Socks do
  @moduledoc """
  SOCKS5 protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `SOCKSABI.Types` and its type definitions:
  - `AuthMethod`  — Authentication methods (4 constructors, tags 0-3)
  - `Command`     — SOCKS commands (3 constructors, tags 0-2)
  - `AddressType` — Address types (3 constructors, tags 0-2)
  - `Reply`       — SOCKS reply codes (9 constructors, tags 0-8)
  - `State`       — Connection state machine (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard SOCKS5 port (RFC 1928)."
  @spec socks_port() :: non_neg_integer()
  def socks_port, do: 1080

  # ===========================================================================
  # AuthMethod (tags 0-3)
  # ===========================================================================

  @typedoc """
  AuthMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_method :: :no_auth | :gssapi | :username_password | :no_acceptable

  @auth_method_tags %{
    no_auth: 0,
    gssapi: 1,
    username_password: 2,
    no_acceptable: 3,
  }

  @tag_to_auth_method Map.new(@auth_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Socks.auth_method_from_tag(0)
      {:ok, :no_auth}
  """
  @spec auth_method_from_tag(non_neg_integer()) :: {:ok, auth_method()} | :error
  def auth_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_auth_method, tag)}
  end

  def auth_method_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthMethod` to the C-ABI tag value.
  """
  @spec auth_method_to_tag(auth_method()) :: non_neg_integer()
  def auth_method_to_tag(val) when is_map_key(@auth_method_tags, val) do
    Map.fetch!(@auth_method_tags, val)
  end

  @doc """
  All `AuthMethod` variants in tag order.
  """
  @spec all_auth_methods() :: [auth_method()]
  def all_auth_methods, do: [:no_auth, :gssapi, :username_password, :no_acceptable]

  # ===========================================================================
  # Command (tags 0-2)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command :: :connect | :bind | :udp_associate

  @command_tags %{
    connect: 0,
    bind: 1,
    udp_associate: 2,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Socks.command_from_tag(0)
      {:ok, :connect}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
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
  def all_commands, do: [:connect, :bind, :udp_associate]

  # ===========================================================================
  # AddressType (tags 0-2)
  # ===========================================================================

  @typedoc """
  AddressType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type address_type :: :i_pv4 | :domain_name | :i_pv6

  @address_type_tags %{
    i_pv4: 0,
    domain_name: 1,
    i_pv6: 2,
  }

  @tag_to_address_type Map.new(@address_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AddressType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Socks.address_type_from_tag(0)
      {:ok, :i_pv4}
  """
  @spec address_type_from_tag(non_neg_integer()) :: {:ok, address_type()} | :error
  def address_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_address_type, tag)}
  end

  def address_type_from_tag(_tag), do: :error

  @doc """
  Encode a `AddressType` to the C-ABI tag value.
  """
  @spec address_type_to_tag(address_type()) :: non_neg_integer()
  def address_type_to_tag(val) when is_map_key(@address_type_tags, val) do
    Map.fetch!(@address_type_tags, val)
  end

  @doc """
  All `AddressType` variants in tag order.
  """
  @spec all_address_types() :: [address_type()]
  def all_address_types, do: [:i_pv4, :domain_name, :i_pv6]

  # ===========================================================================
  # Reply (tags 0-8)
  # ===========================================================================

  @typedoc """
  Reply types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type reply ::
          :succeeded
          | :general_failure
          | :not_allowed
          | :network_unreachable
          | :host_unreachable
          | :connection_refused
          | :ttl_expired
          | :command_not_supported
          | :address_type_not_supported

  @reply_tags %{
    succeeded: 0,
    general_failure: 1,
    not_allowed: 2,
    network_unreachable: 3,
    host_unreachable: 4,
    connection_refused: 5,
    ttl_expired: 6,
    command_not_supported: 7,
    address_type_not_supported: 8,
  }

  @tag_to_reply Map.new(@reply_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Reply` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Socks.reply_from_tag(0)
      {:ok, :succeeded}
  """
  @spec reply_from_tag(non_neg_integer()) :: {:ok, reply()} | :error
  def reply_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_reply, tag)}
  end

  def reply_from_tag(_tag), do: :error

  @doc """
  Encode a `Reply` to the C-ABI tag value.
  """
  @spec reply_to_tag(reply()) :: non_neg_integer()
  def reply_to_tag(val) when is_map_key(@reply_tags, val) do
    Map.fetch!(@reply_tags, val)
  end

  @doc """
  All `Reply` variants in tag order.
  """
  @spec all_replys() :: [reply()]
  def all_replys do
    [
      :succeeded, :general_failure, :not_allowed, :network_unreachable,
      :host_unreachable, :connection_refused, :ttl_expired, :command_not_supported,
      :address_type_not_supported
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this reply indicates success.
  """
  @spec is_success?(reply()) :: boolean()
  def is_success?(val) when val in [:succeeded], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this is a network-level error.
  """
  @spec is_network_error?(reply()) :: boolean()
  def is_network_error?(val) when val in [:network_unreachable, :host_unreachable, :connection_refused], do: true
  def is_network_error?(_val), do: false

  # ===========================================================================
  # State (tags 0-5)
  # ===========================================================================

  @typedoc """
  State types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type state ::
          :initial
          | :authenticating
          | :authenticated
          | :connecting
          | :established
          | :closed

  @state_tags %{
    initial: 0,
    authenticating: 1,
    authenticated: 2,
    connecting: 3,
    established: 4,
    closed: 5,
  }

  @tag_to_state Map.new(@state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `State` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Socks.state_from_tag(0)
      {:ok, :initial}
  """
  @spec state_from_tag(non_neg_integer()) :: {:ok, state()} | :error
  def state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
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
  def all_states do
    [
      :initial, :authenticating, :authenticated, :connecting, :established,
      :closed
    ]
  end

  @doc """
  Validate whether a `State` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_state_transition(state(), state()) :: boolean()
  def validate_state_transition(:initial, :authenticating), do: true
  def validate_state_transition(:initial, :authenticated), do: true
  def validate_state_transition(:authenticating, :authenticated), do: true
  def validate_state_transition(:authenticated, :connecting), do: true
  def validate_state_transition(:connecting, :established), do: true
  def validate_state_transition(:connecting, :closed), do: true
  def validate_state_transition(:established, :closed), do: true
  def validate_state_transition(_from, _to), do: false

end
