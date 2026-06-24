//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// IMAP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `IMAPABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// IMAP Constants
// ===========================================================================

/// Imap Port constant.
pub const imap_port = 143

/// Imaps Port constant.
pub const imaps_port = 993

// ===========================================================================
// Command
// ===========================================================================

/// IMAP protocol commands (RFC 3501).
/// 
/// Matches `Command` in `IMAPABI.Types`.
pub type Command {
  /// LOGIN — authenticate with username/password (tag 0).
  Login
  /// LOGOUT — end session (tag 1).
  CommandLogout
  /// SELECT — select a mailbox for access (tag 2).
  Select
  /// EXAMINE — select a mailbox read-only (tag 3).
  Examine
  /// CREATE — create a new mailbox (tag 4).
  Create
  /// DELETE — remove a mailbox (tag 5).
  Delete
  /// RENAME — rename a mailbox (tag 6).
  Rename
  /// LIST — list available mailboxes (tag 7).
  List
  /// FETCH — retrieve message data (tag 8).
  Fetch
  /// STORE — modify message flags (tag 9).
  Store
  /// SEARCH — search for messages (tag 10).
  Search
  /// COPY — copy messages to another mailbox (tag 11).
  Copy
  /// NOOP — no operation / check for updates (tag 12).
  Noop
  /// CAPABILITY — list server capabilities (tag 13).
  Capability
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    Login -> 0
    CommandLogout -> 1
    Select -> 2
    Examine -> 3
    Create -> 4
    Delete -> 5
    Rename -> 6
    List -> 7
    Fetch -> 8
    Store -> 9
    Search -> 10
    Copy -> 11
    Noop -> 12
    Capability -> 13
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(Login)
    1 -> Ok(CommandLogout)
    2 -> Ok(Select)
    3 -> Ok(Examine)
    4 -> Ok(Create)
    5 -> Ok(Delete)
    6 -> Ok(Rename)
    7 -> Ok(List)
    8 -> Ok(Fetch)
    9 -> Ok(Store)
    10 -> Ok(Search)
    11 -> Ok(Copy)
    12 -> Ok(Noop)
    13 -> Ok(Capability)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// State
// ===========================================================================

/// IMAP session state machine (RFC 3501 Section 3).
/// 
/// Matches `State` in `IMAPABI.Types`.
/// 
/// The valid transitions are formally verified in the Idris2 source
/// via the indexed `ValidStateTransition` type. The Rust equivalent
/// is the [`State::can_transition_to`] validation function.
pub type State {
  /// Not authenticated — awaiting LOGIN or AUTHENTICATE (tag 0).
  NotAuthenticated
  /// Authenticated — can select mailboxes (tag 1).
  Authenticated
  /// Selected — a mailbox is open for message operations (tag 2).
  Selected
  /// Logout — session is ending (tag 3).
  StateLogout
}

/// Convert a `State` to its C-ABI tag value.
pub fn state_to_int(value: State) -> Int {
  case value {
    NotAuthenticated -> 0
    Authenticated -> 1
    Selected -> 2
    StateLogout -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn state_from_int(tag: Int) -> Result(State, Nil) {
  case tag {
    0 -> Ok(NotAuthenticated)
    1 -> Ok(Authenticated)
    2 -> Ok(Selected)
    3 -> Ok(StateLogout)
    _ -> Error(Nil)
  }
}

// state_can_transition_to removed: unproven reimplementation. The verified check
// lives in the Idris2/Zig core; calling it needs @external FFI wiring not yet
// present here.
// Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ===========================================================================
// Flag
// ===========================================================================

/// IMAP message flags (RFC 3501 Section 2.3.2).
/// 
/// Matches `Flag` in `IMAPABI.Types`.
pub type Flag {
  /// \Seen — message has been read (tag 0).
  Seen
  /// \Answered — message has been replied to (tag 1).
  Answered
  /// \Flagged — message is flagged for attention (tag 2).
  Flagged
  /// \Deleted — message is marked for deletion (tag 3).
  Deleted
  /// \Draft — message is a draft (tag 4).
  Draft
  /// \Recent — message recently arrived (server-managed) (tag 5).
  Recent
}

/// Convert a `Flag` to its C-ABI tag value.
pub fn flag_to_int(value: Flag) -> Int {
  case value {
    Seen -> 0
    Answered -> 1
    Flagged -> 2
    Deleted -> 3
    Draft -> 4
    Recent -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn flag_from_int(tag: Int) -> Result(Flag, Nil) {
  case tag {
    0 -> Ok(Seen)
    1 -> Ok(Answered)
    2 -> Ok(Flagged)
    3 -> Ok(Deleted)
    4 -> Ok(Draft)
    5 -> Ok(Recent)
    _ -> Error(Nil)
  }
}

