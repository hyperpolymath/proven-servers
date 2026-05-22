// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP (Trivial File Transfer Protocol) types for the proven-servers ABI.
//
// Mirrors the Idris2 module TFTPABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard TFTP port (RFC 1350).
let tftpPort = 69

/// TFTP data block size (RFC 1350).
let tftpBlockSize = 512

// ===========================================================================
// Opcode (tags 0-4)
// ===========================================================================

/// Standard TFTP port (RFC 1350).
type opcode =
  | @as(0) Rrq
  | @as(1) Wrq
  | @as(2) Data
  | @as(3) Ack
  | @as(4) Error

/// Decode from the C-ABI tag value.
let opcodeFromTag = (tag: int): option<opcode> =>
  switch tag {
  | 0 => Some(Rrq)
  | 1 => Some(Wrq)
  | 2 => Some(Data)
  | 3 => Some(Ack)
  | 4 => Some(Error)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let opcodeToTag = (v: opcode): int =>
  switch v {
  | Rrq => 0
  | Wrq => 1
  | Data => 2
  | Ack => 3
  | Error => 4
  }

/// Whether this opcode initiates a transfer.
let opcodeIsRequest = (v: opcode): bool =>
  switch v {
  | Rrq | Wrq => true
  | _ => false
  }

/// Whether this opcode carries payload data.
let opcodeIsData = (v: opcode): bool =>
  switch v {
  | Data => true
  | _ => false
  }

// ===========================================================================
// TransferMode (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type transferMode =
  | @as(0) NetAscii
  | @as(1) Octet
  | @as(2) Mail

/// Decode from the C-ABI tag value.
let transferModeFromTag = (tag: int): option<transferMode> =>
  switch tag {
  | 0 => Some(NetAscii)
  | 1 => Some(Octet)
  | 2 => Some(Mail)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferModeToTag = (v: transferMode): int =>
  switch v {
  | NetAscii => 0
  | Octet => 1
  | Mail => 2
  }

/// Whether this mode performs character set conversion.
let transferModeIsTextMode = (v: transferMode): bool =>
  switch v {
  | NetAscii => true
  | _ => false
  }

/// Whether this transfer mode is deprecated.
let transferModeIsDeprecated = (v: transferMode): bool =>
  switch v {
  | Mail => true
  | _ => false
  }

// ===========================================================================
// TftpError (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type tftpError =
  | @as(0) NotDefined
  | @as(1) FileNotFound
  | @as(2) AccessViolation
  | @as(3) DiskFull
  | @as(4) IllegalOperation
  | @as(5) UnknownTid
  | @as(6) FileExists
  | @as(7) NoSuchUser

/// Decode from the C-ABI tag value.
let tftpErrorFromTag = (tag: int): option<tftpError> =>
  switch tag {
  | 0 => Some(NotDefined)
  | 1 => Some(FileNotFound)
  | 2 => Some(AccessViolation)
  | 3 => Some(DiskFull)
  | 4 => Some(IllegalOperation)
  | 5 => Some(UnknownTid)
  | 6 => Some(FileExists)
  | 7 => Some(NoSuchUser)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let tftpErrorToTag = (v: tftpError): int =>
  switch v {
  | NotDefined => 0
  | FileNotFound => 1
  | AccessViolation => 2
  | DiskFull => 3
  | IllegalOperation => 4
  | UnknownTid => 5
  | FileExists => 6
  | NoSuchUser => 7
  }

/// Whether this error relates to access control.
let tftpErrorIsAccessError = (v: tftpError): bool =>
  switch v {
  | AccessViolation | NoSuchUser => true
  | _ => false
  }

/// Whether this error relates to storage capacity.
let tftpErrorIsStorageError = (v: tftpError): bool =>
  switch v {
  | DiskFull | FileExists => true
  | _ => false
  }

// ===========================================================================
// TransferState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type transferState =
  | @as(0) Idle
  | @as(1) Reading
  | @as(2) Writing
  | @as(3) InError
  | @as(4) Complete

/// Decode from the C-ABI tag value.
let transferStateFromTag = (tag: int): option<transferState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Reading)
  | 2 => Some(Writing)
  | 3 => Some(InError)
  | 4 => Some(Complete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferStateToTag = (v: transferState): int =>
  switch v {
  | Idle => 0
  | Reading => 1
  | Writing => 2
  | InError => 3
  | Complete => 4
  }

/// Whether a transfer is actively in progress.
let transferStateIsActive = (v: transferState): bool =>
  switch v {
  | Reading | Writing => true
  | _ => false
  }

/// Whether the transfer has reached a terminal state.
let transferStateIsTerminal = (v: transferState): bool =>
  switch v {
  | InError | Complete => true
  | _ => false
  }

