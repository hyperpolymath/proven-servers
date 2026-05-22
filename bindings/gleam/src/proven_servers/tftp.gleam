//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// TFTP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `TftpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// TFTP Constants
// ===========================================================================

/// Tftp Port constant.
pub const tftp_port = 69

/// Tftp Block Size constant.
pub const tftp_block_size = 512

// ===========================================================================
// Opcode
// ===========================================================================

/// TFTP opcodes (RFC 1350 Section 5).
/// 
/// Matches `Opcode` in `TFTPABI.Types`.
pub type Opcode {
  /// Read Request (tag 0).
  Rrq
  /// Write Request (tag 1).
  Wrq
  /// Data packet (tag 2).
  Data
  /// Acknowledgement (tag 3).
  Ack
  /// Error packet (tag 4).
  OpcodeError
}

/// Convert a `Opcode` to its C-ABI tag value.
pub fn opcode_to_int(value: Opcode) -> Int {
  case value {
    Rrq -> 0
    Wrq -> 1
    Data -> 2
    Ack -> 3
    OpcodeError -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn opcode_from_int(tag: Int) -> Result(Opcode, Nil) {
  case tag {
    0 -> Ok(Rrq)
    1 -> Ok(Wrq)
    2 -> Ok(Data)
    3 -> Ok(Ack)
    4 -> Ok(OpcodeError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransferMode
// ===========================================================================

/// TFTP transfer modes (RFC 1350 Section 5).
/// 
/// Matches `TransferMode` in `TFTPABI.Types`.
pub type TransferMode {
  /// NetASCII — 7-bit ASCII with CR/LF line endings (tag 0).
  NetAscii
  /// Octet — raw binary transfer (tag 1).
  Octet
  /// Mail — deprecated, sends to a user's mailbox (tag 2).
  Mail
}

/// Convert a `TransferMode` to its C-ABI tag value.
pub fn transfer_mode_to_int(value: TransferMode) -> Int {
  case value {
    NetAscii -> 0
    Octet -> 1
    Mail -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_mode_from_int(tag: Int) -> Result(TransferMode, Nil) {
  case tag {
    0 -> Ok(NetAscii)
    1 -> Ok(Octet)
    2 -> Ok(Mail)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TftpError
// ===========================================================================

/// TFTP error codes (RFC 1350 Section 5).
/// 
/// Matches `TFTPError` in `TFTPABI.Types`.
pub type TftpError {
  /// Not defined — see error message (tag 0).
  NotDefined
  /// File not found (tag 1).
  FileNotFound
  /// Access violation (tag 2).
  AccessViolation
  /// Disk full or allocation exceeded (tag 3).
  DiskFull
  /// Illegal TFTP operation (tag 4).
  IllegalOperation
  /// Unknown transfer ID (tag 5).
  UnknownTid
  /// File already exists (tag 6).
  FileExists
  /// No such user (tag 7).
  NoSuchUser
}

/// Convert a `TftpError` to its C-ABI tag value.
pub fn tftp_error_to_int(value: TftpError) -> Int {
  case value {
    NotDefined -> 0
    FileNotFound -> 1
    AccessViolation -> 2
    DiskFull -> 3
    IllegalOperation -> 4
    UnknownTid -> 5
    FileExists -> 6
    NoSuchUser -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn tftp_error_from_int(tag: Int) -> Result(TftpError, Nil) {
  case tag {
    0 -> Ok(NotDefined)
    1 -> Ok(FileNotFound)
    2 -> Ok(AccessViolation)
    3 -> Ok(DiskFull)
    4 -> Ok(IllegalOperation)
    5 -> Ok(UnknownTid)
    6 -> Ok(FileExists)
    7 -> Ok(NoSuchUser)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransferState
// ===========================================================================

/// TFTP transfer lifecycle states.
/// 
/// Matches `TransferState` in `TFTPABI.Types`.
pub type TransferState {
  /// No transfer in progress (tag 0).
  Idle
  /// Reading from server (RRQ in progress) (tag 1).
  Reading
  /// Writing to server (WRQ in progress) (tag 2).
  Writing
  /// Transfer encountered an error (tag 3).
  InError
  /// Transfer completed successfully (tag 4).
  Complete
}

/// Convert a `TransferState` to its C-ABI tag value.
pub fn transfer_state_to_int(value: TransferState) -> Int {
  case value {
    Idle -> 0
    Reading -> 1
    Writing -> 2
    InError -> 3
    Complete -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_state_from_int(tag: Int) -> Result(TransferState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Reading)
    2 -> Ok(Writing)
    3 -> Ok(InError)
    4 -> Ok(Complete)
    _ -> Error(Nil)
  }
}

