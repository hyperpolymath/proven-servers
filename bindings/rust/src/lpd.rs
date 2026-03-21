// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! LPD types for the proven-servers ABI.
//!
//! Formally verified LPD (Line Printer Daemon, RFC 1179) types.
//! Mirrors the Idris2 module `LpdABI.Types`.
//!
//! - `CommandCode` -- LPD command codes (RFC 1179).
//! - `SubCommandCode` -- LPD sub-command codes.
//! - `JobStatus` -- Print job status.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// LPD Constants
// ===========================================================================

/// Standard LPD port.
pub const LPD_PORT: u16 = 515;

// ===========================================================================
// CommandCode (tags 1-5)
// ===========================================================================

/// LPD command codes (RFC 1179).
///
/// Matches `CommandCode` in `LpdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CommandCode {
    /// Print any waiting jobs  (tag 1).
    PrintJob = 1,
    /// Receive a print job  (tag 2).
    ReceiveJob = 2,
    /// Short queue listing  (tag 3).
    ShortQueue = 3,
    /// Long queue listing  (tag 4).
    LongQueue = 4,
    /// Remove jobs  (tag 5).
    RemoveJobs = 5,
}

impl CommandCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            1 => Some(Self::PrintJob),
            2 => Some(Self::ReceiveJob),
            3 => Some(Self::ShortQueue),
            4 => Some(Self::LongQueue),
            5 => Some(Self::RemoveJobs),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CommandCode; 5] = [
        Self::PrintJob, Self::ReceiveJob, Self::ShortQueue, Self::LongQueue, Self::RemoveJobs,
    ];
}

impl fmt::Display for CommandCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SubCommandCode (tags 1-3)
// ===========================================================================

/// LPD sub-command codes.
///
/// Matches `SubCommandCode` in `LpdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SubCommandCode {
    /// Abort job  (tag 1).
    AbortJob = 1,
    /// Receive control file  (tag 2).
    ControlFile = 2,
    /// Receive data file  (tag 3).
    DataFile = 3,
}

impl SubCommandCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            1 => Some(Self::AbortJob),
            2 => Some(Self::ControlFile),
            3 => Some(Self::DataFile),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SubCommandCode; 3] = [
        Self::AbortJob, Self::ControlFile, Self::DataFile,
    ];
}

impl fmt::Display for SubCommandCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// JobStatus (tags 0-3)
// ===========================================================================

/// Print job status.
///
/// Matches `JobStatus` in `LpdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum JobStatus {
    /// Pending (tag 0).
    Pending = 0,
    /// Printing (tag 1).
    Printing = 1,
    /// Complete (tag 2).
    Complete = 2,
    /// Failed (tag 3).
    Failed = 3,
}

impl JobStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pending),
            1 => Some(Self::Printing),
            2 => Some(Self::Complete),
            3 => Some(Self::Failed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [JobStatus; 4] = [
        Self::Pending, Self::Printing, Self::Complete, Self::Failed,
    ];
}

impl fmt::Display for JobStatus {
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
    fn command_code_roundtrip() {
        for v in CommandCode::ALL {
            let tag = v.to_tag();
            let decoded = CommandCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CommandCode::from_tag(6).is_none());
    }

    #[test]
    fn sub_command_code_roundtrip() {
        for v in SubCommandCode::ALL {
            let tag = v.to_tag();
            let decoded = SubCommandCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SubCommandCode::from_tag(4).is_none());
    }

    #[test]
    fn job_status_roundtrip() {
        for v in JobStatus::ALL {
            let tag = v.to_tag();
            let decoded = JobStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(JobStatus::from_tag(4).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(LPD_PORT, 515);
    }

}
