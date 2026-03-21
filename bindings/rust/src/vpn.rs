// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! VPN (Virtual Private Network) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `VpnABI.Types` and its type definitions:
//! - `TunnelType`           — VPN tunnel technologies (4 constructors, tags 0-3)
//! - `TunnelPhase`          — IKE/tunnel negotiation phases (7 constructors, tags 0-6)
//! - `EncryptionAlgorithm`  — Encryption algorithms (6 constructors, tags 0-5)
//! - `IntegrityAlgorithm`   — Integrity/MAC algorithms (5 constructors, tags 0-4)
//! - `DhGroup`              — Diffie-Hellman groups (4 constructors, tags 0-3)
//! - `SaLifecycle`          — Security Association lifecycle (5 constructors, tags 0-4)
//! - `IkeVersion`           — IKE protocol versions (2 constructors, tags 0-1)
//! - `VpnError`             — VPN error codes (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// VPN Constants
// ===========================================================================

/// Standard IKE (Internet Key Exchange) port.
pub const IKE_PORT: u16 = 500;

/// IKE NAT-Traversal port (RFC 3947).
pub const IKE_NATT_PORT: u16 = 4500;

/// WireGuard default listening port.
pub const WIREGUARD_PORT: u16 = 51820;

/// OpenVPN default port.
pub const OPENVPN_PORT: u16 = 1194;

// ===========================================================================
// TunnelType (tags 0-3)
// ===========================================================================

/// VPN tunnel technology types.
///
/// Matches `TunnelType` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TunnelType {
    /// IPsec — RFC 4301 (tag 0).
    Ipsec = 0,
    /// WireGuard — modern kernel-level VPN (tag 1).
    Wireguard = 1,
    /// OpenVPN — TLS-based VPN (tag 2).
    Openvpn = 2,
    /// L2TP — Layer 2 Tunneling Protocol (tag 3).
    L2tp = 3,
}

impl TunnelType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ipsec),
            1 => Some(Self::Wireguard),
            2 => Some(Self::Openvpn),
            3 => Some(Self::L2tp),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this tunnel type uses IKE for key exchange.
    pub fn uses_ike(self) -> bool {
        matches!(self, Self::Ipsec | Self::L2tp)
    }

    /// Whether this tunnel type operates at the kernel level.
    pub fn is_kernel_level(self) -> bool {
        matches!(self, Self::Ipsec | Self::Wireguard)
    }

    /// The default port for this tunnel type (if applicable).
    pub fn default_port(self) -> u16 {
        match self {
            Self::Ipsec => IKE_PORT,
            Self::Wireguard => WIREGUARD_PORT,
            Self::Openvpn => OPENVPN_PORT,
            Self::L2tp => 1701,
        }
    }

    /// All supported tunnel types.
    pub const ALL: [TunnelType; 4] = [
        Self::Ipsec, Self::Wireguard, Self::Openvpn, Self::L2tp,
    ];
}

impl fmt::Display for TunnelType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TunnelPhase (tags 0-6)
// ===========================================================================

/// VPN tunnel negotiation phases.
///
/// Matches `TunnelPhase` in `VpnABI.Types`.
/// Reflects the IKE Phase 1 / Phase 2 negotiation lifecycle.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TunnelPhase {
    /// No tunnel negotiation in progress (tag 0).
    Idle = 0,
    /// IKE Phase 1 initial exchange started (tag 1).
    Phase1Init = 1,
    /// IKE Phase 1 authentication in progress (tag 2).
    Phase1Auth = 2,
    /// IKE Phase 1 complete — IKE SA established (tag 3).
    Phase1Done = 3,
    /// IKE Phase 2 / Child SA negotiation (tag 4).
    Phase2Negotiating = 4,
    /// Tunnel established and carrying traffic (tag 5).
    Established = 5,
    /// Security Association has expired (tag 6).
    Expired = 6,
}

impl TunnelPhase {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Phase1Init),
            2 => Some(Self::Phase1Auth),
            3 => Some(Self::Phase1Done),
            4 => Some(Self::Phase2Negotiating),
            5 => Some(Self::Established),
            6 => Some(Self::Expired),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the tunnel is carrying traffic.
    pub fn is_established(self) -> bool {
        matches!(self, Self::Established)
    }

    /// Whether negotiation is in progress.
    pub fn is_negotiating(self) -> bool {
        matches!(
            self,
            Self::Phase1Init | Self::Phase1Auth | Self::Phase2Negotiating
        )
    }

    /// Whether Phase 1 (IKE SA) is complete.
    pub fn phase1_complete(self) -> bool {
        matches!(
            self,
            Self::Phase1Done | Self::Phase2Negotiating | Self::Established
        )
    }

    /// All supported tunnel phases.
    pub const ALL: [TunnelPhase; 7] = [
        Self::Idle, Self::Phase1Init, Self::Phase1Auth, Self::Phase1Done,
        Self::Phase2Negotiating, Self::Established, Self::Expired,
    ];
}

impl fmt::Display for TunnelPhase {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EncryptionAlgorithm (tags 0-5)
// ===========================================================================

/// VPN encryption algorithms.
///
/// Matches `EncryptionAlgorithm` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EncryptionAlgorithm {
    /// AES-128-CBC (tag 0).
    Aes128Cbc = 0,
    /// AES-256-CBC (tag 1).
    Aes256Cbc = 1,
    /// AES-128-GCM (AEAD) (tag 2).
    Aes128Gcm = 2,
    /// AES-256-GCM (AEAD) (tag 3).
    Aes256Gcm = 3,
    /// ChaCha20-Poly1305 (AEAD) (tag 4).
    Chacha20Poly1305 = 4,
    /// Null cipher — no encryption (tag 5).
    NullCipher = 5,
}

impl EncryptionAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Aes128Cbc),
            1 => Some(Self::Aes256Cbc),
            2 => Some(Self::Aes128Gcm),
            3 => Some(Self::Aes256Gcm),
            4 => Some(Self::Chacha20Poly1305),
            5 => Some(Self::NullCipher),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this algorithm provides authenticated encryption (AEAD).
    pub fn is_aead(self) -> bool {
        matches!(self, Self::Aes128Gcm | Self::Aes256Gcm | Self::Chacha20Poly1305)
    }

    /// Whether this algorithm actually encrypts data.
    pub fn provides_confidentiality(self) -> bool {
        !matches!(self, Self::NullCipher)
    }

    /// The key size in bits.
    pub fn key_bits(self) -> u16 {
        match self {
            Self::Aes128Cbc | Self::Aes128Gcm => 128,
            Self::Aes256Cbc | Self::Aes256Gcm => 256,
            Self::Chacha20Poly1305 => 256,
            Self::NullCipher => 0,
        }
    }

    /// All supported encryption algorithms.
    pub const ALL: [EncryptionAlgorithm; 6] = [
        Self::Aes128Cbc, Self::Aes256Cbc, Self::Aes128Gcm,
        Self::Aes256Gcm, Self::Chacha20Poly1305, Self::NullCipher,
    ];
}

impl fmt::Display for EncryptionAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IntegrityAlgorithm (tags 0-4)
// ===========================================================================

/// VPN integrity/MAC algorithms.
///
/// Matches `IntegrityAlgorithm` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IntegrityAlgorithm {
    /// HMAC-SHA-1-96 (tag 0).
    HmacSha1 = 0,
    /// HMAC-SHA-256-128 (tag 1).
    HmacSha256 = 1,
    /// HMAC-SHA-384-192 (tag 2).
    HmacSha384 = 2,
    /// HMAC-SHA-512-256 (tag 3).
    HmacSha512 = 3,
    /// No integrity check (tag 4).
    NoIntegrity = 4,
}

impl IntegrityAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::HmacSha1),
            1 => Some(Self::HmacSha256),
            2 => Some(Self::HmacSha384),
            3 => Some(Self::HmacSha512),
            4 => Some(Self::NoIntegrity),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this algorithm provides integrity protection.
    pub fn provides_integrity(self) -> bool {
        !matches!(self, Self::NoIntegrity)
    }

    /// The hash output size in bits (truncated MAC size).
    pub fn mac_bits(self) -> u16 {
        match self {
            Self::HmacSha1 => 96,
            Self::HmacSha256 => 128,
            Self::HmacSha384 => 192,
            Self::HmacSha512 => 256,
            Self::NoIntegrity => 0,
        }
    }

    /// All supported integrity algorithms.
    pub const ALL: [IntegrityAlgorithm; 5] = [
        Self::HmacSha1, Self::HmacSha256, Self::HmacSha384,
        Self::HmacSha512, Self::NoIntegrity,
    ];
}

impl fmt::Display for IntegrityAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DhGroup (tags 0-3)
// ===========================================================================

/// Diffie-Hellman key exchange groups.
///
/// Matches `DHGroup` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DhGroup {
    /// DH Group 14 — 2048-bit MODP (tag 0).
    Dh14 = 0,
    /// ECP-256 — 256-bit Elliptic Curve (tag 1).
    Ecp256 = 1,
    /// ECP-384 — 384-bit Elliptic Curve (tag 2).
    Ecp384 = 2,
    /// Curve25519 — modern elliptic curve (tag 3).
    Curve25519 = 3,
}

impl DhGroup {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Dh14),
            1 => Some(Self::Ecp256),
            2 => Some(Self::Ecp384),
            3 => Some(Self::Curve25519),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this group uses elliptic curve cryptography.
    pub fn is_ecc(self) -> bool {
        matches!(self, Self::Ecp256 | Self::Ecp384 | Self::Curve25519)
    }

    /// The approximate security strength in bits.
    pub fn security_bits(self) -> u16 {
        match self {
            Self::Dh14 => 112,
            Self::Ecp256 => 128,
            Self::Ecp384 => 192,
            Self::Curve25519 => 128,
        }
    }

    /// All supported DH groups.
    pub const ALL: [DhGroup; 4] = [Self::Dh14, Self::Ecp256, Self::Ecp384, Self::Curve25519];
}

impl fmt::Display for DhGroup {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SaLifecycle (tags 0-4)
// ===========================================================================

/// Security Association lifecycle states.
///
/// Matches `SALifecycle` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SaLifecycle {
    /// No SA exists (tag 0).
    None = 0,
    /// SA is active and carrying traffic (tag 1).
    Active = 1,
    /// SA is being rekeyed (tag 2).
    Rekeying = 2,
    /// SA lifetime has expired (tag 3).
    Expired = 3,
    /// SA has been deleted (tag 4).
    Deleted = 4,
}

impl SaLifecycle {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::Active),
            2 => Some(Self::Rekeying),
            3 => Some(Self::Expired),
            4 => Some(Self::Deleted),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the SA is usable for traffic.
    pub fn is_usable(self) -> bool {
        matches!(self, Self::Active | Self::Rekeying)
    }

    /// Whether the SA has been terminated.
    pub fn is_terminated(self) -> bool {
        matches!(self, Self::Expired | Self::Deleted)
    }

    /// All supported SA lifecycle states.
    pub const ALL: [SaLifecycle; 5] = [
        Self::None, Self::Active, Self::Rekeying, Self::Expired, Self::Deleted,
    ];
}

impl fmt::Display for SaLifecycle {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IkeVersion (tags 0-1)
// ===========================================================================

/// IKE (Internet Key Exchange) protocol versions.
///
/// Matches `IKEVersion` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum IkeVersion {
    /// IKEv1 (RFC 2409) (tag 0).
    V1 = 0,
    /// IKEv2 (RFC 7296) (tag 1).
    V2 = 1,
}

impl IkeVersion {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::V1),
            1 => Some(Self::V2),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for IkeVersion {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::V1 => f.write_str("IKEv1"),
            Self::V2 => f.write_str("IKEv2"),
        }
    }
}

// ===========================================================================
// VpnError (tags 0-5)
// ===========================================================================

/// VPN error codes.
///
/// Matches `VPNError` in `VpnABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum VpnError {
    /// Authentication failed (tag 0).
    AuthenticationFailed = 0,
    /// No acceptable proposal from peer (tag 1).
    NoProposalChosen = 1,
    /// SA lifetime expired (tag 2).
    LifetimeExpired = 2,
    /// Invalid Security Parameter Index (tag 3).
    InvalidSpi = 3,
    /// Replay attack detected (tag 4).
    ReplayDetected = 4,
    /// Negotiation timed out (tag 5).
    NegotiationTimeout = 5,
}

impl VpnError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AuthenticationFailed),
            1 => Some(Self::NoProposalChosen),
            2 => Some(Self::LifetimeExpired),
            3 => Some(Self::InvalidSpi),
            4 => Some(Self::ReplayDetected),
            5 => Some(Self::NegotiationTimeout),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error indicates a security concern.
    pub fn is_security_concern(self) -> bool {
        matches!(
            self,
            Self::AuthenticationFailed | Self::InvalidSpi | Self::ReplayDetected
        )
    }

    /// Whether this error is likely transient and retryable.
    pub fn is_retryable(self) -> bool {
        matches!(self, Self::NegotiationTimeout | Self::LifetimeExpired)
    }

    /// All supported VPN errors.
    pub const ALL: [VpnError; 6] = [
        Self::AuthenticationFailed, Self::NoProposalChosen, Self::LifetimeExpired,
        Self::InvalidSpi, Self::ReplayDetected, Self::NegotiationTimeout,
    ];
}

impl fmt::Display for VpnError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for VpnError {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tunnel_type_roundtrip() {
        for tt in TunnelType::ALL {
            let tag = tt.to_tag();
            let decoded = TunnelType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, tt);
        }
        assert!(TunnelType::from_tag(4).is_none());
    }

    #[test]
    fn tunnel_type_classification() {
        assert!(TunnelType::Ipsec.uses_ike());
        assert!(TunnelType::L2tp.uses_ike());
        assert!(!TunnelType::Wireguard.uses_ike());
        assert!(TunnelType::Ipsec.is_kernel_level());
        assert!(TunnelType::Wireguard.is_kernel_level());
        assert!(!TunnelType::Openvpn.is_kernel_level());
    }

    #[test]
    fn tunnel_phase_roundtrip() {
        for tp in TunnelPhase::ALL {
            let tag = tp.to_tag();
            let decoded = TunnelPhase::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, tp);
        }
        assert!(TunnelPhase::from_tag(7).is_none());
    }

    #[test]
    fn tunnel_phase_classification() {
        assert!(TunnelPhase::Established.is_established());
        assert!(!TunnelPhase::Phase1Done.is_established());
        assert!(TunnelPhase::Phase1Init.is_negotiating());
        assert!(TunnelPhase::Phase2Negotiating.is_negotiating());
        assert!(!TunnelPhase::Established.is_negotiating());
        assert!(TunnelPhase::Established.phase1_complete());
        assert!(!TunnelPhase::Phase1Init.phase1_complete());
    }

    #[test]
    fn encryption_algorithm_roundtrip() {
        for ea in EncryptionAlgorithm::ALL {
            let tag = ea.to_tag();
            let decoded = EncryptionAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ea);
        }
        assert!(EncryptionAlgorithm::from_tag(6).is_none());
    }

    #[test]
    fn encryption_algorithm_properties() {
        assert!(EncryptionAlgorithm::Aes128Gcm.is_aead());
        assert!(EncryptionAlgorithm::Chacha20Poly1305.is_aead());
        assert!(!EncryptionAlgorithm::Aes128Cbc.is_aead());
        assert!(!EncryptionAlgorithm::NullCipher.provides_confidentiality());
        assert!(EncryptionAlgorithm::Aes256Gcm.provides_confidentiality());
        assert_eq!(EncryptionAlgorithm::Aes256Gcm.key_bits(), 256);
        assert_eq!(EncryptionAlgorithm::NullCipher.key_bits(), 0);
    }

    #[test]
    fn integrity_algorithm_roundtrip() {
        for ia in IntegrityAlgorithm::ALL {
            let tag = ia.to_tag();
            let decoded = IntegrityAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ia);
        }
        assert!(IntegrityAlgorithm::from_tag(5).is_none());
    }

    #[test]
    fn integrity_algorithm_properties() {
        assert!(IntegrityAlgorithm::HmacSha256.provides_integrity());
        assert!(!IntegrityAlgorithm::NoIntegrity.provides_integrity());
        assert_eq!(IntegrityAlgorithm::HmacSha256.mac_bits(), 128);
    }

    #[test]
    fn dh_group_roundtrip() {
        for dg in DhGroup::ALL {
            let tag = dg.to_tag();
            let decoded = DhGroup::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, dg);
        }
        assert!(DhGroup::from_tag(4).is_none());
    }

    #[test]
    fn dh_group_ecc() {
        assert!(!DhGroup::Dh14.is_ecc());
        assert!(DhGroup::Ecp256.is_ecc());
        assert!(DhGroup::Curve25519.is_ecc());
    }

    #[test]
    fn sa_lifecycle_roundtrip() {
        for sa in SaLifecycle::ALL {
            let tag = sa.to_tag();
            let decoded = SaLifecycle::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, sa);
        }
        assert!(SaLifecycle::from_tag(5).is_none());
    }

    #[test]
    fn sa_lifecycle_classification() {
        assert!(SaLifecycle::Active.is_usable());
        assert!(SaLifecycle::Rekeying.is_usable());
        assert!(!SaLifecycle::Expired.is_usable());
        assert!(SaLifecycle::Expired.is_terminated());
        assert!(SaLifecycle::Deleted.is_terminated());
        assert!(!SaLifecycle::Active.is_terminated());
    }

    #[test]
    fn ike_version_roundtrip() {
        for tag in 0u8..=1 {
            let iv = IkeVersion::from_tag(tag).expect("valid tag");
            assert_eq!(iv.to_tag(), tag);
        }
        assert!(IkeVersion::from_tag(2).is_none());
    }

    #[test]
    fn ike_version_ordering() {
        assert!(IkeVersion::V1 < IkeVersion::V2);
    }

    #[test]
    fn vpn_error_roundtrip() {
        for ve in VpnError::ALL {
            let tag = ve.to_tag();
            let decoded = VpnError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ve);
        }
        assert!(VpnError::from_tag(6).is_none());
    }

    #[test]
    fn vpn_error_classification() {
        assert!(VpnError::AuthenticationFailed.is_security_concern());
        assert!(VpnError::ReplayDetected.is_security_concern());
        assert!(!VpnError::NegotiationTimeout.is_security_concern());
        assert!(VpnError::NegotiationTimeout.is_retryable());
        assert!(!VpnError::AuthenticationFailed.is_retryable());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(IKE_PORT, 500);
        assert_eq!(IKE_NATT_PORT, 4500);
        assert_eq!(WIREGUARD_PORT, 51820);
        assert_eq!(OPENVPN_PORT, 1194);
    }
}
