# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Ldap do
  @moduledoc """
  LDAP protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `LdapABI.Types` and its type definitions:
  - `SessionState` — LDAP session state machine (4 constructors, tags 0-3)
  - `Operation`    — LDAP operations (10 constructors, tags 0-9)
  - `SearchScope`  — search scope levels (3 constructors, tags 0-2)
  - `ResultCode`   — LDAP result codes (11 constructors, tags 0-10)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard LDAP port (RFC 4511)."
  @spec ldap_port() :: non_neg_integer()
  def ldap_port, do: 389

  @doc "Standard LDAPS (LDAP over TLS) port."
  @spec ldaps_port() :: non_neg_integer()
  def ldaps_port, do: 636

  # ===========================================================================
  # SessionState (tags 0-3)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :anonymous | :bound | :closed | :binding

  @session_state_tags %{
    anonymous: 0,
    bound: 1,
    closed: 2,
    binding: 3,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldap.session_state_from_tag(0)
      {:ok, :anonymous}
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
  def all_session_states, do: [:anonymous, :bound, :closed, :binding]

  @doc """
  Validate whether a `SessionState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_session_state_transition(session_state(), session_state()) :: boolean()
  def validate_session_state_transition(:anonymous, :binding), do: true
  def validate_session_state_transition(:binding, :bound), do: true
  def validate_session_state_transition(:binding, :anonymous), do: true
  def validate_session_state_transition(:bound, :anonymous), do: true
  def validate_session_state_transition(_from, :closed), do: true
  def validate_session_state_transition(_from, _to), do: false

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Validate whether a state transition is allowed.
            (self, next),
        )

  Whether operations requiring authentication can be performed.
  """
  @spec is_authenticated?(session_state()) :: boolean()
  def is_authenticated?(val) when val in [:bound], do: true
  def is_authenticated?(_val), do: false

  # ===========================================================================
  # Operation (tags 0-9)
  # ===========================================================================

  @typedoc """
  Operation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type operation ::
          :bind
          | :unbind
          | :search
          | :modify
          | :add
          | :delete
          | :mod_dn
          | :compare
          | :abandon
          | :extended

  @operation_tags %{
    bind: 0,
    unbind: 1,
    search: 2,
    modify: 3,
    add: 4,
    delete: 5,
    mod_dn: 6,
    compare: 7,
    abandon: 8,
    extended: 9,
  }

  @tag_to_operation Map.new(@operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Operation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldap.operation_from_tag(0)
      {:ok, :bind}
  """
  @spec operation_from_tag(non_neg_integer()) :: {:ok, operation()} | :error
  def operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
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
      :bind, :unbind, :search, :modify, :add, :delete, :mod_dn, :compare,
      :abandon, :extended
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this operation modifies directory data.
  """
  @spec is_write?(operation()) :: boolean()
  def is_write?(val) when val in [:modify, :add, :delete, :mod_dn], do: true
  def is_write?(_val), do: false

  # ===========================================================================
  # SearchScope (tags 0-2)
  # ===========================================================================

  @typedoc """
  SearchScope types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type search_scope :: :base_object | :single_level | :whole_subtree

  @search_scope_tags %{
    base_object: 0,
    single_level: 1,
    whole_subtree: 2,
  }

  @tag_to_search_scope Map.new(@search_scope_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SearchScope` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldap.search_scope_from_tag(0)
      {:ok, :base_object}
  """
  @spec search_scope_from_tag(non_neg_integer()) :: {:ok, search_scope()} | :error
  def search_scope_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_search_scope, tag)}
  end

  def search_scope_from_tag(_tag), do: :error

  @doc """
  Encode a `SearchScope` to the C-ABI tag value.
  """
  @spec search_scope_to_tag(search_scope()) :: non_neg_integer()
  def search_scope_to_tag(val) when is_map_key(@search_scope_tags, val) do
    Map.fetch!(@search_scope_tags, val)
  end

  @doc """
  All `SearchScope` variants in tag order.
  """
  @spec all_search_scopes() :: [search_scope()]
  def all_search_scopes, do: [:base_object, :single_level, :whole_subtree]

  # ===========================================================================
  # ResultCode (tags 0-10)
  # ===========================================================================

  @typedoc """
  ResultCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type result_code ::
          :success
          | :operations_error
          | :protocol_error
          | :time_limit_exceeded
          | :size_limit_exceeded
          | :auth_method_not_supported
          | :no_such_object
          | :invalid_credentials
          | :insufficient_access_rights
          | :busy
          | :unavailable

  @result_code_tags %{
    success: 0,
    operations_error: 1,
    protocol_error: 2,
    time_limit_exceeded: 3,
    size_limit_exceeded: 4,
    auth_method_not_supported: 5,
    no_such_object: 6,
    invalid_credentials: 7,
    insufficient_access_rights: 8,
    busy: 9,
    unavailable: 10,
  }

  @tag_to_result_code Map.new(@result_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResultCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ldap.result_code_from_tag(0)
      {:ok, :success}
  """
  @spec result_code_from_tag(non_neg_integer()) :: {:ok, result_code()} | :error
  def result_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_result_code, tag)}
  end

  def result_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ResultCode` to the C-ABI tag value.
  """
  @spec result_code_to_tag(result_code()) :: non_neg_integer()
  def result_code_to_tag(val) when is_map_key(@result_code_tags, val) do
    Map.fetch!(@result_code_tags, val)
  end

  @doc """
  All `ResultCode` variants in tag order.
  """
  @spec all_result_codes() :: [result_code()]
  def all_result_codes do
    [
      :success, :operations_error, :protocol_error, :time_limit_exceeded,
      :size_limit_exceeded, :auth_method_not_supported, :no_such_object,
      :invalid_credentials, :insufficient_access_rights, :busy, :unavailable,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this result code indicates success.
  """
  @spec is_success?(result_code()) :: boolean()
  def is_success?(val) when val in [:success], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this result code indicates an authentication/authorisation failure.
  """
  @spec is_auth_failure?(result_code()) :: boolean()
  def is_auth_failure?(val) when val in [:auth_method_not_supported, :invalid_credentials, :insufficient_access_rights], do: true
  def is_auth_failure?(_val), do: false

  @doc """
  Whether this is a transient error that may succeed on retry.
  """
  @spec is_transient?(result_code()) :: boolean()
  def is_transient?(val) when val in [:busy, :unavailable], do: true
  def is_transient?(_val), do: false

end
