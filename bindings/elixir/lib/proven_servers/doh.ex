# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Doh do
  @moduledoc """
  DNS-over-HTTPS types for the proven-servers ABI.
  
  Formally verified DoH types (RFC 8484).
  Mirrors the Idris2 module `DohABI.Types`.
  
  - `ContentType` -- DoH content types.
  - `RequestMethod` -- DoH HTTP request methods.
  - `WireFormat` -- DNS wire format.
  - `ErrorReason` -- DoH-specific error reasons.
  - `SessionState` -- DoH session lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard HTTPS port for DoH."
  @spec doh_port() :: non_neg_integer()
  def doh_port, do: 443

  # ===========================================================================
  # ContentType (tags 0-1)
  # ===========================================================================

  @typedoc """
  ContentType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type content_type :: :dns_message | :dns_json

  @content_type_tags %{
    dns_message: 0,
    dns_json: 1,
  }

  @tag_to_content_type Map.new(@content_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContentType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doh.content_type_from_tag(0)
      {:ok, :dns_message}
  """
  @spec content_type_from_tag(non_neg_integer()) :: {:ok, content_type()} | :error
  def content_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_content_type, tag)}
  end

  def content_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ContentType` to the C-ABI tag value.
  """
  @spec content_type_to_tag(content_type()) :: non_neg_integer()
  def content_type_to_tag(val) when is_map_key(@content_type_tags, val) do
    Map.fetch!(@content_type_tags, val)
  end

  @doc """
  All `ContentType` variants in tag order.
  """
  @spec all_content_types() :: [content_type()]
  def all_content_types, do: [:dns_message, :dns_json]

  # ===========================================================================
  # RequestMethod (tags 0-1)
  # ===========================================================================

  @typedoc """
  RequestMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type request_method :: :get | :post

  @request_method_tags %{
    get: 0,
    post: 1,
  }

  @tag_to_request_method Map.new(@request_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RequestMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doh.request_method_from_tag(0)
      {:ok, :get}
  """
  @spec request_method_from_tag(non_neg_integer()) :: {:ok, request_method()} | :error
  def request_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_request_method, tag)}
  end

  def request_method_from_tag(_tag), do: :error

  @doc """
  Encode a `RequestMethod` to the C-ABI tag value.
  """
  @spec request_method_to_tag(request_method()) :: non_neg_integer()
  def request_method_to_tag(val) when is_map_key(@request_method_tags, val) do
    Map.fetch!(@request_method_tags, val)
  end

  @doc """
  All `RequestMethod` variants in tag order.
  """
  @spec all_request_methods() :: [request_method()]
  def all_request_methods, do: [:get, :post]

  # ===========================================================================
  # WireFormat (tags 0-1)
  # ===========================================================================

  @typedoc """
  WireFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type wire_format :: :binary | :json

  @wire_format_tags %{
    binary: 0,
    json: 1,
  }

  @tag_to_wire_format Map.new(@wire_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `WireFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doh.wire_format_from_tag(0)
      {:ok, :binary}
  """
  @spec wire_format_from_tag(non_neg_integer()) :: {:ok, wire_format()} | :error
  def wire_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_wire_format, tag)}
  end

  def wire_format_from_tag(_tag), do: :error

  @doc """
  Encode a `WireFormat` to the C-ABI tag value.
  """
  @spec wire_format_to_tag(wire_format()) :: non_neg_integer()
  def wire_format_to_tag(val) when is_map_key(@wire_format_tags, val) do
    Map.fetch!(@wire_format_tags, val)
  end

  @doc """
  All `WireFormat` variants in tag order.
  """
  @spec all_wire_formats() :: [wire_format()]
  def all_wire_formats, do: [:binary, :json]

  # ===========================================================================
  # ErrorReason (tags 0-4)
  # ===========================================================================

  @typedoc """
  ErrorReason types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_reason ::
          :bad_content_type
          | :bad_method
          | :payload_too_large
          | :upstream_timeout
          | :upstream_error

  @error_reason_tags %{
    bad_content_type: 0,
    bad_method: 1,
    payload_too_large: 2,
    upstream_timeout: 3,
    upstream_error: 4,
  }

  @tag_to_error_reason Map.new(@error_reason_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorReason` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doh.error_reason_from_tag(0)
      {:ok, :bad_content_type}
  """
  @spec error_reason_from_tag(non_neg_integer()) :: {:ok, error_reason()} | :error
  def error_reason_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_error_reason, tag)}
  end

  def error_reason_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorReason` to the C-ABI tag value.
  """
  @spec error_reason_to_tag(error_reason()) :: non_neg_integer()
  def error_reason_to_tag(val) when is_map_key(@error_reason_tags, val) do
    Map.fetch!(@error_reason_tags, val)
  end

  @doc """
  All `ErrorReason` variants in tag order.
  """
  @spec all_error_reasons() :: [error_reason()]
  def all_error_reasons do
    [
      :bad_content_type, :bad_method, :payload_too_large, :upstream_timeout,
      :upstream_error
    ]
  end

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :bound | :serving | :resolving | :shutdown

  @session_state_tags %{
    idle: 0,
    bound: 1,
    serving: 2,
    resolving: 3,
    shutdown: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doh.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :bound, :serving, :resolving, :shutdown]

end
