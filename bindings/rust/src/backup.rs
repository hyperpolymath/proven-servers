// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Backup Server types for the proven-servers ABI.
//!
//! Formally verified backup/restore types.
//! Mirrors the Idris2 module `BackupABI.Types`.
//!
//! - `BackupType` -- Backup types.
//! - `ScheduleFreq` -- Backup schedule frequencies.
//! - `CompressionAlg` -- Backup compression algorithms.
//! - `EncryptionAlg` -- Backup encryption algorithms.
//! - `BackupState` -- Backup job states.
//! - `RetentionPolicy` -- Backup retention policies.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// BackupType (tags 0-4)
// ===========================================================================

/// Backup types.
///
/// Matches `BackupType` in `BackupABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BackupType {
    /// Full (tag 0).
    Full = 0,
    /// Incremental (tag 1).
    Incremental = 1,
    /// Differential (tag 2).
    Differential = 2,
    /// Snapshot (tag 3).
    Snapshot = 3,
    /// Mirror (tag 4).
    Mirror = 4,
}

impl BackupType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Full),
            1 => Some(Self::Incremental),
            2 => Some(Self::Differential),
            3 => Some(Self::Snapshot),
            4 => Some(Self::Mirror),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [BackupType; 5] = [
        Self::Full, Self::Incremental, Self::Differential, Self::Snapshot, Self::Mirror,
    ];
}

impl fmt::Display for BackupType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ScheduleFreq (tags 0-4)
// ===========================================================================

/// Backup schedule frequencies.
///
/// Matches `ScheduleFreq` in `BackupABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ScheduleFreq {
    /// Hourly (tag 0).
    Hourly = 0,
    /// Daily (tag 1).
    Daily = 1,
    /// Weekly (tag 2).
    Weekly = 2,
    /// Monthly (tag 3).
    Monthly = 3,
    /// OnDemand (tag 4).
    OnDemand = 4,
}

impl ScheduleFreq {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Hourly),
            1 => Some(Self::Daily),
            2 => Some(Self::Weekly),
            3 => Some(Self::Monthly),
            4 => Some(Self::OnDemand),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ScheduleFreq; 5] = [
        Self::Hourly, Self::Daily, Self::Weekly, Self::Monthly, Self::OnDemand,
    ];
}

impl fmt::Display for ScheduleFreq {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CompressionAlg (tags 0-4)
// ===========================================================================

/// Backup compression algorithms.
///
/// Matches `CompressionAlg` in `BackupABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CompressionAlg {
    /// None (tag 0).
    None = 0,
    /// Gzip (tag 1).
    Gzip = 1,
    /// Zstd (tag 2).
    Zstd = 2,
    /// LZ4 (tag 3).
    Lz4 = 3,
    /// XZ (tag 4).
    Xz = 4,
}

impl CompressionAlg {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::Gzip),
            2 => Some(Self::Zstd),
            3 => Some(Self::Lz4),
            4 => Some(Self::Xz),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CompressionAlg; 5] = [
        Self::None, Self::Gzip, Self::Zstd, Self::Lz4, Self::Xz,
    ];
}

impl fmt::Display for CompressionAlg {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EncryptionAlg (tags 0-2)
// ===========================================================================

/// Backup encryption algorithms.
///
/// Matches `EncryptionAlg` in `BackupABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EncryptionAlg {
    /// NoEncryption (tag 0).
    NoEncryption = 0,
    /// AES-256-GCM (tag 1).
    Aes256Gcm = 1,
    /// ChaCha20Poly1305 (tag 2).
    ChaCha20Poly1305 = 2,
}

impl EncryptionAlg {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoEncryption),
            1 => Some(Self::Aes256Gcm),
            2 => Some(Self::ChaCha20Poly1305),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [EncryptionAlg; 3] = [
        Self::NoEncryption, Self::Aes256Gcm, Self::ChaCha20Poly1305,
    ];
}

impl fmt::Display for EncryptionAlg {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// BackupState (tags 0-5)
// ===========================================================================

/// Backup job states.
///
/// Matches `BackupState` in `BackupABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BackupState {
    /// Idle (tag 0).
    Idle = 0,
    /// Running (tag 1).
    Running = 1,
    /// Verifying (tag 2).
    Verifying = 2,
    /// Complete (tag 3).
    Complete = 3,
    /// Failed (tag 4).
    Failed = 4,
    /// Cancelled (tag 5).
    Cancelled = 5,
}

impl BackupState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Running),
            2 => Some(Self::Verifying),
            3 => Some(Self::Complete),
            4 => Some(Self::Failed),
            5 => Some(Self::Cancelled),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [BackupState; 6] = [
        Self::Idle, Self::Running, Self::Verifying, Self::Complete, Self::Failed, Self::Cancelled,
    ];
}

impl fmt::Display for BackupState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RetentionPolicy (tags 0-4)
// ===========================================================================

/// Backup retention policies.
///
/// Matches `RetentionPolicy` in `BackupABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RetentionPolicy {
    /// KeepAll (tag 0).
    KeepAll = 0,
    /// KeepLast (tag 1).
    KeepLast = 1,
    /// KeepDaily (tag 2).
    KeepDaily = 2,
    /// KeepWeekly (tag 3).
    KeepWeekly = 3,
    /// KeepMonthly (tag 4).
    KeepMonthly = 4,
}

impl RetentionPolicy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::KeepAll),
            1 => Some(Self::KeepLast),
            2 => Some(Self::KeepDaily),
            3 => Some(Self::KeepWeekly),
            4 => Some(Self::KeepMonthly),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RetentionPolicy; 5] = [
        Self::KeepAll, Self::KeepLast, Self::KeepDaily, Self::KeepWeekly, Self::KeepMonthly,
    ];
}

impl fmt::Display for RetentionPolicy {
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
    fn backup_type_roundtrip() {
        for v in BackupType::ALL {
            let tag = v.to_tag();
            let decoded = BackupType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(BackupType::from_tag(5).is_none());
    }

    #[test]
    fn schedule_freq_roundtrip() {
        for v in ScheduleFreq::ALL {
            let tag = v.to_tag();
            let decoded = ScheduleFreq::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ScheduleFreq::from_tag(5).is_none());
    }

    #[test]
    fn compression_alg_roundtrip() {
        for v in CompressionAlg::ALL {
            let tag = v.to_tag();
            let decoded = CompressionAlg::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CompressionAlg::from_tag(5).is_none());
    }

    #[test]
    fn encryption_alg_roundtrip() {
        for v in EncryptionAlg::ALL {
            let tag = v.to_tag();
            let decoded = EncryptionAlg::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(EncryptionAlg::from_tag(3).is_none());
    }

    #[test]
    fn backup_state_roundtrip() {
        for v in BackupState::ALL {
            let tag = v.to_tag();
            let decoded = BackupState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(BackupState::from_tag(6).is_none());
    }

    #[test]
    fn retention_policy_roundtrip() {
        for v in RetentionPolicy::ALL {
            let tag = v.to_tag();
            let decoded = RetentionPolicy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RetentionPolicy::from_tag(5).is_none());
    }

}
