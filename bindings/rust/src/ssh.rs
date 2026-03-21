// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! SSH Bastion protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `SshBastionABI.Types` and its type definitions:
//! - `SshMessageType`    — SSH message types (8 constructors, tags 0-7)
//! - `AuthMethod`        — authentication methods (4 constructors, tags 0-3)
//! - `KexMethod`         — key exchange methods (6 constructors, tags 0-5)
//! - `ChannelType`       — SSH channel types (4 constructors, tags 0-3)
//! - `BastionState`      — bastion connection state machine (6 constructors, tags 0-5)
//! - `ChannelState`      — per-channel state machine (4 constructors, tags 0-3)
//! - `DisconnectReason`  — disconnect reason codes (12 constructors, tags 0-11)
//! - `HostKeyAlgorithm`  — host key algorithms (4 constructors, tags 0-3)
//! - `CipherAlgorithm`   — symmetric cipher algorithms (6 constructors, tags 0-5)
//! - `ChannelOpenFailure` — channel open failure reasons (4 constructors, tags 0-3)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SSH Constants
// ===========================================================================

/// Standard SSH port (RFC 4253).
pub const SSH_PORT: u16 = 22;

// ===========================================================================
// SshMessageType (tags 0-7)
// ===========================================================================

/// SSH message types as defined in the `SshBastionABI.Types` Idris2 module.
///
/// Covers the 8 core message types for SSH bastion operation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SshMessageType {
    /// Key exchange initialisation (tag 0).
    Kexinit = 0,
    /// New keys established after key exchange (tag 1).
    Newkeys = 1,
    /// Service request from client (tag 2).
    ServiceRequest = 2,
    /// User authentication request (tag 3).
    UserauthRequest = 3,
    /// Channel open request (tag 4).
    ChannelOpen = 4,
    /// Channel data transfer (tag 5).
    ChannelData = 5,
    /// Channel close notification (tag 6).
    ChannelClose = 6,
    /// Disconnect notification (tag 7).
    Disconnect = 7,
}

impl SshMessageType {
    /// Decode from an ABI tag value.
    ///
    /// Matches `tagToSshMessageType` in `SshBastionABI.Types`.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Kexinit),
            1 => Some(Self::Newkeys),
            2 => Some(Self::ServiceRequest),
            3 => Some(Self::UserauthRequest),
            4 => Some(Self::ChannelOpen),
            5 => Some(Self::ChannelData),
            6 => Some(Self::ChannelClose),
            7 => Some(Self::Disconnect),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    ///
    /// Matches `ssh_message_typeToTag` in `SshBastionABI.Types`.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported message types.
    pub const ALL: [SshMessageType; 8] = [
        Self::Kexinit,
        Self::Newkeys,
        Self::ServiceRequest,
        Self::UserauthRequest,
        Self::ChannelOpen,
        Self::ChannelData,
        Self::ChannelClose,
        Self::Disconnect,
    ];
}

impl fmt::Display for SshMessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthMethod (tags 0-3)
// ===========================================================================

/// SSH authentication methods.
///
/// Matches `AuthMethod` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthMethod {
    /// Public key authentication (tag 0).
    Publickey = 0,
    /// Password authentication (tag 1).
    Password = 1,
    /// Keyboard-interactive authentication (tag 2).
    KeyboardInteractive = 2,
    /// No authentication / "none" method (tag 3).
    AuthNone = 3,
}

impl AuthMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Publickey),
            1 => Some(Self::Password),
            2 => Some(Self::KeyboardInteractive),
            3 => Some(Self::AuthNone),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this method is considered secure for production use.
    ///
    /// Password and none methods are considered less secure than
    /// public key or keyboard-interactive with MFA.
    pub fn is_secure(self) -> bool {
        matches!(self, Self::Publickey | Self::KeyboardInteractive)
    }
}

impl fmt::Display for AuthMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Publickey => "publickey",
            Self::Password => "password",
            Self::KeyboardInteractive => "keyboard-interactive",
            Self::AuthNone => "none",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// KexMethod (tags 0-5)
// ===========================================================================

/// SSH key exchange methods.
///
/// Matches `KexMethod` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KexMethod {
    /// diffie-hellman-group14-sha256 (tag 0).
    DiffieHellmanGroup14Sha256 = 0,
    /// curve25519-sha256 (tag 1).
    Curve25519Sha256 = 1,
    /// diffie-hellman-group16-sha512 (tag 2).
    DiffieHellmanGroup16Sha512 = 2,
    /// diffie-hellman-group18-sha512 (tag 3).
    DiffieHellmanGroup18Sha512 = 3,
    /// ecdh-sha2-nistp256 (tag 4).
    EcdhSha2Nistp256 = 4,
    /// ecdh-sha2-nistp384 (tag 5).
    EcdhSha2Nistp384 = 5,
}

impl KexMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::DiffieHellmanGroup14Sha256),
            1 => Some(Self::Curve25519Sha256),
            2 => Some(Self::DiffieHellmanGroup16Sha512),
            3 => Some(Self::DiffieHellmanGroup18Sha512),
            4 => Some(Self::EcdhSha2Nistp256),
            5 => Some(Self::EcdhSha2Nistp384),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this key exchange method uses elliptic curve cryptography.
    pub fn is_ecc(self) -> bool {
        matches!(
            self,
            Self::Curve25519Sha256 | Self::EcdhSha2Nistp256 | Self::EcdhSha2Nistp384
        )
    }
}

impl fmt::Display for KexMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::DiffieHellmanGroup14Sha256 => "diffie-hellman-group14-sha256",
            Self::Curve25519Sha256 => "curve25519-sha256",
            Self::DiffieHellmanGroup16Sha512 => "diffie-hellman-group16-sha512",
            Self::DiffieHellmanGroup18Sha512 => "diffie-hellman-group18-sha512",
            Self::EcdhSha2Nistp256 => "ecdh-sha2-nistp256",
            Self::EcdhSha2Nistp384 => "ecdh-sha2-nistp384",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// ChannelType (tags 0-3)
// ===========================================================================

/// SSH channel types.
///
/// Matches `ChannelType` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChannelType {
    /// Interactive shell session (tag 0).
    Session = 0,
    /// Direct TCP/IP forwarding (tag 1).
    DirectTcpip = 1,
    /// Forwarded TCP/IP from remote (tag 2).
    ForwardedTcpip = 2,
    /// X11 forwarding (tag 3).
    X11 = 3,
}

impl ChannelType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Session),
            1 => Some(Self::DirectTcpip),
            2 => Some(Self::ForwardedTcpip),
            3 => Some(Self::X11),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this channel type involves TCP/IP forwarding.
    pub fn is_forwarding(self) -> bool {
        matches!(self, Self::DirectTcpip | Self::ForwardedTcpip)
    }
}

impl fmt::Display for ChannelType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Session => "session",
            Self::DirectTcpip => "direct-tcpip",
            Self::ForwardedTcpip => "forwarded-tcpip",
            Self::X11 => "x11",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// BastionState (tags 0-5)
// ===========================================================================

/// SSH bastion connection state machine.
///
/// Matches `BastionState` in `SshBastionABI.Types`.
/// States progress linearly: Connected -> KeyExchanged -> Authenticated ->
/// ChannelOpen -> Active -> Closed.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BastionState {
    /// TCP connection established, no SSH handshake yet (tag 0).
    Connected = 0,
    /// Key exchange completed successfully (tag 1).
    KeyExchanged = 1,
    /// User authentication succeeded (tag 2).
    Authenticated = 2,
    /// At least one channel is open (tag 3).
    ChannelOpen = 3,
    /// Actively transferring data (tag 4).
    Active = 4,
    /// Connection closed (tag 5).
    Closed = 5,
}

impl BastionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connected),
            1 => Some(Self::KeyExchanged),
            2 => Some(Self::Authenticated),
            3 => Some(Self::ChannelOpen),
            4 => Some(Self::Active),
            5 => Some(Self::Closed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    ///
    /// The bastion state machine enforces a linear progression plus
    /// the ability to close from any state.
    pub fn can_transition_to(self, next: BastionState) -> bool {
        matches!(
            (self, next),
            (Self::Connected, Self::KeyExchanged)
                | (Self::KeyExchanged, Self::Authenticated)
                | (Self::Authenticated, Self::ChannelOpen)
                | (Self::ChannelOpen, Self::Active)
                | (_, Self::Closed) // Can close from any state
        )
    }
}

impl fmt::Display for BastionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ChannelState (tags 0-3)
// ===========================================================================

/// SSH channel state machine.
///
/// Matches `ChannelState` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChannelState {
    /// Channel open request sent, awaiting confirmation (tag 0).
    Opening = 0,
    /// Channel is open and active (tag 1).
    Open = 1,
    /// Channel close has been initiated (tag 2).
    Closing = 2,
    /// Channel is fully closed (tag 3).
    Closed = 3,
}

impl ChannelState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Opening),
            1 => Some(Self::Open),
            2 => Some(Self::Closing),
            3 => Some(Self::Closed),
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
            (Self::Opening, Self::Open)
                | (Self::Opening, Self::Closed) // Open failed
                | (Self::Open, Self::Closing)
                | (Self::Closing, Self::Closed)
        )
    }
}

impl fmt::Display for ChannelState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DisconnectReason (tags 0-11)
// ===========================================================================

/// SSH disconnect reason codes.
///
/// Matches `DisconnectReason` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DisconnectReason {
    /// Host not allowed to connect (tag 0).
    HostNotAllowed = 0,
    /// Protocol error detected (tag 1).
    ProtocolError = 1,
    /// Key exchange failed (tag 2).
    KeyExchangeFailed = 2,
    /// Host authentication failed (tag 3).
    HostAuthFailed = 3,
    /// MAC verification error (tag 4).
    MacError = 4,
    /// Requested service not available (tag 5).
    ServiceNotAvailable = 5,
    /// Protocol version not supported (tag 6).
    VersionNotSupported = 6,
    /// Host key not verifiable (tag 7).
    HostKeyNotVerifiable = 7,
    /// Connection lost unexpectedly (tag 8).
    ConnectionLost = 8,
    /// Disconnected by application (tag 9).
    ByApplication = 9,
    /// Too many concurrent connections (tag 10).
    TooManyConnections = 10,
    /// Authentication cancelled by user (tag 11).
    AuthCancelled = 11,
}

impl DisconnectReason {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::HostNotAllowed),
            1 => Some(Self::ProtocolError),
            2 => Some(Self::KeyExchangeFailed),
            3 => Some(Self::HostAuthFailed),
            4 => Some(Self::MacError),
            5 => Some(Self::ServiceNotAvailable),
            6 => Some(Self::VersionNotSupported),
            7 => Some(Self::HostKeyNotVerifiable),
            8 => Some(Self::ConnectionLost),
            9 => Some(Self::ByApplication),
            10 => Some(Self::TooManyConnections),
            11 => Some(Self::AuthCancelled),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this disconnect reason indicates a security issue.
    pub fn is_security_related(self) -> bool {
        matches!(
            self,
            Self::HostNotAllowed
                | Self::HostAuthFailed
                | Self::MacError
                | Self::HostKeyNotVerifiable
                | Self::AuthCancelled
        )
    }
}

impl fmt::Display for DisconnectReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HostKeyAlgorithm (tags 0-3)
// ===========================================================================

/// SSH host key algorithms.
///
/// Matches `HostKeyAlgorithm` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HostKeyAlgorithm {
    /// ssh-ed25519 (tag 0).
    SshEd25519 = 0,
    /// rsa-sha2-256 (tag 1).
    RsaSha2256 = 1,
    /// rsa-sha2-512 (tag 2).
    RsaSha2512 = 2,
    /// ecdsa-sha2-nistp256 (tag 3).
    EcdsaNistp256 = 3,
}

impl HostKeyAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SshEd25519),
            1 => Some(Self::RsaSha2256),
            2 => Some(Self::RsaSha2512),
            3 => Some(Self::EcdsaNistp256),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this algorithm uses elliptic curve cryptography.
    pub fn is_ecc(self) -> bool {
        matches!(self, Self::SshEd25519 | Self::EcdsaNistp256)
    }
}

impl fmt::Display for HostKeyAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::SshEd25519 => "ssh-ed25519",
            Self::RsaSha2256 => "rsa-sha2-256",
            Self::RsaSha2512 => "rsa-sha2-512",
            Self::EcdsaNistp256 => "ecdsa-sha2-nistp256",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// CipherAlgorithm (tags 0-5)
// ===========================================================================

/// SSH symmetric cipher algorithms.
///
/// Matches `CipherAlgorithm` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CipherAlgorithm {
    /// chacha20-poly1305@openssh.com (tag 0).
    Chacha20Poly1305 = 0,
    /// aes256-gcm@openssh.com (tag 1).
    Aes256Gcm = 1,
    /// aes128-gcm@openssh.com (tag 2).
    Aes128Gcm = 2,
    /// aes256-ctr (tag 3).
    Aes256Ctr = 3,
    /// aes192-ctr (tag 4).
    Aes192Ctr = 4,
    /// aes128-ctr (tag 5).
    Aes128Ctr = 5,
}

impl CipherAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Chacha20Poly1305),
            1 => Some(Self::Aes256Gcm),
            2 => Some(Self::Aes128Gcm),
            3 => Some(Self::Aes256Ctr),
            4 => Some(Self::Aes192Ctr),
            5 => Some(Self::Aes128Ctr),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this cipher provides authenticated encryption (AEAD).
    pub fn is_aead(self) -> bool {
        matches!(
            self,
            Self::Chacha20Poly1305 | Self::Aes256Gcm | Self::Aes128Gcm
        )
    }

    /// The key size in bits for this cipher.
    pub fn key_bits(self) -> u16 {
        match self {
            Self::Chacha20Poly1305 => 256,
            Self::Aes256Gcm | Self::Aes256Ctr => 256,
            Self::Aes192Ctr => 192,
            Self::Aes128Gcm | Self::Aes128Ctr => 128,
        }
    }
}

impl fmt::Display for CipherAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Chacha20Poly1305 => "chacha20-poly1305@openssh.com",
            Self::Aes256Gcm => "aes256-gcm@openssh.com",
            Self::Aes128Gcm => "aes128-gcm@openssh.com",
            Self::Aes256Ctr => "aes256-ctr",
            Self::Aes192Ctr => "aes192-ctr",
            Self::Aes128Ctr => "aes128-ctr",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// ChannelOpenFailure (tags 0-3)
// ===========================================================================

/// Reasons an SSH channel open request can be rejected.
///
/// Matches `ChannelOpenFailure` in `SshBastionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChannelOpenFailure {
    /// Administratively prohibited (tag 0).
    AdminProhibited = 0,
    /// Connection to forwarding target failed (tag 1).
    ConnectFailed = 1,
    /// Unknown channel type requested (tag 2).
    UnknownChannelType = 2,
    /// Insufficient resources on server (tag 3).
    ResourceShortage = 3,
}

impl ChannelOpenFailure {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AdminProhibited),
            1 => Some(Self::ConnectFailed),
            2 => Some(Self::UnknownChannelType),
            3 => Some(Self::ResourceShortage),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for ChannelOpenFailure {
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
        for msg in SshMessageType::ALL {
            let tag = msg.to_tag();
            let decoded = SshMessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, msg);
        }
    }

    #[test]
    fn message_type_invalid_rejected() {
        assert!(SshMessageType::from_tag(8).is_none());
        assert!(SshMessageType::from_tag(255).is_none());
    }

    #[test]
    fn auth_method_roundtrip() {
        for tag in 0u8..=3 {
            let method = AuthMethod::from_tag(tag).expect("valid tag");
            assert_eq!(method.to_tag(), tag);
        }
        assert!(AuthMethod::from_tag(4).is_none());
    }

    #[test]
    fn auth_method_security() {
        assert!(AuthMethod::Publickey.is_secure());
        assert!(AuthMethod::KeyboardInteractive.is_secure());
        assert!(!AuthMethod::Password.is_secure());
        assert!(!AuthMethod::AuthNone.is_secure());
    }

    #[test]
    fn kex_method_roundtrip() {
        for tag in 0u8..=5 {
            let kex = KexMethod::from_tag(tag).expect("valid tag");
            assert_eq!(kex.to_tag(), tag);
        }
        assert!(KexMethod::from_tag(6).is_none());
    }

    #[test]
    fn kex_method_ecc() {
        assert!(KexMethod::Curve25519Sha256.is_ecc());
        assert!(KexMethod::EcdhSha2Nistp256.is_ecc());
        assert!(!KexMethod::DiffieHellmanGroup14Sha256.is_ecc());
    }

    #[test]
    fn channel_type_roundtrip() {
        for tag in 0u8..=3 {
            let ct = ChannelType::from_tag(tag).expect("valid tag");
            assert_eq!(ct.to_tag(), tag);
        }
        assert!(ChannelType::from_tag(4).is_none());
    }

    #[test]
    fn channel_type_forwarding() {
        assert!(!ChannelType::Session.is_forwarding());
        assert!(ChannelType::DirectTcpip.is_forwarding());
        assert!(ChannelType::ForwardedTcpip.is_forwarding());
        assert!(!ChannelType::X11.is_forwarding());
    }

    #[test]
    fn bastion_state_roundtrip() {
        for tag in 0u8..=5 {
            let state = BastionState::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(BastionState::from_tag(6).is_none());
    }

    #[test]
    fn bastion_state_transitions() {
        // Valid forward transitions.
        assert!(BastionState::Connected.can_transition_to(BastionState::KeyExchanged));
        assert!(BastionState::KeyExchanged.can_transition_to(BastionState::Authenticated));
        assert!(BastionState::Authenticated.can_transition_to(BastionState::ChannelOpen));
        assert!(BastionState::ChannelOpen.can_transition_to(BastionState::Active));
        // Can always close.
        assert!(BastionState::Connected.can_transition_to(BastionState::Closed));
        assert!(BastionState::Active.can_transition_to(BastionState::Closed));
        // Invalid transitions.
        assert!(!BastionState::Connected.can_transition_to(BastionState::Authenticated));
        assert!(!BastionState::Closed.can_transition_to(BastionState::Connected));
    }

    #[test]
    fn channel_state_roundtrip() {
        for tag in 0u8..=3 {
            let state = ChannelState::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(ChannelState::from_tag(4).is_none());
    }

    #[test]
    fn channel_state_transitions() {
        assert!(ChannelState::Opening.can_transition_to(ChannelState::Open));
        assert!(ChannelState::Opening.can_transition_to(ChannelState::Closed));
        assert!(ChannelState::Open.can_transition_to(ChannelState::Closing));
        assert!(ChannelState::Closing.can_transition_to(ChannelState::Closed));
        assert!(!ChannelState::Closed.can_transition_to(ChannelState::Opening));
    }

    #[test]
    fn disconnect_reason_roundtrip() {
        for tag in 0u8..=11 {
            let reason = DisconnectReason::from_tag(tag).expect("valid tag");
            assert_eq!(reason.to_tag(), tag);
        }
        assert!(DisconnectReason::from_tag(12).is_none());
    }

    #[test]
    fn disconnect_reason_security() {
        assert!(DisconnectReason::HostNotAllowed.is_security_related());
        assert!(DisconnectReason::MacError.is_security_related());
        assert!(!DisconnectReason::ByApplication.is_security_related());
        assert!(!DisconnectReason::ConnectionLost.is_security_related());
    }

    #[test]
    fn host_key_algorithm_roundtrip() {
        for tag in 0u8..=3 {
            let alg = HostKeyAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(alg.to_tag(), tag);
        }
        assert!(HostKeyAlgorithm::from_tag(4).is_none());
    }

    #[test]
    fn cipher_algorithm_roundtrip() {
        for tag in 0u8..=5 {
            let cipher = CipherAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(cipher.to_tag(), tag);
        }
        assert!(CipherAlgorithm::from_tag(6).is_none());
    }

    #[test]
    fn cipher_aead_and_key_bits() {
        assert!(CipherAlgorithm::Chacha20Poly1305.is_aead());
        assert!(CipherAlgorithm::Aes256Gcm.is_aead());
        assert!(!CipherAlgorithm::Aes256Ctr.is_aead());
        assert_eq!(CipherAlgorithm::Chacha20Poly1305.key_bits(), 256);
        assert_eq!(CipherAlgorithm::Aes192Ctr.key_bits(), 192);
        assert_eq!(CipherAlgorithm::Aes128Ctr.key_bits(), 128);
    }

    #[test]
    fn channel_open_failure_roundtrip() {
        for tag in 0u8..=3 {
            let failure = ChannelOpenFailure::from_tag(tag).expect("valid tag");
            assert_eq!(failure.to_tag(), tag);
        }
        assert!(ChannelOpenFailure::from_tag(4).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SSH_PORT, 22);
    }
}
