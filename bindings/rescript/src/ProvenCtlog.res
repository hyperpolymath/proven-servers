// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log types for the proven-servers ABI.
//
// Mirrors the Idris2 module CtlogABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// LogEntryType (tags 0-1)
// ===========================================================================

/// CT log entry types.
type logEntryType =
  | @as(0) X509Entry
  | @as(1) PrecertEntry

/// Decode from the C-ABI tag value.
let logEntryTypeFromTag = (tag: int): option<logEntryType> =>
  switch tag {
  | 0 => Some(X509Entry)
  | 1 => Some(PrecertEntry)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let logEntryTypeToTag = (v: logEntryType): int =>
  switch v {
  | X509Entry => 0
  | PrecertEntry => 1
  }

// ===========================================================================
// SignatureType (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type signatureType =
  | @as(0) CertificateTimestamp
  | @as(1) TreeHash

/// Decode from the C-ABI tag value.
let signatureTypeFromTag = (tag: int): option<signatureType> =>
  switch tag {
  | 0 => Some(CertificateTimestamp)
  | 1 => Some(TreeHash)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let signatureTypeToTag = (v: signatureType): int =>
  switch v {
  | CertificateTimestamp => 0
  | TreeHash => 1
  }

// ===========================================================================
// MerkleLeafType (tags 0-0)
// ===========================================================================

/// Decode from an ABI tag value.
type merkleLeafType =
  | @as(0) TimestampedEntry

/// Decode from the C-ABI tag value.
let merkleLeafTypeFromTag = (tag: int): option<merkleLeafType> =>
  switch tag {
  | 0 => Some(TimestampedEntry)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let merkleLeafTypeToTag = (v: merkleLeafType): int =>
  switch v {
  | TimestampedEntry => 0
  }

// ===========================================================================
// SubmissionStatus (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type submissionStatus =
  | @as(0) Accepted
  | @as(1) Duplicate
  | @as(2) RateLimited
  | @as(3) Rejected
  | @as(4) InvalidChain
  | @as(5) UnknownAnchor

/// Decode from the C-ABI tag value.
let submissionStatusFromTag = (tag: int): option<submissionStatus> =>
  switch tag {
  | 0 => Some(Accepted)
  | 1 => Some(Duplicate)
  | 2 => Some(RateLimited)
  | 3 => Some(Rejected)
  | 4 => Some(InvalidChain)
  | 5 => Some(UnknownAnchor)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let submissionStatusToTag = (v: submissionStatus): int =>
  switch v {
  | Accepted => 0
  | Duplicate => 1
  | RateLimited => 2
  | Rejected => 3
  | InvalidChain => 4
  | UnknownAnchor => 5
  }

// ===========================================================================
// VerificationResult (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type verificationResult =
  | @as(0) ValidProof
  | @as(1) InvalidProof
  | @as(2) InconsistentTree
  | @as(3) StaleSth

/// Decode from the C-ABI tag value.
let verificationResultFromTag = (tag: int): option<verificationResult> =>
  switch tag {
  | 0 => Some(ValidProof)
  | 1 => Some(InvalidProof)
  | 2 => Some(InconsistentTree)
  | 3 => Some(StaleSth)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let verificationResultToTag = (v: verificationResult): int =>
  switch v {
  | ValidProof => 0
  | InvalidProof => 1
  | InconsistentTree => 2
  | StaleSth => 3
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Active
  | @as(2) Merging
  | @as(3) Signing
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Active)
  | 2 => Some(Merging)
  | 3 => Some(Signing)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Active => 1
  | Merging => 2
  | Signing => 3
  | Shutdown => 4
  }

