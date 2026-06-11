// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! SOCKS5 protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `SOCKSABI.Types` and its type definitions:
//! - `AuthMethod`  — Authentication methods (4 constructors, tags 0-3)
//! - `Command`     — SOCKS commands (3 constructors, tags 0-2)
//! - `AddressType` — Address types (3 constructors, tags 0-2)
//! - `Reply`       — SOCKS reply codes (9 constructors, tags 0-8)
//! - `State`       — Connection state machine (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SOCKS Constants
// ===========================================================================

/// Standard SOCKS5 port (RFC 1928).
pub const SOCKS_PORT: u16 = 1080;

// ===========================================================================
// AuthMethod (tags 0-3)
// ===========================================================================

/// SOCKS5 authentication methods (RFC 1928).
///
/// Matches `AuthMethod` in `SOCKSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthMethod {
    /// No authentication required (tag 0).
    NoAuth = 0,
    /// GSSAPI (tag 1).
    Gssapi = 1,
    /// Username/Password (RFC 1929) (tag 2).
    UsernamePassword = 2,
    /// No acceptable methods (tag 3).
    NoAcceptable = 3,
}

impl AuthMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoAuth),
            1 => Some(Self::Gssapi),
            2 => Some(Self::UsernamePassword),
            3 => Some(Self::NoAcceptable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported methods.
    pub const ALL: [AuthMethod; 4] = [
        Self::NoAuth, Self::Gssapi, Self::UsernamePassword, Self::NoAcceptable,
    ];
}

impl fmt::Display for AuthMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Command (tags 0-2)
// ===========================================================================

/// SOCKS5 commands (RFC 1928).
///
/// Matches `Command` in `SOCKSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// CONNECT — establish TCP connection (tag 0).
    Connect = 0,
    /// BIND — listen for incoming connection (tag 1).
    Bind = 1,
    /// UDP ASSOCIATE — set up UDP relay (tag 2).
    UdpAssociate = 2,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connect),
            1 => Some(Self::Bind),
            2 => Some(Self::UdpAssociate),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported commands.
    pub const ALL: [Command; 3] = [Self::Connect, Self::Bind, Self::UdpAssociate];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AddressType (tags 0-2)
// ===========================================================================

/// SOCKS5 address types (RFC 1928).
///
/// Matches `AddressType` in `SOCKSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AddressType {
    /// IPv4 address (tag 0).
    IPv4 = 0,
    /// Domain name (tag 1).
    DomainName = 1,
    /// IPv6 address (tag 2).
    IPv6 = 2,
}

impl AddressType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::IPv4),
            1 => Some(Self::DomainName),
            2 => Some(Self::IPv6),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported address types.
    pub const ALL: [AddressType; 3] = [Self::IPv4, Self::DomainName, Self::IPv6];
}

impl fmt::Display for AddressType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Reply (tags 0-8)
// ===========================================================================

/// SOCKS5 reply codes (RFC 1928).
///
/// Matches `Reply` in `SOCKSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Reply {
    /// Succeeded (tag 0).
    Succeeded = 0,
    /// General SOCKS server failure (tag 1).
    GeneralFailure = 1,
    /// Connection not allowed by ruleset (tag 2).
    NotAllowed = 2,
    /// Network unreachable (tag 3).
    NetworkUnreachable = 3,
    /// Host unreachable (tag 4).
    HostUnreachable = 4,
    /// Connection refused (tag 5).
    ConnectionRefused = 5,
    /// TTL expired (tag 6).
    TtlExpired = 6,
    /// Command not supported (tag 7).
    CommandNotSupported = 7,
    /// Address type not supported (tag 8).
    AddressTypeNotSupported = 8,
}

impl Reply {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Succeeded),
            1 => Some(Self::GeneralFailure),
            2 => Some(Self::NotAllowed),
            3 => Some(Self::NetworkUnreachable),
            4 => Some(Self::HostUnreachable),
            5 => Some(Self::ConnectionRefused),
            6 => Some(Self::TtlExpired),
            7 => Some(Self::CommandNotSupported),
            8 => Some(Self::AddressTypeNotSupported),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this reply indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Succeeded)
    }

    /// Whether this is a network-level error.
    pub fn is_network_error(self) -> bool {
        matches!(
            self,
            Self::NetworkUnreachable | Self::HostUnreachable | Self::ConnectionRefused
        )
    }

    /// All supported reply codes.
    pub const ALL: [Reply; 9] = [
        Self::Succeeded, Self::GeneralFailure, Self::NotAllowed,
        Self::NetworkUnreachable, Self::HostUnreachable, Self::ConnectionRefused,
        Self::TtlExpired, Self::CommandNotSupported, Self::AddressTypeNotSupported,
    ];
}

impl fmt::Display for Reply {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for Reply {}

// ===========================================================================
// State (tags 0-5)
// ===========================================================================

/// SOCKS5 connection state machine.
///
/// Matches `State` in `SOCKSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum State {
    /// Initial — awaiting method negotiation (tag 0).
    Initial = 0,
    /// Authenticating (tag 1).
    Authenticating = 1,
    /// Authenticated — awaiting command (tag 2).
    Authenticated = 2,
    /// Connecting to target (tag 3).
    Connecting = 3,
    /// Connection established — relaying data (tag 4).
    Established = 4,
    /// Connection closed (tag 5).
    Closed = 5,
}

impl State {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initial),
            1 => Some(Self::Authenticating),
            2 => Some(Self::Authenticated),
            3 => Some(Self::Connecting),
            4 => Some(Self::Established),
            5 => Some(Self::Closed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: State) -> bool {
        matches!(
            (self, next),
            (Self::Initial, Self::Authenticating)
                | (Self::Initial, Self::Authenticated) // NoAuth
                | (Self::Authenticating, Self::Authenticated)
                | (Self::Authenticated, Self::Connecting)
                | (Self::Connecting, Self::Established)
                | (Self::Connecting, Self::Closed) // connection failed
                | (Self::Established, Self::Closed)
        )
    }

    /// All supported states.
    pub const ALL: [State; 6] = [
        Self::Initial, Self::Authenticating, Self::Authenticated,
        Self::Connecting, Self::Established, Self::Closed,
    ];
}

impl fmt::Display for State {
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
    fn auth_method_roundtrip() {
        for am in AuthMethod::ALL {
            let tag = am.to_tag();
            let decoded = AuthMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, am);
        }
        assert!(AuthMethod::from_tag(4).is_none());
    }

    #[test]
    fn command_roundtrip() {
        for cmd in Command::ALL {
            let tag = cmd.to_tag();
            let decoded = Command::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cmd);
        }
        assert!(Command::from_tag(3).is_none());
    }

    #[test]
    fn address_type_roundtrip() {
        for at in AddressType::ALL {
            let tag = at.to_tag();
            let decoded = AddressType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, at);
        }
        assert!(AddressType::from_tag(3).is_none());
    }

    #[test]
    fn reply_roundtrip() {
        for r in Reply::ALL {
            let tag = r.to_tag();
            let decoded = Reply::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, r);
        }
        assert!(Reply::from_tag(9).is_none());
    }

    #[test]
    fn reply_classification() {
        assert!(Reply::Succeeded.is_success());
        assert!(!Reply::GeneralFailure.is_success());
        assert!(Reply::NetworkUnreachable.is_network_error());
        assert!(!Reply::NotAllowed.is_network_error());
    }

    #[test]
    fn state_roundtrip() {
        for s in State::ALL {
            let tag = s.to_tag();
            let decoded = State::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, s);
        }
        assert!(State::from_tag(6).is_none());
    }

    #[test]
    fn state_transitions() {
        assert!(State::Initial.can_transition_to(State::Authenticating));
        assert!(State::Initial.can_transition_to(State::Authenticated));
        assert!(State::Authenticated.can_transition_to(State::Connecting));
        assert!(State::Connecting.can_transition_to(State::Established));
        assert!(State::Established.can_transition_to(State::Closed));
        assert!(!State::Initial.can_transition_to(State::Established));
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SOCKS_PORT, 1080);
    }
}
