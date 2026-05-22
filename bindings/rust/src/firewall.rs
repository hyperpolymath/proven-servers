// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Firewall types for the proven-servers ABI.
//!
//! Formally verified firewall types.
//! Mirrors the Idris2 module `FirewallABI.Types`.
//!
//! - `Action` -- Firewall rule actions.
//! - `Protocol` -- Network protocols.
//! - `ChainType` -- Firewall chain types (netfilter).
//! - `RuleMatchType` -- Firewall rule match criteria.
//! - `ConnState` -- Connection tracking states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Action (tags 0-7)
// ===========================================================================

/// Firewall rule actions.
///
/// Matches `Action` in `FirewallABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Action {
    /// Accept (tag 0).
    Accept = 0,
    /// Drop (tag 1).
    Drop = 1,
    /// Reject (tag 2).
    Reject = 2,
    /// Log (tag 3).
    Log = 3,
    /// Redirect (tag 4).
    Redirect = 4,
    /// DNAT (tag 5).
    Dnat = 5,
    /// SNAT (tag 6).
    Snat = 6,
    /// Masquerade (tag 7).
    Masquerade = 7,
}

impl Action {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Accept),
            1 => Some(Self::Drop),
            2 => Some(Self::Reject),
            3 => Some(Self::Log),
            4 => Some(Self::Redirect),
            5 => Some(Self::Dnat),
            6 => Some(Self::Snat),
            7 => Some(Self::Masquerade),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this action allows traffic.
    pub fn is_permissive(self) -> bool {
        matches!(self, Self::Accept | Self::Redirect | Self::Dnat | Self::Snat | Self::Masquerade)
    }

    /// All variants of this type.
    pub const ALL: [Action; 8] = [
        Self::Accept, Self::Drop, Self::Reject, Self::Log, Self::Redirect, Self::Dnat, Self::Snat, Self::Masquerade,
    ];
}

impl fmt::Display for Action {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Protocol (tags 0-7)
// ===========================================================================

/// Network protocols.
///
/// Matches `Protocol` in `FirewallABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Protocol {
    /// TCP (tag 0).
    Tcp = 0,
    /// UDP (tag 1).
    Udp = 1,
    /// ICMP (tag 2).
    Icmp = 2,
    /// ICMPv6 (tag 3).
    Icmpv6 = 3,
    /// GRE (tag 4).
    Gre = 4,
    /// ESP (tag 5).
    Esp = 5,
    /// AH (tag 6).
    Ah = 6,
    /// Any (tag 7).
    Any = 7,
}

impl Protocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Tcp),
            1 => Some(Self::Udp),
            2 => Some(Self::Icmp),
            3 => Some(Self::Icmpv6),
            4 => Some(Self::Gre),
            5 => Some(Self::Esp),
            6 => Some(Self::Ah),
            7 => Some(Self::Any),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Protocol; 8] = [
        Self::Tcp, Self::Udp, Self::Icmp, Self::Icmpv6, Self::Gre, Self::Esp, Self::Ah, Self::Any,
    ];
}

impl fmt::Display for Protocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ChainType (tags 0-4)
// ===========================================================================

/// Firewall chain types (netfilter).
///
/// Matches `ChainType` in `FirewallABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChainType {
    /// Input (tag 0).
    Input = 0,
    /// Output (tag 1).
    Output = 1,
    /// Forward (tag 2).
    Forward = 2,
    /// PreRouting (tag 3).
    PreRouting = 3,
    /// PostRouting (tag 4).
    PostRouting = 4,
}

impl ChainType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Input),
            1 => Some(Self::Output),
            2 => Some(Self::Forward),
            3 => Some(Self::PreRouting),
            4 => Some(Self::PostRouting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ChainType; 5] = [
        Self::Input, Self::Output, Self::Forward, Self::PreRouting, Self::PostRouting,
    ];
}

impl fmt::Display for ChainType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RuleMatchType (tags 0-7)
// ===========================================================================

/// Firewall rule match criteria.
///
/// Matches `RuleMatchType` in `FirewallABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RuleMatchType {
    /// SourceIp (tag 0).
    SourceIp = 0,
    /// DestIp (tag 1).
    DestIp = 1,
    /// SourcePort (tag 2).
    SourcePort = 2,
    /// DestPort (tag 3).
    DestPort = 3,
    /// Protocol match (tag 4).
    MatchProto = 4,
    /// Interface (tag 5).
    Interface = 5,
    /// State (tag 6).
    State = 6,
    /// Mark (tag 7).
    Mark = 7,
}

impl RuleMatchType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SourceIp),
            1 => Some(Self::DestIp),
            2 => Some(Self::SourcePort),
            3 => Some(Self::DestPort),
            4 => Some(Self::MatchProto),
            5 => Some(Self::Interface),
            6 => Some(Self::State),
            7 => Some(Self::Mark),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RuleMatchType; 8] = [
        Self::SourceIp, Self::DestIp, Self::SourcePort, Self::DestPort, Self::MatchProto, Self::Interface, Self::State, Self::Mark,
    ];
}

impl fmt::Display for RuleMatchType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ConnState (tags 0-3)
// ===========================================================================

/// Connection tracking states.
///
/// Matches `ConnState` in `FirewallABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConnState {
    /// New (tag 0).
    New = 0,
    /// Established (tag 1).
    Established = 1,
    /// Related (tag 2).
    Related = 2,
    /// Invalid (tag 3).
    Invalid = 3,
}

impl ConnState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::New),
            1 => Some(Self::Established),
            2 => Some(Self::Related),
            3 => Some(Self::Invalid),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ConnState; 4] = [
        Self::New, Self::Established, Self::Related, Self::Invalid,
    ];
}

impl fmt::Display for ConnState {
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
    fn action_roundtrip() {
        for v in Action::ALL {
            let tag = v.to_tag();
            let decoded = Action::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Action::from_tag(8).is_none());
    }

    #[test]
    fn protocol_roundtrip() {
        for v in Protocol::ALL {
            let tag = v.to_tag();
            let decoded = Protocol::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Protocol::from_tag(8).is_none());
    }

    #[test]
    fn chain_type_roundtrip() {
        for v in ChainType::ALL {
            let tag = v.to_tag();
            let decoded = ChainType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ChainType::from_tag(5).is_none());
    }

    #[test]
    fn rule_match_type_roundtrip() {
        for v in RuleMatchType::ALL {
            let tag = v.to_tag();
            let decoded = RuleMatchType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RuleMatchType::from_tag(8).is_none());
    }

    #[test]
    fn conn_state_roundtrip() {
        for v in ConnState::ALL {
            let tag = v.to_tag();
            let decoded = ConnState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ConnState::from_tag(4).is_none());
    }

}
