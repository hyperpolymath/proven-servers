//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// FTP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `FTP.Session`          -- session states (RFC 959 Section 4.1)
//// - `FTP.Command`          -- FTP commands
//// - `FTP.Transfer`         -- transfer types and modes
//// - `FTP.Reply`            -- reply categories
//// - `FTPABI.Layout`        -- C-ABI tag values
//// - `FTPABI.Transitions`   -- session state machine

// ===========================================================================
// FTP Constants
// ===========================================================================

/// Standard FTP control port (RFC 959).
pub const ftp_control_port = 21

/// Standard FTP data port (RFC 959).
pub const ftp_data_port = 20

/// FTPS (implicit TLS) control port.
pub const ftps_port = 990

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// FTP session state machine.
///
/// Matches `SessionState` in `FtpABI.Types`.
pub type SessionState {
  /// TCP connection established, awaiting USER.
  FtpConnected
  /// USER accepted, awaiting PASS.
  UserOk
  /// Fully authenticated and ready.
  FtpAuthenticated
  /// RNFR sent, awaiting RNTO.
  Renaming
  /// QUIT sent, session ending.
  FtpQuit
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(state: SessionState) -> Int {
  case state {
    FtpConnected -> 0
    UserOk -> 1
    FtpAuthenticated -> 2
    Renaming -> 3
    FtpQuit -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(FtpConnected)
    1 -> Ok(UserOk)
    2 -> Ok(FtpAuthenticated)
    3 -> Ok(Renaming)
    4 -> Ok(FtpQuit)
    _ -> Error(Nil)
  }
}

/// Validate whether an FTP session state transition is allowed.
pub fn session_can_transition(
  from: SessionState,
  to: SessionState,
) -> Bool {
  case from, to {
    FtpConnected, UserOk -> True
    UserOk, FtpAuthenticated -> True
    UserOk, FtpConnected -> True
    FtpAuthenticated, Renaming -> True
    Renaming, FtpAuthenticated -> True
    _, FtpQuit -> True
    _, _ -> False
  }
}

// ===========================================================================
// TransferType (tags 0-1)
// ===========================================================================

/// FTP data transfer type (RFC 959 Section 3.1.1).
pub type TransferType {
  /// ASCII mode -- text with CRLF line endings.
  Ascii
  /// Binary (Image) mode -- raw byte transfer.
  FtpBinary
}

/// Convert a `TransferType` to its C-ABI tag value.
pub fn transfer_type_to_int(tt: TransferType) -> Int {
  case tt {
    Ascii -> 0
    FtpBinary -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_type_from_int(tag: Int) -> Result(TransferType, Nil) {
  case tag {
    0 -> Ok(Ascii)
    1 -> Ok(FtpBinary)
    _ -> Error(Nil)
  }
}

/// The FTP TYPE parameter character.
pub fn transfer_type_char(tt: TransferType) -> String {
  case tt {
    Ascii -> "A"
    FtpBinary -> "I"
  }
}

// ===========================================================================
// DataMode (tags 0-1)
// ===========================================================================

/// FTP data connection mode (RFC 959).
pub type DataMode {
  /// Active mode -- server connects to client.
  Active
  /// Passive mode -- client connects to server.
  Passive
}

/// Convert a `DataMode` to its C-ABI tag value.
pub fn data_mode_to_int(mode: DataMode) -> Int {
  case mode {
    Active -> 0
    Passive -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn data_mode_from_int(tag: Int) -> Result(DataMode, Nil) {
  case tag {
    0 -> Ok(Active)
    1 -> Ok(Passive)
    _ -> Error(Nil)
  }
}

/// Whether this mode is firewall-friendly (passive allows NAT traversal).
pub fn data_mode_is_firewall_friendly(mode: DataMode) -> Bool {
  mode == Passive
}

// ===========================================================================
// TransferState (tags 0-3)
// ===========================================================================

/// FTP file transfer state machine.
pub type TransferState {
  /// No transfer in progress.
  TransferIdle
  /// Transfer is actively in progress.
  InProgress
  /// Transfer completed successfully.
  TransferCompleted
  /// Transfer was aborted.
  TransferAborted
}

/// Convert a `TransferState` to its C-ABI tag value.
pub fn transfer_state_to_int(state: TransferState) -> Int {
  case state {
    TransferIdle -> 0
    InProgress -> 1
    TransferCompleted -> 2
    TransferAborted -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_state_from_int(tag: Int) -> Result(TransferState, Nil) {
  case tag {
    0 -> Ok(TransferIdle)
    1 -> Ok(InProgress)
    2 -> Ok(TransferCompleted)
    3 -> Ok(TransferAborted)
    _ -> Error(Nil)
  }
}

/// Whether the transfer has finished (completed or aborted).
pub fn transfer_state_is_terminal(state: TransferState) -> Bool {
  case state {
    TransferCompleted | TransferAborted -> True
    _ -> False
  }
}

// ===========================================================================
// ReplyCategory (tags 0-4)
// ===========================================================================

/// FTP reply categories (RFC 959 Section 4.2).
pub type FtpReplyCategory {
  /// 1xx -- Preliminary positive reply.
  Preliminary
  /// 2xx -- Completion positive reply.
  Completion
  /// 3xx -- Intermediate positive reply.
  FtpIntermediate
  /// 4xx -- Transient negative reply.
  TransientNeg
  /// 5xx -- Permanent negative reply.
  PermanentNeg
}

/// Convert a `FtpReplyCategory` to its C-ABI tag value.
pub fn ftp_reply_category_to_int(cat: FtpReplyCategory) -> Int {
  case cat {
    Preliminary -> 0
    Completion -> 1
    FtpIntermediate -> 2
    TransientNeg -> 3
    PermanentNeg -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn ftp_reply_category_from_int(tag: Int) -> Result(FtpReplyCategory, Nil) {
  case tag {
    0 -> Ok(Preliminary)
    1 -> Ok(Completion)
    2 -> Ok(FtpIntermediate)
    3 -> Ok(TransientNeg)
    4 -> Ok(PermanentNeg)
    _ -> Error(Nil)
  }
}

/// Whether this category indicates a positive outcome.
pub fn ftp_reply_category_is_positive(cat: FtpReplyCategory) -> Bool {
  case cat {
    Preliminary | Completion | FtpIntermediate -> True
    _ -> False
  }
}

/// Whether this category indicates an error.
pub fn ftp_reply_category_is_error(cat: FtpReplyCategory) -> Bool {
  case cat {
    TransientNeg | PermanentNeg -> True
    _ -> False
  }
}
