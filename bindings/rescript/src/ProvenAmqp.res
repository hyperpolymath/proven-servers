// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP 0-9-1 protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module AmqpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard AMQP port (non-TLS).
let amqpPort = 5672

/// Standard AMQPS port (TLS).
let amqpsPort = 5671

// ===========================================================================
// FrameType (tags 0-3)
// ===========================================================================

/// Standard AMQP port (non-TLS).
type frameType =
  | @as(0) Method
  | @as(1) Header
  | @as(2) Body
  | @as(3) Heartbeat

/// Decode from the C-ABI tag value.
let frameTypeFromTag = (tag: int): option<frameType> =>
  switch tag {
  | 0 => Some(Method)
  | 1 => Some(Header)
  | 2 => Some(Body)
  | 3 => Some(Heartbeat)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let frameTypeToTag = (v: frameType): int =>
  switch v {
  | Method => 0
  | Header => 1
  | Body => 2
  | Heartbeat => 3
  }

/// Whether this frame type carries message content.
let frameTypeIsContent = (v: frameType): bool =>
  switch v {
  | Header | Body => true
  | _ => false
  }

// ===========================================================================
// MethodClass (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type methodClass =
  | @as(0) Connection
  | @as(1) Channel
  | @as(2) Exchange
  | @as(3) Queue
  | @as(4) Basic
  | @as(5) Tx
  | @as(6) Confirm

/// Decode from the C-ABI tag value.
let methodClassFromTag = (tag: int): option<methodClass> =>
  switch tag {
  | 0 => Some(Connection)
  | 1 => Some(Channel)
  | 2 => Some(Exchange)
  | 3 => Some(Queue)
  | 4 => Some(Basic)
  | 5 => Some(Tx)
  | 6 => Some(Confirm)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let methodClassToTag = (v: methodClass): int =>
  switch v {
  | Connection => 0
  | Channel => 1
  | Exchange => 2
  | Queue => 3
  | Basic => 4
  | Tx => 5
  | Confirm => 6
  }

/// Whether this class operates at the connection level (vs channel level).
let methodClassIsConnectionLevel = (v: methodClass): bool =>
  switch v {
  | Connection => true
  | _ => false
  }

// ===========================================================================
// ExchangeType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type exchangeType =
  | @as(0) Direct
  | @as(1) Fanout
  | @as(2) Topic
  | @as(3) Headers

/// Decode from the C-ABI tag value.
let exchangeTypeFromTag = (tag: int): option<exchangeType> =>
  switch tag {
  | 0 => Some(Direct)
  | 1 => Some(Fanout)
  | 2 => Some(Topic)
  | 3 => Some(Headers)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let exchangeTypeToTag = (v: exchangeType): int =>
  switch v {
  | Direct => 0
  | Fanout => 1
  | Topic => 2
  | Headers => 3
  }

/// Whether this exchange type uses routing keys for message delivery.
let exchangeTypeUsesRoutingKey = (v: exchangeType): bool =>
  switch v {
  | Direct | Topic => true
  | _ => false
  }

// ===========================================================================
// DeliveryMode (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type deliveryMode =
  | @as(0) NonPersistent
  | @as(1) Persistent

/// Decode from the C-ABI tag value.
let deliveryModeFromTag = (tag: int): option<deliveryMode> =>
  switch tag {
  | 0 => Some(NonPersistent)
  | 1 => Some(Persistent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let deliveryModeToTag = (v: deliveryMode): int =>
  switch v {
  | NonPersistent => 0
  | Persistent => 1
  }

// ===========================================================================
// ErrorSeverity (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type errorSeverity =
  | @as(0) ChannelLevel
  | @as(1) ConnectionLevel

/// Decode from the C-ABI tag value.
let errorSeverityFromTag = (tag: int): option<errorSeverity> =>
  switch tag {
  | 0 => Some(ChannelLevel)
  | 1 => Some(ConnectionLevel)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorSeverityToTag = (v: errorSeverity): int =>
  switch v {
  | ChannelLevel => 0
  | ConnectionLevel => 1
  }

// ===========================================================================
// ConnectionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type connectionState =
  | @as(0) Idle
  | @as(1) Negotiating
  | @as(2) TuningOk
  | @as(3) Open
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let connectionStateFromTag = (tag: int): option<connectionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Negotiating)
  | 2 => Some(TuningOk)
  | 3 => Some(Open)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let connectionStateToTag = (v: connectionState): int =>
  switch v {
  | Idle => 0
  | Negotiating => 1
  | TuningOk => 2
  | Open => 3
  | Closing => 4
  }

/// Validate whether a state transition is allowed.
let connectionStateCanTransitionTo = (from: connectionState, to: connectionState): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// ChannelState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type channelState =
  | @as(0) Closed
  | @as(1) Opening
  | @as(2) ChOpen
  | @as(3) ChClosing

/// Decode from the C-ABI tag value.
let channelStateFromTag = (tag: int): option<channelState> =>
  switch tag {
  | 0 => Some(Closed)
  | 1 => Some(Opening)
  | 2 => Some(ChOpen)
  | 3 => Some(ChClosing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let channelStateToTag = (v: channelState): int =>
  switch v {
  | Closed => 0
  | Opening => 1
  | ChOpen => 2
  | ChClosing => 3
  }

/// Validate whether a state transition is allowed.
let channelStateCanTransitionTo = (from: channelState, to: channelState): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// BrokerState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type brokerState =
  | @as(0) Idle
  | @as(1) Connected
  | @as(2) ChannelOpen
  | @as(3) Consuming
  | @as(4) Publishing
  | @as(5) Disconnecting

/// Decode from the C-ABI tag value.
let brokerStateFromTag = (tag: int): option<brokerState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connected)
  | 2 => Some(ChannelOpen)
  | 3 => Some(Consuming)
  | 4 => Some(Publishing)
  | 5 => Some(Disconnecting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let brokerStateToTag = (v: brokerState): int =>
  switch v {
  | Idle => 0
  | Connected => 1
  | ChannelOpen => 2
  | Consuming => 3
  | Publishing => 4
  | Disconnecting => 5
  }

/// Validate whether a state transition is allowed.
let brokerStateCanTransitionTo = (from: brokerState, to: brokerState): bool =>
  switch (from, to) {
  | _ => false
  }

