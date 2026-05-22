# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Bgp do
  @moduledoc """
  BGP protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `BgpABI.Types` and its type definitions:
  - `BgpState`         — BGP FSM states (6 constructors, tags 0-5)
  - `BgpEvent`         — BGP FSM events (19 constructors, tags 0-18)
  - `MessageType`      — BGP message types (4 constructors, tags 0-3)
  - `ErrorCode`        — BGP NOTIFICATION error codes (6 constructors, tags 0-5)
  - `Origin`           — Path attribute origin types (3 constructors, tags 0-2)
  - `AsPathSegmentType`— AS_PATH segment types (2 constructors, tags 0-1)
  - `PathAttrType`     — Path attribute types (8 constructors, tags 0-7)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard BGP port (RFC 4271)."
  @spec bgp_port() :: non_neg_integer()
  def bgp_port, do: 179

  # ===========================================================================
  # BgpState (tags 0-5)
  # ===========================================================================

  @typedoc """
  BgpState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type bgp_state :: :idle | :connect | :active | :open_sent | :open_confirm | :established

  @bgp_state_tags %{
    idle: 0,
    connect: 1,
    active: 2,
    open_sent: 3,
    open_confirm: 4,
    established: 5,
  }

  @tag_to_bgp_state Map.new(@bgp_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BgpState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.bgp_state_from_tag(0)
      {:ok, :idle}
  """
  @spec bgp_state_from_tag(non_neg_integer()) :: {:ok, bgp_state()} | :error
  def bgp_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_bgp_state, tag)}
  end

  def bgp_state_from_tag(_tag), do: :error

  @doc """
  Encode a `BgpState` to the C-ABI tag value.
  """
  @spec bgp_state_to_tag(bgp_state()) :: non_neg_integer()
  def bgp_state_to_tag(val) when is_map_key(@bgp_state_tags, val) do
    Map.fetch!(@bgp_state_tags, val)
  end

  @doc """
  All `BgpState` variants in tag order.
  """
  @spec all_bgp_states() :: [bgp_state()]
  def all_bgp_states, do: [:idle, :connect, :active, :open_sent, :open_confirm, :established]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether routes can be exchanged in this state.
  """
  @spec is_route_exchange?(bgp_state()) :: boolean()
  def is_route_exchange?(val) when val in [:established], do: true
  def is_route_exchange?(_val), do: false

  @doc """
  Whether a TCP connection exists in this state.
  """
  @spec has_connection?(bgp_state()) :: boolean()
  def has_connection?(val) when val in [:open_sent, :open_confirm, :established], do: true
  def has_connection?(_val), do: false

  # ===========================================================================
  # BgpEvent (tags 0-18)
  # ===========================================================================

  @typedoc """
  BgpEvent types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type bgp_event ::
          :manual_start
          | :manual_stop
          | :automatic_start
          | :connect_retry_timer_expires
          | :hold_timer_expires
          | :keepalive_timer_expires
          | :delay_open_timer_expires
          | :tcp_connection_valid
          | :tcp_cr_acked
          | :tcp_connection_confirmed
          | :tcp_connection_fails
          | :bgp_open_received
          | :bgp_header_err
          | :bgp_open_msg_err
          | :notif_msg_ver_err
          | :notif_msg
          | :keepalive_msg
          | :update_msg
          | :update_msg_err

  @bgp_event_tags %{
    manual_start: 0,
    manual_stop: 1,
    automatic_start: 2,
    connect_retry_timer_expires: 3,
    hold_timer_expires: 4,
    keepalive_timer_expires: 5,
    delay_open_timer_expires: 6,
    tcp_connection_valid: 7,
    tcp_cr_acked: 8,
    tcp_connection_confirmed: 9,
    tcp_connection_fails: 10,
    bgp_open_received: 11,
    bgp_header_err: 12,
    bgp_open_msg_err: 13,
    notif_msg_ver_err: 14,
    notif_msg: 15,
    keepalive_msg: 16,
    update_msg: 17,
    update_msg_err: 18,
  }

  @tag_to_bgp_event Map.new(@bgp_event_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BgpEvent` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..18, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.bgp_event_from_tag(0)
      {:ok, :manual_start}
  """
  @spec bgp_event_from_tag(non_neg_integer()) :: {:ok, bgp_event()} | :error
  def bgp_event_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 18 do
    {:ok, Map.fetch!(@tag_to_bgp_event, tag)}
  end

  def bgp_event_from_tag(_tag), do: :error

  @doc """
  Encode a `BgpEvent` to the C-ABI tag value.
  """
  @spec bgp_event_to_tag(bgp_event()) :: non_neg_integer()
  def bgp_event_to_tag(val) when is_map_key(@bgp_event_tags, val) do
    Map.fetch!(@bgp_event_tags, val)
  end

  @doc """
  All `BgpEvent` variants in tag order.
  """
  @spec all_bgp_events() :: [bgp_event()]
  def all_bgp_events do
    [
      :manual_start, :manual_stop, :automatic_start, :connect_retry_timer_expires,
      :hold_timer_expires, :keepalive_timer_expires, :delay_open_timer_expires,
      :tcp_connection_valid, :tcp_cr_acked, :tcp_connection_confirmed,
      :tcp_connection_fails, :bgp_open_received, :bgp_header_err, :bgp_open_msg_err,
      :notif_msg_ver_err, :notif_msg, :keepalive_msg, :update_msg, :update_msg_err,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this event is a timer expiry.
  """
  @spec is_timer_event?(bgp_event()) :: boolean()
  def is_timer_event?(val) when val in [:connect_retry_timer_expires, :hold_timer_expires, :keepalive_timer_expires, :delay_open_timer_expires], do: true
  def is_timer_event?(_val), do: false

  @doc """
  Whether this event indicates an error.
  """
  @spec is_error_event?(bgp_event()) :: boolean()
  def is_error_event?(val) when val in [:tcp_connection_fails, :bgp_header_err, :bgp_open_msg_err, :notif_msg_ver_err, :update_msg_err], do: true
  def is_error_event?(_val), do: false

  # ===========================================================================
  # MessageType (tags 0-3)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type :: :open | :update | :notification | :keepalive

  @message_type_tags %{
    open: 0,
    update: 1,
    notification: 2,
    keepalive: 3,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.message_type_from_tag(0)
      {:ok, :open}
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
  def all_message_types, do: [:open, :update, :notification, :keepalive]

  # ===========================================================================
  # ErrorCode (tags 0-5)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :message_header_error
          | :open_message_error
          | :update_message_error
          | :hold_timer_expired
          | :fsm_error
          | :cease

  @error_code_tags %{
    message_header_error: 0,
    open_message_error: 1,
    update_message_error: 2,
    hold_timer_expired: 3,
    fsm_error: 4,
    cease: 5,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.error_code_from_tag(0)
      {:ok, :message_header_error}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
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
      :message_header_error, :open_message_error, :update_message_error,
      :hold_timer_expired, :fsm_error, :cease
    ]
  end

  # ===========================================================================
  # Origin (tags 0-2)
  # ===========================================================================

  @typedoc """
  Origin types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type origin :: :igp | :egp | :incomplete

  @origin_tags %{
    igp: 0,
    egp: 1,
    incomplete: 2,
  }

  @tag_to_origin Map.new(@origin_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Origin` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.origin_from_tag(0)
      {:ok, :igp}
  """
  @spec origin_from_tag(non_neg_integer()) :: {:ok, origin()} | :error
  def origin_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_origin, tag)}
  end

  def origin_from_tag(_tag), do: :error

  @doc """
  Encode a `Origin` to the C-ABI tag value.
  """
  @spec origin_to_tag(origin()) :: non_neg_integer()
  def origin_to_tag(val) when is_map_key(@origin_tags, val) do
    Map.fetch!(@origin_tags, val)
  end

  @doc """
  All `Origin` variants in tag order.
  """
  @spec all_origins() :: [origin()]
  def all_origins, do: [:igp, :egp, :incomplete]

  # ===========================================================================
  # AsPathSegmentType (tags 0-1)
  # ===========================================================================

  @typedoc """
  AsPathSegmentType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type as_path_segment_type :: :as_set | :as_sequence

  @as_path_segment_type_tags %{
    as_set: 0,
    as_sequence: 1,
  }

  @tag_to_as_path_segment_type Map.new(@as_path_segment_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AsPathSegmentType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.as_path_segment_type_from_tag(0)
      {:ok, :as_set}
  """
  @spec as_path_segment_type_from_tag(non_neg_integer()) :: {:ok, as_path_segment_type()} | :error
  def as_path_segment_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_as_path_segment_type, tag)}
  end

  def as_path_segment_type_from_tag(_tag), do: :error

  @doc """
  Encode a `AsPathSegmentType` to the C-ABI tag value.
  """
  @spec as_path_segment_type_to_tag(as_path_segment_type()) :: non_neg_integer()
  def as_path_segment_type_to_tag(val) when is_map_key(@as_path_segment_type_tags, val) do
    Map.fetch!(@as_path_segment_type_tags, val)
  end

  @doc """
  All `AsPathSegmentType` variants in tag order.
  """
  @spec all_as_path_segment_types() :: [as_path_segment_type()]
  def all_as_path_segment_types, do: [:as_set, :as_sequence]

  # ===========================================================================
  # PathAttrType (tags 0-7)
  # ===========================================================================

  @typedoc """
  PathAttrType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type path_attr_type ::
          :origin
          | :as_path
          | :next_hop
          | :med
          | :local_pref
          | :atomic_aggr
          | :aggregator
          | :unknown

  @path_attr_type_tags %{
    origin: 0,
    as_path: 1,
    next_hop: 2,
    med: 3,
    local_pref: 4,
    atomic_aggr: 5,
    aggregator: 6,
    unknown: 7,
  }

  @tag_to_path_attr_type Map.new(@path_attr_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PathAttrType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bgp.path_attr_type_from_tag(0)
      {:ok, :origin}
  """
  @spec path_attr_type_from_tag(non_neg_integer()) :: {:ok, path_attr_type()} | :error
  def path_attr_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_path_attr_type, tag)}
  end

  def path_attr_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PathAttrType` to the C-ABI tag value.
  """
  @spec path_attr_type_to_tag(path_attr_type()) :: non_neg_integer()
  def path_attr_type_to_tag(val) when is_map_key(@path_attr_type_tags, val) do
    Map.fetch!(@path_attr_type_tags, val)
  end

  @doc """
  All `PathAttrType` variants in tag order.
  """
  @spec all_path_attr_types() :: [path_attr_type()]
  def all_path_attr_types do
    [
      :origin, :as_path, :next_hop, :med, :local_pref, :atomic_aggr,
      :aggregator, :unknown
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this attribute is mandatory (well-known mandatory per RFC 4271).
  """
  @spec is_mandatory?(path_attr_type()) :: boolean()
  def is_mandatory?(val) when val in [:origin, :as_path, :next_hop], do: true
  def is_mandatory?(_val), do: false

end
