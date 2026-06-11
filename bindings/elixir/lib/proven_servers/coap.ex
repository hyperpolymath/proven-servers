# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Coap do
  @moduledoc """
  CoAP (Constrained Application Protocol) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `CoapABI.Types` and its type definitions:
  - `Method`        — CoAP request methods (4 constructors, tags 0-3)
  - `MessageType`   — CoAP message types (4 constructors, tags 0-3)
  - `ContentFormat` — CoAP content formats (7 constructors, tags 0-6)
  - `ResponseClass` — CoAP response class codes (5 constructors, tags 0-4)
  - `SessionState`  — CoAP server lifecycle (5 constructors, tags 0-4)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard CoAP port (RFC 7252)."
  @spec coap_port() :: non_neg_integer()
  def coap_port, do: 5683

  @doc "Standard CoAPS (CoAP over DTLS) port (RFC 7252)."
  @spec coaps_port() :: non_neg_integer()
  def coaps_port, do: 5684

  @doc "Default CoAP block size (RFC 7959)."
  @spec coap_default_block_size() :: non_neg_integer()
  def coap_default_block_size, do: 1024

  # ===========================================================================
  # Method (tags 0-3)
  # ===========================================================================

  @typedoc """
  Method types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type method :: :get | :post | :put | :delete

  @method_tags %{
    get: 0,
    post: 1,
    put: 2,
    delete: 3,
  }

  @tag_to_method Map.new(@method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Method` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Coap.method_from_tag(0)
      {:ok, :get}
  """
  @spec method_from_tag(non_neg_integer()) :: {:ok, method()} | :error
  def method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_method, tag)}
  end

  def method_from_tag(_tag), do: :error

  @doc """
  Encode a `Method` to the C-ABI tag value.
  """
  @spec method_to_tag(method()) :: non_neg_integer()
  def method_to_tag(val) when is_map_key(@method_tags, val) do
    Map.fetch!(@method_tags, val)
  end

  @doc """
  All `Method` variants in tag order.
  """
  @spec all_methods() :: [method()]
  def all_methods, do: [:get, :post, :put, :delete]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this method is safe (does not alter server state).
  """
  @spec is_safe?(method()) :: boolean()
  def is_safe?(val) when val in [:get], do: true
  def is_safe?(_val), do: false

  @doc """
  Whether this method is idempotent.
  """
  @spec is_idempotent?(method()) :: boolean()
  def is_idempotent?(val) when val in [:get, :put, :delete], do: true
  def is_idempotent?(_val), do: false

  # ===========================================================================
  # MessageType (tags 0-3)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type :: :confirmable | :non_confirmable | :acknowledgement | :reset

  @message_type_tags %{
    confirmable: 0,
    non_confirmable: 1,
    acknowledgement: 2,
    reset: 3,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Coap.message_type_from_tag(0)
      {:ok, :confirmable}
  """
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
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
  def all_message_types, do: [:confirmable, :non_confirmable, :acknowledgement, :reset]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this message type requires a response.
  """
  @spec requires_response?(message_type()) :: boolean()
  def requires_response?(val) when val in [:confirmable], do: true
  def requires_response?(_val), do: false

  @doc """
  Whether this message type is a response.
  """
  @spec is_response?(message_type()) :: boolean()
  def is_response?(val) when val in [:acknowledgement, :reset], do: true
  def is_response?(_val), do: false

  # ===========================================================================
  # ContentFormat (tags 0-6)
  # ===========================================================================

  @typedoc """
  ContentFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type content_format ::
          :text_plain
          | :link_format
          | :xml
          | :octet_stream
          | :exi
          | :json
          | :cbor

  @content_format_tags %{
    text_plain: 0,
    link_format: 1,
    xml: 2,
    octet_stream: 3,
    exi: 4,
    json: 5,
    cbor: 6,
  }

  @tag_to_content_format Map.new(@content_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContentFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Coap.content_format_from_tag(0)
      {:ok, :text_plain}
  """
  @spec content_format_from_tag(non_neg_integer()) :: {:ok, content_format()} | :error
  def content_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_content_format, tag)}
  end

  def content_format_from_tag(_tag), do: :error

  @doc """
  Encode a `ContentFormat` to the C-ABI tag value.
  """
  @spec content_format_to_tag(content_format()) :: non_neg_integer()
  def content_format_to_tag(val) when is_map_key(@content_format_tags, val) do
    Map.fetch!(@content_format_tags, val)
  end

  @doc """
  All `ContentFormat` variants in tag order.
  """
  @spec all_content_formats() :: [content_format()]
  def all_content_formats, do: [:text_plain, :link_format, :xml, :octet_stream, :exi, :json, :cbor]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The IANA media type string for this content format.
        match self {

  Whether this format is text-based (human-readable).
  """
  @spec is_text_based?(content_format()) :: boolean()
  def is_text_based?(val) when val in [:text_plain, :link_format, :xml, :json], do: true
  def is_text_based?(_val), do: false

  # ===========================================================================
  # ResponseClass (tags 0-4)
  # ===========================================================================

  @typedoc """
  ResponseClass types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type response_class :: :success | :client_error | :server_error | :signaling | :empty

  @response_class_tags %{
    success: 0,
    client_error: 1,
    server_error: 2,
    signaling: 3,
    empty: 4,
  }

  @tag_to_response_class Map.new(@response_class_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponseClass` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Coap.response_class_from_tag(0)
      {:ok, :success}
  """
  @spec response_class_from_tag(non_neg_integer()) :: {:ok, response_class()} | :error
  def response_class_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_response_class, tag)}
  end

  def response_class_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponseClass` to the C-ABI tag value.
  """
  @spec response_class_to_tag(response_class()) :: non_neg_integer()
  def response_class_to_tag(val) when is_map_key(@response_class_tags, val) do
    Map.fetch!(@response_class_tags, val)
  end

  @doc """
  All `ResponseClass` variants in tag order.
  """
  @spec all_response_classs() :: [response_class()]
  def all_response_classs, do: [:success, :client_error, :server_error, :signaling, :empty]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this response class indicates success.
  """
  @spec is_success?(response_class()) :: boolean()
  def is_success?(val) when val in [:success], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this response class indicates an error.
  """
  @spec is_error?(response_class()) :: boolean()
  def is_error?(val) when val in [:client_error, :server_error], do: true
  def is_error?(_val), do: false

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :bound | :serving | :observing | :shutdown

  @session_state_tags %{
    idle: 0,
    bound: 1,
    serving: 2,
    observing: 3,
    shutdown: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Coap.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :bound, :serving, :observing, :shutdown]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the server is ready to handle requests.
  """
  @spec is_active?(session_state()) :: boolean()
  def is_active?(val) when val in [:serving, :observing], do: true
  def is_active?(_val), do: false

end
