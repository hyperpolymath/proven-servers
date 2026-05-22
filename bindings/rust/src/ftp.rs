// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! FTP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `FtpABI.Types` and its type definitions:
//! - `SessionState`    — FTP session state machine (5 constructors, tags 0-4)
//! - `TransferType`    — data transfer type (2 constructors, tags 0-1)
//! - `DataMode`        — active vs passive mode (2 constructors, tags 0-1)
//! - `TransferState`   — file transfer state machine (4 constructors, tags 0-3)
//! - `ReplyCategory`   — FTP reply categories (5 constructors, tags 0-4)
//! - `Command`         — FTP commands (23 constructors, tags 0-22)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// FTP Constants
// ===========================================================================

/// Standard FTP control port (RFC 959).
pub const FTP_CONTROL_PORT: u16 = 21;

/// Standard FTP data port (RFC 959).
pub const FTP_DATA_PORT: u16 = 20;

/// FTPS (implicit TLS) control port.
pub const FTPS_PORT: u16 = 990;

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// FTP session state machine.
///
/// Matches `SessionState` in `FtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// TCP connection established, awaiting USER (tag 0).
    Connected = 0,
    /// USER accepted, awaiting PASS (tag 1).
    UserOk = 1,
    /// Fully authenticated and ready (tag 2).
    Authenticated = 2,
    /// RNFR sent, awaiting RNTO (tag 3).
    Renaming = 3,
    /// QUIT sent, session ending (tag 4).
    Quit = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connected),
            1 => Some(Self::UserOk),
            2 => Some(Self::Authenticated),
            3 => Some(Self::Renaming),
            4 => Some(Self::Quit),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: SessionState) -> bool {
        matches!(
            (self, next),
            (Self::Connected, Self::UserOk)
                | (Self::UserOk, Self::Authenticated)
                | (Self::UserOk, Self::Connected)      // Login failed
                | (Self::Authenticated, Self::Renaming)
                | (Self::Renaming, Self::Authenticated) // RNTO completed or RNFR aborted
                | (_, Self::Quit)                       // Can quit from any state
        )
    }
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransferType (tags 0-1)
// ===========================================================================

/// FTP data transfer type (RFC 959 Section 3.1.1).
///
/// Matches `TransferType` in `FtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferType {
    /// ASCII mode — text with CRLF line endings (tag 0).
    Ascii = 0,
    /// Binary (Image) mode — raw byte transfer (tag 1).
    Binary = 1,
}

impl TransferType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ascii),
            1 => Some(Self::Binary),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The FTP TYPE parameter character.
    pub fn type_char(self) -> char {
        match self {
            Self::Ascii => 'A',
            Self::Binary => 'I',
        }
    }
}

impl fmt::Display for TransferType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DataMode (tags 0-1)
// ===========================================================================

/// FTP data connection mode (RFC 959).
///
/// Matches `DataModeTag` in `FtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DataMode {
    /// Active mode — server connects to client (tag 0).
    Active = 0,
    /// Passive mode — client connects to server (tag 1).
    Passive = 1,
}

impl DataMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Active),
            1 => Some(Self::Passive),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this mode is firewall-friendly (passive allows NAT traversal).
    pub fn is_firewall_friendly(self) -> bool {
        matches!(self, Self::Passive)
    }
}

impl fmt::Display for DataMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransferState (tags 0-3)
// ===========================================================================

/// FTP file transfer state machine.
///
/// Matches `TransferStateTag` in `FtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferState {
    /// No transfer in progress (tag 0).
    Idle = 0,
    /// Transfer is actively in progress (tag 1).
    InProgress = 1,
    /// Transfer completed successfully (tag 2).
    Completed = 2,
    /// Transfer was aborted (tag 3).
    Aborted = 3,
}

impl TransferState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::InProgress),
            2 => Some(Self::Completed),
            3 => Some(Self::Aborted),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the transfer has finished (completed or aborted).
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Completed | Self::Aborted)
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: TransferState) -> bool {
        matches!(
            (self, next),
            (Self::Idle, Self::InProgress)
                | (Self::InProgress, Self::Completed)
                | (Self::InProgress, Self::Aborted)
                | (Self::Completed, Self::Idle) // Reset for next transfer
                | (Self::Aborted, Self::Idle)   // Reset for next transfer
        )
    }
}

impl fmt::Display for TransferState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ReplyCategory (tags 0-4)
// ===========================================================================

/// FTP reply categories (RFC 959 Section 4.2).
///
/// Matches `ReplyCategory` in `FtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ReplyCategory {
    /// 1xx — Preliminary positive reply (tag 0).
    Preliminary = 0,
    /// 2xx — Completion positive reply (tag 1).
    Completion = 1,
    /// 3xx — Intermediate positive reply (tag 2).
    Intermediate = 2,
    /// 4xx — Transient negative reply (tag 3).
    TransientNeg = 3,
    /// 5xx — Permanent negative reply (tag 4).
    PermanentNeg = 4,
}

impl ReplyCategory {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Preliminary),
            1 => Some(Self::Completion),
            2 => Some(Self::Intermediate),
            3 => Some(Self::TransientNeg),
            4 => Some(Self::PermanentNeg),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this category indicates a positive outcome.
    pub fn is_positive(self) -> bool {
        matches!(self, Self::Preliminary | Self::Completion | Self::Intermediate)
    }

    /// Whether this category indicates an error.
    pub fn is_error(self) -> bool {
        matches!(self, Self::TransientNeg | Self::PermanentNeg)
    }
}

impl fmt::Display for ReplyCategory {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Command (tags 0-22)
// ===========================================================================

/// FTP protocol commands (RFC 959, RFC 2389, RFC 3659).
///
/// Matches `CommandTag` in `FtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// USER — specify username (tag 0).
    User = 0,
    /// PASS — specify password (tag 1).
    Pass = 1,
    /// ACCT — specify account (tag 2).
    Acct = 2,
    /// CWD — change working directory (tag 3).
    Cwd = 3,
    /// CDUP — change to parent directory (tag 4).
    Cdup = 4,
    /// QUIT — logout (tag 5).
    Quit = 5,
    /// PASV — enter passive mode (tag 6).
    Pasv = 6,
    /// PORT — specify data port (tag 7).
    Port = 7,
    /// TYPE — set transfer type (tag 8).
    TypeCmd = 8,
    /// RETR — retrieve (download) file (tag 9).
    Retr = 9,
    /// STOR — store (upload) file (tag 10).
    Stor = 10,
    /// DELE — delete file (tag 11).
    Dele = 11,
    /// RMD — remove directory (tag 12).
    Rmd = 12,
    /// MKD — make directory (tag 13).
    Mkd = 13,
    /// PWD — print working directory (tag 14).
    Pwd = 14,
    /// LIST — list directory contents (tag 15).
    List = 15,
    /// NLST — name list (tag 16).
    Nlst = 16,
    /// SYST — system type (tag 17).
    Syst = 17,
    /// STAT — server status (tag 18).
    Stat = 18,
    /// NOOP — no operation (tag 19).
    Noop = 19,
    /// RNFR — rename from (tag 20).
    Rnfr = 20,
    /// RNTO — rename to (tag 21).
    Rnto = 21,
    /// SIZE — file size (RFC 3659) (tag 22).
    Size = 22,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::User),
            1 => Some(Self::Pass),
            2 => Some(Self::Acct),
            3 => Some(Self::Cwd),
            4 => Some(Self::Cdup),
            5 => Some(Self::Quit),
            6 => Some(Self::Pasv),
            7 => Some(Self::Port),
            8 => Some(Self::TypeCmd),
            9 => Some(Self::Retr),
            10 => Some(Self::Stor),
            11 => Some(Self::Dele),
            12 => Some(Self::Rmd),
            13 => Some(Self::Mkd),
            14 => Some(Self::Pwd),
            15 => Some(Self::List),
            16 => Some(Self::Nlst),
            17 => Some(Self::Syst),
            18 => Some(Self::Stat),
            19 => Some(Self::Noop),
            20 => Some(Self::Rnfr),
            21 => Some(Self::Rnto),
            22 => Some(Self::Size),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The FTP command verb as a string.
    pub fn verb(self) -> &'static str {
        match self {
            Self::User => "USER",
            Self::Pass => "PASS",
            Self::Acct => "ACCT",
            Self::Cwd => "CWD",
            Self::Cdup => "CDUP",
            Self::Quit => "QUIT",
            Self::Pasv => "PASV",
            Self::Port => "PORT",
            Self::TypeCmd => "TYPE",
            Self::Retr => "RETR",
            Self::Stor => "STOR",
            Self::Dele => "DELE",
            Self::Rmd => "RMD",
            Self::Mkd => "MKD",
            Self::Pwd => "PWD",
            Self::List => "LIST",
            Self::Nlst => "NLST",
            Self::Syst => "SYST",
            Self::Stat => "STAT",
            Self::Noop => "NOOP",
            Self::Rnfr => "RNFR",
            Self::Rnto => "RNTO",
            Self::Size => "SIZE",
        }
    }

    /// Whether this command initiates a data transfer.
    pub fn requires_data_connection(self) -> bool {
        matches!(self, Self::Retr | Self::Stor | Self::List | Self::Nlst)
    }

    /// Whether this command requires authentication.
    pub fn requires_auth(self) -> bool {
        !matches!(self, Self::User | Self::Pass | Self::Acct | Self::Quit)
    }

    /// All supported commands.
    pub const ALL: [Command; 23] = [
        Self::User, Self::Pass, Self::Acct, Self::Cwd, Self::Cdup, Self::Quit,
        Self::Pasv, Self::Port, Self::TypeCmd, Self::Retr, Self::Stor, Self::Dele,
        Self::Rmd, Self::Mkd, Self::Pwd, Self::List, Self::Nlst, Self::Syst,
        Self::Stat, Self::Noop, Self::Rnfr, Self::Rnto, Self::Size,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.verb())
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn session_state_roundtrip() {
        for tag in 0u8..=4 {
            let state = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn session_state_transitions() {
        assert!(SessionState::Connected.can_transition_to(SessionState::UserOk));
        assert!(SessionState::UserOk.can_transition_to(SessionState::Authenticated));
        assert!(SessionState::Authenticated.can_transition_to(SessionState::Renaming));
        assert!(SessionState::Renaming.can_transition_to(SessionState::Authenticated));
        assert!(SessionState::Connected.can_transition_to(SessionState::Quit));
        assert!(!SessionState::Connected.can_transition_to(SessionState::Authenticated));
    }

    #[test]
    fn transfer_type_roundtrip() {
        for tag in 0u8..=1 {
            let tt = TransferType::from_tag(tag).expect("valid tag");
            assert_eq!(tt.to_tag(), tag);
        }
        assert!(TransferType::from_tag(2).is_none());
    }

    #[test]
    fn transfer_type_char() {
        assert_eq!(TransferType::Ascii.type_char(), 'A');
        assert_eq!(TransferType::Binary.type_char(), 'I');
    }

    #[test]
    fn data_mode_roundtrip() {
        for tag in 0u8..=1 {
            let dm = DataMode::from_tag(tag).expect("valid tag");
            assert_eq!(dm.to_tag(), tag);
        }
        assert!(DataMode::from_tag(2).is_none());
    }

    #[test]
    fn data_mode_firewall() {
        assert!(!DataMode::Active.is_firewall_friendly());
        assert!(DataMode::Passive.is_firewall_friendly());
    }

    #[test]
    fn transfer_state_roundtrip() {
        for tag in 0u8..=3 {
            let ts = TransferState::from_tag(tag).expect("valid tag");
            assert_eq!(ts.to_tag(), tag);
        }
        assert!(TransferState::from_tag(4).is_none());
    }

    #[test]
    fn transfer_state_transitions() {
        assert!(TransferState::Idle.can_transition_to(TransferState::InProgress));
        assert!(TransferState::InProgress.can_transition_to(TransferState::Completed));
        assert!(TransferState::InProgress.can_transition_to(TransferState::Aborted));
        assert!(TransferState::Completed.can_transition_to(TransferState::Idle));
        assert!(TransferState::Aborted.can_transition_to(TransferState::Idle));
        assert!(!TransferState::Idle.can_transition_to(TransferState::Completed));
    }

    #[test]
    fn transfer_state_terminal() {
        assert!(!TransferState::Idle.is_terminal());
        assert!(!TransferState::InProgress.is_terminal());
        assert!(TransferState::Completed.is_terminal());
        assert!(TransferState::Aborted.is_terminal());
    }

    #[test]
    fn reply_category_roundtrip() {
        for tag in 0u8..=4 {
            let cat = ReplyCategory::from_tag(tag).expect("valid tag");
            assert_eq!(cat.to_tag(), tag);
        }
        assert!(ReplyCategory::from_tag(5).is_none());
    }

    #[test]
    fn reply_category_classification() {
        assert!(ReplyCategory::Preliminary.is_positive());
        assert!(ReplyCategory::Completion.is_positive());
        assert!(ReplyCategory::Intermediate.is_positive());
        assert!(!ReplyCategory::TransientNeg.is_positive());
        assert!(ReplyCategory::TransientNeg.is_error());
        assert!(ReplyCategory::PermanentNeg.is_error());
    }

    #[test]
    fn command_roundtrip() {
        for cmd in Command::ALL {
            let tag = cmd.to_tag();
            let decoded = Command::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cmd);
        }
        assert!(Command::from_tag(23).is_none());
    }

    #[test]
    fn command_data_connection() {
        assert!(Command::Retr.requires_data_connection());
        assert!(Command::Stor.requires_data_connection());
        assert!(Command::List.requires_data_connection());
        assert!(!Command::Pwd.requires_data_connection());
        assert!(!Command::Quit.requires_data_connection());
    }

    #[test]
    fn command_auth_requirement() {
        assert!(!Command::User.requires_auth());
        assert!(!Command::Pass.requires_auth());
        assert!(!Command::Quit.requires_auth());
        assert!(Command::Retr.requires_auth());
        assert!(Command::Cwd.requires_auth());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(FTP_CONTROL_PORT, 21);
        assert_eq!(FTP_DATA_PORT, 20);
        assert_eq!(FTPS_PORT, 990);
    }
}
