// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! TFTP (Trivial File Transfer Protocol) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `TFTPABI.Types` and its type definitions:
//! - `Opcode`        — TFTP opcodes (5 constructors, tags 0-4)
//! - `TransferMode`  — TFTP transfer modes (3 constructors, tags 0-2)
//! - `TftpError`     — TFTP error codes (8 constructors, tags 0-7)
//! - `TransferState` — TFTP transfer lifecycle (5 constructors, tags 0-4)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// TFTP Constants
// ===========================================================================

/// Standard TFTP port (RFC 1350).
pub const TFTP_PORT: u16 = 69;

/// TFTP data block size (RFC 1350).
pub const TFTP_BLOCK_SIZE: u16 = 512;

// ===========================================================================
// Opcode (tags 0-4)
// ===========================================================================

/// TFTP opcodes (RFC 1350 Section 5).
///
/// Matches `Opcode` in `TFTPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Opcode {
    /// Read Request (tag 0).
    Rrq = 0,
    /// Write Request (tag 1).
    Wrq = 1,
    /// Data packet (tag 2).
    Data = 2,
    /// Acknowledgement (tag 3).
    Ack = 3,
    /// Error packet (tag 4).
    Error = 4,
}

impl Opcode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Rrq),
            1 => Some(Self::Wrq),
            2 => Some(Self::Data),
            3 => Some(Self::Ack),
            4 => Some(Self::Error),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this opcode initiates a transfer.
    pub fn is_request(self) -> bool {
        matches!(self, Self::Rrq | Self::Wrq)
    }

    /// Whether this opcode carries payload data.
    pub fn is_data(self) -> bool {
        matches!(self, Self::Data)
    }

    /// All supported opcodes.
    pub const ALL: [Opcode; 5] = [Self::Rrq, Self::Wrq, Self::Data, Self::Ack, Self::Error];
}

impl fmt::Display for Opcode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransferMode (tags 0-2)
// ===========================================================================

/// TFTP transfer modes (RFC 1350 Section 5).
///
/// Matches `TransferMode` in `TFTPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferMode {
    /// NetASCII — 7-bit ASCII with CR/LF line endings (tag 0).
    NetAscii = 0,
    /// Octet — raw binary transfer (tag 1).
    Octet = 1,
    /// Mail — deprecated, sends to a user's mailbox (tag 2).
    Mail = 2,
}

impl TransferMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NetAscii),
            1 => Some(Self::Octet),
            2 => Some(Self::Mail),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The TFTP mode string (case-insensitive per RFC).
    pub fn mode_string(self) -> &'static str {
        match self {
            Self::NetAscii => "netascii",
            Self::Octet => "octet",
            Self::Mail => "mail",
        }
    }

    /// Whether this mode performs character set conversion.
    pub fn is_text_mode(self) -> bool {
        matches!(self, Self::NetAscii)
    }

    /// Whether this transfer mode is deprecated.
    pub fn is_deprecated(self) -> bool {
        matches!(self, Self::Mail)
    }

    /// All supported transfer modes.
    pub const ALL: [TransferMode; 3] = [Self::NetAscii, Self::Octet, Self::Mail];
}

impl fmt::Display for TransferMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.mode_string())
    }
}

// ===========================================================================
// TftpError (tags 0-7)
// ===========================================================================

/// TFTP error codes (RFC 1350 Section 5).
///
/// Matches `TFTPError` in `TFTPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TftpError {
    /// Not defined — see error message (tag 0).
    NotDefined = 0,
    /// File not found (tag 1).
    FileNotFound = 1,
    /// Access violation (tag 2).
    AccessViolation = 2,
    /// Disk full or allocation exceeded (tag 3).
    DiskFull = 3,
    /// Illegal TFTP operation (tag 4).
    IllegalOperation = 4,
    /// Unknown transfer ID (tag 5).
    UnknownTid = 5,
    /// File already exists (tag 6).
    FileExists = 6,
    /// No such user (tag 7).
    NoSuchUser = 7,
}

impl TftpError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NotDefined),
            1 => Some(Self::FileNotFound),
            2 => Some(Self::AccessViolation),
            3 => Some(Self::DiskFull),
            4 => Some(Self::IllegalOperation),
            5 => Some(Self::UnknownTid),
            6 => Some(Self::FileExists),
            7 => Some(Self::NoSuchUser),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error relates to access control.
    pub fn is_access_error(self) -> bool {
        matches!(self, Self::AccessViolation | Self::NoSuchUser)
    }

    /// Whether this error relates to storage capacity.
    pub fn is_storage_error(self) -> bool {
        matches!(self, Self::DiskFull | Self::FileExists)
    }

    /// All supported error codes.
    pub const ALL: [TftpError; 8] = [
        Self::NotDefined, Self::FileNotFound, Self::AccessViolation, Self::DiskFull,
        Self::IllegalOperation, Self::UnknownTid, Self::FileExists, Self::NoSuchUser,
    ];
}

impl fmt::Display for TftpError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for TftpError {}

// ===========================================================================
// TransferState (tags 0-4)
// ===========================================================================

/// TFTP transfer lifecycle states.
///
/// Matches `TransferState` in `TFTPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferState {
    /// No transfer in progress (tag 0).
    Idle = 0,
    /// Reading from server (RRQ in progress) (tag 1).
    Reading = 1,
    /// Writing to server (WRQ in progress) (tag 2).
    Writing = 2,
    /// Transfer encountered an error (tag 3).
    InError = 3,
    /// Transfer completed successfully (tag 4).
    Complete = 4,
}

impl TransferState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Reading),
            2 => Some(Self::Writing),
            3 => Some(Self::InError),
            4 => Some(Self::Complete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether a transfer is actively in progress.
    pub fn is_active(self) -> bool {
        matches!(self, Self::Reading | Self::Writing)
    }

    /// Whether the transfer has reached a terminal state.
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::InError | Self::Complete)
    }

    /// All supported transfer states.
    pub const ALL: [TransferState; 5] = [
        Self::Idle, Self::Reading, Self::Writing, Self::InError, Self::Complete,
    ];
}

impl fmt::Display for TransferState {
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
    fn opcode_roundtrip() {
        for op in Opcode::ALL {
            let tag = op.to_tag();
            let decoded = Opcode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, op);
        }
        assert!(Opcode::from_tag(5).is_none());
    }

    #[test]
    fn opcode_classification() {
        assert!(Opcode::Rrq.is_request());
        assert!(Opcode::Wrq.is_request());
        assert!(!Opcode::Data.is_request());
        assert!(Opcode::Data.is_data());
        assert!(!Opcode::Ack.is_data());
    }

    #[test]
    fn transfer_mode_roundtrip() {
        for tm in TransferMode::ALL {
            let tag = tm.to_tag();
            let decoded = TransferMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, tm);
        }
        assert!(TransferMode::from_tag(3).is_none());
    }

    #[test]
    fn transfer_mode_classification() {
        assert!(TransferMode::NetAscii.is_text_mode());
        assert!(!TransferMode::Octet.is_text_mode());
        assert!(TransferMode::Mail.is_deprecated());
        assert!(!TransferMode::Octet.is_deprecated());
    }

    #[test]
    fn tftp_error_roundtrip() {
        for te in TftpError::ALL {
            let tag = te.to_tag();
            let decoded = TftpError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, te);
        }
        assert!(TftpError::from_tag(8).is_none());
    }

    #[test]
    fn tftp_error_classification() {
        assert!(TftpError::AccessViolation.is_access_error());
        assert!(TftpError::NoSuchUser.is_access_error());
        assert!(!TftpError::FileNotFound.is_access_error());
        assert!(TftpError::DiskFull.is_storage_error());
        assert!(TftpError::FileExists.is_storage_error());
    }

    #[test]
    fn transfer_state_roundtrip() {
        for ts in TransferState::ALL {
            let tag = ts.to_tag();
            let decoded = TransferState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ts);
        }
        assert!(TransferState::from_tag(5).is_none());
    }

    #[test]
    fn transfer_state_classification() {
        assert!(!TransferState::Idle.is_active());
        assert!(TransferState::Reading.is_active());
        assert!(TransferState::Writing.is_active());
        assert!(!TransferState::Complete.is_active());
        assert!(TransferState::InError.is_terminal());
        assert!(TransferState::Complete.is_terminal());
        assert!(!TransferState::Reading.is_terminal());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(TFTP_PORT, 69);
        assert_eq!(TFTP_BLOCK_SIZE, 512);
    }
}
