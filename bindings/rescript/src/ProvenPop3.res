// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module POP3ABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard POP3 port (RFC 1939).
let pop3Port = 110

/// Standard POP3S (POP3 over TLS) port.
let pop3sPort = 995

// ===========================================================================
// Command (tags 0-10)
// ===========================================================================

/// Standard POP3 port (RFC 1939).
type command =
  | @as(0) User
  | @as(1) Pass
  | @as(2) Stat
  | @as(3) List
  | @as(4) Retr
  | @as(5) Dele
  | @as(6) Noop
  | @as(7) Rset
  | @as(8) Quit
  | @as(9) Top
  | @as(10) Uidl

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(User)
  | 1 => Some(Pass)
  | 2 => Some(Stat)
  | 3 => Some(List)
  | 4 => Some(Retr)
  | 5 => Some(Dele)
  | 6 => Some(Noop)
  | 7 => Some(Rset)
  | 8 => Some(Quit)
  | 9 => Some(Top)
  | 10 => Some(Uidl)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | User => 0
  | Pass => 1
  | Stat => 2
  | List => 3
  | Retr => 4
  | Dele => 5
  | Noop => 6
  | Rset => 7
  | Quit => 8
  | Top => 9
  | Uidl => 10
  }

/// Whether this command modifies mailbox state.
let commandIsWrite = (v: command): bool =>
  switch v {
  | Dele | Rset => true
  | _ => false
  }

// ===========================================================================
// State (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type state =
  | @as(0) Authorization
  | @as(1) Transaction
  | @as(2) Update

/// Decode from the C-ABI tag value.
let stateFromTag = (tag: int): option<state> =>
  switch tag {
  | 0 => Some(Authorization)
  | 1 => Some(Transaction)
  | 2 => Some(Update)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let stateToTag = (v: state): int =>
  switch v {
  | Authorization => 0
  | Transaction => 1
  | Update => 2
  }

/// Validate whether a state transition is allowed.
let stateCanTransitionTo = (from: state, to: state): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// Response (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type response =
  | @as(0) Ok
  | @as(1) Err

/// Decode from the C-ABI tag value.
let responseFromTag = (tag: int): option<response> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(Err)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responseToTag = (v: response): int =>
  switch v {
  | Ok => 0
  | Err => 1
  }

/// Whether this response indicates success.
let responseIsSuccess = (v: response): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

// ===========================================================================
// Pop3Error (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type pop3Error =
  | @as(0) Ok
  | @as(1) InvalidSlot
  | @as(2) NotActive
  | @as(3) InvalidTransition
  | @as(4) InvalidCommand
  | @as(5) AuthFailed

/// Decode from the C-ABI tag value.
let pop3ErrorFromTag = (tag: int): option<pop3Error> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(InvalidSlot)
  | 2 => Some(NotActive)
  | 3 => Some(InvalidTransition)
  | 4 => Some(InvalidCommand)
  | 5 => Some(AuthFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let pop3ErrorToTag = (v: pop3Error): int =>
  switch v {
  | Ok => 0
  | InvalidSlot => 1
  | NotActive => 2
  | InvalidTransition => 3
  | InvalidCommand => 4
  | AuthFailed => 5
  }

/// Whether this error code indicates success.
let pop3ErrorIsSuccess = (v: pop3Error): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

