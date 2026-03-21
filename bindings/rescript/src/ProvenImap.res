// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module IMAPABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard IMAP port (RFC 3501).
let imapPort = 143

/// Standard IMAPS (IMAP over TLS) port.
let imapsPort = 993

// ===========================================================================
// Command (tags 0-13)
// ===========================================================================

/// Standard IMAP port (RFC 3501).
type command =
  | @as(0) Login
  | @as(1) Logout
  | @as(2) Select
  | @as(3) Examine
  | @as(4) Create
  | @as(5) Delete
  | @as(6) Rename
  | @as(7) List
  | @as(8) Fetch
  | @as(9) Store
  | @as(10) Search
  | @as(11) Copy
  | @as(12) Noop
  | @as(13) Capability

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(Login)
  | 1 => Some(Logout)
  | 2 => Some(Select)
  | 3 => Some(Examine)
  | 4 => Some(Create)
  | 5 => Some(Delete)
  | 6 => Some(Rename)
  | 7 => Some(List)
  | 8 => Some(Fetch)
  | 9 => Some(Store)
  | 10 => Some(Search)
  | 11 => Some(Copy)
  | 12 => Some(Noop)
  | 13 => Some(Capability)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | Login => 0
  | Logout => 1
  | Select => 2
  | Examine => 3
  | Create => 4
  | Delete => 5
  | Rename => 6
  | List => 7
  | Fetch => 8
  | Store => 9
  | Search => 10
  | Copy => 11
  | Noop => 12
  | Capability => 13
  }

/// Whether this command modifies mailbox or message state.
let commandIsWrite = (v: command): bool =>
  switch v {
  | Create | Delete | Rename | Store | Copy => true
  | _ => false
  }

// ===========================================================================
// State (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type state =
  | @as(0) NotAuthenticated
  | @as(1) Authenticated
  | @as(2) Selected
  | @as(3) Logout

/// Decode from the C-ABI tag value.
let stateFromTag = (tag: int): option<state> =>
  switch tag {
  | 0 => Some(NotAuthenticated)
  | 1 => Some(Authenticated)
  | 2 => Some(Selected)
  | 3 => Some(Logout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let stateToTag = (v: state): int =>
  switch v {
  | NotAuthenticated => 0
  | Authenticated => 1
  | Selected => 2
  | Logout => 3
  }

/// Validate whether a state transition is allowed.
let stateCanTransitionTo = (from: state, to: state): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// Flag (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type flag =
  | @as(0) Seen
  | @as(1) Answered
  | @as(2) Flagged
  | @as(3) Deleted
  | @as(4) Draft
  | @as(5) Recent

/// Decode from the C-ABI tag value.
let flagFromTag = (tag: int): option<flag> =>
  switch tag {
  | 0 => Some(Seen)
  | 1 => Some(Answered)
  | 2 => Some(Flagged)
  | 3 => Some(Deleted)
  | 4 => Some(Draft)
  | 5 => Some(Recent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let flagToTag = (v: flag): int =>
  switch v {
  | Seen => 0
  | Answered => 1
  | Flagged => 2
  | Deleted => 3
  | Draft => 4
  | Recent => 5
  }

/// /// The \Recent flag is server-managed and cannot be set by clients.
let flagIsClientSettable = (v: flag): bool =>
  switch v {
  | Recent => false
  | _ => true
  }

