# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Grpc do
  @moduledoc """
  gRPC protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `GRPC.Types` — status codes, stream types, compression, content types
    * `GRPCABI.Layout` — C-ABI tag values for stream states
    * `GRPCABI.Transitions` — HTTP/2 stream state machine (RFC 7540 Section 5.1)

  The HTTP/2 stream lifecycle is modelled via `stream_state` and
  `validate_stream_transition/2`, matching the formal proofs in
  `GRPCABI.Transitions` (including impossibility proofs like
  `closedIsTerminal`).

  ## Stream State Machine

  The HTTP/2 stream lifecycle follows RFC 7540 Section 5.1:

      Idle -> Open -> HalfClosedLocal -> Closed
                   -> HalfClosedRemote -> Closed
                   -> Closed (RST_STREAM)
      Idle -> Reserved -> HalfClosedRemote | Closed

  Key invariant: `Closed` is terminal -- no transitions originate from it.
  """

  # ===========================================================================
  # gRPC Status Code (GRPC.Types.StatusCode)
  # ===========================================================================

  @typedoc """
  gRPC status codes per the gRPC specification.

  Matches the `StatusCode` type in `GRPC.Types`.
  Numeric values are the standard gRPC status codes (0..16).
  """
  @type status_code ::
          :ok
          | :cancelled
          | :unknown
          | :invalid_argument
          | :deadline_exceeded
          | :not_found
          | :already_exists
          | :permission_denied
          | :resource_exhausted
          | :failed_precondition
          | :aborted
          | :out_of_range
          | :unimplemented
          | :internal
          | :unavailable
          | :data_loss
          | :unauthenticated

  @status_codes %{
    ok: 0,
    cancelled: 1,
    unknown: 2,
    invalid_argument: 3,
    deadline_exceeded: 4,
    not_found: 5,
    already_exists: 6,
    permission_denied: 7,
    resource_exhausted: 8,
    failed_precondition: 9,
    aborted: 10,
    out_of_range: 11,
    unimplemented: 12,
    internal: 13,
    unavailable: 14,
    data_loss: 15,
    unauthenticated: 16
  }

  @code_to_status Map.new(@status_codes, fn {k, v} -> {v, k} end)

  @doc """
  Decode from a numeric gRPC status code.

  ## Examples

      iex> ProvenServers.Grpc.status_from_code(0)
      {:ok, :ok}

      iex> ProvenServers.Grpc.status_from_code(5)
      {:ok, :not_found}

      iex> ProvenServers.Grpc.status_from_code(99)
      :error
  """
  @spec status_from_code(non_neg_integer()) :: {:ok, status_code()} | :error
  def status_from_code(code) when is_integer(code) and code >= 0 and code <= 16 do
    {:ok, Map.fetch!(@code_to_status, code)}
  end

  def status_from_code(_code), do: :error

  @doc """
  Encode to a numeric gRPC status code.

  ## Examples

      iex> ProvenServers.Grpc.status_to_code(:ok)
      0
  """
  @spec status_to_code(status_code()) :: non_neg_integer()
  def status_to_code(status) when is_map_key(@status_codes, status) do
    Map.fetch!(@status_codes, status)
  end

  @doc """
  Whether this status represents success.
  """
  @spec status_ok?(status_code()) :: boolean()
  def status_ok?(:ok), do: true
  def status_ok?(_status), do: false

  # ===========================================================================
  # Stream Type (GRPC.Types.StreamType)
  # ===========================================================================

  @typedoc """
  gRPC stream cardinality types.

  Matches `StreamType` in `GRPC.Types`.
  """
  @type stream_type :: :unary | :server_streaming | :client_streaming | :bidi_streaming

  @doc """
  Whether the client sends a stream of messages.

  ## Examples

      iex> ProvenServers.Grpc.client_streaming?(:bidi_streaming)
      true

      iex> ProvenServers.Grpc.client_streaming?(:unary)
      false
  """
  @spec client_streaming?(stream_type()) :: boolean()
  def client_streaming?(st) when st in [:client_streaming, :bidi_streaming], do: true
  def client_streaming?(_st), do: false

  @doc """
  Whether the server sends a stream of messages.

  ## Examples

      iex> ProvenServers.Grpc.server_streaming?(:server_streaming)
      true

      iex> ProvenServers.Grpc.server_streaming?(:unary)
      false
  """
  @spec server_streaming?(stream_type()) :: boolean()
  def server_streaming?(st) when st in [:server_streaming, :bidi_streaming], do: true
  def server_streaming?(_st), do: false

  # ===========================================================================
  # Compression (GRPC.Types.Compression)
  # ===========================================================================

  @typedoc """
  gRPC message compression algorithms.

  Matches `Compression` in `GRPC.Types`.
  """
  @type compression :: :identity | :gzip | :deflate | :snappy | :zstd

  @compression_names %{
    identity: "identity",
    gzip: "gzip",
    deflate: "deflate",
    snappy: "snappy",
    zstd: "zstd"
  }

  @doc """
  String encoding name for the compression algorithm.

  ## Examples

      iex> ProvenServers.Grpc.compression_name(:gzip)
      "gzip"
  """
  @spec compression_name(compression()) :: String.t()
  def compression_name(c) when is_map_key(@compression_names, c) do
    Map.fetch!(@compression_names, c)
  end

  # ===========================================================================
  # Content Type (GRPC.Types.ContentType)
  # ===========================================================================

  @typedoc """
  gRPC content type encodings.

  Matches `ContentType` in `GRPC.Types`.
  """
  @type grpc_content_type :: :protobuf | :json

  @doc """
  The gRPC content-type header value.

  ## Examples

      iex> ProvenServers.Grpc.content_type_header(:protobuf)
      "application/grpc+proto"

      iex> ProvenServers.Grpc.content_type_header(:json)
      "application/grpc+json"
  """
  @spec content_type_header(grpc_content_type()) :: String.t()
  def content_type_header(:protobuf), do: "application/grpc+proto"
  def content_type_header(:json), do: "application/grpc+json"

  # ===========================================================================
  # HTTP/2 Stream State (GRPCABI.Layout.StreamState)
  # ===========================================================================

  @typedoc """
  HTTP/2 stream states (RFC 7540 Section 5.1).

  Used as the state index for the gRPC stream lifecycle state machine
  in `GRPCABI.Transitions`.
  """
  @type stream_state ::
          :idle | :open | :half_closed_local | :half_closed_remote | :reserved | :closed

  @stream_state_tags %{
    idle: 0,
    open: 1,
    half_closed_local: 2,
    half_closed_remote: 3,
    reserved: 4,
    closed: 5
  }

  @tag_to_stream_state Map.new(@stream_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode from a C-ABI tag value.

  ## Examples

      iex> ProvenServers.Grpc.stream_state_from_tag(1)
      {:ok, :open}
  """
  @spec stream_state_from_tag(non_neg_integer()) :: {:ok, stream_state()} | :error
  def stream_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_stream_state, tag)}
  end

  def stream_state_from_tag(_tag), do: :error

  @doc """
  Encode to the C-ABI tag value.
  """
  @spec stream_state_to_tag(stream_state()) :: non_neg_integer()
  def stream_state_to_tag(state) when is_map_key(@stream_state_tags, state) do
    Map.fetch!(@stream_state_tags, state)
  end

  @doc """
  Whether DATA frames can be sent (local direction) from this state.

  Matches `CanSendData` witnesses in `GRPCABI.Transitions`.

  ## Examples

      iex> ProvenServers.Grpc.can_send_data?(:open)
      true

      iex> ProvenServers.Grpc.can_send_data?(:half_closed_local)
      false
  """
  @spec can_send_data?(stream_state()) :: boolean()
  def can_send_data?(state) when state in [:open, :half_closed_remote], do: true
  def can_send_data?(_state), do: false

  @doc """
  Whether DATA frames can be received (remote direction) in this state.

  Matches `CanReceiveData` witnesses in `GRPCABI.Transitions`.

  ## Examples

      iex> ProvenServers.Grpc.can_receive_data?(:open)
      true

      iex> ProvenServers.Grpc.can_receive_data?(:half_closed_remote)
      false
  """
  @spec can_receive_data?(stream_state()) :: boolean()
  def can_receive_data?(state) when state in [:open, :half_closed_local], do: true
  def can_receive_data?(_state), do: false

  @doc """
  Whether WINDOW_UPDATE frames can be processed in this state.

  Matches `CanUpdateWindow` witnesses in `GRPCABI.Transitions`.
  """
  @spec can_update_window?(stream_state()) :: boolean()
  def can_update_window?(state)
      when state in [:open, :half_closed_local, :half_closed_remote],
      do: true

  def can_update_window?(_state), do: false

  @doc """
  Whether this is the terminal state (Closed).

  Relates to the `closedIsTerminal` impossibility proof in
  `GRPCABI.Transitions`.
  """
  @spec terminal?(stream_state()) :: boolean()
  def terminal?(:closed), do: true
  def terminal?(_state), do: false

  # ===========================================================================
  # Stream State Transitions
  # ===========================================================================

  @typedoc """
  Named HTTP/2 stream state transitions.

  Each value corresponds to a constructor of `ValidStreamTransition`
  in `GRPCABI.Transitions`.
  """
  @type stream_transition ::
          :send_headers
          | :local_end_stream
          | :remote_end_stream
          | :reset_from_open
          | :close_half_local
          | :close_half_remote
          | :push_promise_recv
          | :reserved_to_half
          | :reserved_reset

  @doc """
  Validate whether a stream state transition is legal.

  Mirrors `validateStreamTransition` in `GRPCABI.Transitions`.
  Returns `{:ok, transition_name}` for valid transitions, `:error` for invalid.

  Key invariant: `:closed` is terminal -- no transitions originate from it.

  ## Examples

      iex> ProvenServers.Grpc.validate_stream_transition(:idle, :open)
      {:ok, :send_headers}

      iex> ProvenServers.Grpc.validate_stream_transition(:closed, :open)
      :error
  """
  @spec validate_stream_transition(stream_state(), stream_state()) ::
          {:ok, stream_transition()} | :error
  def validate_stream_transition(:idle, :open), do: {:ok, :send_headers}
  def validate_stream_transition(:open, :half_closed_local), do: {:ok, :local_end_stream}
  def validate_stream_transition(:open, :half_closed_remote), do: {:ok, :remote_end_stream}
  def validate_stream_transition(:open, :closed), do: {:ok, :reset_from_open}
  def validate_stream_transition(:half_closed_local, :closed), do: {:ok, :close_half_local}
  def validate_stream_transition(:half_closed_remote, :closed), do: {:ok, :close_half_remote}
  def validate_stream_transition(:idle, :reserved), do: {:ok, :push_promise_recv}
  def validate_stream_transition(:reserved, :half_closed_remote), do: {:ok, :reserved_to_half}
  def validate_stream_transition(:reserved, :closed), do: {:ok, :reserved_reset}
  def validate_stream_transition(_from, _to), do: :error
end
