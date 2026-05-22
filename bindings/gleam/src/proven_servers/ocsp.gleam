//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// OCSP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `OcspABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// OCSP Constants
// ===========================================================================

/// Ocsp Port constant.
pub const ocsp_port = 80

// ===========================================================================
// CertStatus
// ===========================================================================

/// Certificate status in OCSP response.
/// 
/// Matches `CertStatus` in `OcspABI.Types`.
pub type CertStatus {
  /// Good (tag 0).
  Good
  /// Revoked (tag 1).
  Revoked
  /// Unknown (tag 2).
  Unknown
}

/// Convert a `CertStatus` to its C-ABI tag value.
pub fn cert_status_to_int(value: CertStatus) -> Int {
  case value {
    Good -> 0
    Revoked -> 1
    Unknown -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn cert_status_from_int(tag: Int) -> Result(CertStatus, Nil) {
  case tag {
    0 -> Ok(Good)
    1 -> Ok(Revoked)
    2 -> Ok(Unknown)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponseStatus
// ===========================================================================

/// OCSP response status.
/// 
/// Matches `ResponseStatus` in `OcspABI.Types`.
pub type ResponseStatus {
  /// Successful (tag 0).
  Successful
  /// MalformedRequest (tag 1).
  MalformedRequest
  /// InternalError (tag 2).
  InternalError
  /// TryLater (tag 3).
  TryLater
  /// SigRequired (tag 4).
  SigRequired
  /// Unauthorized (tag 5).
  Unauthorized
}

/// Convert a `ResponseStatus` to its C-ABI tag value.
pub fn response_status_to_int(value: ResponseStatus) -> Int {
  case value {
    Successful -> 0
    MalformedRequest -> 1
    InternalError -> 2
    TryLater -> 3
    SigRequired -> 4
    Unauthorized -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn response_status_from_int(tag: Int) -> Result(ResponseStatus, Nil) {
  case tag {
    0 -> Ok(Successful)
    1 -> Ok(MalformedRequest)
    2 -> Ok(InternalError)
    3 -> Ok(TryLater)
    4 -> Ok(SigRequired)
    5 -> Ok(Unauthorized)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HashAlgorithm
// ===========================================================================

/// OCSP hash algorithms.
/// 
/// Matches `HashAlgorithm` in `OcspABI.Types`.
pub type HashAlgorithm {
  /// SHA-1 (legacy) (tag 0).
  Sha1
  /// SHA-256 (tag 1).
  Sha256
  /// SHA-384 (tag 2).
  Sha384
  /// SHA-512 (tag 3).
  Sha512
}

/// Convert a `HashAlgorithm` to its C-ABI tag value.
pub fn hash_algorithm_to_int(value: HashAlgorithm) -> Int {
  case value {
    Sha1 -> 0
    Sha256 -> 1
    Sha384 -> 2
    Sha512 -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn hash_algorithm_from_int(tag: Int) -> Result(HashAlgorithm, Nil) {
  case tag {
    0 -> Ok(Sha1)
    1 -> Ok(Sha256)
    2 -> Ok(Sha384)
    3 -> Ok(Sha512)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponderState
// ===========================================================================

/// OCSP responder states.
/// 
/// Matches `ResponderState` in `OcspABI.Types`.
pub type ResponderState {
  /// Idle (tag 0).
  Idle
  /// Ready (tag 1).
  Ready
  /// Processing (tag 2).
  Processing
  /// Signing (tag 3).
  Signing
  /// Closing (tag 4).
  Closing
}

/// Convert a `ResponderState` to its C-ABI tag value.
pub fn responder_state_to_int(value: ResponderState) -> Int {
  case value {
    Idle -> 0
    Ready -> 1
    Processing -> 2
    Signing -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn responder_state_from_int(tag: Int) -> Result(ResponderState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Ready)
    2 -> Ok(Processing)
    3 -> Ok(Signing)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

