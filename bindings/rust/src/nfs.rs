// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! NFS (Network File System) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `NFSABI.Types` and its type definitions:
//! - `Operation` — NFS operations (15 constructors, tags 0-14)
//! - `FileType`  — NFS file types (7 constructors, tags 0-6)
//! - `Status`    — NFS status codes (14 constructors, tags 0-13)
//! - `NfsState`  — NFS server lifecycle (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// NFS Constants
// ===========================================================================

/// Standard NFS port (RFC 7530).
pub const NFS_PORT: u16 = 2049;

// ===========================================================================
// Operation (tags 0-14)
// ===========================================================================

/// NFSv4 operations (RFC 7530).
///
/// Matches `Operation` in `NFSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Operation {
    /// Check access permissions (tag 0).
    Access = 0,
    /// Close a stateful file handle (tag 1).
    Close = 1,
    /// Commit cached data to stable storage (tag 2).
    Commit = 2,
    /// Create a file or directory (tag 3).
    Create = 3,
    /// Get file attributes (tag 4).
    GetAttr = 4,
    /// Create a hard link (tag 5).
    Link = 5,
    /// Lock a byte range (tag 6).
    Lock = 6,
    /// Look up a name in a directory (tag 7).
    Lookup = 7,
    /// Open a file (tag 8).
    Open = 8,
    /// Read file data (tag 9).
    Read = 9,
    /// List directory entries (tag 10).
    ReadDir = 10,
    /// Remove a file or directory (tag 11).
    Remove = 11,
    /// Rename a file or directory (tag 12).
    Rename = 12,
    /// Set file attributes (tag 13).
    SetAttr = 13,
    /// Write file data (tag 14).
    Write = 14,
}

impl Operation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Access),
            1 => Some(Self::Close),
            2 => Some(Self::Commit),
            3 => Some(Self::Create),
            4 => Some(Self::GetAttr),
            5 => Some(Self::Link),
            6 => Some(Self::Lock),
            7 => Some(Self::Lookup),
            8 => Some(Self::Open),
            9 => Some(Self::Read),
            10 => Some(Self::ReadDir),
            11 => Some(Self::Remove),
            12 => Some(Self::Rename),
            13 => Some(Self::SetAttr),
            14 => Some(Self::Write),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this operation modifies the filesystem.
    pub fn is_write(self) -> bool {
        matches!(
            self,
            Self::Create | Self::Link | Self::Remove | Self::Rename
                | Self::SetAttr | Self::Write | Self::Commit
        )
    }

    /// Whether this operation is read-only.
    pub fn is_read(self) -> bool {
        matches!(
            self,
            Self::Access | Self::GetAttr | Self::Lookup | Self::Read | Self::ReadDir
        )
    }

    /// All supported operations.
    pub const ALL: [Operation; 15] = [
        Self::Access, Self::Close, Self::Commit, Self::Create, Self::GetAttr,
        Self::Link, Self::Lock, Self::Lookup, Self::Open, Self::Read,
        Self::ReadDir, Self::Remove, Self::Rename, Self::SetAttr, Self::Write,
    ];
}

impl fmt::Display for Operation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FileType (tags 0-6)
// ===========================================================================

/// NFS file types (RFC 7530 Section 5.8).
///
/// Matches `FileType` in `NFSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FileType {
    /// Regular file (tag 0).
    Regular = 0,
    /// Directory (tag 1).
    Directory = 1,
    /// Block device (tag 2).
    BlockDevice = 2,
    /// Character device (tag 3).
    CharDevice = 3,
    /// Symbolic link (tag 4).
    Link = 4,
    /// Unix domain socket (tag 5).
    Socket = 5,
    /// Named pipe / FIFO (tag 6).
    Fifo = 6,
}

impl FileType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Regular),
            1 => Some(Self::Directory),
            2 => Some(Self::BlockDevice),
            3 => Some(Self::CharDevice),
            4 => Some(Self::Link),
            5 => Some(Self::Socket),
            6 => Some(Self::Fifo),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this file type is a regular data file.
    pub fn is_regular(self) -> bool {
        matches!(self, Self::Regular)
    }

    /// Whether this file type is a special device node.
    pub fn is_device(self) -> bool {
        matches!(self, Self::BlockDevice | Self::CharDevice)
    }

    /// All supported file types.
    pub const ALL: [FileType; 7] = [
        Self::Regular, Self::Directory, Self::BlockDevice, Self::CharDevice,
        Self::Link, Self::Socket, Self::Fifo,
    ];
}

impl fmt::Display for FileType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Status (tags 0-13)
// ===========================================================================

/// NFS status codes (RFC 7530 Section 13).
///
/// Matches `Status` in `NFSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Status {
    /// Success (tag 0).
    Ok = 0,
    /// Permission denied (tag 1).
    Perm = 1,
    /// No such file or directory (tag 2).
    NoEnt = 2,
    /// I/O error (tag 3).
    Io = 3,
    /// No such device or address (tag 4).
    NxIo = 4,
    /// Access denied (tag 5).
    Access = 5,
    /// File or directory already exists (tag 6).
    Exist = 6,
    /// Not a directory (tag 7).
    NotDir = 7,
    /// Is a directory (tag 8).
    IsDir = 8,
    /// File too large (tag 9).
    FBig = 9,
    /// No space left on device (tag 10).
    NoSpc = 10,
    /// Read-only file system (tag 11).
    ROfs = 11,
    /// Directory not empty (tag 12).
    NotEmpty = 12,
    /// Stale file handle (tag 13).
    Stale = 13,
}

impl Status {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::Perm),
            2 => Some(Self::NoEnt),
            3 => Some(Self::Io),
            4 => Some(Self::NxIo),
            5 => Some(Self::Access),
            6 => Some(Self::Exist),
            7 => Some(Self::NotDir),
            8 => Some(Self::IsDir),
            9 => Some(Self::FBig),
            10 => Some(Self::NoSpc),
            11 => Some(Self::ROfs),
            12 => Some(Self::NotEmpty),
            13 => Some(Self::Stale),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this status indicates success.
    pub fn is_ok(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// Whether this error relates to access control.
    pub fn is_access_error(self) -> bool {
        matches!(self, Self::Perm | Self::Access | Self::ROfs)
    }

    /// Whether this error is likely transient and retryable.
    pub fn is_retryable(self) -> bool {
        matches!(self, Self::Io | Self::NxIo | Self::Stale)
    }

    /// All supported status codes.
    pub const ALL: [Status; 14] = [
        Self::Ok, Self::Perm, Self::NoEnt, Self::Io, Self::NxIo, Self::Access,
        Self::Exist, Self::NotDir, Self::IsDir, Self::FBig, Self::NoSpc,
        Self::ROfs, Self::NotEmpty, Self::Stale,
    ];
}

impl fmt::Display for Status {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for Status {}

// ===========================================================================
// NfsState (tags 0-5)
// ===========================================================================

/// NFS server lifecycle states for the FFI layer.
///
/// Matches `NFSState` in `NFSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NfsState {
    /// Not mounted (tag 0).
    Idle = 0,
    /// Connected to server, mount established (tag 1).
    Mounted = 1,
    /// File handle is open (tag 2).
    FileOpen = 2,
    /// Lock held on a file region (tag 3).
    Locked = 3,
    /// I/O in progress (tag 4).
    Busy = 4,
    /// Unmounting (tag 5).
    Unmounting = 5,
}

impl NfsState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Mounted),
            2 => Some(Self::FileOpen),
            3 => Some(Self::Locked),
            4 => Some(Self::Busy),
            5 => Some(Self::Unmounting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the NFS mount is active.
    pub fn is_mounted(self) -> bool {
        !matches!(self, Self::Idle | Self::Unmounting)
    }
}

impl fmt::Display for NfsState {
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
    fn operation_roundtrip() {
        for op in Operation::ALL {
            let tag = op.to_tag();
            let decoded = Operation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, op);
        }
        assert!(Operation::from_tag(15).is_none());
    }

    #[test]
    fn operation_classification() {
        assert!(Operation::Read.is_read());
        assert!(Operation::GetAttr.is_read());
        assert!(!Operation::Write.is_read());
        assert!(Operation::Write.is_write());
        assert!(Operation::Create.is_write());
        assert!(!Operation::Read.is_write());
    }

    #[test]
    fn file_type_roundtrip() {
        for ft in FileType::ALL {
            let tag = ft.to_tag();
            let decoded = FileType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ft);
        }
        assert!(FileType::from_tag(7).is_none());
    }

    #[test]
    fn file_type_classification() {
        assert!(FileType::Regular.is_regular());
        assert!(!FileType::Directory.is_regular());
        assert!(FileType::BlockDevice.is_device());
        assert!(FileType::CharDevice.is_device());
        assert!(!FileType::Regular.is_device());
    }

    #[test]
    fn status_roundtrip() {
        for st in Status::ALL {
            let tag = st.to_tag();
            let decoded = Status::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, st);
        }
        assert!(Status::from_tag(14).is_none());
    }

    #[test]
    fn status_classification() {
        assert!(Status::Ok.is_ok());
        assert!(!Status::Perm.is_ok());
        assert!(Status::Perm.is_access_error());
        assert!(Status::Access.is_access_error());
        assert!(Status::ROfs.is_access_error());
        assert!(Status::Stale.is_retryable());
        assert!(!Status::Perm.is_retryable());
    }

    #[test]
    fn nfs_state_roundtrip() {
        for tag in 0u8..=5 {
            let ns = NfsState::from_tag(tag).expect("valid tag");
            assert_eq!(ns.to_tag(), tag);
        }
        assert!(NfsState::from_tag(6).is_none());
    }

    #[test]
    fn nfs_state_mounted() {
        assert!(!NfsState::Idle.is_mounted());
        assert!(NfsState::Mounted.is_mounted());
        assert!(NfsState::FileOpen.is_mounted());
        assert!(NfsState::Locked.is_mounted());
        assert!(!NfsState::Unmounting.is_mounted());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(NFS_PORT, 2049);
    }
}
