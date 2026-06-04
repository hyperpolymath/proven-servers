# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Opcua do
  @moduledoc """
  OPC UA (OPC Unified Architecture) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `OPCUAABI.Types` and its type definitions:
  - `ServiceType`   — OPC UA service types (11 constructors, tags 0-10)
  - `NodeClass`     — OPC UA node classes (8 constructors, tags 0-7)
  - `StatusCode`    — OPC UA status codes (12 constructors, tags 0-11)
  - `SecurityMode`  — Message security modes (3 constructors, tags 0-2)
  - `SessionState`  — OPC UA session lifecycle (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard OPC UA TCP port."
  @spec opcua_port() :: non_neg_integer()
  def opcua_port, do: 4840

  @doc "Standard OPC UA TCP/TLS port."
  @spec opcua_tls_port() :: non_neg_integer()
  def opcua_tls_port, do: 4843

  # ===========================================================================
  # ServiceType (tags 0-10)
  # ===========================================================================

  @typedoc """
  ServiceType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type service_type ::
          :read
          | :write
          | :browse
          | :subscribe
          | :publish
          | :call
          | :create_session
          | :activate_session
          | :close_session
          | :create_subscription
          | :delete_subscription

  @service_type_tags %{
    read: 0,
    write: 1,
    browse: 2,
    subscribe: 3,
    publish: 4,
    call: 5,
    create_session: 6,
    activate_session: 7,
    close_session: 8,
    create_subscription: 9,
    delete_subscription: 10,
  }

  @tag_to_service_type Map.new(@service_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServiceType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Opcua.service_type_from_tag(0)
      {:ok, :read}
  """
  @spec service_type_from_tag(non_neg_integer()) :: {:ok, service_type()} | :error
  def service_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_service_type, tag)}
  end

  def service_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ServiceType` to the C-ABI tag value.
  """
  @spec service_type_to_tag(service_type()) :: non_neg_integer()
  def service_type_to_tag(val) when is_map_key(@service_type_tags, val) do
    Map.fetch!(@service_type_tags, val)
  end

  @doc """
  All `ServiceType` variants in tag order.
  """
  @spec all_service_types() :: [service_type()]
  def all_service_types do
    [
      :read, :write, :browse, :subscribe, :publish, :call, :create_session,
      :activate_session, :close_session, :create_subscription, :delete_subscription,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this service modifies server state.
  """
  @spec is_write?(service_type()) :: boolean()
  def is_write?(val) when val in [:write, :call], do: true
  def is_write?(_val), do: false

  @doc """
  Whether this service is a session management operation.
  """
  @spec is_session_management?(service_type()) :: boolean()
  def is_session_management?(val) when val in [:create_session, :activate_session, :close_session], do: true
  def is_session_management?(_val), do: false

  @doc """
  Whether this service relates to subscriptions.
  """
  @spec is_subscription_related?(service_type()) :: boolean()
  def is_subscription_related?(val) when val in [:subscribe, :publish, :create_subscription, :delete_subscription], do: true
  def is_subscription_related?(_val), do: false

  # ===========================================================================
  # NodeClass (tags 0-7)
  # ===========================================================================

  @typedoc """
  NodeClass types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type node_class ::
          :object
          | :variable
          | :method
          | :object_type
          | :variable_type
          | :reference_type
          | :data_type
          | :view

  @node_class_tags %{
    object: 0,
    variable: 1,
    method: 2,
    object_type: 3,
    variable_type: 4,
    reference_type: 5,
    data_type: 6,
    view: 7,
  }

  @tag_to_node_class Map.new(@node_class_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NodeClass` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Opcua.node_class_from_tag(0)
      {:ok, :object}
  """
  @spec node_class_from_tag(non_neg_integer()) :: {:ok, node_class()} | :error
  def node_class_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_node_class, tag)}
  end

  def node_class_from_tag(_tag), do: :error

  @doc """
  Encode a `NodeClass` to the C-ABI tag value.
  """
  @spec node_class_to_tag(node_class()) :: non_neg_integer()
  def node_class_to_tag(val) when is_map_key(@node_class_tags, val) do
    Map.fetch!(@node_class_tags, val)
  end

  @doc """
  All `NodeClass` variants in tag order.
  """
  @spec all_node_classs() :: [node_class()]
  def all_node_classs do
    [
      :object, :variable, :method, :object_type, :variable_type, :reference_type,
      :data_type, :view
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this node class is an instance node (not a type definition).
  """
  @spec is_instance?(node_class()) :: boolean()
  def is_instance?(val) when val in [:object, :variable, :method, :view], do: true
  def is_instance?(_val), do: false

  @doc """
  Whether this node class is a type definition.
  """
  @spec is_type?(node_class()) :: boolean()
  def is_type?(val) when val in [:object_type, :variable_type, :reference_type, :data_type], do: true
  def is_type?(_val), do: false

  # ===========================================================================
  # StatusCode (tags 0-11)
  # ===========================================================================

  @typedoc """
  StatusCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type status_code ::
          :good
          | :uncertain
          | :bad
          | :bad_node_id_unknown
          | :bad_attribute_id_invalid
          | :bad_not_readable
          | :bad_not_writable
          | :bad_out_of_range
          | :bad_type_mismatch
          | :bad_session_id_invalid
          | :bad_subscription_id_invalid
          | :bad_timeout

  @status_code_tags %{
    good: 0,
    uncertain: 1,
    bad: 2,
    bad_node_id_unknown: 3,
    bad_attribute_id_invalid: 4,
    bad_not_readable: 5,
    bad_not_writable: 6,
    bad_out_of_range: 7,
    bad_type_mismatch: 8,
    bad_session_id_invalid: 9,
    bad_subscription_id_invalid: 10,
    bad_timeout: 11,
  }

  @tag_to_status_code Map.new(@status_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StatusCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Opcua.status_code_from_tag(0)
      {:ok, :good}
  """
  @spec status_code_from_tag(non_neg_integer()) :: {:ok, status_code()} | :error
  def status_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_status_code, tag)}
  end

  def status_code_from_tag(_tag), do: :error

  @doc """
  Encode a `StatusCode` to the C-ABI tag value.
  """
  @spec status_code_to_tag(status_code()) :: non_neg_integer()
  def status_code_to_tag(val) when is_map_key(@status_code_tags, val) do
    Map.fetch!(@status_code_tags, val)
  end

  @doc """
  All `StatusCode` variants in tag order.
  """
  @spec all_status_codes() :: [status_code()]
  def all_status_codes do
    [
      :good, :uncertain, :bad, :bad_node_id_unknown, :bad_attribute_id_invalid,
      :bad_not_readable, :bad_not_writable, :bad_out_of_range, :bad_type_mismatch,
      :bad_session_id_invalid, :bad_subscription_id_invalid, :bad_timeout,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this status code indicates success.
  """
  @spec is_good?(status_code()) :: boolean()
  def is_good?(val) when val in [:good], do: true
  def is_good?(_val), do: false

  @doc """
  Whether this status code indicates a definite failure.
  """
  @spec is_bad?(status_code()) :: boolean()
  def is_bad?(val) when val in [:good, :uncertain], do: false
  def is_bad?(_val), do: true

  @doc """
  Whether this status code relates to security/session issues.
  """
  @spec is_security_related?(status_code()) :: boolean()
  def is_security_related?(val) when val in [:bad_session_id_invalid], do: true
  def is_security_related?(_val), do: false

  # ===========================================================================
  # SecurityMode (tags 0-2)
  # ===========================================================================

  @typedoc """
  SecurityMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type security_mode :: :none | :sign | :sign_and_encrypt

  @security_mode_tags %{
    none: 0,
    sign: 1,
    sign_and_encrypt: 2,
  }

  @tag_to_security_mode Map.new(@security_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SecurityMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Opcua.security_mode_from_tag(0)
      {:ok, :none}
  """
  @spec security_mode_from_tag(non_neg_integer()) :: {:ok, security_mode()} | :error
  def security_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_security_mode, tag)}
  end

  def security_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `SecurityMode` to the C-ABI tag value.
  """
  @spec security_mode_to_tag(security_mode()) :: non_neg_integer()
  def security_mode_to_tag(val) when is_map_key(@security_mode_tags, val) do
    Map.fetch!(@security_mode_tags, val)
  end

  @doc """
  All `SecurityMode` variants in tag order.
  """
  @spec all_security_modes() :: [security_mode()]
  def all_security_modes, do: [:none, :sign, :sign_and_encrypt]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether messages are signed.
  """
  @spec is_signed?(security_mode()) :: boolean()
  def is_signed?(val) when val in [:sign, :sign_and_encrypt], do: true
  def is_signed?(_val), do: false

  @doc """
  Whether messages are encrypted.
  """
  @spec is_encrypted?(security_mode()) :: boolean()
  def is_encrypted?(val) when val in [:sign_and_encrypt], do: true
  def is_encrypted?(_val), do: false

  # ===========================================================================
  # SessionState (tags 0-5)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :connected | :created | :activated | :monitoring | :closing

  @session_state_tags %{
    idle: 0,
    connected: 1,
    created: 2,
    activated: 3,
    monitoring: 4,
    closing: 5,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Opcua.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :connected, :created, :activated, :monitoring, :closing]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the session can accept service requests.
  """
  @spec can_service?(session_state()) :: boolean()
  def can_service?(val) when val in [:activated, :monitoring], do: true
  def can_service?(_val), do: false

  @doc """
  Whether the session is in a transient state.
  """
  @spec is_transient?(session_state()) :: boolean()
  def is_transient?(val) when val in [:connected, :created, :closing], do: true
  def is_transient?(_val), do: false

end
