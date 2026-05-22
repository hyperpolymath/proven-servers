// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Certificate Authority types for the proven-servers ABI.
//
// Mirrors the Idris2 module CaABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard CA API port.
let caPort = 8443

// ===========================================================================
// CertType (tags 0-6)
// ===========================================================================

/// Standard CA API port.
type certType =
  | @as(0) Root
  | @as(1) Intermediate
  | @as(2) EndEntity
  | @as(3) CrossSigned
  | @as(4) CodeSigning
  | @as(5) EmailProtection
  | @as(6) OcspSigning

/// Decode from the C-ABI tag value.
let certTypeFromTag = (tag: int): option<certType> =>
  switch tag {
  | 0 => Some(Root)
  | 1 => Some(Intermediate)
  | 2 => Some(EndEntity)
  | 3 => Some(CrossSigned)
  | 4 => Some(CodeSigning)
  | 5 => Some(EmailProtection)
  | 6 => Some(OcspSigning)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let certTypeToTag = (v: certType): int =>
  switch v {
  | Root => 0
  | Intermediate => 1
  | EndEntity => 2
  | CrossSigned => 3
  | CodeSigning => 4
  | EmailProtection => 5
  | OcspSigning => 6
  }

/// Whether this certificate type is a CA certificate.
let certTypeIsCa = (v: certType): bool =>
  switch v {
  | Root | Intermediate | CrossSigned => true
  | _ => false
  }

// ===========================================================================
// KeyAlgorithm (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type keyAlgorithm =
  | @as(0) Rsa2048
  | @as(1) Rsa4096
  | @as(2) EcdsaP256
  | @as(3) EcdsaP384
  | @as(4) Ed25519
  | @as(5) Ed448

/// Decode from the C-ABI tag value.
let keyAlgorithmFromTag = (tag: int): option<keyAlgorithm> =>
  switch tag {
  | 0 => Some(Rsa2048)
  | 1 => Some(Rsa4096)
  | 2 => Some(EcdsaP256)
  | 3 => Some(EcdsaP384)
  | 4 => Some(Ed25519)
  | 5 => Some(Ed448)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let keyAlgorithmToTag = (v: keyAlgorithm): int =>
  switch v {
  | Rsa2048 => 0
  | Rsa4096 => 1
  | EcdsaP256 => 2
  | EcdsaP384 => 3
  | Ed25519 => 4
  | Ed448 => 5
  }

/// Whether this is an RSA algorithm.
let keyAlgorithmIsRsa = (v: keyAlgorithm): bool =>
  switch v {
  | Rsa2048 | Rsa4096 => true
  | _ => false
  }

/// Whether this is an elliptic curve algorithm.
let keyAlgorithmIsEllipticCurve = (v: keyAlgorithm): bool =>
  switch v {
  | EcdsaP256 | EcdsaP384 | Ed25519 | Ed448 => true
  | _ => false
  }

// ===========================================================================
// SignatureAlgorithm (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type signatureAlgorithm =
  | @as(0) Sha256WithRsa
  | @as(1) Sha384WithRsa
  | @as(2) Sha512WithRsa
  | @as(3) Sha256WithEcdsa
  | @as(4) Sha384WithEcdsa
  | @as(5) PureEd25519
  | @as(6) PureEd448

/// Decode from the C-ABI tag value.
let signatureAlgorithmFromTag = (tag: int): option<signatureAlgorithm> =>
  switch tag {
  | 0 => Some(Sha256WithRsa)
  | 1 => Some(Sha384WithRsa)
  | 2 => Some(Sha512WithRsa)
  | 3 => Some(Sha256WithEcdsa)
  | 4 => Some(Sha384WithEcdsa)
  | 5 => Some(PureEd25519)
  | 6 => Some(PureEd448)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let signatureAlgorithmToTag = (v: signatureAlgorithm): int =>
  switch v {
  | Sha256WithRsa => 0
  | Sha384WithRsa => 1
  | Sha512WithRsa => 2
  | Sha256WithEcdsa => 3
  | Sha384WithEcdsa => 4
  | PureEd25519 => 5
  | PureEd448 => 6
  }

// ===========================================================================
// CertState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type certState =
  | @as(0) Pending
  | @as(1) Active
  | @as(2) Revoked
  | @as(3) Expired
  | @as(4) Suspended

/// Decode from the C-ABI tag value.
let certStateFromTag = (tag: int): option<certState> =>
  switch tag {
  | 0 => Some(Pending)
  | 1 => Some(Active)
  | 2 => Some(Revoked)
  | 3 => Some(Expired)
  | 4 => Some(Suspended)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let certStateToTag = (v: certState): int =>
  switch v {
  | Pending => 0
  | Active => 1
  | Revoked => 2
  | Expired => 3
  | Suspended => 4
  }

/// Whether the certificate can be used.
let certStateIsUsable = (v: certState): bool =>
  switch v {
  | Active => true
  | _ => false
  }

// ===========================================================================
// RevocationReason (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type revocationReason =
  | @as(0) Unspecified
  | @as(1) KeyCompromise
  | @as(2) CaCompromise
  | @as(3) AffiliationChanged
  | @as(4) Superseded
  | @as(5) CessationOfOperation
  | @as(6) CertificateHold

/// Decode from the C-ABI tag value.
let revocationReasonFromTag = (tag: int): option<revocationReason> =>
  switch tag {
  | 0 => Some(Unspecified)
  | 1 => Some(KeyCompromise)
  | 2 => Some(CaCompromise)
  | 3 => Some(AffiliationChanged)
  | 4 => Some(Superseded)
  | 5 => Some(CessationOfOperation)
  | 6 => Some(CertificateHold)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let revocationReasonToTag = (v: revocationReason): int =>
  switch v {
  | Unspecified => 0
  | KeyCompromise => 1
  | CaCompromise => 2
  | AffiliationChanged => 3
  | Superseded => 4
  | CessationOfOperation => 5
  | CertificateHold => 6
  }

/// Whether this revocation indicates a security incident.
let revocationReasonIsSecurityIncident = (v: revocationReason): bool =>
  switch v {
  | KeyCompromise | CaCompromise => true
  | _ => false
  }

// ===========================================================================
// CrlStatus (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type crlStatus =
  | @as(0) Current
  | @as(1) CrlExpired
  | @as(2) CrlPending
  | @as(3) CrlError

/// Decode from the C-ABI tag value.
let crlStatusFromTag = (tag: int): option<crlStatus> =>
  switch tag {
  | 0 => Some(Current)
  | 1 => Some(CrlExpired)
  | 2 => Some(CrlPending)
  | 3 => Some(CrlError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let crlStatusToTag = (v: crlStatus): int =>
  switch v {
  | Current => 0
  | CrlExpired => 1
  | CrlPending => 2
  | CrlError => 3
  }

// ===========================================================================
// OcspStatus (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type ocspStatus =
  | @as(0) Good
  | @as(1) OcspRevoked
  | @as(2) Unknown
  | @as(3) Unavailable

/// Decode from the C-ABI tag value.
let ocspStatusFromTag = (tag: int): option<ocspStatus> =>
  switch tag {
  | 0 => Some(Good)
  | 1 => Some(OcspRevoked)
  | 2 => Some(Unknown)
  | 3 => Some(Unavailable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ocspStatusToTag = (v: ocspStatus): int =>
  switch v {
  | Good => 0
  | OcspRevoked => 1
  | Unknown => 2
  | Unavailable => 3
  }

// ===========================================================================
// Extension (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type extension =
  | @as(0) BasicConstraints
  | @as(1) KeyUsage
  | @as(2) ExtKeyUsage
  | @as(3) SubjectAltName
  | @as(4) AuthorityInfoAccess
  | @as(5) CrlDistributionPoints

/// Decode from the C-ABI tag value.
let extensionFromTag = (tag: int): option<extension> =>
  switch tag {
  | 0 => Some(BasicConstraints)
  | 1 => Some(KeyUsage)
  | 2 => Some(ExtKeyUsage)
  | 3 => Some(SubjectAltName)
  | 4 => Some(AuthorityInfoAccess)
  | 5 => Some(CrlDistributionPoints)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let extensionToTag = (v: extension): int =>
  switch v {
  | BasicConstraints => 0
  | KeyUsage => 1
  | ExtKeyUsage => 2
  | SubjectAltName => 3
  | AuthorityInfoAccess => 4
  | CrlDistributionPoints => 5
  }

// ===========================================================================
// KeyUsageBit (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type keyUsageBit =
  | @as(0) DigitalSignature
  | @as(1) NonRepudiation
  | @as(2) KeyEncipherment
  | @as(3) DataEncipherment
  | @as(4) KeyAgreement
  | @as(5) KeyCertSign
  | @as(6) CrlSign
  | @as(7) EncipherOnly
  | @as(8) DecipherOnly

/// Decode from the C-ABI tag value.
let keyUsageBitFromTag = (tag: int): option<keyUsageBit> =>
  switch tag {
  | 0 => Some(DigitalSignature)
  | 1 => Some(NonRepudiation)
  | 2 => Some(KeyEncipherment)
  | 3 => Some(DataEncipherment)
  | 4 => Some(KeyAgreement)
  | 5 => Some(KeyCertSign)
  | 6 => Some(CrlSign)
  | 7 => Some(EncipherOnly)
  | 8 => Some(DecipherOnly)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let keyUsageBitToTag = (v: keyUsageBit): int =>
  switch v {
  | DigitalSignature => 0
  | NonRepudiation => 1
  | KeyEncipherment => 2
  | DataEncipherment => 3
  | KeyAgreement => 4
  | KeyCertSign => 5
  | CrlSign => 6
  | EncipherOnly => 7
  | DecipherOnly => 8
  }

