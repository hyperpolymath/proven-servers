# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Rtsp do
  @moduledoc """
  RTSP (Real Time Streaming Protocol) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `RTSPABI.Types` and its type definitions:
  - `Method`            — RTSP request methods (11 constructors, tags 0-10)
  - `TransportProtocol` — RTP transport variants (3 constructors, tags 0-2)
  - `SessionState`      — RTSP session state machine (4 constructors, tags 0-3)
  - `StatusCode`        — RTSP response status codes (12 constructors, tags 0-11)
  - `RtspError`         — FFI error codes (7 constructors, tags 0-6)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard RTSP port (RFC 7826)."
  @spec rtsp_port() :: non_neg_integer()
  def rtsp_port, do: 554

  @doc "Standard RTSPS (RTSP over TLS) port."
  @spec rtsps_port() :: non_neg_integer()
  def rtsps_port, do: 322

  # ===========================================================================
  # Method (tags 0-10)
  # ===========================================================================

  @typedoc """
  Method types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type method ::
          :describe
          | :setup
          | :play
          | :pause
          | :teardown
          | :get_parameter
          | :set_parameter
          | :options
          | :announce
          | :record
          | :redirect

  @method_tags %{
    describe: 0,
    setup: 1,
    play: 2,
    pause: 3,
    teardown: 4,
    get_parameter: 5,
    set_parameter: 6,
    options: 7,
    announce: 8,
    record: 9,
    redirect: 10,
  }

  @tag_to_method Map.new(@method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Method` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Rtsp.method_from_tag(0)
      {:ok, :describe}
  """
  @spec method_from_tag(non_neg_integer()) :: {:ok, method()} | :error
  def method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
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
  def all_methods do
    [
      :describe, :setup, :play, :pause, :teardown, :get_parameter, :set_parameter,
      :options, :announce, :record, :redirect
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The RTSP method name string.
        match self {

  Whether this method requires an active session.
  """
  @spec requires_session?(method()) :: boolean()
  def requires_session?(val) when val in [:play, :pause, :teardown, :get_parameter, :set_parameter, :record], do: true
  def requires_session?(_val), do: false

  # ===========================================================================
  # TransportProtocol (tags 0-2)
  # ===========================================================================

  @typedoc """
  TransportProtocol types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transport_protocol :: :rtp_avp_udp | :rtp_avp_tcp | :rtp_avp_udp_multicast

  @transport_protocol_tags %{
    rtp_avp_udp: 0,
    rtp_avp_tcp: 1,
    rtp_avp_udp_multicast: 2,
  }

  @tag_to_transport_protocol Map.new(@transport_protocol_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransportProtocol` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Rtsp.transport_protocol_from_tag(0)
      {:ok, :rtp_avp_udp}
  """
  @spec transport_protocol_from_tag(non_neg_integer()) :: {:ok, transport_protocol()} | :error
  def transport_protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
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
  def all_transport_protocols, do: [:rtp_avp_udp, :rtp_avp_tcp, :rtp_avp_udp_multicast]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this transport uses TCP.
  """
  @spec is_tcp?(transport_protocol()) :: boolean()
  def is_tcp?(val) when val in [:rtp_avp_tcp], do: true
  def is_tcp?(_val), do: false

  @doc """
  Whether this transport uses multicast.
  """
  @spec is_multicast?(transport_protocol()) :: boolean()
  def is_multicast?(val) when val in [:rtp_avp_udp_multicast], do: true
  def is_multicast?(_val), do: false

  # ===========================================================================
  # SessionState (tags 0-3)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :init | :ready | :playing | :recording

  @session_state_tags %{
    init: 0,
    ready: 1,
    playing: 2,
    recording: 3,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Rtsp.session_state_from_tag(0)
      {:ok, :init}
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
  def all_session_states, do: [:init, :ready, :playing, :recording]

  @doc """
  Validate whether a `SessionState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_session_state_transition(session_state(), session_state()) :: boolean()
  def validate_session_state_transition(:init, :ready), do: true
  def validate_session_state_transition(:ready, :playing), do: true
  def validate_session_state_transition(:ready, :recording), do: true
  def validate_session_state_transition(:playing, :ready), do: true
  def validate_session_state_transition(:recording, :ready), do: true
  def validate_session_state_transition(:ready, :init), do: true
  def validate_session_state_transition(:playing, :init), do: true
  def validate_session_state_transition(:recording, :init), do: true
  def validate_session_state_transition(_from, _to), do: false

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether media is actively streaming (playing or recording).
  """
  @spec is_active?(session_state()) :: boolean()
  def is_active?(val) when val in [:playing, :recording], do: true
  def is_active?(_val), do: false

  # ===========================================================================
  # StatusCode (tags 0-11)
  # ===========================================================================

  @typedoc """
  StatusCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type status_code ::
          :ok
          | :moved_permanently
          | :moved_temporarily
          | :bad_request
          | :unauthorized
          | :not_found
          | :method_not_allowed
          | :not_acceptable
          | :session_not_found
          | :internal_server_error
          | :not_implemented
          | :service_unavailable

  @status_code_tags %{
    ok: 0,
    moved_permanently: 1,
    moved_temporarily: 2,
    bad_request: 3,
    unauthorized: 4,
    not_found: 5,
    method_not_allowed: 6,
    not_acceptable: 7,
    session_not_found: 8,
    internal_server_error: 9,
    not_implemented: 10,
    service_unavailable: 11,
  }

  @tag_to_status_code Map.new(@status_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StatusCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Rtsp.status_code_from_tag(0)
      {:ok, :ok}
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
      :ok, :moved_permanently, :moved_temporarily, :bad_request, :unauthorized,
      :not_found, :method_not_allowed, :not_acceptable, :session_not_found,
      :internal_server_error, :not_implemented, :service_unavailable,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this status code indicates success (2xx).
  """
  @spec is_success?(status_code()) :: boolean()
  def is_success?(val) when val in [:ok], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this status code indicates a client error (4xx).
  """
  @spec is_client_error?(status_code()) :: boolean()
  def is_client_error?(val) when val in [:bad_request, :unauthorized, :not_found, :method_not_allowed, :not_acceptable, :session_not_found], do: true
  def is_client_error?(_val), do: false

  @doc """
  Whether this status code indicates a server error (5xx).
  """
  @spec is_server_error?(status_code()) :: boolean()
  def is_server_error?(val) when val in [:internal_server_error, :not_implemented, :service_unavailable], do: true
  def is_server_error?(_val), do: false

  # ===========================================================================
  # RtspError (tags 0-6)
  # ===========================================================================

  @typedoc """
  RtspError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type rtsp_error ::
          :ok
          | :invalid_slot
          | :not_active
          | :invalid_transition
          | :method_not_allowed
          | :transport_error
          | :session_expired

  @rtsp_error_tags %{
    ok: 0,
    invalid_slot: 1,
    not_active: 2,
    invalid_transition: 3,
    method_not_allowed: 4,
    transport_error: 5,
    session_expired: 6,
  }

  @tag_to_rtsp_error Map.new(@rtsp_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RtspError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Rtsp.rtsp_error_from_tag(0)
      {:ok, :ok}
  """
  @spec rtsp_error_from_tag(non_neg_integer()) :: {:ok, rtsp_error()} | :error
  def rtsp_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_rtsp_error, tag)}
  end

  def rtsp_error_from_tag(_tag), do: :error

  @doc """
  Encode a `RtspError` to the C-ABI tag value.
  """
  @spec rtsp_error_to_tag(rtsp_error()) :: non_neg_integer()
  def rtsp_error_to_tag(val) when is_map_key(@rtsp_error_tags, val) do
    Map.fetch!(@rtsp_error_tags, val)
  end

  @doc """
  All `RtspError` variants in tag order.
  """
  @spec all_rtsp_errors() :: [rtsp_error()]
  def all_rtsp_errors do
    [
      :ok, :invalid_slot, :not_active, :invalid_transition, :method_not_allowed,
      :transport_error, :session_expired
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this represents a successful outcome.
  """
  @spec is_ok?(rtsp_error()) :: boolean()
  def is_ok?(val) when val in [:ok], do: true
  def is_ok?(_val), do: false

end
