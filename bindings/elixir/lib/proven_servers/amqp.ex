# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Amqp do
  @moduledoc """
  AMQP 0-9-1 protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `AmqpABI.Types` and its type definitions:
  - `FrameType`       — AMQP frame types (4 constructors, tags 0-3)
  - `MethodClass`     — AMQP method classes (7 constructors, tags 0-6)
  - `ExchangeType`    — exchange routing types (4 constructors, tags 0-3)
  - `DeliveryMode`    — message persistence modes (2 constructors, tags 0-1)
  - `ErrorSeverity`   — error severity levels (2 constructors, tags 0-1)
  - `ConnectionState` — connection state machine (5 constructors, tags 0-4)
  - `ChannelState`    — channel state machine (4 constructors, tags 0-3)
  - `BrokerState`     — broker lifecycle state machine (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard AMQP port (non-TLS)."
  @spec amqp_port() :: non_neg_integer()
  def amqp_port, do: 5672

  @doc "Standard AMQPS port (TLS)."
  @spec amqps_port() :: non_neg_integer()
  def amqps_port, do: 5671

  # ===========================================================================
  # FrameType (tags 0-3)
  # ===========================================================================

  @typedoc """
  FrameType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type frame_type :: :method | :header | :body | :heartbeat

  @frame_type_tags %{
    method: 0,
    header: 1,
    body: 2,
    heartbeat: 3,
  }

  @tag_to_frame_type Map.new(@frame_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FrameType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.frame_type_from_tag(0)
      {:ok, :method}
  """
  @spec frame_type_from_tag(non_neg_integer()) :: {:ok, frame_type()} | :error
  def frame_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_frame_type, tag)}
  end

  def frame_type_from_tag(_tag), do: :error

  @doc """
  Encode a `FrameType` to the C-ABI tag value.
  """
  @spec frame_type_to_tag(frame_type()) :: non_neg_integer()
  def frame_type_to_tag(val) when is_map_key(@frame_type_tags, val) do
    Map.fetch!(@frame_type_tags, val)
  end

  @doc """
  All `FrameType` variants in tag order.
  """
  @spec all_frame_types() :: [frame_type()]
  def all_frame_types, do: [:method, :header, :body, :heartbeat]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this frame type carries message content.
  """
  @spec is_content?(frame_type()) :: boolean()
  def is_content?(val) when val in [:header, :body], do: true
  def is_content?(_val), do: false

  # ===========================================================================
  # MethodClass (tags 0-6)
  # ===========================================================================

  @typedoc """
  MethodClass types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type method_class :: :connection | :channel | :exchange | :queue | :basic | :tx | :confirm

  @method_class_tags %{
    connection: 0,
    channel: 1,
    exchange: 2,
    queue: 3,
    basic: 4,
    tx: 5,
    confirm: 6,
  }

  @tag_to_method_class Map.new(@method_class_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MethodClass` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.method_class_from_tag(0)
      {:ok, :connection}
  """
  @spec method_class_from_tag(non_neg_integer()) :: {:ok, method_class()} | :error
  def method_class_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_method_class, tag)}
  end

  def method_class_from_tag(_tag), do: :error

  @doc """
  Encode a `MethodClass` to the C-ABI tag value.
  """
  @spec method_class_to_tag(method_class()) :: non_neg_integer()
  def method_class_to_tag(val) when is_map_key(@method_class_tags, val) do
    Map.fetch!(@method_class_tags, val)
  end

  @doc """
  All `MethodClass` variants in tag order.
  """
  @spec all_method_classs() :: [method_class()]
  def all_method_classs, do: [:connection, :channel, :exchange, :queue, :basic, :tx, :confirm]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this class operates at the connection level (vs channel level).
  """
  @spec is_connection_level?(method_class()) :: boolean()
  def is_connection_level?(val) when val in [:connection], do: true
  def is_connection_level?(_val), do: false

  # ===========================================================================
  # ExchangeType (tags 0-3)
  # ===========================================================================

  @typedoc """
  ExchangeType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type exchange_type :: :direct | :fanout | :topic | :headers

  @exchange_type_tags %{
    direct: 0,
    fanout: 1,
    topic: 2,
    headers: 3,
  }

  @tag_to_exchange_type Map.new(@exchange_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ExchangeType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.exchange_type_from_tag(0)
      {:ok, :direct}
  """
  @spec exchange_type_from_tag(non_neg_integer()) :: {:ok, exchange_type()} | :error
  def exchange_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_exchange_type, tag)}
  end

  def exchange_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ExchangeType` to the C-ABI tag value.
  """
  @spec exchange_type_to_tag(exchange_type()) :: non_neg_integer()
  def exchange_type_to_tag(val) when is_map_key(@exchange_type_tags, val) do
    Map.fetch!(@exchange_type_tags, val)
  end

  @doc """
  All `ExchangeType` variants in tag order.
  """
  @spec all_exchange_types() :: [exchange_type()]
  def all_exchange_types, do: [:direct, :fanout, :topic, :headers]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this exchange type uses routing keys for message delivery.
  """
  @spec uses_routing_key?(exchange_type()) :: boolean()
  def uses_routing_key?(val) when val in [:direct, :topic], do: true
  def uses_routing_key?(_val), do: false

  # ===========================================================================
  # DeliveryMode (tags 0-1)
  # ===========================================================================

  @typedoc """
  DeliveryMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type delivery_mode :: :non_persistent | :persistent

  @delivery_mode_tags %{
    non_persistent: 0,
    persistent: 1,
  }

  @tag_to_delivery_mode Map.new(@delivery_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DeliveryMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.delivery_mode_from_tag(0)
      {:ok, :non_persistent}
  """
  @spec delivery_mode_from_tag(non_neg_integer()) :: {:ok, delivery_mode()} | :error
  def delivery_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_delivery_mode, tag)}
  end

  def delivery_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `DeliveryMode` to the C-ABI tag value.
  """
  @spec delivery_mode_to_tag(delivery_mode()) :: non_neg_integer()
  def delivery_mode_to_tag(val) when is_map_key(@delivery_mode_tags, val) do
    Map.fetch!(@delivery_mode_tags, val)
  end

  @doc """
  All `DeliveryMode` variants in tag order.
  """
  @spec all_delivery_modes() :: [delivery_mode()]
  def all_delivery_modes, do: [:non_persistent, :persistent]

  # ===========================================================================
  # ErrorSeverity (tags 0-1)
  # ===========================================================================

  @typedoc """
  ErrorSeverity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_severity :: :channel_level | :connection_level

  @error_severity_tags %{
    channel_level: 0,
    connection_level: 1,
  }

  @tag_to_error_severity Map.new(@error_severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorSeverity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.error_severity_from_tag(0)
      {:ok, :channel_level}
  """
  @spec error_severity_from_tag(non_neg_integer()) :: {:ok, error_severity()} | :error
  def error_severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_error_severity, tag)}
  end

  def error_severity_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorSeverity` to the C-ABI tag value.
  """
  @spec error_severity_to_tag(error_severity()) :: non_neg_integer()
  def error_severity_to_tag(val) when is_map_key(@error_severity_tags, val) do
    Map.fetch!(@error_severity_tags, val)
  end

  @doc """
  All `ErrorSeverity` variants in tag order.
  """
  @spec all_error_severitys() :: [error_severity()]
  def all_error_severitys, do: [:channel_level, :connection_level]

  # ===========================================================================
  # ConnectionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ConnectionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type connection_state :: :idle | :negotiating | :tuning_ok | :open | :closing

  @connection_state_tags %{
    idle: 0,
    negotiating: 1,
    tuning_ok: 2,
    open: 3,
    closing: 4,
  }

  @tag_to_connection_state Map.new(@connection_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ConnectionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.connection_state_from_tag(0)
      {:ok, :idle}
  """
  @spec connection_state_from_tag(non_neg_integer()) :: {:ok, connection_state()} | :error
  def connection_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_connection_state, tag)}
  end

  def connection_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ConnectionState` to the C-ABI tag value.
  """
  @spec connection_state_to_tag(connection_state()) :: non_neg_integer()
  def connection_state_to_tag(val) when is_map_key(@connection_state_tags, val) do
    Map.fetch!(@connection_state_tags, val)
  end

  @doc """
  All `ConnectionState` variants in tag order.
  """
  @spec all_connection_states() :: [connection_state()]
  def all_connection_states, do: [:idle, :negotiating, :tuning_ok, :open, :closing]

  @doc """
  Validate whether a `ConnectionState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_connection_state_transition(connection_state(), connection_state()) :: boolean()
  def validate_connection_state_transition(:idle, :negotiating), do: true
  def validate_connection_state_transition(:negotiating, :tuning_ok), do: true
  def validate_connection_state_transition(:tuning_ok, :open), do: true
  def validate_connection_state_transition(:open, :closing), do: true
  def validate_connection_state_transition(_from, :closing), do: true
  def validate_connection_state_transition(_from, _to), do: false

  # ===========================================================================
  # ChannelState (tags 0-3)
  # ===========================================================================

  @typedoc """
  ChannelState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type channel_state :: :closed | :opening | :ch_open | :ch_closing

  @channel_state_tags %{
    closed: 0,
    opening: 1,
    ch_open: 2,
    ch_closing: 3,
  }

  @tag_to_channel_state Map.new(@channel_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ChannelState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.channel_state_from_tag(0)
      {:ok, :closed}
  """
  @spec channel_state_from_tag(non_neg_integer()) :: {:ok, channel_state()} | :error
  def channel_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_channel_state, tag)}
  end

  def channel_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ChannelState` to the C-ABI tag value.
  """
  @spec channel_state_to_tag(channel_state()) :: non_neg_integer()
  def channel_state_to_tag(val) when is_map_key(@channel_state_tags, val) do
    Map.fetch!(@channel_state_tags, val)
  end

  @doc """
  All `ChannelState` variants in tag order.
  """
  @spec all_channel_states() :: [channel_state()]
  def all_channel_states, do: [:closed, :opening, :ch_open, :ch_closing]

  @doc """
  Validate whether a `ChannelState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_channel_state_transition(channel_state(), channel_state()) :: boolean()
  def validate_channel_state_transition(:closed, :opening), do: true
  def validate_channel_state_transition(:opening, :ch_open), do: true
  def validate_channel_state_transition(:opening, :closed), do: true
  def validate_channel_state_transition(:ch_open, :ch_closing), do: true
  def validate_channel_state_transition(:ch_closing, :closed), do: true
  def validate_channel_state_transition(_from, _to), do: false

  # ===========================================================================
  # BrokerState (tags 0-5)
  # ===========================================================================

  @typedoc """
  BrokerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type broker_state ::
          :idle
          | :connected
          | :channel_open
          | :consuming
          | :publishing
          | :disconnecting

  @broker_state_tags %{
    idle: 0,
    connected: 1,
    channel_open: 2,
    consuming: 3,
    publishing: 4,
    disconnecting: 5,
  }

  @tag_to_broker_state Map.new(@broker_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BrokerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Amqp.broker_state_from_tag(0)
      {:ok, :idle}
  """
  @spec broker_state_from_tag(non_neg_integer()) :: {:ok, broker_state()} | :error
  def broker_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_broker_state, tag)}
  end

  def broker_state_from_tag(_tag), do: :error

  @doc """
  Encode a `BrokerState` to the C-ABI tag value.
  """
  @spec broker_state_to_tag(broker_state()) :: non_neg_integer()
  def broker_state_to_tag(val) when is_map_key(@broker_state_tags, val) do
    Map.fetch!(@broker_state_tags, val)
  end

  @doc """
  All `BrokerState` variants in tag order.
  """
  @spec all_broker_states() :: [broker_state()]
  def all_broker_states do
    [
      :idle, :connected, :channel_open, :consuming, :publishing, :disconnecting,
    ]
  end

  @doc """
  Validate whether a `BrokerState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_broker_state_transition(broker_state(), broker_state()) :: boolean()
  def validate_broker_state_transition(:idle, :connected), do: true
  def validate_broker_state_transition(:connected, :channel_open), do: true
  def validate_broker_state_transition(:channel_open, :consuming), do: true
  def validate_broker_state_transition(:channel_open, :publishing), do: true
  def validate_broker_state_transition(:consuming, :disconnecting), do: true
  def validate_broker_state_transition(:publishing, :disconnecting), do: true
  def validate_broker_state_transition(_from, :disconnecting), do: true
  def validate_broker_state_transition(_from, _to), do: false

end
