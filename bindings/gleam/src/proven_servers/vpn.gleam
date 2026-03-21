//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// VPN/IPsec protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `VpnABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// VPN/IPsec Constants
// ===========================================================================

/// Ike Port constant.
pub const ike_port = 500

/// Ike Natt Port constant.
pub const ike_natt_port = 4500

/// Wireguard Port constant.
pub const wireguard_port = 51820

/// Openvpn Port constant.
pub const openvpn_port = 1194

// ===========================================================================
// TunnelType
// ===========================================================================

/// VPN tunnel technology types.
/// 
/// Matches `TunnelType` in `VpnABI.Types`.
pub type TunnelType {
  /// IPsec — RFC 4301 (tag 0).
  Ipsec
  /// WireGuard — modern kernel-level VPN (tag 1).
  Wireguard
  /// OpenVPN — TLS-based VPN (tag 2).
  Openvpn
  /// L2TP — Layer 2 Tunneling Protocol (tag 3).
  L2tp
}

/// Convert a `TunnelType` to its C-ABI tag value.
pub fn tunnel_type_to_int(value: TunnelType) -> Int {
  case value {
    Ipsec -> 0
    Wireguard -> 1
    Openvpn -> 2
    L2tp -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn tunnel_type_from_int(tag: Int) -> Result(TunnelType, Nil) {
  case tag {
    0 -> Ok(Ipsec)
    1 -> Ok(Wireguard)
    2 -> Ok(Openvpn)
    3 -> Ok(L2tp)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TunnelPhase
// ===========================================================================

/// VPN tunnel negotiation phases.
/// 
/// Matches `TunnelPhase` in `VpnABI.Types`.
/// Reflects the IKE Phase 1 / Phase 2 negotiation lifecycle.
pub type TunnelPhase {
  /// No tunnel negotiation in progress (tag 0).
  Idle
  /// IKE Phase 1 initial exchange started (tag 1).
  Phase1Init
  /// IKE Phase 1 authentication in progress (tag 2).
  Phase1Auth
  /// IKE Phase 1 complete — IKE SA established (tag 3).
  Phase1Done
  /// IKE Phase 2 / Child SA negotiation (tag 4).
  Phase2Negotiating
  /// Tunnel established and carrying traffic (tag 5).
  Established
  /// Security Association has expired (tag 6).
  TunnelPhaseExpired
}

/// Convert a `TunnelPhase` to its C-ABI tag value.
pub fn tunnel_phase_to_int(value: TunnelPhase) -> Int {
  case value {
    Idle -> 0
    Phase1Init -> 1
    Phase1Auth -> 2
    Phase1Done -> 3
    Phase2Negotiating -> 4
    Established -> 5
    TunnelPhaseExpired -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn tunnel_phase_from_int(tag: Int) -> Result(TunnelPhase, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Phase1Init)
    2 -> Ok(Phase1Auth)
    3 -> Ok(Phase1Done)
    4 -> Ok(Phase2Negotiating)
    5 -> Ok(Established)
    6 -> Ok(TunnelPhaseExpired)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EncryptionAlgorithm
// ===========================================================================

/// VPN encryption algorithms.
/// 
/// Matches `EncryptionAlgorithm` in `VpnABI.Types`.
pub type EncryptionAlgorithm {
  /// AES-128-CBC (tag 0).
  Aes128Cbc
  /// AES-256-CBC (tag 1).
  Aes256Cbc
  /// AES-128-GCM (AEAD) (tag 2).
  Aes128Gcm
  /// AES-256-GCM (AEAD) (tag 3).
  Aes256Gcm
  /// ChaCha20-Poly1305 (AEAD) (tag 4).
  Chacha20Poly1305
  /// Null cipher — no encryption (tag 5).
  NullCipher
}

/// Convert a `EncryptionAlgorithm` to its C-ABI tag value.
pub fn encryption_algorithm_to_int(value: EncryptionAlgorithm) -> Int {
  case value {
    Aes128Cbc -> 0
    Aes256Cbc -> 1
    Aes128Gcm -> 2
    Aes256Gcm -> 3
    Chacha20Poly1305 -> 4
    NullCipher -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn encryption_algorithm_from_int(tag: Int) -> Result(EncryptionAlgorithm, Nil) {
  case tag {
    0 -> Ok(Aes128Cbc)
    1 -> Ok(Aes256Cbc)
    2 -> Ok(Aes128Gcm)
    3 -> Ok(Aes256Gcm)
    4 -> Ok(Chacha20Poly1305)
    5 -> Ok(NullCipher)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IntegrityAlgorithm
// ===========================================================================

/// VPN integrity/MAC algorithms.
/// 
/// Matches `IntegrityAlgorithm` in `VpnABI.Types`.
pub type IntegrityAlgorithm {
  /// HMAC-SHA-1-96 (tag 0).
  HmacSha1
  /// HMAC-SHA-256-128 (tag 1).
  HmacSha256
  /// HMAC-SHA-384-192 (tag 2).
  HmacSha384
  /// HMAC-SHA-512-256 (tag 3).
  HmacSha512
  /// No integrity check (tag 4).
  NoIntegrity
}

/// Convert a `IntegrityAlgorithm` to its C-ABI tag value.
pub fn integrity_algorithm_to_int(value: IntegrityAlgorithm) -> Int {
  case value {
    HmacSha1 -> 0
    HmacSha256 -> 1
    HmacSha384 -> 2
    HmacSha512 -> 3
    NoIntegrity -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn integrity_algorithm_from_int(tag: Int) -> Result(IntegrityAlgorithm, Nil) {
  case tag {
    0 -> Ok(HmacSha1)
    1 -> Ok(HmacSha256)
    2 -> Ok(HmacSha384)
    3 -> Ok(HmacSha512)
    4 -> Ok(NoIntegrity)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DhGroup
// ===========================================================================

/// Diffie-Hellman key exchange groups.
/// 
/// Matches `DHGroup` in `VpnABI.Types`.
pub type DhGroup {
  /// DH Group 14 — 2048-bit MODP (tag 0).
  Dh14
  /// ECP-256 — 256-bit Elliptic Curve (tag 1).
  Ecp256
  /// ECP-384 — 384-bit Elliptic Curve (tag 2).
  Ecp384
  /// Curve25519 — modern elliptic curve (tag 3).
  Curve25519
}

/// Convert a `DhGroup` to its C-ABI tag value.
pub fn dh_group_to_int(value: DhGroup) -> Int {
  case value {
    Dh14 -> 0
    Ecp256 -> 1
    Ecp384 -> 2
    Curve25519 -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn dh_group_from_int(tag: Int) -> Result(DhGroup, Nil) {
  case tag {
    0 -> Ok(Dh14)
    1 -> Ok(Ecp256)
    2 -> Ok(Ecp384)
    3 -> Ok(Curve25519)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SaLifecycle
// ===========================================================================

/// Security Association lifecycle states.
/// 
/// Matches `SALifecycle` in `VpnABI.Types`.
pub type SaLifecycle {
  /// No SA exists (tag 0).
  SaLifecycleNone
  /// SA is active and carrying traffic (tag 1).
  Active
  /// SA is being rekeyed (tag 2).
  Rekeying
  /// SA lifetime has expired (tag 3).
  SaLifecycleExpired
  /// SA has been deleted (tag 4).
  Deleted
}

/// Convert a `SaLifecycle` to its C-ABI tag value.
pub fn sa_lifecycle_to_int(value: SaLifecycle) -> Int {
  case value {
    SaLifecycleNone -> 0
    Active -> 1
    Rekeying -> 2
    SaLifecycleExpired -> 3
    Deleted -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn sa_lifecycle_from_int(tag: Int) -> Result(SaLifecycle, Nil) {
  case tag {
    0 -> Ok(SaLifecycleNone)
    1 -> Ok(Active)
    2 -> Ok(Rekeying)
    3 -> Ok(SaLifecycleExpired)
    4 -> Ok(Deleted)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IkeVersion
// ===========================================================================

/// IKE (Internet Key Exchange) protocol versions.
/// 
/// Matches `IKEVersion` in `VpnABI.Types`.
pub type IkeVersion {
  /// IKEv1 (RFC 2409) (tag 0).
  V1
  /// IKEv2 (RFC 7296) (tag 1).
  V2
}

/// Convert a `IkeVersion` to its C-ABI tag value.
pub fn ike_version_to_int(value: IkeVersion) -> Int {
  case value {
    V1 -> 0
    V2 -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn ike_version_from_int(tag: Int) -> Result(IkeVersion, Nil) {
  case tag {
    0 -> Ok(V1)
    1 -> Ok(V2)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// VpnError
// ===========================================================================

/// VPN error codes.
/// 
/// Matches `VPNError` in `VpnABI.Types`.
pub type VpnError {
  /// Authentication failed (tag 0).
  AuthenticationFailed
  /// No acceptable proposal from peer (tag 1).
  NoProposalChosen
  /// SA lifetime expired (tag 2).
  LifetimeExpired
  /// Invalid Security Parameter Index (tag 3).
  InvalidSpi
  /// Replay attack detected (tag 4).
  ReplayDetected
  /// Negotiation timed out (tag 5).
  NegotiationTimeout
}

/// Convert a `VpnError` to its C-ABI tag value.
pub fn vpn_error_to_int(value: VpnError) -> Int {
  case value {
    AuthenticationFailed -> 0
    NoProposalChosen -> 1
    LifetimeExpired -> 2
    InvalidSpi -> 3
    ReplayDetected -> 4
    NegotiationTimeout -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn vpn_error_from_int(tag: Int) -> Result(VpnError, Nil) {
  case tag {
    0 -> Ok(AuthenticationFailed)
    1 -> Ok(NoProposalChosen)
    2 -> Ok(LifetimeExpired)
    3 -> Ok(InvalidSpi)
    4 -> Ok(ReplayDetected)
    5 -> Ok(NegotiationTimeout)
    _ -> Error(Nil)
  }
}

