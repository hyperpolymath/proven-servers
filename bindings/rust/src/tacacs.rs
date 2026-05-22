// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! TACACS+ (Terminal Access Controller Access-Control System Plus) types
//! for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `TACACSABI.Types` and its type definitions:
//! - `PacketType`    — TACACS+ packet types (3 constructors, tags 0-2)
//! - `AuthenType`    — Authentication types (5 constructors, tags 0-4)
//! - `AuthenAction`  — Authentication actions (3 constructors, tags 0-2)
//! - `AuthenStatus`  — Authentication reply statuses (8 constructors, tags 0-7)
//! - `AuthorStatus`  — Authorization reply statuses (5 constructors, tags 0-4)
//! - `AcctStatus`    — Accounting reply statuses (3 constructors, tags 0-2)
//! - `AcctFlag`      — Accounting record flags (3 constructors, tags 0-2)
//! - `SessionState`  — TACACS+ session lifecycle (5 constructors, tags 0-4)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// TACACS+ Constants
// ===========================================================================

/// Standard TACACS+ port (RFC 8907).
pub const TACACS_PORT: u16 = 49;

// ===========================================================================
// PacketType (tags 0-2)
// ===========================================================================

/// TACACS+ packet types (RFC 8907 Section 4.1).
///
/// Matches `PacketType` in `TACACSABI.Types`.
/// The three fundamental AAA (Authentication, Authorization, Accounting)
/// service types.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketType {
    /// Authentication packet (tag 0).
    Authentication = 0,
    /// Authorization packet (tag 1).
    Authorization = 1,
    /// Accounting packet (tag 2).
    Accounting = 2,
}

impl PacketType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Authentication),
            1 => Some(Self::Authorization),
            2 => Some(Self::Accounting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The short AAA label for this packet type.
    pub fn aaa_label(self) -> &'static str {
        match self {
            Self::Authentication => "authen",
            Self::Authorization => "author",
            Self::Accounting => "acct",
        }
    }

    /// All supported packet types.
    pub const ALL: [PacketType; 3] = [
        Self::Authentication, Self::Authorization, Self::Accounting,
    ];
}

impl fmt::Display for PacketType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthenType (tags 0-4)
// ===========================================================================

/// TACACS+ authentication types (RFC 8907 Section 4.4.2).
///
/// Matches `AuthenType` in `TACACSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthenType {
    /// ASCII interactive login (tag 0).
    Ascii = 0,
    /// PAP — Password Authentication Protocol (tag 1).
    Pap = 1,
    /// CHAP — Challenge-Handshake Authentication Protocol (tag 2).
    Chap = 2,
    /// MS-CHAPv1 (tag 3).
    MsChapV1 = 3,
    /// MS-CHAPv2 (tag 4).
    MsChapV2 = 4,
}

impl AuthenType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ascii),
            1 => Some(Self::Pap),
            2 => Some(Self::Chap),
            3 => Some(Self::MsChapV1),
            4 => Some(Self::MsChapV2),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this authentication type uses challenge-response.
    pub fn is_challenge_response(self) -> bool {
        matches!(self, Self::Chap | Self::MsChapV1 | Self::MsChapV2)
    }

    /// Whether this authentication type is interactive (multi-round).
    pub fn is_interactive(self) -> bool {
        matches!(self, Self::Ascii)
    }

    /// All supported authentication types.
    pub const ALL: [AuthenType; 5] = [
        Self::Ascii, Self::Pap, Self::Chap, Self::MsChapV1, Self::MsChapV2,
    ];
}

impl fmt::Display for AuthenType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthenAction (tags 0-2)
// ===========================================================================

/// TACACS+ authentication actions (RFC 8907 Section 4.4.1).
///
/// Matches `AuthenAction` in `TACACSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthenAction {
    /// Login — authenticate a user (tag 0).
    Login = 0,
    /// ChangePass — change user password (tag 1).
    ChangePass = 1,
    /// SendAuth — send authentication data (tag 2).
    SendAuth = 2,
}

impl AuthenAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Login),
            1 => Some(Self::ChangePass),
            2 => Some(Self::SendAuth),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported authentication actions.
    pub const ALL: [AuthenAction; 3] = [Self::Login, Self::ChangePass, Self::SendAuth];
}

impl fmt::Display for AuthenAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthenStatus (tags 0-7)
// ===========================================================================

/// TACACS+ authentication reply statuses (RFC 8907 Section 4.4.2).
///
/// Matches `AuthenStatus` in `TACACSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthenStatus {
    /// Authentication passed (tag 0).
    Pass = 0,
    /// Authentication failed (tag 1).
    Fail = 1,
    /// Server requests additional data (tag 2).
    GetData = 2,
    /// Server requests username (tag 3).
    GetUser = 3,
    /// Server requests password (tag 4).
    GetPass = 4,
    /// Restart authentication (tag 5).
    Restart = 5,
    /// Authentication error (tag 6).
    Error = 6,
    /// Follow — redirect to another server (tag 7).
    Follow = 7,
}

impl AuthenStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pass),
            1 => Some(Self::Fail),
            2 => Some(Self::GetData),
            3 => Some(Self::GetUser),
            4 => Some(Self::GetPass),
            5 => Some(Self::Restart),
            6 => Some(Self::Error),
            7 => Some(Self::Follow),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether authentication succeeded.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Pass)
    }

    /// Whether the server needs more information from the client.
    pub fn needs_more_data(self) -> bool {
        matches!(self, Self::GetData | Self::GetUser | Self::GetPass)
    }

    /// Whether this status indicates a terminal (final) state.
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Pass | Self::Fail | Self::Error)
    }

    /// All supported authentication statuses.
    pub const ALL: [AuthenStatus; 8] = [
        Self::Pass, Self::Fail, Self::GetData, Self::GetUser, Self::GetPass,
        Self::Restart, Self::Error, Self::Follow,
    ];
}

impl fmt::Display for AuthenStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthorStatus (tags 0-4)
// ===========================================================================

/// TACACS+ authorization reply statuses (RFC 8907 Section 4.5).
///
/// Matches `AuthorStatus` in `TACACSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthorStatus {
    /// Authorized, server added attributes (tag 0).
    PassAdd = 0,
    /// Authorized, server replaced attributes (tag 1).
    PassRepl = 1,
    /// Authorization failed (tag 2).
    Fail = 2,
    /// Authorization error (tag 3).
    Error = 3,
    /// Follow — redirect to another server (tag 4).
    Follow = 4,
}

impl AuthorStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::PassAdd),
            1 => Some(Self::PassRepl),
            2 => Some(Self::Fail),
            3 => Some(Self::Error),
            4 => Some(Self::Follow),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether authorization was granted.
    pub fn is_authorized(self) -> bool {
        matches!(self, Self::PassAdd | Self::PassRepl)
    }

    /// All supported authorization statuses.
    pub const ALL: [AuthorStatus; 5] = [
        Self::PassAdd, Self::PassRepl, Self::Fail, Self::Error, Self::Follow,
    ];
}

impl fmt::Display for AuthorStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AcctStatus (tags 0-2)
// ===========================================================================

/// TACACS+ accounting reply statuses (RFC 8907 Section 4.6).
///
/// Matches `AcctStatus` in `TACACSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AcctStatus {
    /// Accounting record accepted (tag 0).
    Success = 0,
    /// Accounting error (tag 1).
    Error = 1,
    /// Follow — redirect to another server (tag 2).
    Follow = 2,
}

impl AcctStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Success),
            1 => Some(Self::Error),
            2 => Some(Self::Follow),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the accounting record was accepted.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Success)
    }

    /// All supported accounting statuses.
    pub const ALL: [AcctStatus; 3] = [Self::Success, Self::Error, Self::Follow];
}

impl fmt::Display for AcctStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AcctFlag (tags 0-2)
// ===========================================================================

/// TACACS+ accounting record flags (RFC 8907 Section 4.6.1).
///
/// Matches `AcctFlag` in `TACACSABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AcctFlag {
    /// Start of a session (tag 0).
    Start = 0,
    /// End of a session (tag 1).
    Stop = 1,
    /// Interim update / watchdog (tag 2).
    Watchdog = 2,
}

impl AcctFlag {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Start),
            1 => Some(Self::Stop),
            2 => Some(Self::Watchdog),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this flag marks a session boundary (start or stop).
    pub fn is_boundary(self) -> bool {
        matches!(self, Self::Start | Self::Stop)
    }

    /// All supported accounting flags.
    pub const ALL: [AcctFlag; 3] = [Self::Start, Self::Stop, Self::Watchdog];
}

impl fmt::Display for AcctFlag {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// TACACS+ session lifecycle states for the FFI layer.
///
/// Matches `SessionState` in `TACACSABI.Types`.
/// Combines the AAA phases into a single composite lifecycle enum.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// No session active (tag 0).
    Idle = 0,
    /// Authentication in progress (tag 1).
    Authenticating = 1,
    /// Authorization in progress (tag 2).
    Authorizing = 2,
    /// Session active, accounting records may be generated (tag 3).
    Active = 3,
    /// Session ending, final accounting being sent (tag 4).
    Closing = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Authenticating),
            2 => Some(Self::Authorizing),
            3 => Some(Self::Active),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the session is in an AAA processing phase.
    pub fn is_processing(self) -> bool {
        matches!(self, Self::Authenticating | Self::Authorizing)
    }

    /// Whether the session has been fully authorised and is active.
    pub fn is_active(self) -> bool {
        matches!(self, Self::Active)
    }

    /// All supported session states.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Authenticating, Self::Authorizing,
        Self::Active, Self::Closing,
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
    fn packet_type_roundtrip() {
        for pt in PacketType::ALL {
            let tag = pt.to_tag();
            let decoded = PacketType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, pt);
        }
        assert!(PacketType::from_tag(3).is_none());
    }

    #[test]
    fn authen_type_roundtrip() {
        for at in AuthenType::ALL {
            let tag = at.to_tag();
            let decoded = AuthenType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, at);
        }
        assert!(AuthenType::from_tag(5).is_none());
    }

    #[test]
    fn authen_type_classification() {
        assert!(AuthenType::Ascii.is_interactive());
        assert!(!AuthenType::Pap.is_interactive());
        assert!(AuthenType::Chap.is_challenge_response());
        assert!(AuthenType::MsChapV2.is_challenge_response());
        assert!(!AuthenType::Ascii.is_challenge_response());
    }

    #[test]
    fn authen_action_roundtrip() {
        for aa in AuthenAction::ALL {
            let tag = aa.to_tag();
            let decoded = AuthenAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, aa);
        }
        assert!(AuthenAction::from_tag(3).is_none());
    }

    #[test]
    fn authen_status_roundtrip() {
        for s in AuthenStatus::ALL {
            let tag = s.to_tag();
            let decoded = AuthenStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, s);
        }
        assert!(AuthenStatus::from_tag(8).is_none());
    }

    #[test]
    fn authen_status_classification() {
        assert!(AuthenStatus::Pass.is_success());
        assert!(!AuthenStatus::Fail.is_success());
        assert!(AuthenStatus::GetData.needs_more_data());
        assert!(AuthenStatus::GetUser.needs_more_data());
        assert!(AuthenStatus::GetPass.needs_more_data());
        assert!(!AuthenStatus::Pass.needs_more_data());
        assert!(AuthenStatus::Pass.is_terminal());
        assert!(AuthenStatus::Fail.is_terminal());
        assert!(!AuthenStatus::GetData.is_terminal());
    }

    #[test]
    fn author_status_roundtrip() {
        for s in AuthorStatus::ALL {
            let tag = s.to_tag();
            let decoded = AuthorStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, s);
        }
        assert!(AuthorStatus::from_tag(5).is_none());
    }

    #[test]
    fn author_status_authorized() {
        assert!(AuthorStatus::PassAdd.is_authorized());
        assert!(AuthorStatus::PassRepl.is_authorized());
        assert!(!AuthorStatus::Fail.is_authorized());
        assert!(!AuthorStatus::Error.is_authorized());
    }

    #[test]
    fn acct_status_roundtrip() {
        for s in AcctStatus::ALL {
            let tag = s.to_tag();
            let decoded = AcctStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, s);
        }
        assert!(AcctStatus::from_tag(3).is_none());
    }

    #[test]
    fn acct_flag_roundtrip() {
        for f in AcctFlag::ALL {
            let tag = f.to_tag();
            let decoded = AcctFlag::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, f);
        }
        assert!(AcctFlag::from_tag(3).is_none());
    }

    #[test]
    fn acct_flag_boundary() {
        assert!(AcctFlag::Start.is_boundary());
        assert!(AcctFlag::Stop.is_boundary());
        assert!(!AcctFlag::Watchdog.is_boundary());
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
    fn session_state_classification() {
        assert!(SessionState::Authenticating.is_processing());
        assert!(SessionState::Authorizing.is_processing());
        assert!(!SessionState::Active.is_processing());
        assert!(SessionState::Active.is_active());
        assert!(!SessionState::Authenticating.is_active());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(TACACS_PORT, 49);
    }
}
