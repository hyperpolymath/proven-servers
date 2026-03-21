// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! IMAP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `IMAPABI.Types` and its type definitions:
//! - `Command`  — IMAP commands (14 constructors, tags 0-13)
//! - `State`    — IMAP session state machine (4 constructors, tags 0-3)
//! - `Flag`     — message flags (6 constructors, tags 0-5)
//!
//! The state machine includes formally verified valid transitions from
//! the Idris2 `ValidStateTransition` indexed type, translated to a
//! validation function here.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// IMAP Constants
// ===========================================================================

/// Standard IMAP port (RFC 3501).
pub const IMAP_PORT: u16 = 143;

/// Standard IMAPS (IMAP over TLS) port.
pub const IMAPS_PORT: u16 = 993;

// ===========================================================================
// Command (tags 0-13)
// ===========================================================================

/// IMAP protocol commands (RFC 3501).
///
/// Matches `Command` in `IMAPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// LOGIN — authenticate with username/password (tag 0).
    Login = 0,
    /// LOGOUT — end session (tag 1).
    Logout = 1,
    /// SELECT — select a mailbox for access (tag 2).
    Select = 2,
    /// EXAMINE — select a mailbox read-only (tag 3).
    Examine = 3,
    /// CREATE — create a new mailbox (tag 4).
    Create = 4,
    /// DELETE — remove a mailbox (tag 5).
    Delete = 5,
    /// RENAME — rename a mailbox (tag 6).
    Rename = 6,
    /// LIST — list available mailboxes (tag 7).
    List = 7,
    /// FETCH — retrieve message data (tag 8).
    Fetch = 8,
    /// STORE — modify message flags (tag 9).
    Store = 9,
    /// SEARCH — search for messages (tag 10).
    Search = 10,
    /// COPY — copy messages to another mailbox (tag 11).
    Copy = 11,
    /// NOOP — no operation / check for updates (tag 12).
    Noop = 12,
    /// CAPABILITY — list server capabilities (tag 13).
    Capability = 13,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Login),
            1 => Some(Self::Logout),
            2 => Some(Self::Select),
            3 => Some(Self::Examine),
            4 => Some(Self::Create),
            5 => Some(Self::Delete),
            6 => Some(Self::Rename),
            7 => Some(Self::List),
            8 => Some(Self::Fetch),
            9 => Some(Self::Store),
            10 => Some(Self::Search),
            11 => Some(Self::Copy),
            12 => Some(Self::Noop),
            13 => Some(Self::Capability),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The IMAP command name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::Login => "LOGIN",
            Self::Logout => "LOGOUT",
            Self::Select => "SELECT",
            Self::Examine => "EXAMINE",
            Self::Create => "CREATE",
            Self::Delete => "DELETE",
            Self::Rename => "RENAME",
            Self::List => "LIST",
            Self::Fetch => "FETCH",
            Self::Store => "STORE",
            Self::Search => "SEARCH",
            Self::Copy => "COPY",
            Self::Noop => "NOOP",
            Self::Capability => "CAPABILITY",
        }
    }

    /// The minimum IMAP state required to issue this command.
    pub fn required_state(self) -> State {
        match self {
            Self::Login | Self::Logout | Self::Capability | Self::Noop => State::NotAuthenticated,
            Self::Select | Self::Examine | Self::Create | Self::Delete
            | Self::Rename | Self::List => State::Authenticated,
            Self::Fetch | Self::Store | Self::Search | Self::Copy => State::Selected,
        }
    }

    /// Whether this command modifies mailbox or message state.
    pub fn is_write(self) -> bool {
        matches!(
            self,
            Self::Create | Self::Delete | Self::Rename | Self::Store | Self::Copy
        )
    }

    /// All supported commands.
    pub const ALL: [Command; 14] = [
        Self::Login, Self::Logout, Self::Select, Self::Examine, Self::Create,
        Self::Delete, Self::Rename, Self::List, Self::Fetch, Self::Store,
        Self::Search, Self::Copy, Self::Noop, Self::Capability,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

// ===========================================================================
// State (tags 0-3)
// ===========================================================================

/// IMAP session state machine (RFC 3501 Section 3).
///
/// Matches `State` in `IMAPABI.Types`.
///
/// The valid transitions are formally verified in the Idris2 source
/// via the indexed `ValidStateTransition` type. The Rust equivalent
/// is the [`State::can_transition_to`] validation function.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum State {
    /// Not authenticated — awaiting LOGIN or AUTHENTICATE (tag 0).
    NotAuthenticated = 0,
    /// Authenticated — can select mailboxes (tag 1).
    Authenticated = 1,
    /// Selected — a mailbox is open for message operations (tag 2).
    Selected = 2,
    /// Logout — session is ending (tag 3).
    Logout = 3,
}

impl State {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NotAuthenticated),
            1 => Some(Self::Authenticated),
            2 => Some(Self::Selected),
            3 => Some(Self::Logout),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    ///
    /// This mirrors the Idris2 `ValidStateTransition` indexed type,
    /// which formally proves that only these transitions are valid:
    /// - NotAuthenticated -> Authenticated (LOGIN)
    /// - Authenticated -> Selected (SELECT/EXAMINE)
    /// - Selected -> Authenticated (CLOSE)
    /// - NotAuthenticated -> Logout (LOGOUT)
    /// - Authenticated -> Logout (LOGOUT)
    /// - Selected -> Logout (LOGOUT)
    ///
    /// The Idris2 proof `cannotSelectWithoutAuth` formally proves
    /// that NotAuthenticated -> Selected is impossible.
    pub fn can_transition_to(self, next: State) -> bool {
        matches!(
            (self, next),
            (Self::NotAuthenticated, Self::Authenticated) // AuthLogin
                | (Self::Authenticated, Self::Selected)   // SelectMailbox
                | (Self::Selected, Self::Authenticated)   // CloseMailbox
                | (Self::NotAuthenticated, Self::Logout)   // LogoutFromUnauth
                | (Self::Authenticated, Self::Logout)      // LogoutFromAuth
                | (Self::Selected, Self::Logout)           // LogoutFromSelected
        )
    }
}

impl fmt::Display for State {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Flag (tags 0-5)
// ===========================================================================

/// IMAP message flags (RFC 3501 Section 2.3.2).
///
/// Matches `Flag` in `IMAPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Flag {
    /// \Seen — message has been read (tag 0).
    Seen = 0,
    /// \Answered — message has been replied to (tag 1).
    Answered = 1,
    /// \Flagged — message is flagged for attention (tag 2).
    Flagged = 2,
    /// \Deleted — message is marked for deletion (tag 3).
    Deleted = 3,
    /// \Draft — message is a draft (tag 4).
    Draft = 4,
    /// \Recent — message recently arrived (server-managed) (tag 5).
    Recent = 5,
}

impl Flag {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Seen),
            1 => Some(Self::Answered),
            2 => Some(Self::Flagged),
            3 => Some(Self::Deleted),
            4 => Some(Self::Draft),
            5 => Some(Self::Recent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The IMAP flag string including the backslash prefix.
    pub fn imap_name(self) -> &'static str {
        match self {
            Self::Seen => "\\Seen",
            Self::Answered => "\\Answered",
            Self::Flagged => "\\Flagged",
            Self::Deleted => "\\Deleted",
            Self::Draft => "\\Draft",
            Self::Recent => "\\Recent",
        }
    }

    /// Whether this flag can be set by clients.
    ///
    /// The \Recent flag is server-managed and cannot be set by clients.
    pub fn is_client_settable(self) -> bool {
        !matches!(self, Self::Recent)
    }

    /// All supported flags.
    pub const ALL: [Flag; 6] = [
        Self::Seen, Self::Answered, Self::Flagged,
        Self::Deleted, Self::Draft, Self::Recent,
    ];
}

impl fmt::Display for Flag {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.imap_name())
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
        assert!(Command::from_tag(14).is_none());
    }

    #[test]
    fn command_required_state() {
        assert_eq!(Command::Login.required_state(), State::NotAuthenticated);
        assert_eq!(Command::Select.required_state(), State::Authenticated);
        assert_eq!(Command::Fetch.required_state(), State::Selected);
        assert_eq!(Command::Noop.required_state(), State::NotAuthenticated);
    }

    #[test]
    fn command_write_classification() {
        assert!(Command::Create.is_write());
        assert!(Command::Delete.is_write());
        assert!(Command::Store.is_write());
        assert!(Command::Copy.is_write());
        assert!(!Command::Fetch.is_write());
        assert!(!Command::Search.is_write());
        assert!(!Command::Login.is_write());
    }

    #[test]
    fn state_roundtrip() {
        for tag in 0u8..=3 {
            let state = State::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(State::from_tag(4).is_none());
    }

    #[test]
    fn state_valid_transitions() {
        // AuthLogin: NotAuthenticated -> Authenticated
        assert!(State::NotAuthenticated.can_transition_to(State::Authenticated));
        // SelectMailbox: Authenticated -> Selected
        assert!(State::Authenticated.can_transition_to(State::Selected));
        // CloseMailbox: Selected -> Authenticated
        assert!(State::Selected.can_transition_to(State::Authenticated));
        // Logout from any non-logout state
        assert!(State::NotAuthenticated.can_transition_to(State::Logout));
        assert!(State::Authenticated.can_transition_to(State::Logout));
        assert!(State::Selected.can_transition_to(State::Logout));
    }

    #[test]
    fn state_invalid_transitions() {
        // cannotSelectWithoutAuth: formally proven in Idris2
        assert!(!State::NotAuthenticated.can_transition_to(State::Selected));
        // Cannot go back from Logout
        assert!(!State::Logout.can_transition_to(State::NotAuthenticated));
        assert!(!State::Logout.can_transition_to(State::Authenticated));
        // Cannot skip to Selected from NotAuthenticated
        assert!(!State::NotAuthenticated.can_transition_to(State::Selected));
    }

    #[test]
    fn flag_roundtrip() {
        for flag in Flag::ALL {
            let tag = flag.to_tag();
            let decoded = Flag::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, flag);
        }
        assert!(Flag::from_tag(6).is_none());
    }

    #[test]
    fn flag_client_settable() {
        assert!(Flag::Seen.is_client_settable());
        assert!(Flag::Answered.is_client_settable());
        assert!(Flag::Flagged.is_client_settable());
        assert!(Flag::Deleted.is_client_settable());
        assert!(Flag::Draft.is_client_settable());
        assert!(!Flag::Recent.is_client_settable());
    }

    #[test]
    fn flag_imap_names() {
        assert_eq!(Flag::Seen.imap_name(), "\\Seen");
        assert_eq!(Flag::Deleted.imap_name(), "\\Deleted");
        assert_eq!(Flag::Recent.imap_name(), "\\Recent");
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(IMAP_PORT, 143);
        assert_eq!(IMAPS_PORT, 993);
    }
}
