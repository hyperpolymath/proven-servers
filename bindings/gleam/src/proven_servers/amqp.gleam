//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// AMQP 0-9-1 protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `AmqpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// AMQP 0-9-1 Constants
// ===========================================================================

/// Amqp Port constant.
pub const amqp_port = 5672

/// Amqps Port constant.
pub const amqps_port = 5671

// ===========================================================================
// FrameType
// ===========================================================================

/// AMQP 0-9-1 frame types.
/// 
/// Matches `FrameType` in `AmqpABI.Types`.
pub type FrameType {
  /// Method frame carrying AMQP commands (tag 0).
  Method
  /// Content header frame with message properties (tag 1).
  Header
  /// Content body frame with message payload (tag 2).
  Body
  /// Heartbeat frame for keepalive (tag 3).
  Heartbeat
}

/// Convert a `FrameType` to its C-ABI tag value.
pub fn frame_type_to_int(value: FrameType) -> Int {
  case value {
    Method -> 0
    Header -> 1
    Body -> 2
    Heartbeat -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn frame_type_from_int(tag: Int) -> Result(FrameType, Nil) {
  case tag {
    0 -> Ok(Method)
    1 -> Ok(Header)
    2 -> Ok(Body)
    3 -> Ok(Heartbeat)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MethodClass
// ===========================================================================

/// AMQP 0-9-1 method classes.
/// 
/// Matches `MethodClass` in `AmqpABI.Types`.
pub type MethodClass {
  /// Connection-level methods (tag 0).
  Connection
  /// Channel-level methods (tag 1).
  Channel
  /// Exchange declaration and management (tag 2).
  Exchange
  /// Queue declaration and management (tag 3).
  Queue
  /// Basic publish/consume/ack operations (tag 4).
  Basic
  /// Transaction support (tag 5).
  Tx
  /// Publisher confirms (tag 6).
  Confirm
}

/// Convert a `MethodClass` to its C-ABI tag value.
pub fn method_class_to_int(value: MethodClass) -> Int {
  case value {
    Connection -> 0
    Channel -> 1
    Exchange -> 2
    Queue -> 3
    Basic -> 4
    Tx -> 5
    Confirm -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn method_class_from_int(tag: Int) -> Result(MethodClass, Nil) {
  case tag {
    0 -> Ok(Connection)
    1 -> Ok(Channel)
    2 -> Ok(Exchange)
    3 -> Ok(Queue)
    4 -> Ok(Basic)
    5 -> Ok(Tx)
    6 -> Ok(Confirm)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ExchangeType
// ===========================================================================

/// AMQP exchange routing types.
/// 
/// Matches `ExchangeType` in `AmqpABI.Types`.
pub type ExchangeType {
  /// Direct routing by exact routing key match (tag 0).
  Direct
  /// Fanout to all bound queues (tag 1).
  Fanout
  /// Topic-based pattern matching on routing keys (tag 2).
  Topic
  /// Headers-based matching on message properties (tag 3).
  Headers
}

/// Convert a `ExchangeType` to its C-ABI tag value.
pub fn exchange_type_to_int(value: ExchangeType) -> Int {
  case value {
    Direct -> 0
    Fanout -> 1
    Topic -> 2
    Headers -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn exchange_type_from_int(tag: Int) -> Result(ExchangeType, Nil) {
  case tag {
    0 -> Ok(Direct)
    1 -> Ok(Fanout)
    2 -> Ok(Topic)
    3 -> Ok(Headers)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DeliveryMode
// ===========================================================================

/// AMQP message delivery/persistence mode.
/// 
/// Matches `DeliveryMode` in `AmqpABI.Types`.
pub type DeliveryMode {
  /// Non-persistent: message may be lost on broker restart (tag 0).
  NonPersistent
  /// Persistent: message survives broker restart (tag 1).
  Persistent
}

/// Convert a `DeliveryMode` to its C-ABI tag value.
pub fn delivery_mode_to_int(value: DeliveryMode) -> Int {
  case value {
    NonPersistent -> 0
    Persistent -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn delivery_mode_from_int(tag: Int) -> Result(DeliveryMode, Nil) {
  case tag {
    0 -> Ok(NonPersistent)
    1 -> Ok(Persistent)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorSeverity
// ===========================================================================

/// AMQP error severity levels.
/// 
/// Matches `ErrorSeverity` in `AmqpABI.Types`.
pub type ErrorSeverity {
  /// Channel-level error: only the affected channel is closed (tag 0).
  ChannelLevel
  /// Connection-level error: the entire connection is closed (tag 1).
  ConnectionLevel
}

/// Convert a `ErrorSeverity` to its C-ABI tag value.
pub fn error_severity_to_int(value: ErrorSeverity) -> Int {
  case value {
    ChannelLevel -> 0
    ConnectionLevel -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn error_severity_from_int(tag: Int) -> Result(ErrorSeverity, Nil) {
  case tag {
    0 -> Ok(ChannelLevel)
    1 -> Ok(ConnectionLevel)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ConnectionState
// ===========================================================================

/// AMQP connection state machine.
/// 
/// Matches `ConnectionState` in `AmqpABI.Types`.
pub type ConnectionState {
  /// Initial idle state, no connection yet (tag 0).
  ConnectionStateIdle
  /// Protocol negotiation in progress (tag 1).
  Negotiating
  /// Connection tuning parameters accepted (tag 2).
  TuningOk
  /// Connection is open and ready (tag 3).
  Open
  /// Connection close in progress (tag 4).
  Closing
}

/// Convert a `ConnectionState` to its C-ABI tag value.
pub fn connection_state_to_int(value: ConnectionState) -> Int {
  case value {
    ConnectionStateIdle -> 0
    Negotiating -> 1
    TuningOk -> 2
    Open -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn connection_state_from_int(tag: Int) -> Result(ConnectionState, Nil) {
  case tag {
    0 -> Ok(ConnectionStateIdle)
    1 -> Ok(Negotiating)
    2 -> Ok(TuningOk)
    3 -> Ok(Open)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn connection_state_can_transition_to(from: ConnectionState, to: ConnectionState) -> Bool {
  case from, to {
    ConnectionStateIdle, Negotiating -> True
    Negotiating, TuningOk -> True
    TuningOk, Open -> True
    Open, Closing -> True
    ConnectionStateIdle, Closing -> True
    Negotiating, Closing -> True
    TuningOk, Closing -> True
    Closing, Closing -> True
    _, _ -> False
  }
}

// ===========================================================================
// ChannelState
// ===========================================================================

/// AMQP channel state machine.
/// 
/// Matches `ChannelState` in `AmqpABI.Types`.
pub type ChannelState {
  /// Channel is closed (tag 0).
  Closed
  /// Channel open request sent (tag 1).
  Opening
  /// Channel is open and ready (tag 2).
  ChOpen
  /// Channel close in progress (tag 3).
  ChClosing
}

/// Convert a `ChannelState` to its C-ABI tag value.
pub fn channel_state_to_int(value: ChannelState) -> Int {
  case value {
    Closed -> 0
    Opening -> 1
    ChOpen -> 2
    ChClosing -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn channel_state_from_int(tag: Int) -> Result(ChannelState, Nil) {
  case tag {
    0 -> Ok(Closed)
    1 -> Ok(Opening)
    2 -> Ok(ChOpen)
    3 -> Ok(ChClosing)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn channel_state_can_transition_to(from: ChannelState, to: ChannelState) -> Bool {
  case from, to {
    Closed, Opening -> True
    Opening, ChOpen -> True
    Opening, Closed -> True
    ChOpen, ChClosing -> True
    ChClosing, Closed -> True
    _, _ -> False
  }
}

// ===========================================================================
// BrokerState
// ===========================================================================

/// AMQP broker lifecycle state machine.
/// 
/// Matches `BrokerState` in `AmqpABI.Types`.
pub type BrokerState {
  /// Broker is idle, not connected (tag 0).
  BrokerStateIdle
  /// Connected to broker (tag 1).
  Connected
  /// Channel is open on the broker connection (tag 2).
  ChannelOpen
  /// Actively consuming messages (tag 3).
  Consuming
  /// Actively publishing messages (tag 4).
  Publishing
  /// Disconnecting from broker (tag 5).
  Disconnecting
}

/// Convert a `BrokerState` to its C-ABI tag value.
pub fn broker_state_to_int(value: BrokerState) -> Int {
  case value {
    BrokerStateIdle -> 0
    Connected -> 1
    ChannelOpen -> 2
    Consuming -> 3
    Publishing -> 4
    Disconnecting -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn broker_state_from_int(tag: Int) -> Result(BrokerState, Nil) {
  case tag {
    0 -> Ok(BrokerStateIdle)
    1 -> Ok(Connected)
    2 -> Ok(ChannelOpen)
    3 -> Ok(Consuming)
    4 -> Ok(Publishing)
    5 -> Ok(Disconnecting)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn broker_state_can_transition_to(from: BrokerState, to: BrokerState) -> Bool {
  case from, to {
    BrokerStateIdle, Connected -> True
    Connected, ChannelOpen -> True
    ChannelOpen, Consuming -> True
    ChannelOpen, Publishing -> True
    Consuming, Disconnecting -> True
    Publishing, Disconnecting -> True
    BrokerStateIdle, Disconnecting -> True
    Connected, Disconnecting -> True
    ChannelOpen, Disconnecting -> True
    Disconnecting, Disconnecting -> True
    _, _ -> False
  }
}

