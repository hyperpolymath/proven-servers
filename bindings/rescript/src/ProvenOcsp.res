// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP types for the proven-servers ABI.
//
// Mirrors the Idris2 module OcspABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard OCSP HTTP port.
let ocspPort = 80

// ===========================================================================
// CertStatus (tags 0-2)
// ===========================================================================

/// Standard OCSP HTTP port.
type certStatus =
  | @as(0) Good
  | @as(1) Revoked
  | @as(2) Unknown

/// Decode from the C-ABI tag value.
let certStatusFromTag = (tag: int): option<certStatus> =>
  switch tag {
  | 0 => Some(Good)
  | 1 => Some(Revoked)
  | 2 => Some(Unknown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let certStatusToTag = (v: certStatus): int =>
  switch v {
  | Good => 0
  | Revoked => 1
  | Unknown => 2
  }

// ===========================================================================
// ResponseStatus (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type responseStatus =
  | @as(0) Successful
  | @as(1) MalformedRequest
  | @as(2) InternalError
  | @as(3) TryLater
  | @as(4) SigRequired
  | @as(5) Unauthorized

/// Decode from the C-ABI tag value.
let responseStatusFromTag = (tag: int): option<responseStatus> =>
  switch tag {
  | 0 => Some(Successful)
  | 1 => Some(MalformedRequest)
  | 2 => Some(InternalError)
  | 3 => Some(TryLater)
  | 4 => Some(SigRequired)
  | 5 => Some(Unauthorized)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responseStatusToTag = (v: responseStatus): int =>
  switch v {
  | Successful => 0
  | MalformedRequest => 1
  | InternalError => 2
  | TryLater => 3
  | SigRequired => 4
  | Unauthorized => 5
  }

// ===========================================================================
// HashAlgorithm (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type hashAlgorithm =
  | @as(0) Sha1
  | @as(1) Sha256
  | @as(2) Sha384
  | @as(3) Sha512

/// Decode from the C-ABI tag value.
let hashAlgorithmFromTag = (tag: int): option<hashAlgorithm> =>
  switch tag {
  | 0 => Some(Sha1)
  | 1 => Some(Sha256)
  | 2 => Some(Sha384)
  | 3 => Some(Sha512)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hashAlgorithmToTag = (v: hashAlgorithm): int =>
  switch v {
  | Sha1 => 0
  | Sha256 => 1
  | Sha384 => 2
  | Sha512 => 3
  }

// ===========================================================================
// ResponderState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type responderState =
  | @as(0) Idle
  | @as(1) Ready
  | @as(2) Processing
  | @as(3) Signing
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let responderStateFromTag = (tag: int): option<responderState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Ready)
  | 2 => Some(Processing)
  | 3 => Some(Signing)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responderStateToTag = (v: responderState): int =>
  switch v {
  | Idle => 0
  | Ready => 1
  | Processing => 2
  | Signing => 3
  | Closing => 4
  }

