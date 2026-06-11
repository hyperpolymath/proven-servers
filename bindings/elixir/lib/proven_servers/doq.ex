# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Doq do
  @moduledoc """
  DNS-over-QUIC types for the proven-servers ABI.
  
  Formally verified DoQ types (RFC 9250).
  Mirrors the Idris2 module `DoqABI.Types`.
  
  - `StreamType` -- QUIC stream types.
  - `ErrorCode` -- DoQ error codes.
  - `SessionState` -- DoQ session lifecycle states.
  - `ServerState` -- DoQ server lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard DoQ port."
  @spec doq_port() :: non_neg_integer()
  def doq_port, do: 853

  # ===========================================================================
  # StreamType (tags 0-1)
  # ===========================================================================

  @typedoc """
  StreamType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type stream_type :: :unidirectional | :bidirectional

  @stream_type_tags %{
    unidirectional: 0,
    bidirectional: 1,
  }

  @tag_to_stream_type Map.new(@stream_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StreamType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doq.stream_type_from_tag(0)
      {:ok, :unidirectional}
  """
  @spec stream_type_from_tag(non_neg_integer()) :: {:ok, stream_type()} | :error
  def stream_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_stream_type, tag)}
  end

  def stream_type_from_tag(_tag), do: :error

  @doc """
  Encode a `StreamType` to the C-ABI tag value.
  """
  @spec stream_type_to_tag(stream_type()) :: non_neg_integer()
  def stream_type_to_tag(val) when is_map_key(@stream_type_tags, val) do
    Map.fetch!(@stream_type_tags, val)
  end

  @doc """
  All `StreamType` variants in tag order.
  """
  @spec all_stream_types() :: [stream_type()]
  def all_stream_types, do: [:unidirectional, :bidirectional]

  # ===========================================================================
  # ErrorCode (tags 0-3)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code :: :no_error | :internal_error | :excessive_load | :protocol_error

  @error_code_tags %{
    no_error: 0,
    internal_error: 1,
    excessive_load: 2,
    protocol_error: 3,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doq.error_code_from_tag(0)
      {:ok, :no_error}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
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
  def all_error_codes, do: [:no_error, :internal_error, :excessive_load, :protocol_error]

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :initial | :handshaking | :ready | :draining | :closed

  @session_state_tags %{
    initial: 0,
    handshaking: 1,
    ready: 2,
    draining: 3,
    closed: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doq.session_state_from_tag(0)
      {:ok, :initial}
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
  def all_session_states, do: [:initial, :handshaking, :ready, :draining, :closed]

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :bound | :listening | :processing | :shutdown

  @server_state_tags %{
    idle: 0,
    bound: 1,
    listening: 2,
    processing: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Doq.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_server_state, tag)}
  end

  def server_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ServerState` to the C-ABI tag value.
  """
  @spec server_state_to_tag(server_state()) :: non_neg_integer()
  def server_state_to_tag(val) when is_map_key(@server_state_tags, val) do
    Map.fetch!(@server_state_tags, val)
  end

  @doc """
  All `ServerState` variants in tag order.
  """
  @spec all_server_states() :: [server_state()]
  def all_server_states, do: [:idle, :bound, :listening, :processing, :shutdown]

end
