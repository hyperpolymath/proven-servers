// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! CT Log types for the proven-servers ABI.
//!
//! Formally verified Certificate Transparency log types (RFC 6962).
//! Mirrors the Idris2 module `CtlogABI.Types`.
//!
//! - `LogEntryType` -- CT log entry types.
//! - `SignatureType` -- CT signature types.
//! - `MerkleLeafType` -- Merkle tree leaf types.
//! - `SubmissionStatus` -- Certificate submission status.
//! - `VerificationResult` -- Proof verification results.
//! - `ServerState` -- CT log server states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// LogEntryType (tags 0-1)
// ===========================================================================

/// CT log entry types.
///
/// Matches `LogEntryType` in `CtlogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LogEntryType {
    /// X509Entry (tag 0).
    X509Entry = 0,
    /// PrecertEntry (tag 1).
    PrecertEntry = 1,
}

impl LogEntryType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::X509Entry),
            1 => Some(Self::PrecertEntry),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [LogEntryType; 2] = [
        Self::X509Entry, Self::PrecertEntry,
    ];
}

impl fmt::Display for LogEntryType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SignatureType (tags 0-1)
// ===========================================================================

/// CT signature types.
///
/// Matches `SignatureType` in `CtlogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SignatureType {
    /// CertificateTimestamp (tag 0).
    CertificateTimestamp = 0,
    /// TreeHash (tag 1).
    TreeHash = 1,
}

impl SignatureType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::CertificateTimestamp),
            1 => Some(Self::TreeHash),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SignatureType; 2] = [
        Self::CertificateTimestamp, Self::TreeHash,
    ];
}

impl fmt::Display for SignatureType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MerkleLeafType (tags 0-0)
// ===========================================================================

/// Merkle tree leaf types.
///
/// Matches `MerkleLeafType` in `CtlogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MerkleLeafType {
    /// TimestampedEntry (tag 0).
    TimestampedEntry = 0,
}

impl MerkleLeafType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::TimestampedEntry),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MerkleLeafType; 1] = [
        Self::TimestampedEntry,
    ];
}

impl fmt::Display for MerkleLeafType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SubmissionStatus (tags 0-5)
// ===========================================================================

/// Certificate submission status.
///
/// Matches `SubmissionStatus` in `CtlogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SubmissionStatus {
    /// Accepted (tag 0).
    Accepted = 0,
    /// Duplicate (tag 1).
    Duplicate = 1,
    /// RateLimited (tag 2).
    RateLimited = 2,
    /// Rejected (tag 3).
    Rejected = 3,
    /// InvalidChain (tag 4).
    InvalidChain = 4,
    /// UnknownAnchor (tag 5).
    UnknownAnchor = 5,
}

impl SubmissionStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Accepted),
            1 => Some(Self::Duplicate),
            2 => Some(Self::RateLimited),
            3 => Some(Self::Rejected),
            4 => Some(Self::InvalidChain),
            5 => Some(Self::UnknownAnchor),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SubmissionStatus; 6] = [
        Self::Accepted, Self::Duplicate, Self::RateLimited, Self::Rejected, Self::InvalidChain, Self::UnknownAnchor,
    ];
}

impl fmt::Display for SubmissionStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// VerificationResult (tags 0-3)
// ===========================================================================

/// Proof verification results.
///
/// Matches `VerificationResult` in `CtlogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum VerificationResult {
    /// ValidProof (tag 0).
    ValidProof = 0,
    /// InvalidProof (tag 1).
    InvalidProof = 1,
    /// InconsistentTree (tag 2).
    InconsistentTree = 2,
    /// Stale STH (tag 3).
    StaleSth = 3,
}

impl VerificationResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ValidProof),
            1 => Some(Self::InvalidProof),
            2 => Some(Self::InconsistentTree),
            3 => Some(Self::StaleSth),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [VerificationResult; 4] = [
        Self::ValidProof, Self::InvalidProof, Self::InconsistentTree, Self::StaleSth,
    ];
}

impl fmt::Display for VerificationResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// CT log server states.
///
/// Matches `ServerState` in `CtlogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Active (tag 1).
    Active = 1,
    /// Merging (tag 2).
    Merging = 2,
    /// Signing (tag 3).
    Signing = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Active),
            2 => Some(Self::Merging),
            3 => Some(Self::Signing),
            4 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServerState; 5] = [
        Self::Idle, Self::Active, Self::Merging, Self::Signing, Self::Shutdown,
    ];
}

impl fmt::Display for ServerState {
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
    fn log_entry_type_roundtrip() {
        for v in LogEntryType::ALL {
            let tag = v.to_tag();
            let decoded = LogEntryType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(LogEntryType::from_tag(2).is_none());
    }

    #[test]
    fn signature_type_roundtrip() {
        for v in SignatureType::ALL {
            let tag = v.to_tag();
            let decoded = SignatureType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SignatureType::from_tag(2).is_none());
    }

    #[test]
    fn merkle_leaf_type_roundtrip() {
        for v in MerkleLeafType::ALL {
            let tag = v.to_tag();
            let decoded = MerkleLeafType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MerkleLeafType::from_tag(1).is_none());
    }

    #[test]
    fn submission_status_roundtrip() {
        for v in SubmissionStatus::ALL {
            let tag = v.to_tag();
            let decoded = SubmissionStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SubmissionStatus::from_tag(6).is_none());
    }

    #[test]
    fn verification_result_roundtrip() {
        for v in VerificationResult::ALL {
            let tag = v.to_tag();
            let decoded = VerificationResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(VerificationResult::from_tag(4).is_none());
    }

    #[test]
    fn server_state_roundtrip() {
        for v in ServerState::ALL {
            let tag = v.to_tag();
            let decoded = ServerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServerState::from_tag(5).is_none());
    }

}
