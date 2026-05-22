// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Air Gap types for the proven-servers ABI.
//!
//! Formally verified air-gapped transfer types.
//! Mirrors the Idris2 module `AirgapABI.Types`.
//!
//! - `TransferDirection` -- Air gap transfer direction.
//! - `MediaType` -- Physical transfer media types.
//! - `ScanResult` -- Content scan results.
//! - `TransferState` -- Air gap transfer lifecycle.
//! - `ValidationCheck` -- Validation check types.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// TransferDirection (tags 0-1)
// ===========================================================================

/// Air gap transfer direction.
///
/// Matches `TransferDirection` in `AirgapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferDirection {
    /// Import (tag 0).
    Import = 0,
    /// Export (tag 1).
    Export = 1,
}

impl TransferDirection {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Import),
            1 => Some(Self::Export),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TransferDirection; 2] = [
        Self::Import, Self::Export,
    ];
}

impl fmt::Display for TransferDirection {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MediaType (tags 0-3)
// ===========================================================================

/// Physical transfer media types.
///
/// Matches `MediaType` in `AirgapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MediaType {
    /// USB (tag 0).
    Usb = 0,
    /// OpticalDisc (tag 1).
    OpticalDisc = 1,
    /// TapeCartridge (tag 2).
    TapeCartridge = 2,
    /// DiodeLink (tag 3).
    DiodeLink = 3,
}

impl MediaType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Usb),
            1 => Some(Self::OpticalDisc),
            2 => Some(Self::TapeCartridge),
            3 => Some(Self::DiodeLink),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MediaType; 4] = [
        Self::Usb, Self::OpticalDisc, Self::TapeCartridge, Self::DiodeLink,
    ];
}

impl fmt::Display for MediaType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ScanResult (tags 0-3)
// ===========================================================================

/// Content scan results.
///
/// Matches `ScanResult` in `AirgapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ScanResult {
    /// Clean (tag 0).
    Clean = 0,
    /// Suspicious (tag 1).
    Suspicious = 1,
    /// Malicious (tag 2).
    Malicious = 2,
    /// Unscannable (tag 3).
    Unscannable = 3,
}

impl ScanResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Clean),
            1 => Some(Self::Suspicious),
            2 => Some(Self::Malicious),
            3 => Some(Self::Unscannable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the content is safe to transfer.
    pub fn is_safe(self) -> bool {
        matches!(self, Self::Clean)
    }

    /// All variants of this type.
    pub const ALL: [ScanResult; 4] = [
        Self::Clean, Self::Suspicious, Self::Malicious, Self::Unscannable,
    ];
}

impl fmt::Display for ScanResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransferState (tags 0-6)
// ===========================================================================

/// Air gap transfer lifecycle.
///
/// Matches `TransferState` in `AirgapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferState {
    /// Pending (tag 0).
    Pending = 0,
    /// Scanning (tag 1).
    Scanning = 1,
    /// Approved (tag 2).
    Approved = 2,
    /// Rejected (tag 3).
    Rejected = 3,
    /// InProgress (tag 4).
    InProgress = 4,
    /// Complete (tag 5).
    Complete = 5,
    /// Failed (tag 6).
    Failed = 6,
}

impl TransferState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pending),
            1 => Some(Self::Scanning),
            2 => Some(Self::Approved),
            3 => Some(Self::Rejected),
            4 => Some(Self::InProgress),
            5 => Some(Self::Complete),
            6 => Some(Self::Failed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TransferState; 7] = [
        Self::Pending, Self::Scanning, Self::Approved, Self::Rejected, Self::InProgress, Self::Complete, Self::Failed,
    ];
}

impl fmt::Display for TransferState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ValidationCheck (tags 0-4)
// ===========================================================================

/// Validation check types.
///
/// Matches `ValidationCheck` in `AirgapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ValidationCheck {
    /// HashVerify (tag 0).
    HashVerify = 0,
    /// SignatureVerify (tag 1).
    SignatureVerify = 1,
    /// FormatCheck (tag 2).
    FormatCheck = 2,
    /// ContentInspection (tag 3).
    ContentInspection = 3,
    /// MalwareScan (tag 4).
    MalwareScan = 4,
}

impl ValidationCheck {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::HashVerify),
            1 => Some(Self::SignatureVerify),
            2 => Some(Self::FormatCheck),
            3 => Some(Self::ContentInspection),
            4 => Some(Self::MalwareScan),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ValidationCheck; 5] = [
        Self::HashVerify, Self::SignatureVerify, Self::FormatCheck, Self::ContentInspection, Self::MalwareScan,
    ];
}

impl fmt::Display for ValidationCheck {
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
    fn transfer_direction_roundtrip() {
        for v in TransferDirection::ALL {
            let tag = v.to_tag();
            let decoded = TransferDirection::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TransferDirection::from_tag(2).is_none());
    }

    #[test]
    fn media_type_roundtrip() {
        for v in MediaType::ALL {
            let tag = v.to_tag();
            let decoded = MediaType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MediaType::from_tag(4).is_none());
    }

    #[test]
    fn scan_result_roundtrip() {
        for v in ScanResult::ALL {
            let tag = v.to_tag();
            let decoded = ScanResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ScanResult::from_tag(4).is_none());
    }

    #[test]
    fn transfer_state_roundtrip() {
        for v in TransferState::ALL {
            let tag = v.to_tag();
            let decoded = TransferState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TransferState::from_tag(7).is_none());
    }

    #[test]
    fn validation_check_roundtrip() {
        for v in ValidationCheck::ALL {
            let tag = v.to_tag();
            let decoded = ValidationCheck::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ValidationCheck::from_tag(5).is_none());
    }

}
