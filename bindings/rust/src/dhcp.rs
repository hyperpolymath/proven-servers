// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! DHCP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `DhcpABI.Types` and its type definitions:
//! - `MessageType`    — DHCP message types (8 constructors, tags 0-7)
//! - `OptionCode`     — DHCP option codes (8 constructors, tags 0-7)
//! - `HardwareType`   — Hardware address types (4 constructors, tags 0-3)
//! - `DhcpState`      — Server state machine (6 constructors, tags 0-5)
//! - `LeaseState`     — Lease lifecycle (6 constructors, tags 0-5)
//! - `RelaySubOption` — Relay agent sub-options (2 constructors, tags 0-1)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// DHCP Constants
// ===========================================================================

/// Standard DHCP server port (RFC 2131).
pub const DHCP_SERVER_PORT: u16 = 67;

/// Standard DHCP client port (RFC 2131).
pub const DHCP_CLIENT_PORT: u16 = 68;

// ===========================================================================
// MessageType (tags 0-7)
// ===========================================================================

/// DHCP message types (RFC 2131 Section 3.1).
///
/// Matches `MessageType` in `DhcpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// DHCPDISCOVER — client broadcasts to find servers (tag 0).
    Discover = 0,
    /// DHCPOFFER — server response with address offer (tag 1).
    Offer = 1,
    /// DHCPREQUEST — client requests offered address (tag 2).
    Request = 2,
    /// DHCPACK — server confirms address assignment (tag 3).
    Ack = 3,
    /// DHCPNAK — server rejects request (tag 4).
    Nak = 4,
    /// DHCPRELEASE — client releases address (tag 5).
    Release = 5,
    /// DHCPINFORM — client requests config without address (tag 6).
    Inform = 6,
    /// DHCPDECLINE — client rejects offered address (tag 7).
    Decline = 7,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Discover),
            1 => Some(Self::Offer),
            2 => Some(Self::Request),
            3 => Some(Self::Ack),
            4 => Some(Self::Nak),
            5 => Some(Self::Release),
            6 => Some(Self::Inform),
            7 => Some(Self::Decline),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this message is sent by a client.
    pub fn is_client_message(self) -> bool {
        matches!(
            self,
            Self::Discover | Self::Request | Self::Release
                | Self::Inform | Self::Decline
        )
    }

    /// Whether this message is sent by a server.
    pub fn is_server_message(self) -> bool {
        matches!(self, Self::Offer | Self::Ack | Self::Nak)
    }

    /// All supported message types.
    pub const ALL: [MessageType; 8] = [
        Self::Discover, Self::Offer, Self::Request, Self::Ack,
        Self::Nak, Self::Release, Self::Inform, Self::Decline,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OptionCode (tags 0-7)
// ===========================================================================

/// DHCP option codes (RFC 2132).
///
/// Matches `OptionCode` in `DhcpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OptionCode {
    /// Subnet Mask (option 1) (tag 0).
    SubnetMask = 0,
    /// Router (option 3) (tag 1).
    Router = 1,
    /// DNS Server (option 6) (tag 2).
    Dns = 2,
    /// Domain Name (option 15) (tag 3).
    DomainName = 3,
    /// IP Address Lease Time (option 51) (tag 4).
    LeaseTime = 4,
    /// Server Identifier (option 54) (tag 5).
    ServerId = 5,
    /// Requested IP Address (option 50) (tag 6).
    RequestedIp = 6,
    /// DHCP Message Type (option 53) (tag 7).
    MsgType = 7,
}

impl OptionCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SubnetMask),
            1 => Some(Self::Router),
            2 => Some(Self::Dns),
            3 => Some(Self::DomainName),
            4 => Some(Self::LeaseTime),
            5 => Some(Self::ServerId),
            6 => Some(Self::RequestedIp),
            7 => Some(Self::MsgType),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported option codes.
    pub const ALL: [OptionCode; 8] = [
        Self::SubnetMask, Self::Router, Self::Dns, Self::DomainName,
        Self::LeaseTime, Self::ServerId, Self::RequestedIp, Self::MsgType,
    ];
}

impl fmt::Display for OptionCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HardwareType (tags 0-3)
// ===========================================================================

/// Hardware address types (RFC 1700).
///
/// Matches `HardwareType` in `DhcpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HardwareType {
    /// Ethernet (10Mb) (tag 0).
    Ethernet = 0,
    /// IEEE 802 Networks (tag 1).
    Ieee802 = 1,
    /// ARCNET (tag 2).
    Arcnet = 2,
    /// Frame Relay (tag 3).
    FrameRelay = 3,
}

impl HardwareType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ethernet),
            1 => Some(Self::Ieee802),
            2 => Some(Self::Arcnet),
            3 => Some(Self::FrameRelay),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The hardware address length in bytes for this type.
    pub fn addr_len(self) -> u8 {
        match self {
            Self::Ethernet | Self::Ieee802 => 6,
            Self::Arcnet => 1,
            Self::FrameRelay => 4,
        }
    }

    /// All supported hardware types.
    pub const ALL: [HardwareType; 4] = [
        Self::Ethernet, Self::Ieee802, Self::Arcnet, Self::FrameRelay,
    ];
}

impl fmt::Display for HardwareType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DhcpState (tags 0-5)
// ===========================================================================

/// DHCP server state machine.
///
/// Matches `DhcpState` in `DhcpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DhcpState {
    /// Idle — awaiting DHCPDISCOVER (tag 0).
    Idle = 0,
    /// DHCPDISCOVER received (tag 1).
    DiscoverReceived = 1,
    /// DHCPOFFER sent (tag 2).
    OfferSent = 2,
    /// DHCPREQUEST received (tag 3).
    RequestReceived = 3,
    /// DHCPACK sent (tag 4).
    AckSent = 4,
    /// DHCPNAK sent (tag 5).
    NakSent = 5,
}

impl DhcpState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::DiscoverReceived),
            2 => Some(Self::OfferSent),
            3 => Some(Self::RequestReceived),
            4 => Some(Self::AckSent),
            5 => Some(Self::NakSent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: DhcpState) -> bool {
        matches!(
            (self, next),
            (Self::Idle, Self::DiscoverReceived)
                | (Self::DiscoverReceived, Self::OfferSent)
                | (Self::OfferSent, Self::RequestReceived)
                | (Self::RequestReceived, Self::AckSent)
                | (Self::RequestReceived, Self::NakSent)
                | (Self::AckSent, Self::Idle)
                | (Self::NakSent, Self::Idle)
        )
    }

    /// All supported states.
    pub const ALL: [DhcpState; 6] = [
        Self::Idle, Self::DiscoverReceived, Self::OfferSent,
        Self::RequestReceived, Self::AckSent, Self::NakSent,
    ];
}

impl fmt::Display for DhcpState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LeaseState (tags 0-5)
// ===========================================================================

/// DHCP lease lifecycle states.
///
/// Matches `LeaseState` in `DhcpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LeaseState {
    /// Available in pool (tag 0).
    Available = 0,
    /// Offered to a client (tag 1).
    Offered = 1,
    /// Bound — client actively using (tag 2).
    Bound = 2,
    /// Renewing — client requesting lease extension (tag 3).
    Renewing = 3,
    /// Rebinding — broadcast renewal attempt (tag 4).
    Rebinding = 4,
    /// Expired — lease no longer valid (tag 5).
    Expired = 5,
}

impl LeaseState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Available),
            1 => Some(Self::Offered),
            2 => Some(Self::Bound),
            3 => Some(Self::Renewing),
            4 => Some(Self::Rebinding),
            5 => Some(Self::Expired),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this state means the address is in use.
    pub fn is_active(self) -> bool {
        matches!(self, Self::Bound | Self::Renewing | Self::Rebinding)
    }

    /// All supported lease states.
    pub const ALL: [LeaseState; 6] = [
        Self::Available, Self::Offered, Self::Bound,
        Self::Renewing, Self::Rebinding, Self::Expired,
    ];
}

impl fmt::Display for LeaseState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RelaySubOption (tags 0-1)
// ===========================================================================

/// DHCP relay agent sub-options (RFC 3046).
///
/// Matches `RelaySubOption` in `DhcpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RelaySubOption {
    /// Circuit ID — identifies the relay agent port (tag 0).
    CircuitId = 0,
    /// Remote ID — identifies the remote host (tag 1).
    RemoteId = 1,
}

impl RelaySubOption {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::CircuitId),
            1 => Some(Self::RemoteId),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for RelaySubOption {
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
    fn message_type_roundtrip() {
        for mt in MessageType::ALL {
            let tag = mt.to_tag();
            let decoded = MessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, mt);
        }
        assert!(MessageType::from_tag(8).is_none());
    }

    #[test]
    fn message_type_direction() {
        assert!(MessageType::Discover.is_client_message());
        assert!(MessageType::Offer.is_server_message());
        assert!(!MessageType::Discover.is_server_message());
    }

    #[test]
    fn option_code_roundtrip() {
        for oc in OptionCode::ALL {
            let tag = oc.to_tag();
            let decoded = OptionCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, oc);
        }
        assert!(OptionCode::from_tag(8).is_none());
    }

    #[test]
    fn hardware_type_roundtrip() {
        for hw in HardwareType::ALL {
            let tag = hw.to_tag();
            let decoded = HardwareType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, hw);
        }
        assert!(HardwareType::from_tag(4).is_none());
    }

    #[test]
    fn hardware_type_addr_len() {
        assert_eq!(HardwareType::Ethernet.addr_len(), 6);
        assert_eq!(HardwareType::Arcnet.addr_len(), 1);
    }

    #[test]
    fn dhcp_state_roundtrip() {
        for ds in DhcpState::ALL {
            let tag = ds.to_tag();
            let decoded = DhcpState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ds);
        }
        assert!(DhcpState::from_tag(6).is_none());
    }

    #[test]
    fn dhcp_state_transitions() {
        assert!(DhcpState::Idle.can_transition_to(DhcpState::DiscoverReceived));
        assert!(DhcpState::RequestReceived.can_transition_to(DhcpState::AckSent));
        assert!(DhcpState::RequestReceived.can_transition_to(DhcpState::NakSent));
        assert!(!DhcpState::Idle.can_transition_to(DhcpState::AckSent));
    }

    #[test]
    fn lease_state_roundtrip() {
        for ls in LeaseState::ALL {
            let tag = ls.to_tag();
            let decoded = LeaseState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ls);
        }
        assert!(LeaseState::from_tag(6).is_none());
    }

    #[test]
    fn lease_state_active() {
        assert!(!LeaseState::Available.is_active());
        assert!(LeaseState::Bound.is_active());
        assert!(LeaseState::Renewing.is_active());
        assert!(!LeaseState::Expired.is_active());
    }

    #[test]
    fn relay_sub_option_roundtrip() {
        assert_eq!(RelaySubOption::from_tag(0), Some(RelaySubOption::CircuitId));
        assert_eq!(RelaySubOption::from_tag(1), Some(RelaySubOption::RemoteId));
        assert!(RelaySubOption::from_tag(2).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(DHCP_SERVER_PORT, 67);
        assert_eq!(DHCP_CLIENT_PORT, 68);
    }
}
