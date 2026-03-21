// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Telnet protocol types for the proven-servers ABI.
//!
//! **INSECURE PROTOCOL** — for legacy interoperability only.
//!
//! Mirrors the Idris2 module `TelnetABI.Types` and its type definitions:
//! - `Command`          — Telnet commands (16 constructors, tags 0-15)
//! - `TelnetOption`     — Telnet options (10 constructors, tags 0-9)
//! - `NegotiationState` — Option negotiation states (4 constructors, tags 0-3)
//! - `SessionState`     — Session lifecycle states (5 constructors, tags 0-4)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Telnet Constants
// ===========================================================================

/// Standard Telnet port (RFC 854).
pub const TELNET_PORT: u16 = 23;

// ===========================================================================
// Command (tags 0-15)
// ===========================================================================

/// Telnet protocol commands (RFC 854).
///
/// Matches `Command` in `TelnetABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// SE — End of subnegotiation (tag 0).
    Se = 0,
    /// NOP — No operation (tag 1).
    Nop = 1,
    /// Data Mark (tag 2).
    DataMark = 2,
    /// Break (tag 3).
    Break = 3,
    /// Interrupt Process (tag 4).
    InterruptProcess = 4,
    /// Abort Output (tag 5).
    AbortOutput = 5,
    /// Are You There (tag 6).
    AreYouThere = 6,
    /// Erase Character (tag 7).
    EraseChar = 7,
    /// Erase Line (tag 8).
    EraseLine = 8,
    /// Go Ahead (tag 9).
    GoAhead = 9,
    /// SB — Begin subnegotiation (tag 10).
    Sb = 10,
    /// WILL — sender wants to enable option (tag 11).
    Will = 11,
    /// WONT — sender refuses to enable option (tag 12).
    Wont = 12,
    /// DO — sender wants receiver to enable option (tag 13).
    Do = 13,
    /// DONT — sender wants receiver to disable option (tag 14).
    Dont = 14,
    /// IAC — Interpret As Command escape (tag 15).
    Iac = 15,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Se),
            1 => Some(Self::Nop),
            2 => Some(Self::DataMark),
            3 => Some(Self::Break),
            4 => Some(Self::InterruptProcess),
            5 => Some(Self::AbortOutput),
            6 => Some(Self::AreYouThere),
            7 => Some(Self::EraseChar),
            8 => Some(Self::EraseLine),
            9 => Some(Self::GoAhead),
            10 => Some(Self::Sb),
            11 => Some(Self::Will),
            12 => Some(Self::Wont),
            13 => Some(Self::Do),
            14 => Some(Self::Dont),
            15 => Some(Self::Iac),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this command is a negotiation command (WILL/WONT/DO/DONT).
    pub fn is_negotiation(self) -> bool {
        matches!(self, Self::Will | Self::Wont | Self::Do | Self::Dont)
    }

    /// All supported commands.
    pub const ALL: [Command; 16] = [
        Self::Se, Self::Nop, Self::DataMark, Self::Break,
        Self::InterruptProcess, Self::AbortOutput, Self::AreYouThere,
        Self::EraseChar, Self::EraseLine, Self::GoAhead, Self::Sb,
        Self::Will, Self::Wont, Self::Do, Self::Dont, Self::Iac,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TelnetOption (tags 0-9)
// ===========================================================================

/// Telnet options (RFC 854, RFC 1091, RFC 1073, etc.).
///
/// Matches `Option` in `TelnetABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TelnetOption {
    /// Echo (tag 0).
    Echo = 0,
    /// Suppress Go Ahead (tag 1).
    SuppressGoAhead = 1,
    /// Status (tag 2).
    Status = 2,
    /// Timing Mark (tag 3).
    TimingMark = 3,
    /// Terminal Type (tag 4).
    TerminalType = 4,
    /// Window Size — NAWS (tag 5).
    WindowSize = 5,
    /// Terminal Speed (tag 6).
    TerminalSpeed = 6,
    /// Remote Flow Control (tag 7).
    RemoteFlowControl = 7,
    /// Linemode (tag 8).
    Linemode = 8,
    /// Environment Variables (tag 9).
    Environment = 9,
}

impl TelnetOption {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Echo),
            1 => Some(Self::SuppressGoAhead),
            2 => Some(Self::Status),
            3 => Some(Self::TimingMark),
            4 => Some(Self::TerminalType),
            5 => Some(Self::WindowSize),
            6 => Some(Self::TerminalSpeed),
            7 => Some(Self::RemoteFlowControl),
            8 => Some(Self::Linemode),
            9 => Some(Self::Environment),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported options.
    pub const ALL: [TelnetOption; 10] = [
        Self::Echo, Self::SuppressGoAhead, Self::Status, Self::TimingMark,
        Self::TerminalType, Self::WindowSize, Self::TerminalSpeed,
        Self::RemoteFlowControl, Self::Linemode, Self::Environment,
    ];
}

impl fmt::Display for TelnetOption {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NegotiationState (tags 0-3)
// ===========================================================================

/// Telnet option negotiation state.
///
/// Matches `NegotiationState` in `TelnetABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NegotiationState {
    /// Option inactive (tag 0).
    Inactive = 0,
    /// WILL sent, awaiting response (tag 1).
    WillSent = 1,
    /// DO sent, awaiting response (tag 2).
    DoSent = 2,
    /// Option active (tag 3).
    Active = 3,
}

impl NegotiationState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Inactive),
            1 => Some(Self::WillSent),
            2 => Some(Self::DoSent),
            3 => Some(Self::Active),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported states.
    pub const ALL: [NegotiationState; 4] = [
        Self::Inactive, Self::WillSent, Self::DoSent, Self::Active,
    ];
}

impl fmt::Display for NegotiationState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Telnet session lifecycle states.
///
/// Matches `SessionState` in `TelnetABI.Types`.
/// **INSECURE PROTOCOL** — for legacy interoperability only.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// No connection (tag 0).
    Idle = 0,
    /// Connection established, negotiation in progress (tag 1).
    Negotiating = 1,
    /// Negotiation complete, data transfer active (tag 2).
    Active = 2,
    /// Subnegotiation in progress (tag 3).
    Subneg = 3,
    /// Connection closing (tag 4).
    Closing = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Negotiating),
            2 => Some(Self::Active),
            3 => Some(Self::Subneg),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported states.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Negotiating, Self::Active, Self::Subneg, Self::Closing,
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
    fn command_negotiation() {
        assert!(Command::Will.is_negotiation());
        assert!(Command::Do.is_negotiation());
        assert!(!Command::Nop.is_negotiation());
        assert!(!Command::Iac.is_negotiation());
    }

    #[test]
    fn option_roundtrip() {
        for opt in TelnetOption::ALL {
            let tag = opt.to_tag();
            let decoded = TelnetOption::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, opt);
        }
        assert!(TelnetOption::from_tag(10).is_none());
    }

    #[test]
    fn negotiation_state_roundtrip() {
        for ns in NegotiationState::ALL {
            let tag = ns.to_tag();
            let decoded = NegotiationState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ns);
        }
        assert!(NegotiationState::from_tag(4).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for ss in SessionState::ALL {
            let tag = ss.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ss);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(TELNET_PORT, 23);
    }
}
