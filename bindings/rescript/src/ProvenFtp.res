// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// FTP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module FtpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard FTP control port (RFC 959).
let ftpControlPort = 21

/// Standard FTP data port (RFC 959).
let ftpDataPort = 20

/// FTPS (implicit TLS) control port.
let ftpsPort = 990

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Standard FTP control port (RFC 959).
type sessionState =
  | @as(0) Connected
  | @as(1) UserOk
  | @as(2) Authenticated
  | @as(3) Renaming
  | @as(4) Quit

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Connected)
  | 1 => Some(UserOk)
  | 2 => Some(Authenticated)
  | 3 => Some(Renaming)
  | 4 => Some(Quit)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Connected => 0
  | UserOk => 1
  | Authenticated => 2
  | Renaming => 3
  | Quit => 4
  }

// sessionStateCanTransitionTo removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ===========================================================================
// TransferType (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type transferType =
  | @as(0) Ascii
  | @as(1) Binary

/// Decode from the C-ABI tag value.
let transferTypeFromTag = (tag: int): option<transferType> =>
  switch tag {
  | 0 => Some(Ascii)
  | 1 => Some(Binary)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferTypeToTag = (v: transferType): int =>
  switch v {
  | Ascii => 0
  | Binary => 1
  }

// ===========================================================================
// DataMode (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type dataMode =
  | @as(0) Active
  | @as(1) Passive

/// Decode from the C-ABI tag value.
let dataModeFromTag = (tag: int): option<dataMode> =>
  switch tag {
  | 0 => Some(Active)
  | 1 => Some(Passive)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dataModeToTag = (v: dataMode): int =>
  switch v {
  | Active => 0
  | Passive => 1
  }

/// Whether this mode is firewall-friendly (passive allows NAT traversal).
let dataModeIsFirewallFriendly = (v: dataMode): bool =>
  switch v {
  | Passive => true
  | _ => false
  }

// ===========================================================================
// TransferState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type transferState =
  | @as(0) Idle
  | @as(1) InProgress
  | @as(2) Completed
  | @as(3) Aborted

/// Decode from the C-ABI tag value.
let transferStateFromTag = (tag: int): option<transferState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(InProgress)
  | 2 => Some(Completed)
  | 3 => Some(Aborted)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferStateToTag = (v: transferState): int =>
  switch v {
  | Idle => 0
  | InProgress => 1
  | Completed => 2
  | Aborted => 3
  }

// transferStateCanTransitionTo removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

/// Whether the transfer has finished (completed or aborted).
let transferStateIsTerminal = (v: transferState): bool =>
  switch v {
  | Completed | Aborted => true
  | _ => false
  }

// ===========================================================================
// ReplyCategory (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type replyCategory =
  | @as(0) Preliminary
  | @as(1) Completion
  | @as(2) Intermediate
  | @as(3) TransientNeg
  | @as(4) PermanentNeg

/// Decode from the C-ABI tag value.
let replyCategoryFromTag = (tag: int): option<replyCategory> =>
  switch tag {
  | 0 => Some(Preliminary)
  | 1 => Some(Completion)
  | 2 => Some(Intermediate)
  | 3 => Some(TransientNeg)
  | 4 => Some(PermanentNeg)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let replyCategoryToTag = (v: replyCategory): int =>
  switch v {
  | Preliminary => 0
  | Completion => 1
  | Intermediate => 2
  | TransientNeg => 3
  | PermanentNeg => 4
  }

/// Whether this category indicates a positive outcome.
let replyCategoryIsPositive = (v: replyCategory): bool =>
  switch v {
  | Preliminary | Completion | Intermediate => true
  | _ => false
  }

/// Whether this category indicates an error.
let replyCategoryIsError = (v: replyCategory): bool =>
  switch v {
  | TransientNeg | PermanentNeg => true
  | _ => false
  }

// ===========================================================================
// Command (tags 0-22)
// ===========================================================================

/// Decode from an ABI tag value.
type command =
  | @as(0) User
  | @as(1) Pass
  | @as(2) Acct
  | @as(3) Cwd
  | @as(4) Cdup
  | @as(5) Quit
  | @as(6) Pasv
  | @as(7) Port
  | @as(8) TypeCmd
  | @as(9) Retr
  | @as(10) Stor
  | @as(11) Dele
  | @as(12) Rmd
  | @as(13) Mkd
  | @as(14) Pwd
  | @as(15) List
  | @as(16) Nlst
  | @as(17) Syst
  | @as(18) Stat
  | @as(19) Noop
  | @as(20) Rnfr
  | @as(21) Rnto
  | @as(22) Size

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(User)
  | 1 => Some(Pass)
  | 2 => Some(Acct)
  | 3 => Some(Cwd)
  | 4 => Some(Cdup)
  | 5 => Some(Quit)
  | 6 => Some(Pasv)
  | 7 => Some(Port)
  | 8 => Some(TypeCmd)
  | 9 => Some(Retr)
  | 10 => Some(Stor)
  | 11 => Some(Dele)
  | 12 => Some(Rmd)
  | 13 => Some(Mkd)
  | 14 => Some(Pwd)
  | 15 => Some(List)
  | 16 => Some(Nlst)
  | 17 => Some(Syst)
  | 18 => Some(Stat)
  | 19 => Some(Noop)
  | 20 => Some(Rnfr)
  | 21 => Some(Rnto)
  | 22 => Some(Size)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | User => 0
  | Pass => 1
  | Acct => 2
  | Cwd => 3
  | Cdup => 4
  | Quit => 5
  | Pasv => 6
  | Port => 7
  | TypeCmd => 8
  | Retr => 9
  | Stor => 10
  | Dele => 11
  | Rmd => 12
  | Mkd => 13
  | Pwd => 14
  | List => 15
  | Nlst => 16
  | Syst => 17
  | Stat => 18
  | Noop => 19
  | Rnfr => 20
  | Rnto => 21
  | Size => 22
  }

/// Whether this command initiates a data transfer.
let commandRequiresDataConnection = (v: command): bool =>
  switch v {
  | Retr | Stor | List | Nlst => true
  | _ => false
  }

/// Whether this command requires authentication.
let commandRequiresAuth = (v: command): bool =>
  switch v {
  | User | Pass | Acct | Quit => false
  | _ => true
  }

