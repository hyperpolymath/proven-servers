// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! mDNS types for the proven-servers ABI.
//!
//! Formally verified mDNS (multicast DNS, RFC 6762) types.
//! Mirrors the Idris2 module `MdnsABI.Types`.
//!
//! - `MdnsRecordType` -- mDNS record types.
//! - `QueryType` -- mDNS query types.
//! - `ConflictAction` -- mDNS conflict resolution actions.
//! - `ServiceFlag` -- mDNS service flags.
//! - `ResponderState` -- mDNS responder states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// mDNS Constants
// ===========================================================================

/// Standard mDNS port.
pub const MDNS_PORT: u16 = 5353;

// ===========================================================================
// MdnsRecordType (tags 0-4)
// ===========================================================================

/// mDNS record types.
///
/// Matches `MdnsRecordType` in `MdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MdnsRecordType {
    /// IPv4 address (tag 0).
    A = 0,
    /// IPv6 address (tag 1).
    Aaaa = 1,
    /// Pointer (tag 2).
    Ptr = 2,
    /// Service (tag 3).
    Srv = 3,
    /// Text (tag 4).
    Txt = 4,
}

impl MdnsRecordType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::A),
            1 => Some(Self::Aaaa),
            2 => Some(Self::Ptr),
            3 => Some(Self::Srv),
            4 => Some(Self::Txt),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MdnsRecordType; 5] = [
        Self::A, Self::Aaaa, Self::Ptr, Self::Srv, Self::Txt,
    ];
}

impl fmt::Display for MdnsRecordType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// QueryType (tags 0-2)
// ===========================================================================

/// mDNS query types.
///
/// Matches `QueryType` in `MdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum QueryType {
    /// Standard (tag 0).
    Standard = 0,
    /// OneShot (tag 1).
    OneShot = 1,
    /// Continuous (tag 2).
    Continuous = 2,
}

impl QueryType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Standard),
            1 => Some(Self::OneShot),
            2 => Some(Self::Continuous),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [QueryType; 3] = [
        Self::Standard, Self::OneShot, Self::Continuous,
    ];
}

impl fmt::Display for QueryType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ConflictAction (tags 0-2)
// ===========================================================================

/// mDNS conflict resolution actions.
///
/// Matches `ConflictAction` in `MdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConflictAction {
    /// Probe (tag 0).
    Probe = 0,
    /// Defend (tag 1).
    Defend = 1,
    /// Withdraw (tag 2).
    Withdraw = 2,
}

impl ConflictAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Probe),
            1 => Some(Self::Defend),
            2 => Some(Self::Withdraw),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ConflictAction; 3] = [
        Self::Probe, Self::Defend, Self::Withdraw,
    ];
}

impl fmt::Display for ConflictAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServiceFlag (tags 0-1)
// ===========================================================================

/// mDNS service flags.
///
/// Matches `ServiceFlag` in `MdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServiceFlag {
    /// Unique (tag 0).
    Unique = 0,
    /// Shared (tag 1).
    Shared = 1,
}

impl ServiceFlag {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unique),
            1 => Some(Self::Shared),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServiceFlag; 2] = [
        Self::Unique, Self::Shared,
    ];
}

impl fmt::Display for ServiceFlag {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResponderState (tags 0-4)
// ===========================================================================

/// mDNS responder states.
///
/// Matches `ResponderState` in `MdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponderState {
    /// Idle (tag 0).
    Idle = 0,
    /// Probing (tag 1).
    Probing = 1,
    /// Announcing (tag 2).
    Announcing = 2,
    /// Running (tag 3).
    Running = 3,
    /// ShuttingDown (tag 4).
    ShuttingDown = 4,
}

impl ResponderState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Probing),
            2 => Some(Self::Announcing),
            3 => Some(Self::Running),
            4 => Some(Self::ShuttingDown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResponderState; 5] = [
        Self::Idle, Self::Probing, Self::Announcing, Self::Running, Self::ShuttingDown,
    ];
}

impl fmt::Display for ResponderState {
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
    fn mdns_record_type_roundtrip() {
        for v in MdnsRecordType::ALL {
            let tag = v.to_tag();
            let decoded = MdnsRecordType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MdnsRecordType::from_tag(5).is_none());
    }

    #[test]
    fn query_type_roundtrip() {
        for v in QueryType::ALL {
            let tag = v.to_tag();
            let decoded = QueryType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(QueryType::from_tag(3).is_none());
    }

    #[test]
    fn conflict_action_roundtrip() {
        for v in ConflictAction::ALL {
            let tag = v.to_tag();
            let decoded = ConflictAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ConflictAction::from_tag(3).is_none());
    }

    #[test]
    fn service_flag_roundtrip() {
        for v in ServiceFlag::ALL {
            let tag = v.to_tag();
            let decoded = ServiceFlag::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServiceFlag::from_tag(2).is_none());
    }

    #[test]
    fn responder_state_roundtrip() {
        for v in ResponderState::ALL {
            let tag = v.to_tag();
            let decoded = ResponderState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResponderState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(MDNS_PORT, 5353);
    }

}
