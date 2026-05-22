//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// PKI/CA protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `CaABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// PKI/CA Constants
// ===========================================================================

/// Ca Port constant.
pub const ca_port = 8443

// ===========================================================================
// CertType
// ===========================================================================

/// X.509 certificate types.
/// 
/// Matches `CertType` in `CaABI.Types`.
pub type CertType {
  /// Root (tag 0).
  Root
  /// Intermediate (tag 1).
  Intermediate
  /// EndEntity (tag 2).
  EndEntity
  /// CrossSigned (tag 3).
  CrossSigned
  /// CodeSigning (tag 4).
  CodeSigning
  /// EmailProtection (tag 5).
  EmailProtection
  /// OCSP signing (tag 6).
  OcspSigning
}

/// Convert a `CertType` to its C-ABI tag value.
pub fn cert_type_to_int(value: CertType) -> Int {
  case value {
    Root -> 0
    Intermediate -> 1
    EndEntity -> 2
    CrossSigned -> 3
    CodeSigning -> 4
    EmailProtection -> 5
    OcspSigning -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn cert_type_from_int(tag: Int) -> Result(CertType, Nil) {
  case tag {
    0 -> Ok(Root)
    1 -> Ok(Intermediate)
    2 -> Ok(EndEntity)
    3 -> Ok(CrossSigned)
    4 -> Ok(CodeSigning)
    5 -> Ok(EmailProtection)
    6 -> Ok(OcspSigning)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KeyAlgorithm
// ===========================================================================

/// Cryptographic key algorithms.
/// 
/// Matches `KeyAlgorithm` in `CaABI.Types`.
pub type KeyAlgorithm {
  /// Rsa2048 (tag 0).
  Rsa2048
  /// Rsa4096 (tag 1).
  Rsa4096
  /// ECDSA P-256 (tag 2).
  EcdsaP256
  /// ECDSA P-384 (tag 3).
  EcdsaP384
  /// Ed25519 (tag 4).
  Ed25519
  /// Ed448 (tag 5).
  Ed448
}

/// Convert a `KeyAlgorithm` to its C-ABI tag value.
pub fn key_algorithm_to_int(value: KeyAlgorithm) -> Int {
  case value {
    Rsa2048 -> 0
    Rsa4096 -> 1
    EcdsaP256 -> 2
    EcdsaP384 -> 3
    Ed25519 -> 4
    Ed448 -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn key_algorithm_from_int(tag: Int) -> Result(KeyAlgorithm, Nil) {
  case tag {
    0 -> Ok(Rsa2048)
    1 -> Ok(Rsa4096)
    2 -> Ok(EcdsaP256)
    3 -> Ok(EcdsaP384)
    4 -> Ok(Ed25519)
    5 -> Ok(Ed448)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SignatureAlgorithm
// ===========================================================================

/// Cryptographic signature algorithms.
/// 
/// Matches `SignatureAlgorithm` in `CaABI.Types`.
pub type SignatureAlgorithm {
  /// Sha256WithRsa (tag 0).
  Sha256WithRsa
  /// Sha384WithRsa (tag 1).
  Sha384WithRsa
  /// Sha512WithRsa (tag 2).
  Sha512WithRsa
  /// Sha256WithEcdsa (tag 3).
  Sha256WithEcdsa
  /// Sha384WithEcdsa (tag 4).
  Sha384WithEcdsa
  /// PureEd25519 (tag 5).
  PureEd25519
  /// PureEd448 (tag 6).
  PureEd448
}

/// Convert a `SignatureAlgorithm` to its C-ABI tag value.
pub fn signature_algorithm_to_int(value: SignatureAlgorithm) -> Int {
  case value {
    Sha256WithRsa -> 0
    Sha384WithRsa -> 1
    Sha512WithRsa -> 2
    Sha256WithEcdsa -> 3
    Sha384WithEcdsa -> 4
    PureEd25519 -> 5
    PureEd448 -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn signature_algorithm_from_int(tag: Int) -> Result(SignatureAlgorithm, Nil) {
  case tag {
    0 -> Ok(Sha256WithRsa)
    1 -> Ok(Sha384WithRsa)
    2 -> Ok(Sha512WithRsa)
    3 -> Ok(Sha256WithEcdsa)
    4 -> Ok(Sha384WithEcdsa)
    5 -> Ok(PureEd25519)
    6 -> Ok(PureEd448)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CertState
// ===========================================================================

/// Certificate lifecycle states.
/// 
/// Matches `CertState` in `CaABI.Types`.
pub type CertState {
  /// Pending (tag 0).
  Pending
  /// Active (tag 1).
  Active
  /// Revoked (tag 2).
  Revoked
  /// Expired (tag 3).
  Expired
  /// Suspended (tag 4).
  Suspended
}

/// Convert a `CertState` to its C-ABI tag value.
pub fn cert_state_to_int(value: CertState) -> Int {
  case value {
    Pending -> 0
    Active -> 1
    Revoked -> 2
    Expired -> 3
    Suspended -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn cert_state_from_int(tag: Int) -> Result(CertState, Nil) {
  case tag {
    0 -> Ok(Pending)
    1 -> Ok(Active)
    2 -> Ok(Revoked)
    3 -> Ok(Expired)
    4 -> Ok(Suspended)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RevocationReason
// ===========================================================================

/// Certificate revocation reasons (RFC 5280).
/// 
/// Matches `RevocationReason` in `CaABI.Types`.
pub type RevocationReason {
  /// Unspecified (tag 0).
  Unspecified
  /// KeyCompromise (tag 1).
  KeyCompromise
  /// CaCompromise (tag 2).
  CaCompromise
  /// AffiliationChanged (tag 3).
  AffiliationChanged
  /// Superseded (tag 4).
  Superseded
  /// CessationOfOperation (tag 5).
  CessationOfOperation
  /// CertificateHold (tag 6).
  CertificateHold
}

/// Convert a `RevocationReason` to its C-ABI tag value.
pub fn revocation_reason_to_int(value: RevocationReason) -> Int {
  case value {
    Unspecified -> 0
    KeyCompromise -> 1
    CaCompromise -> 2
    AffiliationChanged -> 3
    Superseded -> 4
    CessationOfOperation -> 5
    CertificateHold -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn revocation_reason_from_int(tag: Int) -> Result(RevocationReason, Nil) {
  case tag {
    0 -> Ok(Unspecified)
    1 -> Ok(KeyCompromise)
    2 -> Ok(CaCompromise)
    3 -> Ok(AffiliationChanged)
    4 -> Ok(Superseded)
    5 -> Ok(CessationOfOperation)
    6 -> Ok(CertificateHold)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CrlStatus
// ===========================================================================

/// CRL status.
/// 
/// Matches `CrlStatus` in `CaABI.Types`.
pub type CrlStatus {
  /// Current (tag 0).
  Current
  /// CrlExpired (tag 1).
  CrlExpired
  /// CrlPending (tag 2).
  CrlPending
  /// CrlError (tag 3).
  CrlError
}

/// Convert a `CrlStatus` to its C-ABI tag value.
pub fn crl_status_to_int(value: CrlStatus) -> Int {
  case value {
    Current -> 0
    CrlExpired -> 1
    CrlPending -> 2
    CrlError -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn crl_status_from_int(tag: Int) -> Result(CrlStatus, Nil) {
  case tag {
    0 -> Ok(Current)
    1 -> Ok(CrlExpired)
    2 -> Ok(CrlPending)
    3 -> Ok(CrlError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OcspStatus
// ===========================================================================

/// OCSP response status.
/// 
/// Matches `OcspStatus` in `CaABI.Types`.
pub type OcspStatus {
  /// Good (tag 0).
  Good
  /// OcspRevoked (tag 1).
  OcspRevoked
  /// Unknown (tag 2).
  Unknown
  /// Unavailable (tag 3).
  Unavailable
}

/// Convert a `OcspStatus` to its C-ABI tag value.
pub fn ocsp_status_to_int(value: OcspStatus) -> Int {
  case value {
    Good -> 0
    OcspRevoked -> 1
    Unknown -> 2
    Unavailable -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn ocsp_status_from_int(tag: Int) -> Result(OcspStatus, Nil) {
  case tag {
    0 -> Ok(Good)
    1 -> Ok(OcspRevoked)
    2 -> Ok(Unknown)
    3 -> Ok(Unavailable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Extension
// ===========================================================================

/// X.509 extension types.
/// 
/// Matches `Extension` in `CaABI.Types`.
pub type Extension {
  /// BasicConstraints (tag 0).
  BasicConstraints
  /// KeyUsage (tag 1).
  KeyUsage
  /// ExtKeyUsage (tag 2).
  ExtKeyUsage
  /// SubjectAltName (tag 3).
  SubjectAltName
  /// AuthorityInfoAccess (tag 4).
  AuthorityInfoAccess
  /// CrlDistributionPoints (tag 5).
  CrlDistributionPoints
}

/// Convert a `Extension` to its C-ABI tag value.
pub fn extension_to_int(value: Extension) -> Int {
  case value {
    BasicConstraints -> 0
    KeyUsage -> 1
    ExtKeyUsage -> 2
    SubjectAltName -> 3
    AuthorityInfoAccess -> 4
    CrlDistributionPoints -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn extension_from_int(tag: Int) -> Result(Extension, Nil) {
  case tag {
    0 -> Ok(BasicConstraints)
    1 -> Ok(KeyUsage)
    2 -> Ok(ExtKeyUsage)
    3 -> Ok(SubjectAltName)
    4 -> Ok(AuthorityInfoAccess)
    5 -> Ok(CrlDistributionPoints)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KeyUsageBit
// ===========================================================================

/// Key usage bit flags (RFC 5280).
/// 
/// Matches `KeyUsageBit` in `CaABI.Types`.
pub type KeyUsageBit {
  /// DigitalSignature (tag 0).
  DigitalSignature
  /// NonRepudiation (tag 1).
  NonRepudiation
  /// KeyEncipherment (tag 2).
  KeyEncipherment
  /// DataEncipherment (tag 3).
  DataEncipherment
  /// KeyAgreement (tag 4).
  KeyAgreement
  /// KeyCertSign (tag 5).
  KeyCertSign
  /// CrlSign (tag 6).
  CrlSign
  /// EncipherOnly (tag 7).
  EncipherOnly
  /// DecipherOnly (tag 8).
  DecipherOnly
}

/// Convert a `KeyUsageBit` to its C-ABI tag value.
pub fn key_usage_bit_to_int(value: KeyUsageBit) -> Int {
  case value {
    DigitalSignature -> 0
    NonRepudiation -> 1
    KeyEncipherment -> 2
    DataEncipherment -> 3
    KeyAgreement -> 4
    KeyCertSign -> 5
    CrlSign -> 6
    EncipherOnly -> 7
    DecipherOnly -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn key_usage_bit_from_int(tag: Int) -> Result(KeyUsageBit, Nil) {
  case tag {
    0 -> Ok(DigitalSignature)
    1 -> Ok(NonRepudiation)
    2 -> Ok(KeyEncipherment)
    3 -> Ok(DataEncipherment)
    4 -> Ok(KeyAgreement)
    5 -> Ok(KeyCertSign)
    6 -> Ok(CrlSign)
    7 -> Ok(EncipherOnly)
    8 -> Ok(DecipherOnly)
    _ -> Error(Nil)
  }
}

