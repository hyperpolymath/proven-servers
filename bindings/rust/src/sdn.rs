// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! SDN types for the proven-servers ABI.
//!
//! Formally verified SDN (Software-Defined Networking) types.
//! Mirrors the Idris2 module `SdnABI.Types`.
//!
//! - `SdnMessageType` -- SDN/OpenFlow message types.
//! - `FlowAction` -- OpenFlow flow actions.
//! - `MatchField` -- OpenFlow match fields.
//! - `PortState` -- SDN port states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SDN Constants
// ===========================================================================

/// Standard OpenFlow port.
pub const SDN_PORT: u16 = 6653;

// ===========================================================================
// SdnMessageType (tags 0-11)
// ===========================================================================

/// SDN/OpenFlow message types.
///
/// Matches `SdnMessageType` in `SdnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SdnMessageType {
    /// Hello (tag 0).
    Hello = 0,
    /// Error (tag 1).
    Error = 1,
    /// EchoRequest (tag 2).
    EchoRequest = 2,
    /// EchoReply (tag 3).
    EchoReply = 3,
    /// FeaturesRequest (tag 4).
    FeaturesRequest = 4,
    /// FeaturesReply (tag 5).
    FeaturesReply = 5,
    /// FlowMod (tag 6).
    FlowMod = 6,
    /// PacketIn (tag 7).
    PacketIn = 7,
    /// PacketOut (tag 8).
    PacketOut = 8,
    /// PortStatus (tag 9).
    PortStatus = 9,
    /// BarrierRequest (tag 10).
    BarrierRequest = 10,
    /// BarrierReply (tag 11).
    BarrierReply = 11,
}

impl SdnMessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Hello),
            1 => Some(Self::Error),
            2 => Some(Self::EchoRequest),
            3 => Some(Self::EchoReply),
            4 => Some(Self::FeaturesRequest),
            5 => Some(Self::FeaturesReply),
            6 => Some(Self::FlowMod),
            7 => Some(Self::PacketIn),
            8 => Some(Self::PacketOut),
            9 => Some(Self::PortStatus),
            10 => Some(Self::BarrierRequest),
            11 => Some(Self::BarrierReply),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SdnMessageType; 12] = [
        Self::Hello, Self::Error, Self::EchoRequest, Self::EchoReply, Self::FeaturesRequest, Self::FeaturesReply, Self::FlowMod, Self::PacketIn, Self::PacketOut, Self::PortStatus, Self::BarrierRequest, Self::BarrierReply,
    ];
}

impl fmt::Display for SdnMessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FlowAction (tags 0-6)
// ===========================================================================

/// OpenFlow flow actions.
///
/// Matches `FlowAction` in `SdnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FlowAction {
    /// Output (tag 0).
    Output = 0,
    /// SetField (tag 1).
    SetField = 1,
    /// Drop (tag 2).
    Drop = 2,
    /// Push VLAN (tag 3).
    PushVlan = 3,
    /// Pop VLAN (tag 4).
    PopVlan = 4,
    /// SetQueue (tag 5).
    SetQueue = 5,
    /// Group (tag 6).
    Group = 6,
}

impl FlowAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Output),
            1 => Some(Self::SetField),
            2 => Some(Self::Drop),
            3 => Some(Self::PushVlan),
            4 => Some(Self::PopVlan),
            5 => Some(Self::SetQueue),
            6 => Some(Self::Group),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FlowAction; 7] = [
        Self::Output, Self::SetField, Self::Drop, Self::PushVlan, Self::PopVlan, Self::SetQueue, Self::Group,
    ];
}

impl fmt::Display for FlowAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MatchField (tags 0-10)
// ===========================================================================

/// OpenFlow match fields.
///
/// Matches `MatchField` in `SdnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MatchField {
    /// InPort (tag 0).
    InPort = 0,
    /// EthDst (tag 1).
    EthDst = 1,
    /// EthSrc (tag 2).
    EthSrc = 2,
    /// EthType (tag 3).
    EthType = 3,
    /// VLAN ID (tag 4).
    VlanId = 4,
    /// IP source (tag 5).
    IpSrc = 5,
    /// IP destination (tag 6).
    IpDst = 6,
    /// TCP source (tag 7).
    TcpSrc = 7,
    /// TCP destination (tag 8).
    TcpDst = 8,
    /// UDP source (tag 9).
    UdpSrc = 9,
    /// UDP destination (tag 10).
    UdpDst = 10,
}

impl MatchField {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::InPort),
            1 => Some(Self::EthDst),
            2 => Some(Self::EthSrc),
            3 => Some(Self::EthType),
            4 => Some(Self::VlanId),
            5 => Some(Self::IpSrc),
            6 => Some(Self::IpDst),
            7 => Some(Self::TcpSrc),
            8 => Some(Self::TcpDst),
            9 => Some(Self::UdpSrc),
            10 => Some(Self::UdpDst),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MatchField; 11] = [
        Self::InPort, Self::EthDst, Self::EthSrc, Self::EthType, Self::VlanId, Self::IpSrc, Self::IpDst, Self::TcpSrc, Self::TcpDst, Self::UdpSrc, Self::UdpDst,
    ];
}

impl fmt::Display for MatchField {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PortState (tags 0-2)
// ===========================================================================

/// SDN port states.
///
/// Matches `PortState` in `SdnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PortState {
    /// Up (tag 0).
    Up = 0,
    /// Down (tag 1).
    Down = 1,
    /// Blocked (tag 2).
    Blocked = 2,
}

impl PortState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Up),
            1 => Some(Self::Down),
            2 => Some(Self::Blocked),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PortState; 3] = [
        Self::Up, Self::Down, Self::Blocked,
    ];
}

impl fmt::Display for PortState {
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
    fn sdn_message_type_roundtrip() {
        for v in SdnMessageType::ALL {
            let tag = v.to_tag();
            let decoded = SdnMessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SdnMessageType::from_tag(12).is_none());
    }

    #[test]
    fn flow_action_roundtrip() {
        for v in FlowAction::ALL {
            let tag = v.to_tag();
            let decoded = FlowAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FlowAction::from_tag(7).is_none());
    }

    #[test]
    fn match_field_roundtrip() {
        for v in MatchField::ALL {
            let tag = v.to_tag();
            let decoded = MatchField::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MatchField::from_tag(11).is_none());
    }

    #[test]
    fn port_state_roundtrip() {
        for v in PortState::ALL {
            let tag = v.to_tag();
            let decoded = PortState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PortState::from_tag(3).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SDN_PORT, 6653);
    }

}
