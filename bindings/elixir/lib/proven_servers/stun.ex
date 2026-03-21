# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Stun do
  @moduledoc """
  STUN/TURN types for the proven-servers ABI.
  
  Formally verified STUN/TURN types (RFC 8489, RFC 8656).
  Mirrors the Idris2 module `StunABI.Types`.
  
  - `MessageType` -- STUN/TURN message types.
  - `TransportProtocol` -- STUN transport protocols.
  - `ErrorCode` -- STUN error codes.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard STUN port."
  @spec stun_port() :: non_neg_integer()
  def stun_port, do: 3478

  @doc "Standard STUN TLS port."
  @spec stun_tls_port() :: non_neg_integer()
  def stun_tls_port, do: 5349

  # ===========================================================================
  # MessageType (tags 0-11)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type ::
          :binding_request
          | :binding_response
          | :binding_error
          | :allocate_request
          | :allocate_response
          | :allocate_error
          | :refresh_request
          | :refresh_response
          | :send_indication
          | :data_indication
          | :create_permission
          | :channel_bind

  @message_type_tags %{
    binding_request: 0,
    binding_response: 1,
    binding_error: 2,
    allocate_request: 3,
    allocate_response: 4,
    allocate_error: 5,
    refresh_request: 6,
    refresh_response: 7,
    send_indication: 8,
    data_indication: 9,
    create_permission: 10,
    channel_bind: 11,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Stun.message_type_from_tag(0)
      {:ok, :binding_request}
  """
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_message_type, tag)}
  end

  def message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MessageType` to the C-ABI tag value.
  """
  @spec message_type_to_tag(message_type()) :: non_neg_integer()
  def message_type_to_tag(val) when is_map_key(@message_type_tags, val) do
    Map.fetch!(@message_type_tags, val)
  end

  @doc """
  All `MessageType` variants in tag order.
  """
  @spec all_message_types() :: [message_type()]
  def all_message_types do
    [
      :binding_request, :binding_response, :binding_error, :allocate_request,
      :allocate_response, :allocate_error, :refresh_request, :refresh_response,
      :send_indication, :data_indication, :create_permission, :channel_bind,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a request message.
  """
  @spec is_request?(message_type()) :: boolean()
  def is_request?(val) when val in [:binding_request, :allocate_request, :refresh_request, :create_permission, :channel_bind], do: true
  def is_request?(_val), do: false

  @doc """
  Whether this is a TURN-specific message.
  """
  @spec is_turn?(message_type()) :: boolean()
  def is_turn?(val) when val in [:allocate_request, :allocate_response, :allocate_error, :refresh_request, :refresh_response, :send_indication, :data_indication, :create_permission, :channel_bind], do: true
  def is_turn?(_val), do: false

  # ===========================================================================
  # TransportProtocol (tags 0-3)
  # ===========================================================================

  @typedoc """
  TransportProtocol types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transport_protocol :: :udp | :tcp | :tls | :dtls

  @transport_protocol_tags %{
    udp: 0,
    tcp: 1,
    tls: 2,
    dtls: 3,
  }

  @tag_to_transport_protocol Map.new(@transport_protocol_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransportProtocol` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Stun.transport_protocol_from_tag(0)
      {:ok, :udp}
  """
  @spec transport_protocol_from_tag(non_neg_integer()) :: {:ok, transport_protocol()} | :error
  def transport_protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_transport_protocol, tag)}
  end

  def transport_protocol_from_tag(_tag), do: :error

  @doc """
  Encode a `TransportProtocol` to the C-ABI tag value.
  """
  @spec transport_protocol_to_tag(transport_protocol()) :: non_neg_integer()
  def transport_protocol_to_tag(val) when is_map_key(@transport_protocol_tags, val) do
    Map.fetch!(@transport_protocol_tags, val)
  end

  @doc """
  All `TransportProtocol` variants in tag order.
  """
  @spec all_transport_protocols() :: [transport_protocol()]
  def all_transport_protocols, do: [:udp, :tcp, :tls, :dtls]

  # ===========================================================================
  # ErrorCode (tags 0-7)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :try_alternate
          | :bad_request
          | :unauthorized
          | :forbidden
          | :mobility_forbidden
          | :stale_nonce
          | :server_error
          | :insufficient_capacity

  @error_code_tags %{
    try_alternate: 0,
    bad_request: 1,
    unauthorized: 2,
    forbidden: 3,
    mobility_forbidden: 4,
    stale_nonce: 5,
    server_error: 6,
    insufficient_capacity: 7,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Stun.error_code_from_tag(0)
      {:ok, :try_alternate}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_error_code, tag)}
  end

  def error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorCode` to the C-ABI tag value.
  """
  @spec error_code_to_tag(error_code()) :: non_neg_integer()
  def error_code_to_tag(val) when is_map_key(@error_code_tags, val) do
    Map.fetch!(@error_code_tags, val)
  end

  @doc """
  All `ErrorCode` variants in tag order.
  """
  @spec all_error_codes() :: [error_code()]
  def all_error_codes do
    [
      :try_alternate, :bad_request, :unauthorized, :forbidden, :mobility_forbidden,
      :stale_nonce, :server_error, :insufficient_capacity
    ]
  end

end
