// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! File Server types for the proven-servers ABI.
//!
//! Formally verified file server types.
//! Mirrors the Idris2 module `FileserverABI.Types`.
//!
//! - `FileOperation` -- File server operations.
//! - `FileType` -- File types.
//! - `FilePermission` -- POSIX file permissions.
//! - `LockType` -- File lock types.
//! - `FileErrorCode` -- File server error codes.
//! - `SessionState` -- File server session states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// FileOperation (tags 0-9)
// ===========================================================================

/// File server operations.
///
/// Matches `FileOperation` in `FileserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FileOperation {
    /// Read (tag 0).
    Read = 0,
    /// Write (tag 1).
    Write = 1,
    /// Create (tag 2).
    Create = 2,
    /// Delete (tag 3).
    Delete = 3,
    /// Rename (tag 4).
    Rename = 4,
    /// List (tag 5).
    List = 5,
    /// Stat (tag 6).
    Stat = 6,
    /// Lock (tag 7).
    Lock = 7,
    /// Unlock (tag 8).
    Unlock = 8,
    /// Watch (tag 9).
    Watch = 9,
}

impl FileOperation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Read),
            1 => Some(Self::Write),
            2 => Some(Self::Create),
            3 => Some(Self::Delete),
            4 => Some(Self::Rename),
            5 => Some(Self::List),
            6 => Some(Self::Stat),
            7 => Some(Self::Lock),
            8 => Some(Self::Unlock),
            9 => Some(Self::Watch),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FileOperation; 10] = [
        Self::Read, Self::Write, Self::Create, Self::Delete, Self::Rename, Self::List, Self::Stat, Self::Lock, Self::Unlock, Self::Watch,
    ];
}

impl fmt::Display for FileOperation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FileType (tags 0-6)
// ===========================================================================

/// File types.
///
/// Matches `FileType` in `FileserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FileType {
    /// Regular (tag 0).
    Regular = 0,
    /// Directory (tag 1).
    Directory = 1,
    /// Symlink (tag 2).
    Symlink = 2,
    /// BlockDevice (tag 3).
    BlockDevice = 3,
    /// CharDevice (tag 4).
    CharDevice = 4,
    /// FIFO (tag 5).
    Fifo = 5,
    /// Socket (tag 6).
    Socket = 6,
}

impl FileType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Regular),
            1 => Some(Self::Directory),
            2 => Some(Self::Symlink),
            3 => Some(Self::BlockDevice),
            4 => Some(Self::CharDevice),
            5 => Some(Self::Fifo),
            6 => Some(Self::Socket),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FileType; 7] = [
        Self::Regular, Self::Directory, Self::Symlink, Self::BlockDevice, Self::CharDevice, Self::Fifo, Self::Socket,
    ];
}

impl fmt::Display for FileType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FilePermission (tags 0-8)
// ===========================================================================

/// POSIX file permissions.
///
/// Matches `FilePermission` in `FileserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FilePermission {
    /// OwnerRead (tag 0).
    OwnerRead = 0,
    /// OwnerWrite (tag 1).
    OwnerWrite = 1,
    /// OwnerExecute (tag 2).
    OwnerExecute = 2,
    /// GroupRead (tag 3).
    GroupRead = 3,
    /// GroupWrite (tag 4).
    GroupWrite = 4,
    /// GroupExecute (tag 5).
    GroupExecute = 5,
    /// OtherRead (tag 6).
    OtherRead = 6,
    /// OtherWrite (tag 7).
    OtherWrite = 7,
    /// OtherExecute (tag 8).
    OtherExecute = 8,
}

impl FilePermission {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::OwnerRead),
            1 => Some(Self::OwnerWrite),
            2 => Some(Self::OwnerExecute),
            3 => Some(Self::GroupRead),
            4 => Some(Self::GroupWrite),
            5 => Some(Self::GroupExecute),
            6 => Some(Self::OtherRead),
            7 => Some(Self::OtherWrite),
            8 => Some(Self::OtherExecute),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FilePermission; 9] = [
        Self::OwnerRead, Self::OwnerWrite, Self::OwnerExecute, Self::GroupRead, Self::GroupWrite, Self::GroupExecute, Self::OtherRead, Self::OtherWrite, Self::OtherExecute,
    ];
}

impl fmt::Display for FilePermission {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LockType (tags 0-3)
// ===========================================================================

/// File lock types.
///
/// Matches `LockType` in `FileserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LockType {
    /// Shared (tag 0).
    Shared = 0,
    /// Exclusive (tag 1).
    Exclusive = 1,
    /// Advisory (tag 2).
    Advisory = 2,
    /// Mandatory (tag 3).
    Mandatory = 3,
}

impl LockType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Shared),
            1 => Some(Self::Exclusive),
            2 => Some(Self::Advisory),
            3 => Some(Self::Mandatory),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [LockType; 4] = [
        Self::Shared, Self::Exclusive, Self::Advisory, Self::Mandatory,
    ];
}

impl fmt::Display for LockType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FileErrorCode (tags 0-9)
// ===========================================================================

/// File server error codes.
///
/// Matches `FileErrorCode` in `FileserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FileErrorCode {
    /// NotFound (tag 0).
    NotFound = 0,
    /// PermissionDenied (tag 1).
    PermissionDenied = 1,
    /// AlreadyExists (tag 2).
    AlreadyExists = 2,
    /// NotEmpty (tag 3).
    NotEmpty = 3,
    /// IsDirectory (tag 4).
    IsDirectory = 4,
    /// NotDirectory (tag 5).
    NotDirectory = 5,
    /// NoSpace (tag 6).
    NoSpace = 6,
    /// ReadOnly (tag 7).
    ReadOnly = 7,
    /// Locked (tag 8).
    Locked = 8,
    /// I/O error (tag 9).
    IoError = 9,
}

impl FileErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NotFound),
            1 => Some(Self::PermissionDenied),
            2 => Some(Self::AlreadyExists),
            3 => Some(Self::NotEmpty),
            4 => Some(Self::IsDirectory),
            5 => Some(Self::NotDirectory),
            6 => Some(Self::NoSpace),
            7 => Some(Self::ReadOnly),
            8 => Some(Self::Locked),
            9 => Some(Self::IoError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FileErrorCode; 10] = [
        Self::NotFound, Self::PermissionDenied, Self::AlreadyExists, Self::NotEmpty, Self::IsDirectory, Self::NotDirectory, Self::NoSpace, Self::ReadOnly, Self::Locked, Self::IoError,
    ];
}

impl fmt::Display for FileErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// File server session states.
///
/// Matches `SessionState` in `FileserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Connected (tag 1).
    Connected = 1,
    /// Operating (tag 2).
    Operating = 2,
    /// Locked (tag 3).
    FsLocked = 3,
    /// Disconnecting (tag 4).
    Disconnecting = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::Operating),
            3 => Some(Self::FsLocked),
            4 => Some(Self::Disconnecting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Connected, Self::Operating, Self::FsLocked, Self::Disconnecting,
    ];
}

impl fmt::Display for SessionState {
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
    fn file_operation_roundtrip() {
        for v in FileOperation::ALL {
            let tag = v.to_tag();
            let decoded = FileOperation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FileOperation::from_tag(10).is_none());
    }

    #[test]
    fn file_type_roundtrip() {
        for v in FileType::ALL {
            let tag = v.to_tag();
            let decoded = FileType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FileType::from_tag(7).is_none());
    }

    #[test]
    fn file_permission_roundtrip() {
        for v in FilePermission::ALL {
            let tag = v.to_tag();
            let decoded = FilePermission::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FilePermission::from_tag(9).is_none());
    }

    #[test]
    fn lock_type_roundtrip() {
        for v in LockType::ALL {
            let tag = v.to_tag();
            let decoded = LockType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(LockType::from_tag(4).is_none());
    }

    #[test]
    fn file_error_code_roundtrip() {
        for v in FileErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = FileErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FileErrorCode::from_tag(10).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

}
