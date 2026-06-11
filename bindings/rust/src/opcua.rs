// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! OPC UA (OPC Unified Architecture) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `OPCUAABI.Types` and its type definitions:
//! - `ServiceType`   — OPC UA service types (11 constructors, tags 0-10)
//! - `NodeClass`     — OPC UA node classes (8 constructors, tags 0-7)
//! - `StatusCode`    — OPC UA status codes (12 constructors, tags 0-11)
//! - `SecurityMode`  — Message security modes (3 constructors, tags 0-2)
//! - `SessionState`  — OPC UA session lifecycle (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// OPC UA Constants
// ===========================================================================

/// Standard OPC UA TCP port.
pub const OPCUA_PORT: u16 = 4840;

/// Standard OPC UA TCP/TLS port.
pub const OPCUA_TLS_PORT: u16 = 4843;

// ===========================================================================
// ServiceType (tags 0-10)
// ===========================================================================

/// OPC UA service types (OPC 10000 Part 4).
///
/// Matches `ServiceType` in `OPCUAABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServiceType {
    /// Read attribute values from nodes (tag 0).
    Read = 0,
    /// Write attribute values to nodes (tag 1).
    Write = 1,
    /// Browse the address space (tag 2).
    Browse = 2,
    /// Create a monitored item subscription (tag 3).
    Subscribe = 3,
    /// Publish subscription notifications (tag 4).
    Publish = 4,
    /// Call a method on a node (tag 5).
    Call = 5,
    /// Create a new session (tag 6).
    CreateSession = 6,
    /// Activate an existing session (tag 7).
    ActivateSession = 7,
    /// Close a session (tag 8).
    CloseSession = 8,
    /// Create a new subscription (tag 9).
    CreateSubscription = 9,
    /// Delete a subscription (tag 10).
    DeleteSubscription = 10,
}

impl ServiceType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Read),
            1 => Some(Self::Write),
            2 => Some(Self::Browse),
            3 => Some(Self::Subscribe),
            4 => Some(Self::Publish),
            5 => Some(Self::Call),
            6 => Some(Self::CreateSession),
            7 => Some(Self::ActivateSession),
            8 => Some(Self::CloseSession),
            9 => Some(Self::CreateSubscription),
            10 => Some(Self::DeleteSubscription),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this service modifies server state.
    pub fn is_write(self) -> bool {
        matches!(self, Self::Write | Self::Call)
    }

    /// Whether this service is a session management operation.
    pub fn is_session_management(self) -> bool {
        matches!(
            self,
            Self::CreateSession | Self::ActivateSession | Self::CloseSession
        )
    }

    /// Whether this service relates to subscriptions.
    pub fn is_subscription_related(self) -> bool {
        matches!(
            self,
            Self::Subscribe | Self::Publish | Self::CreateSubscription | Self::DeleteSubscription
        )
    }

    /// All supported service types.
    pub const ALL: [ServiceType; 11] = [
        Self::Read, Self::Write, Self::Browse, Self::Subscribe, Self::Publish,
        Self::Call, Self::CreateSession, Self::ActivateSession, Self::CloseSession,
        Self::CreateSubscription, Self::DeleteSubscription,
    ];
}

impl fmt::Display for ServiceType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NodeClass (tags 0-7)
// ===========================================================================

/// OPC UA node classes (OPC 10000 Part 3).
///
/// Matches `NodeClass` in `OPCUAABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NodeClass {
    /// Object instance node (tag 0).
    Object = 0,
    /// Variable node holding a value (tag 1).
    Variable = 1,
    /// Method node that can be called (tag 2).
    Method = 2,
    /// Object type definition (tag 3).
    ObjectType = 3,
    /// Variable type definition (tag 4).
    VariableType = 4,
    /// Reference type definition (tag 5).
    ReferenceType = 5,
    /// Data type definition (tag 6).
    DataType = 6,
    /// View node for address space subsets (tag 7).
    View = 7,
}

impl NodeClass {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Object),
            1 => Some(Self::Variable),
            2 => Some(Self::Method),
            3 => Some(Self::ObjectType),
            4 => Some(Self::VariableType),
            5 => Some(Self::ReferenceType),
            6 => Some(Self::DataType),
            7 => Some(Self::View),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this node class is an instance node (not a type definition).
    pub fn is_instance(self) -> bool {
        matches!(self, Self::Object | Self::Variable | Self::Method | Self::View)
    }

    /// Whether this node class is a type definition.
    pub fn is_type(self) -> bool {
        matches!(
            self,
            Self::ObjectType | Self::VariableType | Self::ReferenceType | Self::DataType
        )
    }

    /// All supported node classes.
    pub const ALL: [NodeClass; 8] = [
        Self::Object, Self::Variable, Self::Method, Self::ObjectType,
        Self::VariableType, Self::ReferenceType, Self::DataType, Self::View,
    ];
}

impl fmt::Display for NodeClass {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StatusCode (tags 0-11)
// ===========================================================================

/// OPC UA status codes (OPC 10000 Part 4).
///
/// Matches `StatusCode` in `OPCUAABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StatusCode {
    /// Good — operation succeeded (tag 0).
    Good = 0,
    /// Uncertain — result is not fully reliable (tag 1).
    Uncertain = 1,
    /// Bad — generic failure (tag 2).
    Bad = 2,
    /// NodeId does not exist (tag 3).
    BadNodeIdUnknown = 3,
    /// Attribute ID is invalid for this node (tag 4).
    BadAttributeIdInvalid = 4,
    /// Attribute is not readable (tag 5).
    BadNotReadable = 5,
    /// Attribute is not writable (tag 6).
    BadNotWritable = 6,
    /// Value is out of range (tag 7).
    BadOutOfRange = 7,
    /// Data type mismatch (tag 8).
    BadTypeMismatch = 8,
    /// Session ID is invalid (tag 9).
    BadSessionIdInvalid = 9,
    /// Subscription ID is invalid (tag 10).
    BadSubscriptionIdInvalid = 10,
    /// Operation timed out (tag 11).
    BadTimeout = 11,
}

impl StatusCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Good),
            1 => Some(Self::Uncertain),
            2 => Some(Self::Bad),
            3 => Some(Self::BadNodeIdUnknown),
            4 => Some(Self::BadAttributeIdInvalid),
            5 => Some(Self::BadNotReadable),
            6 => Some(Self::BadNotWritable),
            7 => Some(Self::BadOutOfRange),
            8 => Some(Self::BadTypeMismatch),
            9 => Some(Self::BadSessionIdInvalid),
            10 => Some(Self::BadSubscriptionIdInvalid),
            11 => Some(Self::BadTimeout),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this status code indicates success.
    pub fn is_good(self) -> bool {
        matches!(self, Self::Good)
    }

    /// Whether this status code indicates a definite failure.
    pub fn is_bad(self) -> bool {
        !matches!(self, Self::Good | Self::Uncertain)
    }

    /// Whether this status code relates to security/session issues.
    pub fn is_security_related(self) -> bool {
        matches!(self, Self::BadSessionIdInvalid)
    }

    /// All supported status codes.
    pub const ALL: [StatusCode; 12] = [
        Self::Good, Self::Uncertain, Self::Bad, Self::BadNodeIdUnknown,
        Self::BadAttributeIdInvalid, Self::BadNotReadable, Self::BadNotWritable,
        Self::BadOutOfRange, Self::BadTypeMismatch, Self::BadSessionIdInvalid,
        Self::BadSubscriptionIdInvalid, Self::BadTimeout,
    ];
}

impl fmt::Display for StatusCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for StatusCode {}

// ===========================================================================
// SecurityMode (tags 0-2)
// ===========================================================================

/// OPC UA message security modes (OPC 10000 Part 4).
///
/// Matches `SecurityMode` in `OPCUAABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum SecurityMode {
    /// No security (tag 0).
    None = 0,
    /// Messages are signed but not encrypted (tag 1).
    Sign = 1,
    /// Messages are signed and encrypted (tag 2).
    SignAndEncrypt = 2,
}

impl SecurityMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::Sign),
            2 => Some(Self::SignAndEncrypt),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether messages are signed.
    pub fn is_signed(self) -> bool {
        matches!(self, Self::Sign | Self::SignAndEncrypt)
    }

    /// Whether messages are encrypted.
    pub fn is_encrypted(self) -> bool {
        matches!(self, Self::SignAndEncrypt)
    }
}

impl fmt::Display for SecurityMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-5)
// ===========================================================================

/// OPC UA session lifecycle states for the FFI layer.
///
/// Matches `SessionState` in `OPCUAABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// No session (tag 0).
    Idle = 0,
    /// Secure channel established (tag 1).
    Connected = 1,
    /// Session created, awaiting activation (tag 2).
    Created = 2,
    /// Session activated, ready for service requests (tag 3).
    Activated = 3,
    /// Subscription active, monitoring nodes (tag 4).
    Monitoring = 4,
    /// Session closing (tag 5).
    Closing = 5,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::Created),
            3 => Some(Self::Activated),
            4 => Some(Self::Monitoring),
            5 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the session can accept service requests.
    pub fn can_service(self) -> bool {
        matches!(self, Self::Activated | Self::Monitoring)
    }

    /// Whether the session is in a transient state.
    pub fn is_transient(self) -> bool {
        matches!(self, Self::Connected | Self::Created | Self::Closing)
    }
}

impl fmt::Display for SessionState {
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
    fn service_type_roundtrip() {
        for st in ServiceType::ALL {
            let tag = st.to_tag();
            let decoded = ServiceType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, st);
        }
        assert!(ServiceType::from_tag(11).is_none());
    }

    #[test]
    fn service_type_classification() {
        assert!(ServiceType::Write.is_write());
        assert!(ServiceType::Call.is_write());
        assert!(!ServiceType::Read.is_write());
        assert!(ServiceType::CreateSession.is_session_management());
        assert!(!ServiceType::Read.is_session_management());
        assert!(ServiceType::Subscribe.is_subscription_related());
        assert!(ServiceType::Publish.is_subscription_related());
    }

    #[test]
    fn node_class_roundtrip() {
        for nc in NodeClass::ALL {
            let tag = nc.to_tag();
            let decoded = NodeClass::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, nc);
        }
        assert!(NodeClass::from_tag(8).is_none());
    }

    #[test]
    fn node_class_classification() {
        assert!(NodeClass::Object.is_instance());
        assert!(NodeClass::Variable.is_instance());
        assert!(!NodeClass::ObjectType.is_instance());
        assert!(NodeClass::ObjectType.is_type());
        assert!(NodeClass::DataType.is_type());
        assert!(!NodeClass::Object.is_type());
    }

    #[test]
    fn status_code_roundtrip() {
        for sc in StatusCode::ALL {
            let tag = sc.to_tag();
            let decoded = StatusCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, sc);
        }
        assert!(StatusCode::from_tag(12).is_none());
    }

    #[test]
    fn status_code_classification() {
        assert!(StatusCode::Good.is_good());
        assert!(!StatusCode::Uncertain.is_good());
        assert!(!StatusCode::Good.is_bad());
        assert!(!StatusCode::Uncertain.is_bad());
        assert!(StatusCode::Bad.is_bad());
        assert!(StatusCode::BadTimeout.is_bad());
    }

    #[test]
    fn security_mode_roundtrip() {
        for tag in 0u8..=2 {
            let sm = SecurityMode::from_tag(tag).expect("valid tag");
            assert_eq!(sm.to_tag(), tag);
        }
        assert!(SecurityMode::from_tag(3).is_none());
    }

    #[test]
    fn security_mode_ordering() {
        assert!(SecurityMode::None < SecurityMode::Sign);
        assert!(SecurityMode::Sign < SecurityMode::SignAndEncrypt);
    }

    #[test]
    fn security_mode_properties() {
        assert!(!SecurityMode::None.is_signed());
        assert!(SecurityMode::Sign.is_signed());
        assert!(SecurityMode::SignAndEncrypt.is_signed());
        assert!(!SecurityMode::Sign.is_encrypted());
        assert!(SecurityMode::SignAndEncrypt.is_encrypted());
    }

    #[test]
    fn session_state_roundtrip() {
        for tag in 0u8..=5 {
            let ss = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(ss.to_tag(), tag);
        }
        assert!(SessionState::from_tag(6).is_none());
    }

    #[test]
    fn session_state_service_capability() {
        assert!(!SessionState::Idle.can_service());
        assert!(!SessionState::Connected.can_service());
        assert!(!SessionState::Created.can_service());
        assert!(SessionState::Activated.can_service());
        assert!(SessionState::Monitoring.can_service());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(OPCUA_PORT, 4840);
        assert_eq!(OPCUA_TLS_PORT, 4843);
    }
}
