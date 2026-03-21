// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! POP3 protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `POP3ABI.Types` and its type definitions:
//! - `Command`   — POP3 commands (11 constructors, tags 0-10)
//! - `State`     — POP3 session state machine (3 constructors, tags 0-2)
//! - `Response`  — POP3 response indicators (2 constructors, tags 0-1)
//! - `Pop3Error` — FFI error codes (6 constructors, tags 0-5)
//!
//! The state machine mirrors the formally verified transitions from the
//! Idris2 source. All discriminant values match the ABI tag definitions.

use std::fmt;

// ===========================================================================
// POP3 Constants
// ===========================================================================

/// Standard POP3 port (RFC 1939).
pub const POP3_PORT: u16 = 110;

/// Standard POP3S (POP3 over TLS) port.
pub const POP3S_PORT: u16 = 995;

// ===========================================================================
// Command (tags 0-10)
// ===========================================================================

/// POP3 protocol commands (RFC 1939).
///
/// Matches `Command` in `POP3ABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// USER — identify user for authentication (tag 0).
    User = 0,
    /// PASS — supply password for authentication (tag 1).
    Pass = 1,
    /// STAT — request mailbox status (tag 2).
    Stat = 2,
    /// LIST — list message sizes (tag 3).
    List = 3,
    /// RETR — retrieve a message (tag 4).
    Retr = 4,
    /// DELE — mark a message for deletion (tag 5).
    Dele = 5,
    /// NOOP — no operation (tag 6).
    Noop = 6,
    /// RSET — reset deletion marks (tag 7).
    Rset = 7,
    /// QUIT — end session (tag 8).
    Quit = 8,
    /// TOP — retrieve message headers plus N lines (tag 9).
    Top = 9,
    /// UIDL — unique ID listing (tag 10).
    Uidl = 10,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::User),
            1 => Some(Self::Pass),
            2 => Some(Self::Stat),
            3 => Some(Self::List),
            4 => Some(Self::Retr),
            5 => Some(Self::Dele),
            6 => Some(Self::Noop),
            7 => Some(Self::Rset),
            8 => Some(Self::Quit),
            9 => Some(Self::Top),
            10 => Some(Self::Uidl),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The POP3 command name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::User => "USER",
            Self::Pass => "PASS",
            Self::Stat => "STAT",
            Self::List => "LIST",
            Self::Retr => "RETR",
            Self::Dele => "DELE",
            Self::Noop => "NOOP",
            Self::Rset => "RSET",
            Self::Quit => "QUIT",
            Self::Top => "TOP",
            Self::Uidl => "UIDL",
        }
    }

    /// The minimum POP3 state required to issue this command.
    pub fn required_state(self) -> State {
        match self {
            Self::User | Self::Pass | Self::Quit => State::Authorization,
            Self::Stat | Self::List | Self::Retr | Self::Dele
            | Self::Noop | Self::Rset | Self::Top | Self::Uidl => State::Transaction,
        }
    }

    /// Whether this command modifies mailbox state.
    pub fn is_write(self) -> bool {
        matches!(self, Self::Dele | Self::Rset)
    }

    /// All supported commands.
    pub const ALL: [Command; 11] = [
        Self::User, Self::Pass, Self::Stat, Self::List, Self::Retr,
        Self::Dele, Self::Noop, Self::Rset, Self::Quit, Self::Top, Self::Uidl,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

// ===========================================================================
// State (tags 0-2)
// ===========================================================================

/// POP3 session state machine (RFC 1939 Section 5).
///
/// Matches `State` in `POP3ABI.Types`.
///
/// Valid transitions (formally verified in Idris2):
/// - Authorization -> Transaction (successful authentication)
/// - Transaction -> Update (QUIT command)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum State {
    /// Authorization — awaiting USER/PASS (tag 0).
    Authorization = 0,
    /// Transaction — mailbox open for commands (tag 1).
    Transaction = 1,
    /// Update — QUIT received, deletions being committed (tag 2).
    Update = 2,
}

impl State {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Authorization),
            1 => Some(Self::Transaction),
            2 => Some(Self::Update),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: State) -> bool {
        matches!(
            (self, next),
            (Self::Authorization, Self::Transaction)
                | (Self::Transaction, Self::Update)
        )
    }
}

impl fmt::Display for State {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Response (tags 0-1)
// ===========================================================================

/// POP3 response indicators (RFC 1939).
///
/// Matches `Response` in `POP3ABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Response {
    /// +OK — command succeeded (tag 0).
    Ok = 0,
    /// -ERR — command failed (tag 1).
    Err = 1,
}

impl Response {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::Err),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this response indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// The POP3 response prefix string.
    pub fn prefix(self) -> &'static str {
        match self {
            Self::Ok => "+OK",
            Self::Err => "-ERR",
        }
    }
}

impl fmt::Display for Response {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.prefix())
    }
}

// ===========================================================================
// Pop3Error (tags 0-5)
// ===========================================================================

/// POP3 FFI error codes.
///
/// Matches `POP3Error` in `POP3ABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Pop3Error {
    /// No error (tag 0).
    Ok = 0,
    /// Invalid slot index (tag 1).
    InvalidSlot = 1,
    /// Session not active (tag 2).
    NotActive = 2,
    /// Invalid state transition (tag 3).
    InvalidTransition = 3,
    /// Command not allowed in current state (tag 4).
    InvalidCommand = 4,
    /// Authentication failed (tag 5).
    AuthFailed = 5,
}

impl Pop3Error {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::InvalidSlot),
            2 => Some(Self::NotActive),
            3 => Some(Self::InvalidTransition),
            4 => Some(Self::InvalidCommand),
            5 => Some(Self::AuthFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error code indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// All error codes.
    pub const ALL: [Pop3Error; 6] = [
        Self::Ok, Self::InvalidSlot, Self::NotActive,
        Self::InvalidTransition, Self::InvalidCommand, Self::AuthFailed,
    ];
}

impl fmt::Display for Pop3Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for Pop3Error {}

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
        assert!(Command::from_tag(11).is_none());
    }

    #[test]
    fn command_required_state() {
        assert_eq!(Command::User.required_state(), State::Authorization);
        assert_eq!(Command::Pass.required_state(), State::Authorization);
        assert_eq!(Command::Stat.required_state(), State::Transaction);
        assert_eq!(Command::Retr.required_state(), State::Transaction);
    }

    #[test]
    fn state_roundtrip() {
        for tag in 0u8..=2 {
            let state = State::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(State::from_tag(3).is_none());
    }

    #[test]
    fn state_valid_transitions() {
        assert!(State::Authorization.can_transition_to(State::Transaction));
        assert!(State::Transaction.can_transition_to(State::Update));
    }

    #[test]
    fn state_invalid_transitions() {
        assert!(!State::Authorization.can_transition_to(State::Update));
        assert!(!State::Update.can_transition_to(State::Authorization));
        assert!(!State::Transaction.can_transition_to(State::Authorization));
    }

    #[test]
    fn response_roundtrip() {
        assert_eq!(Response::from_tag(0), Some(Response::Ok));
        assert_eq!(Response::from_tag(1), Some(Response::Err));
        assert!(Response::from_tag(2).is_none());
    }

    #[test]
    fn pop3_error_roundtrip() {
        for err in Pop3Error::ALL {
            let tag = err.to_tag();
            let decoded = Pop3Error::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, err);
        }
        assert!(Pop3Error::from_tag(6).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(POP3_PORT, 110);
        assert_eq!(POP3S_PORT, 995);
    }
}
