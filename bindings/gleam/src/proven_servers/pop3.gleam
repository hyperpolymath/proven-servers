//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// POP3 protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `POP3ABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// POP3 Constants
// ===========================================================================

/// Pop3 Port constant.
pub const pop3_port = 110

/// Pop3S Port constant.
pub const pop3s_port = 995

// ===========================================================================
// Command
// ===========================================================================

/// POP3 protocol commands (RFC 1939).
/// 
/// Matches `Command` in `POP3ABI.Types`.
pub type Command {
  /// USER — identify user for authentication (tag 0).
  User
  /// PASS — supply password for authentication (tag 1).
  Pass
  /// STAT — request mailbox status (tag 2).
  Stat
  /// LIST — list message sizes (tag 3).
  List
  /// RETR — retrieve a message (tag 4).
  Retr
  /// DELE — mark a message for deletion (tag 5).
  Dele
  /// NOOP — no operation (tag 6).
  Noop
  /// RSET — reset deletion marks (tag 7).
  Rset
  /// QUIT — end session (tag 8).
  Quit
  /// TOP — retrieve message headers plus N lines (tag 9).
  Top
  /// UIDL — unique ID listing (tag 10).
  Uidl
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    User -> 0
    Pass -> 1
    Stat -> 2
    List -> 3
    Retr -> 4
    Dele -> 5
    Noop -> 6
    Rset -> 7
    Quit -> 8
    Top -> 9
    Uidl -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(User)
    1 -> Ok(Pass)
    2 -> Ok(Stat)
    3 -> Ok(List)
    4 -> Ok(Retr)
    5 -> Ok(Dele)
    6 -> Ok(Noop)
    7 -> Ok(Rset)
    8 -> Ok(Quit)
    9 -> Ok(Top)
    10 -> Ok(Uidl)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// State
// ===========================================================================

/// POP3 session state machine (RFC 1939 Section 5).
/// 
/// Matches `State` in `POP3ABI.Types`.
/// 
/// Valid transitions (formally verified in Idris2):
/// - Authorization -> Transaction (successful authentication)
/// - Transaction -> Update (QUIT command)
pub type State {
  /// Authorization — awaiting USER/PASS (tag 0).
  Authorization
  /// Transaction — mailbox open for commands (tag 1).
  Transaction
  /// Update — QUIT received, deletions being committed (tag 2).
  Update
}

/// Convert a `State` to its C-ABI tag value.
pub fn state_to_int(value: State) -> Int {
  case value {
    Authorization -> 0
    Transaction -> 1
    Update -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn state_from_int(tag: Int) -> Result(State, Nil) {
  case tag {
    0 -> Ok(Authorization)
    1 -> Ok(Transaction)
    2 -> Ok(Update)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn state_can_transition_to(from: State, to: State) -> Bool {
  case from, to {
    Authorization, Transaction -> True
    Transaction, Update -> True
    _, _ -> False
  }
}

// ===========================================================================
// Response
// ===========================================================================

/// POP3 response indicators (RFC 1939).
/// 
/// Matches `Response` in `POP3ABI.Types`.
pub type Response {
  /// +OK — command succeeded (tag 0).
  ResponseOk
  /// -ERR — command failed (tag 1).
  Err
}

/// Convert a `Response` to its C-ABI tag value.
pub fn response_to_int(value: Response) -> Int {
  case value {
    ResponseOk -> 0
    Err -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn response_from_int(tag: Int) -> Result(Response, Nil) {
  case tag {
    0 -> Ok(ResponseOk)
    1 -> Ok(Err)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Pop3Error
// ===========================================================================

/// POP3 FFI error codes.
/// 
/// Matches `POP3Error` in `POP3ABI.Types`.
pub type Pop3Error {
  /// No error (tag 0).
  Pop3ErrorOk
  /// Invalid slot index (tag 1).
  InvalidSlot
  /// Session not active (tag 2).
  NotActive
  /// Invalid state transition (tag 3).
  InvalidTransition
  /// Command not allowed in current state (tag 4).
  InvalidCommand
  /// Authentication failed (tag 5).
  AuthFailed
}

/// Convert a `Pop3Error` to its C-ABI tag value.
pub fn pop3_error_to_int(value: Pop3Error) -> Int {
  case value {
    Pop3ErrorOk -> 0
    InvalidSlot -> 1
    NotActive -> 2
    InvalidTransition -> 3
    InvalidCommand -> 4
    AuthFailed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn pop3_error_from_int(tag: Int) -> Result(Pop3Error, Nil) {
  case tag {
    0 -> Ok(Pop3ErrorOk)
    1 -> Ok(InvalidSlot)
    2 -> Ok(NotActive)
    3 -> Ok(InvalidTransition)
    4 -> Ok(InvalidCommand)
    5 -> Ok(AuthFailed)
    _ -> Error(Nil)
  }
}

