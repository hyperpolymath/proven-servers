# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Radius do
  @moduledoc """
  RADIUS protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `RadiusABI.Types` and its type definitions:
  - `PacketType`    — RADIUS packet types (6 constructors, non-contiguous tags)
  - `AttributeType` — RADIUS attribute types (9 constructors, non-contiguous tags)
  - `ServiceType`   — Service type values (6 constructors, tags 1-6)
  - `AuthMethod`    — Authentication methods (5 constructors, tags 0-4)
  - `SessionState`  — Session state machine (7 constructors, tags 0-6)
  - `RadiusResult`  — FFI result codes (5 constructors, tags 0-4)
  
  Note: PacketType and AttributeType use non-contiguous tags matching
  the actual RADIUS wire values from RFC 2865.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard RADIUS authentication port (RFC 2865)."
  @spec radius_auth_port() :: non_neg_integer()
  def radius_auth_port, do: 1812

  @doc "Standard RADIUS accounting port (RFC 2866)."
  @spec radius_acct_port() :: non_neg_integer()
  def radius_acct_port, do: 1813

  # ===========================================================================
  # PacketType (tags 0-11)
  # ===========================================================================

  @typedoc """
  PacketType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type packet_type ::
          :access_request
          | :access_accept
          | :access_reject
          | :accounting_request
          | :accounting_response
          | :access_challenge

  @packet_type_tags %{
    access_request: 1,
    access_accept: 2,
    access_reject: 3,
    accounting_request: 4,
    accounting_response: 5,
    access_challenge: 11,
  }

  @tag_to_packet_type Map.new(@packet_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PacketType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Radius.packet_type_from_tag(0)
      {:ok, :access_request}
  """
  @spec packet_type_from_tag(non_neg_integer()) :: {:ok, packet_type()} | :error
  def packet_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
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
  def all_packet_types do
    [
      :access_request, :access_accept, :access_reject, :accounting_request,
      :accounting_response, :access_challenge
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this packet is an authentication request/response.
  """
  @spec is_auth?(packet_type()) :: boolean()
  def is_auth?(val) when val in [:access_request, :access_accept, :access_reject, :access_challenge], do: true
  def is_auth?(_val), do: false

  @doc """
  Whether this packet is an accounting request/response.
  """
  @spec is_accounting?(packet_type()) :: boolean()
  def is_accounting?(val) when val in [:accounting_request, :accounting_response], do: true
  def is_accounting?(_val), do: false

  @doc """
  Whether this packet is a request (client -> server).
  """
  @spec is_request?(packet_type()) :: boolean()
  def is_request?(val) when val in [:access_request, :accounting_request], do: true
  def is_request?(_val), do: false

  # ===========================================================================
  # AttributeType (tags 0-27)
  # ===========================================================================

  @typedoc """
  AttributeType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type attribute_type ::
          :user_name
          | :user_password
          | :nas_ip_address
          | :nas_port
          | :service_type
          | :framed_protocol
          | :framed_ip_address
          | :reply_message
          | :session_timeout

  @attribute_type_tags %{
    user_name: 1,
    user_password: 2,
    nas_ip_address: 4,
    nas_port: 5,
    service_type: 6,
    framed_protocol: 7,
    framed_ip_address: 8,
    reply_message: 18,
    session_timeout: 27,
  }

  @tag_to_attribute_type Map.new(@attribute_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AttributeType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..27, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Radius.attribute_type_from_tag(0)
      {:ok, :user_name}
  """
  @spec attribute_type_from_tag(non_neg_integer()) :: {:ok, attribute_type()} | :error
  def attribute_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 27 do
    {:ok, Map.fetch!(@tag_to_attribute_type, tag)}
  end

  def attribute_type_from_tag(_tag), do: :error

  @doc """
  Encode a `AttributeType` to the C-ABI tag value.
  """
  @spec attribute_type_to_tag(attribute_type()) :: non_neg_integer()
  def attribute_type_to_tag(val) when is_map_key(@attribute_type_tags, val) do
    Map.fetch!(@attribute_type_tags, val)
  end

  @doc """
  All `AttributeType` variants in tag order.
  """
  @spec all_attribute_types() :: [attribute_type()]
  def all_attribute_types do
    [
      :user_name, :user_password, :nas_ip_address, :nas_port, :service_type,
      :framed_protocol, :framed_ip_address, :reply_message, :session_timeout,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this attribute contains sensitive data.
  """
  @spec is_sensitive?(attribute_type()) :: boolean()
  def is_sensitive?(val) when val in [:user_password], do: true
  def is_sensitive?(_val), do: false

  # ===========================================================================
  # ServiceType (tags 0-6)
  # ===========================================================================

  @typedoc """
  ServiceType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type service_type ::
          :login
          | :framed
          | :callback_login
          | :callback_framed
          | :outbound
          | :administrative

  @service_type_tags %{
    login: 1,
    framed: 2,
    callback_login: 3,
    callback_framed: 4,
    outbound: 5,
    administrative: 6,
  }

  @tag_to_service_type Map.new(@service_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServiceType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Radius.service_type_from_tag(0)
      {:ok, :login}
  """
  @spec service_type_from_tag(non_neg_integer()) :: {:ok, service_type()} | :error
  def service_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
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
      :login, :framed, :callback_login, :callback_framed, :outbound,
      :administrative
    ]
  end

  # ===========================================================================
  # AuthMethod (tags 0-4)
  # ===========================================================================

  @typedoc """
  AuthMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_method :: :pap | :chap | :mschap | :mschapv2 | :eap

  @auth_method_tags %{
    pap: 0,
    chap: 1,
    mschap: 2,
    mschapv2: 3,
    eap: 4,
  }

  @tag_to_auth_method Map.new(@auth_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Radius.auth_method_from_tag(0)
      {:ok, :pap}
  """
  @spec auth_method_from_tag(non_neg_integer()) :: {:ok, auth_method()} | :error
  def auth_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
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
  def all_auth_methods, do: [:pap, :chap, :mschap, :mschapv2, :eap]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this method is considered legacy/weak.
  """
  @spec is_legacy?(auth_method()) :: boolean()
  def is_legacy?(val) when val in [:pap, :mschap], do: true
  def is_legacy?(_val), do: false

  # ===========================================================================
  # SessionState (tags 0-6)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state ::
          :idle
          | :authenticating
          | :authorized
          | :rejected
          | :challenged
          | :accounting
          | :complete

  @session_state_tags %{
    idle: 0,
    authenticating: 1,
    authorized: 2,
    rejected: 3,
    challenged: 4,
    accounting: 5,
    complete: 6,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Radius.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
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
      :idle, :authenticating, :authorized, :rejected, :challenged, :accounting,
      :complete
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a terminal state.
  """
  @spec is_terminal?(session_state()) :: boolean()
  def is_terminal?(val) when val in [:rejected, :complete], do: true
  def is_terminal?(_val), do: false

  # ===========================================================================
  # RadiusResult (tags 0-4)
  # ===========================================================================

  @typedoc """
  RadiusResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type radius_result :: :ok | :err | :invalid_param | :pool_exhausted | :bad_secret

  @radius_result_tags %{
    ok: 0,
    err: 1,
    invalid_param: 2,
    pool_exhausted: 3,
    bad_secret: 4,
  }

  @tag_to_radius_result Map.new(@radius_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RadiusResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Radius.radius_result_from_tag(0)
      {:ok, :ok}
  """
  @spec radius_result_from_tag(non_neg_integer()) :: {:ok, radius_result()} | :error
  def radius_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_radius_result, tag)}
  end

  def radius_result_from_tag(_tag), do: :error

  @doc """
  Encode a `RadiusResult` to the C-ABI tag value.
  """
  @spec radius_result_to_tag(radius_result()) :: non_neg_integer()
  def radius_result_to_tag(val) when is_map_key(@radius_result_tags, val) do
    Map.fetch!(@radius_result_tags, val)
  end

  @doc """
  All `RadiusResult` variants in tag order.
  """
  @spec all_radius_results() :: [radius_result()]
  def all_radius_results, do: [:ok, :err, :invalid_param, :pool_exhausted, :bad_secret]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this result indicates success.
  """
  @spec is_success?(radius_result()) :: boolean()
  def is_success?(val) when val in [:ok], do: true
  def is_success?(_val), do: false

end
