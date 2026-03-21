# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Authserver do
  @moduledoc """
  Authentication server types for the proven-servers ABI.
  
  Formally verified authentication/authorization types.
  Mirrors the Idris2 module `AuthserverABI.Types`.
  
  - `AuthMethod` -- Authentication methods.
  - `TokenType` -- Authentication token types.
  - `AuthResult` -- Authentication attempt result codes.
  - `MfaMethod` -- Multi-factor authentication methods.
  - `SessionState` -- Auth session lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard HTTPS port for auth."
  @spec auth_https_port() :: non_neg_integer()
  def auth_https_port, do: 443

  # ===========================================================================
  # AuthMethod (tags 0-7)
  # ===========================================================================

  @typedoc """
  AuthMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_method ::
          :password
          | :certificate
          | :o_auth2
          | :saml
          | :fido2
          | :kerberos
          | :ldap
          | :radius

  @auth_method_tags %{
    password: 0,
    certificate: 1,
    o_auth2: 2,
    saml: 3,
    fido2: 4,
    kerberos: 5,
    ldap: 6,
    radius: 7,
  }

  @tag_to_auth_method Map.new(@auth_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Authserver.auth_method_from_tag(0)
      {:ok, :password}
  """
  @spec auth_method_from_tag(non_neg_integer()) :: {:ok, auth_method()} | :error
  def auth_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
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
  def all_auth_methods do
    [
      :password, :certificate, :o_auth2, :saml, :fido2, :kerberos, :ldap,
      :radius
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this method is passwordless.
  """
  @spec is_passwordless?(auth_method()) :: boolean()
  def is_passwordless?(val) when val in [:certificate, :fido2], do: true
  def is_passwordless?(_val), do: false

  # ===========================================================================
  # TokenType (tags 0-3)
  # ===========================================================================

  @typedoc """
  TokenType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type token_type :: :access | :refresh | :id | :api

  @token_type_tags %{
    access: 0,
    refresh: 1,
    id: 2,
    api: 3,
  }

  @tag_to_token_type Map.new(@token_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TokenType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Authserver.token_type_from_tag(0)
      {:ok, :access}
  """
  @spec token_type_from_tag(non_neg_integer()) :: {:ok, token_type()} | :error
  def token_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_token_type, tag)}
  end

  def token_type_from_tag(_tag), do: :error

  @doc """
  Encode a `TokenType` to the C-ABI tag value.
  """
  @spec token_type_to_tag(token_type()) :: non_neg_integer()
  def token_type_to_tag(val) when is_map_key(@token_type_tags, val) do
    Map.fetch!(@token_type_tags, val)
  end

  @doc """
  All `TokenType` variants in tag order.
  """
  @spec all_token_types() :: [token_type()]
  def all_token_types, do: [:access, :refresh, :id, :api]

  # ===========================================================================
  # AuthResult (tags 0-5)
  # ===========================================================================

  @typedoc """
  AuthResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_result ::
          :success
          | :invalid_credentials
          | :account_locked
          | :account_expired
          | :mfa_required
          | :ip_blocked

  @auth_result_tags %{
    success: 0,
    invalid_credentials: 1,
    account_locked: 2,
    account_expired: 3,
    mfa_required: 4,
    ip_blocked: 5,
  }

  @tag_to_auth_result Map.new(@auth_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Authserver.auth_result_from_tag(0)
      {:ok, :success}
  """
  @spec auth_result_from_tag(non_neg_integer()) :: {:ok, auth_result()} | :error
  def auth_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_auth_result, tag)}
  end

  def auth_result_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthResult` to the C-ABI tag value.
  """
  @spec auth_result_to_tag(auth_result()) :: non_neg_integer()
  def auth_result_to_tag(val) when is_map_key(@auth_result_tags, val) do
    Map.fetch!(@auth_result_tags, val)
  end

  @doc """
  All `AuthResult` variants in tag order.
  """
  @spec all_auth_results() :: [auth_result()]
  def all_auth_results do
    [
      :success, :invalid_credentials, :account_locked, :account_expired,
      :mfa_required, :ip_blocked
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether authentication succeeded.
  """
  @spec is_success?(auth_result()) :: boolean()
  def is_success?(val) when val in [:success], do: true
  def is_success?(_val), do: false

  @doc """
  Whether the result requires further user action.
  """
  @spec requires_action?(auth_result()) :: boolean()
  def requires_action?(val) when val in [:mfa_required], do: true
  def requires_action?(_val), do: false

  # ===========================================================================
  # MfaMethod (tags 0-4)
  # ===========================================================================

  @typedoc """
  MfaMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mfa_method :: :totp | :sms | :push | :fido2_mfa | :email

  @mfa_method_tags %{
    totp: 0,
    sms: 1,
    push: 2,
    fido2_mfa: 3,
    email: 4,
  }

  @tag_to_mfa_method Map.new(@mfa_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MfaMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Authserver.mfa_method_from_tag(0)
      {:ok, :totp}
  """
  @spec mfa_method_from_tag(non_neg_integer()) :: {:ok, mfa_method()} | :error
  def mfa_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_mfa_method, tag)}
  end

  def mfa_method_from_tag(_tag), do: :error

  @doc """
  Encode a `MfaMethod` to the C-ABI tag value.
  """
  @spec mfa_method_to_tag(mfa_method()) :: non_neg_integer()
  def mfa_method_to_tag(val) when is_map_key(@mfa_method_tags, val) do
    Map.fetch!(@mfa_method_tags, val)
  end

  @doc """
  All `MfaMethod` variants in tag order.
  """
  @spec all_mfa_methods() :: [mfa_method()]
  def all_mfa_methods, do: [:totp, :sms, :push, :fido2_mfa, :email]

  # ===========================================================================
  # SessionState (tags 0-3)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :active | :expired | :revoked | :locked

  @session_state_tags %{
    active: 0,
    expired: 1,
    revoked: 2,
    locked: 3,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Authserver.session_state_from_tag(0)
      {:ok, :active}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
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
  def all_session_states, do: [:active, :expired, :revoked, :locked]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the session is still usable.
  """
  @spec is_valid?(session_state()) :: boolean()
  def is_valid?(val) when val in [:active], do: true
  def is_valid?(_val), do: false

end
