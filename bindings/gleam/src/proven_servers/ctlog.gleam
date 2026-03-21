//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Certificate Transparency Log protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `CtlogABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// LogEntryType
// ===========================================================================

/// CT log entry types.
/// 
/// Matches `LogEntryType` in `CtlogABI.Types`.
pub type LogEntryType {
  /// X509Entry (tag 0).
  X509Entry
  /// PrecertEntry (tag 1).
  PrecertEntry
}

/// Convert a `LogEntryType` to its C-ABI tag value.
pub fn log_entry_type_to_int(value: LogEntryType) -> Int {
  case value {
    X509Entry -> 0
    PrecertEntry -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn log_entry_type_from_int(tag: Int) -> Result(LogEntryType, Nil) {
  case tag {
    0 -> Ok(X509Entry)
    1 -> Ok(PrecertEntry)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SignatureType
// ===========================================================================

/// CT signature types.
/// 
/// Matches `SignatureType` in `CtlogABI.Types`.
pub type SignatureType {
  /// CertificateTimestamp (tag 0).
  CertificateTimestamp
  /// TreeHash (tag 1).
  TreeHash
}

/// Convert a `SignatureType` to its C-ABI tag value.
pub fn signature_type_to_int(value: SignatureType) -> Int {
  case value {
    CertificateTimestamp -> 0
    TreeHash -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn signature_type_from_int(tag: Int) -> Result(SignatureType, Nil) {
  case tag {
    0 -> Ok(CertificateTimestamp)
    1 -> Ok(TreeHash)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MerkleLeafType
// ===========================================================================

/// Merkle tree leaf types.
/// 
/// Matches `MerkleLeafType` in `CtlogABI.Types`.
pub type MerkleLeafType {
  /// TimestampedEntry (tag 0).
  TimestampedEntry
}

/// Convert a `MerkleLeafType` to its C-ABI tag value.
pub fn merkle_leaf_type_to_int(value: MerkleLeafType) -> Int {
  case value {
    TimestampedEntry -> 0
  }
}

/// Decode from a C-ABI tag value.
pub fn merkle_leaf_type_from_int(tag: Int) -> Result(MerkleLeafType, Nil) {
  case tag {
    0 -> Ok(TimestampedEntry)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SubmissionStatus
// ===========================================================================

/// Certificate submission status.
/// 
/// Matches `SubmissionStatus` in `CtlogABI.Types`.
pub type SubmissionStatus {
  /// Accepted (tag 0).
  Accepted
  /// Duplicate (tag 1).
  Duplicate
  /// RateLimited (tag 2).
  RateLimited
  /// Rejected (tag 3).
  Rejected
  /// InvalidChain (tag 4).
  InvalidChain
  /// UnknownAnchor (tag 5).
  UnknownAnchor
}

/// Convert a `SubmissionStatus` to its C-ABI tag value.
pub fn submission_status_to_int(value: SubmissionStatus) -> Int {
  case value {
    Accepted -> 0
    Duplicate -> 1
    RateLimited -> 2
    Rejected -> 3
    InvalidChain -> 4
    UnknownAnchor -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn submission_status_from_int(tag: Int) -> Result(SubmissionStatus, Nil) {
  case tag {
    0 -> Ok(Accepted)
    1 -> Ok(Duplicate)
    2 -> Ok(RateLimited)
    3 -> Ok(Rejected)
    4 -> Ok(InvalidChain)
    5 -> Ok(UnknownAnchor)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// VerificationResult
// ===========================================================================

/// Proof verification results.
/// 
/// Matches `VerificationResult` in `CtlogABI.Types`.
pub type VerificationResult {
  /// ValidProof (tag 0).
  ValidProof
  /// InvalidProof (tag 1).
  InvalidProof
  /// InconsistentTree (tag 2).
  InconsistentTree
  /// Stale STH (tag 3).
  StaleSth
}

/// Convert a `VerificationResult` to its C-ABI tag value.
pub fn verification_result_to_int(value: VerificationResult) -> Int {
  case value {
    ValidProof -> 0
    InvalidProof -> 1
    InconsistentTree -> 2
    StaleSth -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn verification_result_from_int(tag: Int) -> Result(VerificationResult, Nil) {
  case tag {
    0 -> Ok(ValidProof)
    1 -> Ok(InvalidProof)
    2 -> Ok(InconsistentTree)
    3 -> Ok(StaleSth)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// CT log server states.
/// 
/// Matches `ServerState` in `CtlogABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Active (tag 1).
  Active
  /// Merging (tag 2).
  Merging
  /// Signing (tag 3).
  Signing
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Active -> 1
    Merging -> 2
    Signing -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Active)
    2 -> Ok(Merging)
    3 -> Ok(Signing)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

