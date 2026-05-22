// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! AMQP 0-9-1 protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `AmqpABI.Types` and its type definitions:
//! - `FrameType`       — AMQP frame types (4 constructors, tags 0-3)
//! - `MethodClass`     — AMQP method classes (7 constructors, tags 0-6)
//! - `ExchangeType`    — exchange routing types (4 constructors, tags 0-3)
//! - `DeliveryMode`    — message persistence modes (2 constructors, tags 0-1)
//! - `ErrorSeverity`   — error severity levels (2 constructors, tags 0-1)
//! - `ConnectionState` — connection state machine (5 constructors, tags 0-4)
//! - `ChannelState`    — channel state machine (4 constructors, tags 0-3)
//! - `BrokerState`     — broker lifecycle state machine (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// AMQP Constants
// ===========================================================================

/// Standard AMQP port (non-TLS).
pub const AMQP_PORT: u16 = 5672;

/// Standard AMQPS port (TLS).
pub const AMQPS_PORT: u16 = 5671;

// ===========================================================================
// FrameType (tags 0-3)
// ===========================================================================

/// AMQP 0-9-1 frame types.
///
/// Matches `FrameType` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FrameType {
    /// Method frame carrying AMQP commands (tag 0).
    Method = 0,
    /// Content header frame with message properties (tag 1).
    Header = 1,
    /// Content body frame with message payload (tag 2).
    Body = 2,
    /// Heartbeat frame for keepalive (tag 3).
    Heartbeat = 3,
}

impl FrameType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Method),
            1 => Some(Self::Header),
            2 => Some(Self::Body),
            3 => Some(Self::Heartbeat),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this frame type carries message content.
    pub fn is_content(self) -> bool {
        matches!(self, Self::Header | Self::Body)
    }
}

impl fmt::Display for FrameType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MethodClass (tags 0-6)
// ===========================================================================

/// AMQP 0-9-1 method classes.
///
/// Matches `MethodClass` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MethodClass {
    /// Connection-level methods (tag 0).
    Connection = 0,
    /// Channel-level methods (tag 1).
    Channel = 1,
    /// Exchange declaration and management (tag 2).
    Exchange = 2,
    /// Queue declaration and management (tag 3).
    Queue = 3,
    /// Basic publish/consume/ack operations (tag 4).
    Basic = 4,
    /// Transaction support (tag 5).
    Tx = 5,
    /// Publisher confirms (tag 6).
    Confirm = 6,
}

impl MethodClass {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connection),
            1 => Some(Self::Channel),
            2 => Some(Self::Exchange),
            3 => Some(Self::Queue),
            4 => Some(Self::Basic),
            5 => Some(Self::Tx),
            6 => Some(Self::Confirm),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this class operates at the connection level (vs channel level).
    pub fn is_connection_level(self) -> bool {
        matches!(self, Self::Connection)
    }
}

impl fmt::Display for MethodClass {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ExchangeType (tags 0-3)
// ===========================================================================

/// AMQP exchange routing types.
///
/// Matches `ExchangeType` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ExchangeType {
    /// Direct routing by exact routing key match (tag 0).
    Direct = 0,
    /// Fanout to all bound queues (tag 1).
    Fanout = 1,
    /// Topic-based pattern matching on routing keys (tag 2).
    Topic = 2,
    /// Headers-based matching on message properties (tag 3).
    Headers = 3,
}

impl ExchangeType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Direct),
            1 => Some(Self::Fanout),
            2 => Some(Self::Topic),
            3 => Some(Self::Headers),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this exchange type uses routing keys for message delivery.
    pub fn uses_routing_key(self) -> bool {
        matches!(self, Self::Direct | Self::Topic)
    }
}

impl fmt::Display for ExchangeType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Direct => "direct",
            Self::Fanout => "fanout",
            Self::Topic => "topic",
            Self::Headers => "headers",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// DeliveryMode (tags 0-1)
// ===========================================================================

/// AMQP message delivery/persistence mode.
///
/// Matches `DeliveryMode` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DeliveryMode {
    /// Non-persistent: message may be lost on broker restart (tag 0).
    NonPersistent = 0,
    /// Persistent: message survives broker restart (tag 1).
    Persistent = 1,
}

impl DeliveryMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NonPersistent),
            1 => Some(Self::Persistent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for DeliveryMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorSeverity (tags 0-1)
// ===========================================================================

/// AMQP error severity levels.
///
/// Matches `ErrorSeverity` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorSeverity {
    /// Channel-level error: only the affected channel is closed (tag 0).
    ChannelLevel = 0,
    /// Connection-level error: the entire connection is closed (tag 1).
    ConnectionLevel = 1,
}

impl ErrorSeverity {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ChannelLevel),
            1 => Some(Self::ConnectionLevel),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for ErrorSeverity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ConnectionState (tags 0-4)
// ===========================================================================

/// AMQP connection state machine.
///
/// Matches `ConnectionState` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConnectionState {
    /// Initial idle state, no connection yet (tag 0).
    Idle = 0,
    /// Protocol negotiation in progress (tag 1).
    Negotiating = 1,
    /// Connection tuning parameters accepted (tag 2).
    TuningOk = 2,
    /// Connection is open and ready (tag 3).
    Open = 3,
    /// Connection close in progress (tag 4).
    Closing = 4,
}

impl ConnectionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Negotiating),
            2 => Some(Self::TuningOk),
            3 => Some(Self::Open),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: ConnectionState) -> bool {
        matches!(
            (self, next),
            (Self::Idle, Self::Negotiating)
                | (Self::Negotiating, Self::TuningOk)
                | (Self::TuningOk, Self::Open)
                | (Self::Open, Self::Closing)
                | (_, Self::Closing) // Can initiate close from any active state
        )
    }
}

impl fmt::Display for ConnectionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ChannelState (tags 0-3)
// ===========================================================================

/// AMQP channel state machine.
///
/// Matches `ChannelState` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChannelState {
    /// Channel is closed (tag 0).
    Closed = 0,
    /// Channel open request sent (tag 1).
    Opening = 1,
    /// Channel is open and ready (tag 2).
    ChOpen = 2,
    /// Channel close in progress (tag 3).
    ChClosing = 3,
}

impl ChannelState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Closed),
            1 => Some(Self::Opening),
            2 => Some(Self::ChOpen),
            3 => Some(Self::ChClosing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: ChannelState) -> bool {
        matches!(
            (self, next),
            (Self::Closed, Self::Opening)
                | (Self::Opening, Self::ChOpen)
                | (Self::Opening, Self::Closed) // Open failed
                | (Self::ChOpen, Self::ChClosing)
                | (Self::ChClosing, Self::Closed)
        )
    }
}

impl fmt::Display for ChannelState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// BrokerState (tags 0-5)
// ===========================================================================

/// AMQP broker lifecycle state machine.
///
/// Matches `BrokerState` in `AmqpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BrokerState {
    /// Broker is idle, not connected (tag 0).
    Idle = 0,
    /// Connected to broker (tag 1).
    Connected = 1,
    /// Channel is open on the broker connection (tag 2).
    ChannelOpen = 2,
    /// Actively consuming messages (tag 3).
    Consuming = 3,
    /// Actively publishing messages (tag 4).
    Publishing = 4,
    /// Disconnecting from broker (tag 5).
    Disconnecting = 5,
}

impl BrokerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::ChannelOpen),
            3 => Some(Self::Consuming),
            4 => Some(Self::Publishing),
            5 => Some(Self::Disconnecting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: BrokerState) -> bool {
        matches!(
            (self, next),
            (Self::Idle, Self::Connected)
                | (Self::Connected, Self::ChannelOpen)
                | (Self::ChannelOpen, Self::Consuming)
                | (Self::ChannelOpen, Self::Publishing)
                | (Self::Consuming, Self::Disconnecting)
                | (Self::Publishing, Self::Disconnecting)
                | (_, Self::Disconnecting) // Can disconnect from any active state
        )
    }
}

impl fmt::Display for BrokerState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn frame_type_roundtrip() {
        for tag in 0u8..=3 {
            let ft = FrameType::from_tag(tag).expect("valid tag");
            assert_eq!(ft.to_tag(), tag);
        }
        assert!(FrameType::from_tag(4).is_none());
    }

    #[test]
    fn frame_type_content() {
        assert!(!FrameType::Method.is_content());
        assert!(FrameType::Header.is_content());
        assert!(FrameType::Body.is_content());
        assert!(!FrameType::Heartbeat.is_content());
    }

    #[test]
    fn method_class_roundtrip() {
        for tag in 0u8..=6 {
            let mc = MethodClass::from_tag(tag).expect("valid tag");
            assert_eq!(mc.to_tag(), tag);
        }
        assert!(MethodClass::from_tag(7).is_none());
    }

    #[test]
    fn exchange_type_roundtrip() {
        for tag in 0u8..=3 {
            let et = ExchangeType::from_tag(tag).expect("valid tag");
            assert_eq!(et.to_tag(), tag);
        }
        assert!(ExchangeType::from_tag(4).is_none());
    }

    #[test]
    fn exchange_type_routing_key() {
        assert!(ExchangeType::Direct.uses_routing_key());
        assert!(ExchangeType::Topic.uses_routing_key());
        assert!(!ExchangeType::Fanout.uses_routing_key());
        assert!(!ExchangeType::Headers.uses_routing_key());
    }

    #[test]
    fn delivery_mode_roundtrip() {
        for tag in 0u8..=1 {
            let dm = DeliveryMode::from_tag(tag).expect("valid tag");
            assert_eq!(dm.to_tag(), tag);
        }
        assert!(DeliveryMode::from_tag(2).is_none());
    }

    #[test]
    fn error_severity_roundtrip() {
        for tag in 0u8..=1 {
            let es = ErrorSeverity::from_tag(tag).expect("valid tag");
            assert_eq!(es.to_tag(), tag);
        }
        assert!(ErrorSeverity::from_tag(2).is_none());
    }

    #[test]
    fn connection_state_roundtrip() {
        for tag in 0u8..=4 {
            let cs = ConnectionState::from_tag(tag).expect("valid tag");
            assert_eq!(cs.to_tag(), tag);
        }
        assert!(ConnectionState::from_tag(5).is_none());
    }

    #[test]
    fn connection_state_transitions() {
        assert!(ConnectionState::Idle.can_transition_to(ConnectionState::Negotiating));
        assert!(ConnectionState::Negotiating.can_transition_to(ConnectionState::TuningOk));
        assert!(ConnectionState::TuningOk.can_transition_to(ConnectionState::Open));
        assert!(ConnectionState::Open.can_transition_to(ConnectionState::Closing));
        // Can always close
        assert!(ConnectionState::Idle.can_transition_to(ConnectionState::Closing));
        // Invalid
        assert!(!ConnectionState::Idle.can_transition_to(ConnectionState::Open));
    }

    #[test]
    fn channel_state_roundtrip() {
        for tag in 0u8..=3 {
            let cs = ChannelState::from_tag(tag).expect("valid tag");
            assert_eq!(cs.to_tag(), tag);
        }
        assert!(ChannelState::from_tag(4).is_none());
    }

    #[test]
    fn channel_state_transitions() {
        assert!(ChannelState::Closed.can_transition_to(ChannelState::Opening));
        assert!(ChannelState::Opening.can_transition_to(ChannelState::ChOpen));
        assert!(ChannelState::Opening.can_transition_to(ChannelState::Closed));
        assert!(ChannelState::ChOpen.can_transition_to(ChannelState::ChClosing));
        assert!(ChannelState::ChClosing.can_transition_to(ChannelState::Closed));
        assert!(!ChannelState::ChOpen.can_transition_to(ChannelState::Opening));
    }

    #[test]
    fn broker_state_roundtrip() {
        for tag in 0u8..=5 {
            let bs = BrokerState::from_tag(tag).expect("valid tag");
            assert_eq!(bs.to_tag(), tag);
        }
        assert!(BrokerState::from_tag(6).is_none());
    }

    #[test]
    fn broker_state_transitions() {
        assert!(BrokerState::Idle.can_transition_to(BrokerState::Connected));
        assert!(BrokerState::Connected.can_transition_to(BrokerState::ChannelOpen));
        assert!(BrokerState::ChannelOpen.can_transition_to(BrokerState::Consuming));
        assert!(BrokerState::ChannelOpen.can_transition_to(BrokerState::Publishing));
        assert!(BrokerState::Consuming.can_transition_to(BrokerState::Disconnecting));
        assert!(!BrokerState::Idle.can_transition_to(BrokerState::ChannelOpen));
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(AMQP_PORT, 5672);
        assert_eq!(AMQPS_PORT, 5671);
    }
}
