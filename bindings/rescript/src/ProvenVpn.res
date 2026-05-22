// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN (Virtual Private Network) types for the proven-servers ABI.
//
// Mirrors the Idris2 module VpnABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard IKE (Internet Key Exchange) port.
let ikePort = 500

/// IKE NAT-Traversal port (RFC 3947).
let ikeNattPort = 4500

/// WireGuard default listening port.
let wireguardPort = 51820

/// OpenVPN default port.
let openvpnPort = 1194

// ===========================================================================
// TunnelType (tags 0-3)
// ===========================================================================

/// Standard IKE (Internet Key Exchange) port.
type tunnelType =
  | @as(0) Ipsec
  | @as(1) Wireguard
  | @as(2) Openvpn
  | @as(3) L2tp

/// Decode from the C-ABI tag value.
let tunnelTypeFromTag = (tag: int): option<tunnelType> =>
  switch tag {
  | 0 => Some(Ipsec)
  | 1 => Some(Wireguard)
  | 2 => Some(Openvpn)
  | 3 => Some(L2tp)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let tunnelTypeToTag = (v: tunnelType): int =>
  switch v {
  | Ipsec => 0
  | Wireguard => 1
  | Openvpn => 2
  | L2tp => 3
  }

/// Whether this tunnel type uses IKE for key exchange.
let tunnelTypeUsesIke = (v: tunnelType): bool =>
  switch v {
  | Ipsec | L2tp => true
  | _ => false
  }

/// Whether this tunnel type operates at the kernel level.
let tunnelTypeIsKernelLevel = (v: tunnelType): bool =>
  switch v {
  | Ipsec | Wireguard => true
  | _ => false
  }

// ===========================================================================
// TunnelPhase (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type tunnelPhase =
  | @as(0) Idle
  | @as(1) Phase1Init
  | @as(2) Phase1Auth
  | @as(3) Phase1Done
  | @as(4) Phase2Negotiating
  | @as(5) Established
  | @as(6) Expired

/// Decode from the C-ABI tag value.
let tunnelPhaseFromTag = (tag: int): option<tunnelPhase> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Phase1Init)
  | 2 => Some(Phase1Auth)
  | 3 => Some(Phase1Done)
  | 4 => Some(Phase2Negotiating)
  | 5 => Some(Established)
  | 6 => Some(Expired)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let tunnelPhaseToTag = (v: tunnelPhase): int =>
  switch v {
  | Idle => 0
  | Phase1Init => 1
  | Phase1Auth => 2
  | Phase1Done => 3
  | Phase2Negotiating => 4
  | Established => 5
  | Expired => 6
  }

/// Whether the tunnel is carrying traffic.
let tunnelPhaseIsEstablished = (v: tunnelPhase): bool =>
  switch v {
  | Established => true
  | _ => false
  }

/// Whether negotiation is in progress.
let tunnelPhaseIsNegotiating = (v: tunnelPhase): bool =>
  switch v {
  | Phase1Init | Phase1Auth | Phase2Negotiating => true
  | _ => false
  }

/// Whether Phase 1 (IKE SA) is complete.
let tunnelPhasePhase1Complete = (v: tunnelPhase): bool =>
  switch v {
  | Phase1Done | Phase2Negotiating | Established => true
  | _ => false
  }

// ===========================================================================
// EncryptionAlgorithm (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type encryptionAlgorithm =
  | @as(0) Aes128Cbc
  | @as(1) Aes256Cbc
  | @as(2) Aes128Gcm
  | @as(3) Aes256Gcm
  | @as(4) Chacha20Poly1305
  | @as(5) NullCipher

/// Decode from the C-ABI tag value.
let encryptionAlgorithmFromTag = (tag: int): option<encryptionAlgorithm> =>
  switch tag {
  | 0 => Some(Aes128Cbc)
  | 1 => Some(Aes256Cbc)
  | 2 => Some(Aes128Gcm)
  | 3 => Some(Aes256Gcm)
  | 4 => Some(Chacha20Poly1305)
  | 5 => Some(NullCipher)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let encryptionAlgorithmToTag = (v: encryptionAlgorithm): int =>
  switch v {
  | Aes128Cbc => 0
  | Aes256Cbc => 1
  | Aes128Gcm => 2
  | Aes256Gcm => 3
  | Chacha20Poly1305 => 4
  | NullCipher => 5
  }

/// Whether this algorithm provides authenticated encryption (AEAD).
let encryptionAlgorithmIsAead = (v: encryptionAlgorithm): bool =>
  switch v {
  | Aes128Gcm | Aes256Gcm | Chacha20Poly1305 => true
  | _ => false
  }

/// Whether this algorithm actually encrypts data.
let encryptionAlgorithmProvidesConfidentiality = (v: encryptionAlgorithm): bool =>
  switch v {
  | NullCipher => false
  | _ => true
  }

// ===========================================================================
// IntegrityAlgorithm (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type integrityAlgorithm =
  | @as(0) HmacSha1
  | @as(1) HmacSha256
  | @as(2) HmacSha384
  | @as(3) HmacSha512
  | @as(4) NoIntegrity

/// Decode from the C-ABI tag value.
let integrityAlgorithmFromTag = (tag: int): option<integrityAlgorithm> =>
  switch tag {
  | 0 => Some(HmacSha1)
  | 1 => Some(HmacSha256)
  | 2 => Some(HmacSha384)
  | 3 => Some(HmacSha512)
  | 4 => Some(NoIntegrity)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let integrityAlgorithmToTag = (v: integrityAlgorithm): int =>
  switch v {
  | HmacSha1 => 0
  | HmacSha256 => 1
  | HmacSha384 => 2
  | HmacSha512 => 3
  | NoIntegrity => 4
  }

/// Whether this algorithm provides integrity protection.
let integrityAlgorithmProvidesIntegrity = (v: integrityAlgorithm): bool =>
  switch v {
  | NoIntegrity => false
  | _ => true
  }

// ===========================================================================
// DhGroup (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type dhGroup =
  | @as(0) Dh14
  | @as(1) Ecp256
  | @as(2) Ecp384
  | @as(3) Curve25519

/// Decode from the C-ABI tag value.
let dhGroupFromTag = (tag: int): option<dhGroup> =>
  switch tag {
  | 0 => Some(Dh14)
  | 1 => Some(Ecp256)
  | 2 => Some(Ecp384)
  | 3 => Some(Curve25519)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dhGroupToTag = (v: dhGroup): int =>
  switch v {
  | Dh14 => 0
  | Ecp256 => 1
  | Ecp384 => 2
  | Curve25519 => 3
  }

/// Whether this group uses elliptic curve cryptography.
let dhGroupIsEcc = (v: dhGroup): bool =>
  switch v {
  | Ecp256 | Ecp384 | Curve25519 => true
  | _ => false
  }

// ===========================================================================
// SaLifecycle (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type saLifecycle =
  | @as(0) None
  | @as(1) Active
  | @as(2) Rekeying
  | @as(3) Expired
  | @as(4) Deleted

/// Decode from the C-ABI tag value.
let saLifecycleFromTag = (tag: int): option<saLifecycle> =>
  switch tag {
  | 0 => Some(None)
  | 1 => Some(Active)
  | 2 => Some(Rekeying)
  | 3 => Some(Expired)
  | 4 => Some(Deleted)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let saLifecycleToTag = (v: saLifecycle): int =>
  switch v {
  | None => 0
  | Active => 1
  | Rekeying => 2
  | Expired => 3
  | Deleted => 4
  }

/// Whether the SA is usable for traffic.
let saLifecycleIsUsable = (v: saLifecycle): bool =>
  switch v {
  | Active | Rekeying => true
  | _ => false
  }

/// Whether the SA has been terminated.
let saLifecycleIsTerminated = (v: saLifecycle): bool =>
  switch v {
  | Expired | Deleted => true
  | _ => false
  }

// ===========================================================================
// IkeVersion (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type ikeVersion =
  | @as(0) V1
  | @as(1) V2

/// Decode from the C-ABI tag value.
let ikeVersionFromTag = (tag: int): option<ikeVersion> =>
  switch tag {
  | 0 => Some(V1)
  | 1 => Some(V2)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ikeVersionToTag = (v: ikeVersion): int =>
  switch v {
  | V1 => 0
  | V2 => 1
  }

// ===========================================================================
// VpnError (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type vpnError =
  | @as(0) AuthenticationFailed
  | @as(1) NoProposalChosen
  | @as(2) LifetimeExpired
  | @as(3) InvalidSpi
  | @as(4) ReplayDetected
  | @as(5) NegotiationTimeout

/// Decode from the C-ABI tag value.
let vpnErrorFromTag = (tag: int): option<vpnError> =>
  switch tag {
  | 0 => Some(AuthenticationFailed)
  | 1 => Some(NoProposalChosen)
  | 2 => Some(LifetimeExpired)
  | 3 => Some(InvalidSpi)
  | 4 => Some(ReplayDetected)
  | 5 => Some(NegotiationTimeout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let vpnErrorToTag = (v: vpnError): int =>
  switch v {
  | AuthenticationFailed => 0
  | NoProposalChosen => 1
  | LifetimeExpired => 2
  | InvalidSpi => 3
  | ReplayDetected => 4
  | NegotiationTimeout => 5
  }

/// Whether this error indicates a security concern.
let vpnErrorIsSecurityConcern = (v: vpnError): bool =>
  switch v {
  | AuthenticationFailed | InvalidSpi | ReplayDetected => true
  | _ => false
  }

/// Whether this error is likely transient and retryable.
let vpnErrorIsRetryable = (v: vpnError): bool =>
  switch v {
  | NegotiationTimeout | LifetimeExpired => true
  | _ => false
  }

