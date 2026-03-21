// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! BGP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `BgpABI.Types` and its type definitions:
//! - `BgpState`         — BGP FSM states (6 constructors, tags 0-5)
//! - `BgpEvent`         — BGP FSM events (19 constructors, tags 0-18)
//! - `MessageType`      — BGP message types (4 constructors, tags 0-3)
//! - `ErrorCode`        — BGP NOTIFICATION error codes (6 constructors, tags 0-5)
//! - `Origin`           — Path attribute origin types (3 constructors, tags 0-2)
//! - `AsPathSegmentType`— AS_PATH segment types (2 constructors, tags 0-1)
//! - `PathAttrType`     — Path attribute types (8 constructors, tags 0-7)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// BGP Constants
// ===========================================================================

/// Standard BGP port (RFC 4271).
pub const BGP_PORT: u16 = 179;

// ===========================================================================
// BgpState (tags 0-5)
// ===========================================================================

/// BGP finite state machine states (RFC 4271 Section 8.2.2).
///
/// Matches `BGPState` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BgpState {
    /// Idle — initial state, no connection (tag 0).
    Idle = 0,
    /// Connect — waiting for TCP connection (tag 1).
    Connect = 1,
    /// Active — retrying TCP connection (tag 2).
    Active = 2,
    /// OpenSent — OPEN message sent, awaiting OPEN (tag 3).
    OpenSent = 3,
    /// OpenConfirm — OPEN received, awaiting KEEPALIVE (tag 4).
    OpenConfirm = 4,
    /// Established — peers exchanging UPDATE messages (tag 5).
    Established = 5,
}

impl BgpState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connect),
            2 => Some(Self::Active),
            3 => Some(Self::OpenSent),
            4 => Some(Self::OpenConfirm),
            5 => Some(Self::Established),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether routes can be exchanged in this state.
    pub fn is_route_exchange(self) -> bool {
        matches!(self, Self::Established)
    }

    /// Whether a TCP connection exists in this state.
    pub fn has_connection(self) -> bool {
        matches!(self, Self::OpenSent | Self::OpenConfirm | Self::Established)
    }

    /// All supported states.
    pub const ALL: [BgpState; 6] = [
        Self::Idle, Self::Connect, Self::Active,
        Self::OpenSent, Self::OpenConfirm, Self::Established,
    ];
}

impl fmt::Display for BgpState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// BgpEvent (tags 0-18)
// ===========================================================================

/// BGP FSM events (RFC 4271 Section 8.1).
///
/// Matches `BGPEvent` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BgpEvent {
    /// ManualStart — administrative start (tag 0).
    ManualStart = 0,
    /// ManualStop — administrative stop (tag 1).
    ManualStop = 1,
    /// AutomaticStart — automatic restart (tag 2).
    AutomaticStart = 2,
    /// ConnectRetryTimer_Expires (tag 3).
    ConnectRetryTimerExpires = 3,
    /// HoldTimer_Expires (tag 4).
    HoldTimerExpires = 4,
    /// KeepaliveTimer_Expires (tag 5).
    KeepaliveTimerExpires = 5,
    /// DelayOpenTimer_Expires (tag 6).
    DelayOpenTimerExpires = 6,
    /// Tcp_CR_Valid — valid incoming TCP connection (tag 7).
    TcpConnectionValid = 7,
    /// Tcp_CR_Acked — outgoing TCP connection acknowledged (tag 8).
    TcpCrAcked = 8,
    /// TcpConnectionConfirmed (tag 9).
    TcpConnectionConfirmed = 9,
    /// TcpConnectionFails (tag 10).
    TcpConnectionFails = 10,
    /// BGPOpen received (tag 11).
    BgpOpenReceived = 11,
    /// BGPHeaderErr — bad header received (tag 12).
    BgpHeaderErr = 12,
    /// BGPOpenMsgErr — bad OPEN received (tag 13).
    BgpOpenMsgErr = 13,
    /// NotifMsgVerErr — NOTIFICATION version error (tag 14).
    NotifMsgVerErr = 14,
    /// NotifMsg — NOTIFICATION received (tag 15).
    NotifMsg = 15,
    /// KeepaliveMsg — KEEPALIVE received (tag 16).
    KeepaliveMsg = 16,
    /// UpdateMsg — UPDATE received (tag 17).
    UpdateMsg = 17,
    /// UpdateMsgErr — bad UPDATE received (tag 18).
    UpdateMsgErr = 18,
}

impl BgpEvent {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ManualStart),
            1 => Some(Self::ManualStop),
            2 => Some(Self::AutomaticStart),
            3 => Some(Self::ConnectRetryTimerExpires),
            4 => Some(Self::HoldTimerExpires),
            5 => Some(Self::KeepaliveTimerExpires),
            6 => Some(Self::DelayOpenTimerExpires),
            7 => Some(Self::TcpConnectionValid),
            8 => Some(Self::TcpCrAcked),
            9 => Some(Self::TcpConnectionConfirmed),
            10 => Some(Self::TcpConnectionFails),
            11 => Some(Self::BgpOpenReceived),
            12 => Some(Self::BgpHeaderErr),
            13 => Some(Self::BgpOpenMsgErr),
            14 => Some(Self::NotifMsgVerErr),
            15 => Some(Self::NotifMsg),
            16 => Some(Self::KeepaliveMsg),
            17 => Some(Self::UpdateMsg),
            18 => Some(Self::UpdateMsgErr),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this event is a timer expiry.
    pub fn is_timer_event(self) -> bool {
        matches!(
            self,
            Self::ConnectRetryTimerExpires
                | Self::HoldTimerExpires
                | Self::KeepaliveTimerExpires
                | Self::DelayOpenTimerExpires
        )
    }

    /// Whether this event indicates an error.
    pub fn is_error_event(self) -> bool {
        matches!(
            self,
            Self::TcpConnectionFails
                | Self::BgpHeaderErr
                | Self::BgpOpenMsgErr
                | Self::NotifMsgVerErr
                | Self::UpdateMsgErr
        )
    }

    /// All supported events.
    pub const ALL: [BgpEvent; 19] = [
        Self::ManualStart, Self::ManualStop, Self::AutomaticStart,
        Self::ConnectRetryTimerExpires, Self::HoldTimerExpires,
        Self::KeepaliveTimerExpires, Self::DelayOpenTimerExpires,
        Self::TcpConnectionValid, Self::TcpCrAcked, Self::TcpConnectionConfirmed,
        Self::TcpConnectionFails, Self::BgpOpenReceived, Self::BgpHeaderErr,
        Self::BgpOpenMsgErr, Self::NotifMsgVerErr, Self::NotifMsg,
        Self::KeepaliveMsg, Self::UpdateMsg, Self::UpdateMsgErr,
    ];
}

impl fmt::Display for BgpEvent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MessageType (tags 0-3)
// ===========================================================================

/// BGP message types (RFC 4271 Section 4).
///
/// Matches `MessageType` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// OPEN — establish BGP session (tag 0).
    Open = 0,
    /// UPDATE — advertise/withdraw routes (tag 1).
    Update = 1,
    /// NOTIFICATION — report error (tag 2).
    Notification = 2,
    /// KEEPALIVE — maintain session (tag 3).
    Keepalive = 3,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Open),
            1 => Some(Self::Update),
            2 => Some(Self::Notification),
            3 => Some(Self::Keepalive),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported message types.
    pub const ALL: [MessageType; 4] = [
        Self::Open, Self::Update, Self::Notification, Self::Keepalive,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-5)
// ===========================================================================

/// BGP NOTIFICATION error codes (RFC 4271 Section 4.5).
///
/// Matches `ErrorCode` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// Message Header Error (tag 0).
    MessageHeaderError = 0,
    /// OPEN Message Error (tag 1).
    OpenMessageError = 1,
    /// UPDATE Message Error (tag 2).
    UpdateMessageError = 2,
    /// Hold Timer Expired (tag 3).
    HoldTimerExpired = 3,
    /// Finite State Machine Error (tag 4).
    FsmError = 4,
    /// Cease (tag 5).
    Cease = 5,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::MessageHeaderError),
            1 => Some(Self::OpenMessageError),
            2 => Some(Self::UpdateMessageError),
            3 => Some(Self::HoldTimerExpired),
            4 => Some(Self::FsmError),
            5 => Some(Self::Cease),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error is fatal (always terminates session).
    pub fn is_fatal(self) -> bool {
        // All BGP NOTIFICATION errors are session-fatal per RFC 4271
        true
    }

    /// All supported error codes.
    pub const ALL: [ErrorCode; 6] = [
        Self::MessageHeaderError, Self::OpenMessageError, Self::UpdateMessageError,
        Self::HoldTimerExpired, Self::FsmError, Self::Cease,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for ErrorCode {}

// ===========================================================================
// Origin (tags 0-2)
// ===========================================================================

/// BGP ORIGIN path attribute values (RFC 4271 Section 4.3).
///
/// Matches `Origin` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Origin {
    /// IGP — route originated within the AS (tag 0).
    Igp = 0,
    /// EGP — route learned via EGP (tag 1).
    Egp = 1,
    /// Incomplete — origin unknown (tag 2).
    Incomplete = 2,
}

impl Origin {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Igp),
            1 => Some(Self::Egp),
            2 => Some(Self::Incomplete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported origin types.
    pub const ALL: [Origin; 3] = [Self::Igp, Self::Egp, Self::Incomplete];
}

impl fmt::Display for Origin {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AsPathSegmentType (tags 0-1)
// ===========================================================================

/// BGP AS_PATH segment types (RFC 4271 Section 4.3).
///
/// Matches `ASPathSegmentType` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AsPathSegmentType {
    /// AS_SET — unordered set of ASes (tag 0).
    AsSet = 0,
    /// AS_SEQUENCE — ordered sequence of ASes (tag 1).
    AsSequence = 1,
}

impl AsPathSegmentType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AsSet),
            1 => Some(Self::AsSequence),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported segment types.
    pub const ALL: [AsPathSegmentType; 2] = [Self::AsSet, Self::AsSequence];
}

impl fmt::Display for AsPathSegmentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PathAttrType (tags 0-7)
// ===========================================================================

/// BGP path attribute types (RFC 4271 Section 5).
///
/// Matches `PathAttrType` in `BgpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PathAttrType {
    /// ORIGIN (tag 0).
    Origin = 0,
    /// AS_PATH (tag 1).
    AsPath = 1,
    /// NEXT_HOP (tag 2).
    NextHop = 2,
    /// MULTI_EXIT_DISC (tag 3).
    Med = 3,
    /// LOCAL_PREF (tag 4).
    LocalPref = 4,
    /// ATOMIC_AGGREGATE (tag 5).
    AtomicAggr = 5,
    /// AGGREGATOR (tag 6).
    Aggregator = 6,
    /// Unknown/vendor-specific (tag 7).
    Unknown = 7,
}

impl PathAttrType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Origin),
            1 => Some(Self::AsPath),
            2 => Some(Self::NextHop),
            3 => Some(Self::Med),
            4 => Some(Self::LocalPref),
            5 => Some(Self::AtomicAggr),
            6 => Some(Self::Aggregator),
            7 => Some(Self::Unknown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this attribute is mandatory (well-known mandatory per RFC 4271).
    pub fn is_mandatory(self) -> bool {
        matches!(self, Self::Origin | Self::AsPath | Self::NextHop)
    }

    /// All supported path attribute types.
    pub const ALL: [PathAttrType; 8] = [
        Self::Origin, Self::AsPath, Self::NextHop, Self::Med,
        Self::LocalPref, Self::AtomicAggr, Self::Aggregator, Self::Unknown,
    ];
}

impl fmt::Display for PathAttrType {
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
    fn bgp_state_roundtrip() {
        for s in BgpState::ALL { assert_eq!(BgpState::from_tag(s.to_tag()), Some(s)); }
        assert!(BgpState::from_tag(6).is_none());
    }

    #[test]
    fn bgp_state_properties() {
        assert!(BgpState::Established.is_route_exchange());
        assert!(!BgpState::OpenSent.is_route_exchange());
        assert!(BgpState::OpenSent.has_connection());
        assert!(!BgpState::Idle.has_connection());
    }

    #[test]
    fn bgp_event_roundtrip() {
        for e in BgpEvent::ALL { assert_eq!(BgpEvent::from_tag(e.to_tag()), Some(e)); }
        assert!(BgpEvent::from_tag(19).is_none());
    }

    #[test]
    fn bgp_event_classification() {
        assert!(BgpEvent::HoldTimerExpires.is_timer_event());
        assert!(!BgpEvent::ManualStart.is_timer_event());
        assert!(BgpEvent::BgpHeaderErr.is_error_event());
        assert!(!BgpEvent::KeepaliveMsg.is_error_event());
    }

    #[test]
    fn message_type_roundtrip() {
        for mt in MessageType::ALL { assert_eq!(MessageType::from_tag(mt.to_tag()), Some(mt)); }
        assert!(MessageType::from_tag(4).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for ec in ErrorCode::ALL { assert_eq!(ErrorCode::from_tag(ec.to_tag()), Some(ec)); }
        assert!(ErrorCode::from_tag(6).is_none());
        assert!(ErrorCode::Cease.is_fatal());
    }

    #[test]
    fn origin_roundtrip() {
        for o in Origin::ALL { assert_eq!(Origin::from_tag(o.to_tag()), Some(o)); }
        assert!(Origin::from_tag(3).is_none());
    }

    #[test]
    fn as_path_segment_type_roundtrip() {
        for s in AsPathSegmentType::ALL { assert_eq!(AsPathSegmentType::from_tag(s.to_tag()), Some(s)); }
        assert!(AsPathSegmentType::from_tag(2).is_none());
    }

    #[test]
    fn path_attr_type_roundtrip() {
        for pa in PathAttrType::ALL { assert_eq!(PathAttrType::from_tag(pa.to_tag()), Some(pa)); }
        assert!(PathAttrType::from_tag(8).is_none());
    }

    #[test]
    fn path_attr_mandatory() {
        assert!(PathAttrType::Origin.is_mandatory());
        assert!(PathAttrType::AsPath.is_mandatory());
        assert!(PathAttrType::NextHop.is_mandatory());
        assert!(!PathAttrType::Med.is_mandatory());
        assert!(!PathAttrType::Unknown.is_mandatory());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(BGP_PORT, 179);
    }
}
