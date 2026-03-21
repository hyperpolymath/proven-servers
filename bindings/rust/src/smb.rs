// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! SMB (Server Message Block) protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `SMBABI.Types` and its type definitions:
//! - `Command`      — SMB2/3 commands (16 constructors, tags 0-15)
//! - `Dialect`      — SMB protocol dialects (5 constructors, tags 0-4)
//! - `ShareType`    — SMB share types (3 constructors, tags 0-2)
//! - `SessionState` — SMB session lifecycle (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SMB Constants
// ===========================================================================

/// Standard SMB port (TCP).
pub const SMB_PORT: u16 = 445;

/// Legacy NetBIOS over TCP port (used by older SMB implementations).
pub const SMB_NETBIOS_PORT: u16 = 139;

// ===========================================================================
// Command (tags 0-15)
// ===========================================================================

/// SMB2/3 command codes (MS-SMB2 Section 2.2).
///
/// Matches `Command` in `SMBABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// Negotiate protocol dialect (tag 0).
    Negotiate = 0,
    /// Set up an authenticated session (tag 1).
    SessionSetup = 1,
    /// Log off a session (tag 2).
    Logoff = 2,
    /// Connect to a share (tag 3).
    TreeConnect = 3,
    /// Disconnect from a share (tag 4).
    TreeDisconnect = 4,
    /// Create or open a file/directory (tag 5).
    Create = 5,
    /// Close a file handle (tag 6).
    Close = 6,
    /// Read from a file (tag 7).
    Read = 7,
    /// Write to a file (tag 8).
    Write = 8,
    /// Lock a byte range (tag 9).
    Lock = 9,
    /// Send an I/O control code (tag 10).
    Ioctl = 10,
    /// Cancel a pending request (tag 11).
    Cancel = 11,
    /// List directory contents (tag 12).
    QueryDirectory = 12,
    /// Register for change notifications (tag 13).
    ChangeNotify = 13,
    /// Query file or filesystem information (tag 14).
    QueryInfo = 14,
    /// Set file or filesystem information (tag 15).
    SetInfo = 15,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Negotiate),
            1 => Some(Self::SessionSetup),
            2 => Some(Self::Logoff),
            3 => Some(Self::TreeConnect),
            4 => Some(Self::TreeDisconnect),
            5 => Some(Self::Create),
            6 => Some(Self::Close),
            7 => Some(Self::Read),
            8 => Some(Self::Write),
            9 => Some(Self::Lock),
            10 => Some(Self::Ioctl),
            11 => Some(Self::Cancel),
            12 => Some(Self::QueryDirectory),
            13 => Some(Self::ChangeNotify),
            14 => Some(Self::QueryInfo),
            15 => Some(Self::SetInfo),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this command is a session/connection management operation.
    pub fn is_session_management(self) -> bool {
        matches!(
            self,
            Self::Negotiate | Self::SessionSetup | Self::Logoff
                | Self::TreeConnect | Self::TreeDisconnect
        )
    }

    /// Whether this command operates on file data.
    pub fn is_file_io(self) -> bool {
        matches!(self, Self::Read | Self::Write | Self::Lock | Self::Ioctl)
    }

    /// Whether this command modifies server state.
    pub fn is_write(self) -> bool {
        matches!(
            self,
            Self::Create | Self::Write | Self::SetInfo | Self::Lock
        )
    }

    /// All supported commands.
    pub const ALL: [Command; 16] = [
        Self::Negotiate, Self::SessionSetup, Self::Logoff, Self::TreeConnect,
        Self::TreeDisconnect, Self::Create, Self::Close, Self::Read,
        Self::Write, Self::Lock, Self::Ioctl, Self::Cancel,
        Self::QueryDirectory, Self::ChangeNotify, Self::QueryInfo, Self::SetInfo,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Dialect (tags 0-4)
// ===========================================================================

/// SMB protocol dialect versions (MS-SMB2 Section 3.3.5.4).
///
/// Matches `Dialect` in `SMBABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum Dialect {
    /// SMB 2.0.2 (tag 0).
    Smb2_0_2 = 0,
    /// SMB 2.1 (tag 1).
    Smb2_1 = 1,
    /// SMB 3.0 (tag 2).
    Smb3_0 = 2,
    /// SMB 3.0.2 (tag 3).
    Smb3_0_2 = 3,
    /// SMB 3.1.1 (tag 4).
    Smb3_1_1 = 4,
}

impl Dialect {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Smb2_0_2),
            1 => Some(Self::Smb2_1),
            2 => Some(Self::Smb3_0),
            3 => Some(Self::Smb3_0_2),
            4 => Some(Self::Smb3_1_1),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this dialect supports encryption.
    pub fn supports_encryption(self) -> bool {
        matches!(self, Self::Smb3_0 | Self::Smb3_0_2 | Self::Smb3_1_1)
    }

    /// Whether this is an SMB3 dialect.
    pub fn is_smb3(self) -> bool {
        matches!(self, Self::Smb3_0 | Self::Smb3_0_2 | Self::Smb3_1_1)
    }

    /// The dialect revision string.
    pub fn revision(self) -> &'static str {
        match self {
            Self::Smb2_0_2 => "2.0.2",
            Self::Smb2_1 => "2.1",
            Self::Smb3_0 => "3.0",
            Self::Smb3_0_2 => "3.0.2",
            Self::Smb3_1_1 => "3.1.1",
        }
    }

    /// All supported dialects.
    pub const ALL: [Dialect; 5] = [
        Self::Smb2_0_2, Self::Smb2_1, Self::Smb3_0, Self::Smb3_0_2, Self::Smb3_1_1,
    ];
}

impl fmt::Display for Dialect {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "SMB {}", self.revision())
    }
}

// ===========================================================================
// ShareType (tags 0-2)
// ===========================================================================

/// SMB share types (MS-SMB2 Section 2.2.10).
///
/// Matches `ShareType` in `SMBABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ShareType {
    /// Disk share — file system access (tag 0).
    Disk = 0,
    /// Named pipe share — IPC (tag 1).
    Pipe = 1,
    /// Print share — printer access (tag 2).
    Print = 2,
}

impl ShareType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Disk),
            1 => Some(Self::Pipe),
            2 => Some(Self::Print),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this share provides file system access.
    pub fn is_filesystem(self) -> bool {
        matches!(self, Self::Disk)
    }

    /// All supported share types.
    pub const ALL: [ShareType; 3] = [Self::Disk, Self::Pipe, Self::Print];
}

impl fmt::Display for ShareType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-5)
// ===========================================================================

/// SMB session lifecycle states for the FFI layer.
///
/// Matches `SessionState` in `SMBABI.Types`.
/// Combines connection, tree, and file handle states into a single enum.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// No connection established (tag 0).
    Idle = 0,
    /// Dialect negotiated, session not yet authenticated (tag 1).
    Negotiated = 1,
    /// Session authenticated, no tree connections (tag 2).
    Authenticated = 2,
    /// At least one tree connection is active (tag 3).
    TreeConnected = 3,
    /// At least one file handle is open (tag 4).
    FileOpen = 4,
    /// Connection closing (logoff in progress) (tag 5).
    Disconnecting = 5,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Negotiated),
            2 => Some(Self::Authenticated),
            3 => Some(Self::TreeConnected),
            4 => Some(Self::FileOpen),
            5 => Some(Self::Disconnecting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the session is authenticated (can perform operations).
    pub fn is_authenticated(self) -> bool {
        matches!(
            self,
            Self::Authenticated | Self::TreeConnected | Self::FileOpen
        )
    }

    /// Whether file operations are possible.
    pub fn can_do_file_io(self) -> bool {
        matches!(self, Self::FileOpen)
    }

    /// All supported session states.
    pub const ALL: [SessionState; 6] = [
        Self::Idle, Self::Negotiated, Self::Authenticated,
        Self::TreeConnected, Self::FileOpen, Self::Disconnecting,
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
    fn command_roundtrip() {
        for cmd in Command::ALL {
            let tag = cmd.to_tag();
            let decoded = Command::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cmd);
        }
        assert!(Command::from_tag(16).is_none());
    }

    #[test]
    fn command_classification() {
        assert!(Command::Negotiate.is_session_management());
        assert!(Command::SessionSetup.is_session_management());
        assert!(!Command::Read.is_session_management());
        assert!(Command::Read.is_file_io());
        assert!(Command::Write.is_file_io());
        assert!(!Command::Negotiate.is_file_io());
        assert!(Command::Write.is_write());
        assert!(!Command::Read.is_write());
    }

    #[test]
    fn dialect_roundtrip() {
        for d in Dialect::ALL {
            let tag = d.to_tag();
            let decoded = Dialect::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, d);
        }
        assert!(Dialect::from_tag(5).is_none());
    }

    #[test]
    fn dialect_ordering() {
        assert!(Dialect::Smb2_0_2 < Dialect::Smb2_1);
        assert!(Dialect::Smb2_1 < Dialect::Smb3_0);
        assert!(Dialect::Smb3_0 < Dialect::Smb3_1_1);
    }

    #[test]
    fn dialect_features() {
        assert!(!Dialect::Smb2_0_2.supports_encryption());
        assert!(!Dialect::Smb2_1.supports_encryption());
        assert!(Dialect::Smb3_0.supports_encryption());
        assert!(Dialect::Smb3_1_1.supports_encryption());
        assert!(Dialect::Smb3_0.is_smb3());
        assert!(!Dialect::Smb2_1.is_smb3());
    }

    #[test]
    fn share_type_roundtrip() {
        for st in ShareType::ALL {
            let tag = st.to_tag();
            let decoded = ShareType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, st);
        }
        assert!(ShareType::from_tag(3).is_none());
    }

    #[test]
    fn share_type_filesystem() {
        assert!(ShareType::Disk.is_filesystem());
        assert!(!ShareType::Pipe.is_filesystem());
        assert!(!ShareType::Print.is_filesystem());
    }

    #[test]
    fn session_state_roundtrip() {
        for ss in SessionState::ALL {
            let tag = ss.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ss);
        }
        assert!(SessionState::from_tag(6).is_none());
    }

    #[test]
    fn session_state_classification() {
        assert!(!SessionState::Idle.is_authenticated());
        assert!(!SessionState::Negotiated.is_authenticated());
        assert!(SessionState::Authenticated.is_authenticated());
        assert!(SessionState::TreeConnected.is_authenticated());
        assert!(SessionState::FileOpen.is_authenticated());
        assert!(SessionState::FileOpen.can_do_file_io());
        assert!(!SessionState::TreeConnected.can_do_file_io());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SMB_PORT, 445);
        assert_eq!(SMB_NETBIOS_PORT, 139);
    }
}
