// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! NETCONF types for the proven-servers ABI.
//!
//! Formally verified NETCONF types (RFC 6241).
//! Mirrors the Idris2 module `NetconfABI.Types`.
//!
//! - `NetconfOperation` -- NETCONF operations.
//! - `Datastore` -- NETCONF datastores.
//! - `EditOperation` -- NETCONF edit operations.
//! - `NetconfErrorType` -- NETCONF error types.
//! - `ErrorSeverity` -- NETCONF error severity.
//! - `NetconfState` -- NETCONF session states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// NETCONF Constants
// ===========================================================================

/// Standard NETCONF SSH port.
pub const NETCONF_PORT: u16 = 830;

// ===========================================================================
// NetconfOperation (tags 0-11)
// ===========================================================================

/// NETCONF operations.
///
/// Matches `NetconfOperation` in `NetconfABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NetconfOperation {
    /// Get (tag 0).
    Get = 0,
    /// GetConfig (tag 1).
    GetConfig = 1,
    /// EditConfig (tag 2).
    EditConfig = 2,
    /// CopyConfig (tag 3).
    CopyConfig = 3,
    /// DeleteConfig (tag 4).
    DeleteConfig = 4,
    /// Lock (tag 5).
    Lock = 5,
    /// Unlock (tag 6).
    Unlock = 6,
    /// CloseSession (tag 7).
    CloseSession = 7,
    /// KillSession (tag 8).
    KillSession = 8,
    /// Commit (tag 9).
    Commit = 9,
    /// Validate (tag 10).
    Validate = 10,
    /// DiscardChanges (tag 11).
    DiscardChanges = 11,
}

impl NetconfOperation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::GetConfig),
            2 => Some(Self::EditConfig),
            3 => Some(Self::CopyConfig),
            4 => Some(Self::DeleteConfig),
            5 => Some(Self::Lock),
            6 => Some(Self::Unlock),
            7 => Some(Self::CloseSession),
            8 => Some(Self::KillSession),
            9 => Some(Self::Commit),
            10 => Some(Self::Validate),
            11 => Some(Self::DiscardChanges),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NetconfOperation; 12] = [
        Self::Get, Self::GetConfig, Self::EditConfig, Self::CopyConfig, Self::DeleteConfig, Self::Lock, Self::Unlock, Self::CloseSession, Self::KillSession, Self::Commit, Self::Validate, Self::DiscardChanges,
    ];
}

impl fmt::Display for NetconfOperation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Datastore (tags 0-2)
// ===========================================================================

/// NETCONF datastores.
///
/// Matches `Datastore` in `NetconfABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Datastore {
    /// Running (tag 0).
    Running = 0,
    /// Startup (tag 1).
    Startup = 1,
    /// Candidate (tag 2).
    Candidate = 2,
}

impl Datastore {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Running),
            1 => Some(Self::Startup),
            2 => Some(Self::Candidate),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Datastore; 3] = [
        Self::Running, Self::Startup, Self::Candidate,
    ];
}

impl fmt::Display for Datastore {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EditOperation (tags 0-4)
// ===========================================================================

/// NETCONF edit operations.
///
/// Matches `EditOperation` in `NetconfABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EditOperation {
    /// Merge (tag 0).
    Merge = 0,
    /// Replace (tag 1).
    Replace = 1,
    /// Create (tag 2).
    Create = 2,
    /// Delete (tag 3).
    Delete = 3,
    /// Remove (tag 4).
    Remove = 4,
}

impl EditOperation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Merge),
            1 => Some(Self::Replace),
            2 => Some(Self::Create),
            3 => Some(Self::Delete),
            4 => Some(Self::Remove),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [EditOperation; 5] = [
        Self::Merge, Self::Replace, Self::Create, Self::Delete, Self::Remove,
    ];
}

impl fmt::Display for EditOperation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NetconfErrorType (tags 0-3)
// ===========================================================================

/// NETCONF error types.
///
/// Matches `NetconfErrorType` in `NetconfABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NetconfErrorType {
    /// Transport (tag 0).
    Transport = 0,
    /// RPC (tag 1).
    Rpc = 1,
    /// Protocol (tag 2).
    Protocol = 2,
    /// Application (tag 3).
    Application = 3,
}

impl NetconfErrorType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Transport),
            1 => Some(Self::Rpc),
            2 => Some(Self::Protocol),
            3 => Some(Self::Application),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NetconfErrorType; 4] = [
        Self::Transport, Self::Rpc, Self::Protocol, Self::Application,
    ];
}

impl fmt::Display for NetconfErrorType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorSeverity (tags 0-1)
// ===========================================================================

/// NETCONF error severity.
///
/// Matches `ErrorSeverity` in `NetconfABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorSeverity {
    /// Error (tag 0).
    Error = 0,
    /// Warning (tag 1).
    Warning = 1,
}

impl ErrorSeverity {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Error),
            1 => Some(Self::Warning),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorSeverity; 2] = [
        Self::Error, Self::Warning,
    ];
}

impl fmt::Display for ErrorSeverity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NetconfState (tags 0-5)
// ===========================================================================

/// NETCONF session states.
///
/// Matches `NetconfState` in `NetconfABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NetconfState {
    /// Idle (tag 0).
    Idle = 0,
    /// Connected (tag 1).
    Connected = 1,
    /// Locked (tag 2).
    Locked = 2,
    /// Editing (tag 3).
    Editing = 3,
    /// Closing (tag 4).
    Closing = 4,
    /// Terminated (tag 5).
    Terminated = 5,
}

impl NetconfState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::Locked),
            3 => Some(Self::Editing),
            4 => Some(Self::Closing),
            5 => Some(Self::Terminated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NetconfState; 6] = [
        Self::Idle, Self::Connected, Self::Locked, Self::Editing, Self::Closing, Self::Terminated,
    ];
}

impl fmt::Display for NetconfState {
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
    fn netconf_operation_roundtrip() {
        for v in NetconfOperation::ALL {
            let tag = v.to_tag();
            let decoded = NetconfOperation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NetconfOperation::from_tag(12).is_none());
    }

    #[test]
    fn datastore_roundtrip() {
        for v in Datastore::ALL {
            let tag = v.to_tag();
            let decoded = Datastore::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Datastore::from_tag(3).is_none());
    }

    #[test]
    fn edit_operation_roundtrip() {
        for v in EditOperation::ALL {
            let tag = v.to_tag();
            let decoded = EditOperation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(EditOperation::from_tag(5).is_none());
    }

    #[test]
    fn netconf_error_type_roundtrip() {
        for v in NetconfErrorType::ALL {
            let tag = v.to_tag();
            let decoded = NetconfErrorType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NetconfErrorType::from_tag(4).is_none());
    }

    #[test]
    fn error_severity_roundtrip() {
        for v in ErrorSeverity::ALL {
            let tag = v.to_tag();
            let decoded = ErrorSeverity::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorSeverity::from_tag(2).is_none());
    }

    #[test]
    fn netconf_state_roundtrip() {
        for v in NetconfState::ALL {
            let tag = v.to_tag();
            let decoded = NetconfState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NetconfState::from_tag(6).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(NETCONF_PORT, 830);
    }

}
