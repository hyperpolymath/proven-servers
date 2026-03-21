// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// FTP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - FTP.Session         -- session states (RFC 959 Section 4.1)
// - FTP.Command         -- FTP commands
// - FTP.Transfer        -- transfer types and modes
// - FTP.Reply           -- reply categories
// - FTPABI.Layout       -- C-ABI tag values
// - FTPABI.Transitions  -- session state machine with impossibility proofs
//
// All tag values match the Layout encoders in FTPABI.Layout exactly.

// ===========================================================================
// Session State (FTPABI.Layout.SessionState, tags 0-4)
// ===========================================================================

/// FTP session states (RFC 959).
/// Matches SessionState in FTP.Session.
type sessionState =
  | @as(0) Connected
  | @as(1) UserOk
  | @as(2) Authenticated
  | @as(3) Renaming
  | @as(4) FtpQuit

/// Decode from C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Connected)
  | 1 => Some(UserOk)
  | 2 => Some(Authenticated)
  | 3 => Some(Renaming)
  | 4 => Some(FtpQuit)
  | _ => None
  }

/// Encode to C-ABI tag value.
let sessionStateToTag = (s: sessionState): int =>
  switch s {
  | Connected => 0
  | UserOk => 1
  | Authenticated => 2
  | Renaming => 3
  | FtpQuit => 4
  }

/// Whether this is a terminal state (Quit).
let sessionStateIsTerminal = (s: sessionState): bool =>
  switch s {
  | FtpQuit => true
  | _ => false
  }

// ===========================================================================
// Transfer Type (FTPABI.Layout.TransferType, tags 0-1)
// ===========================================================================

/// FTP transfer types (ASCII or Binary).
/// Matches TransferType in FTP.Transfer.
type transferType =
  | @as(0) Ascii
  | @as(1) Binary

/// Decode from C-ABI tag value.
let transferTypeFromTag = (tag: int): option<transferType> =>
  switch tag {
  | 0 => Some(Ascii)
  | 1 => Some(Binary)
  | _ => None
  }

/// Encode to C-ABI tag value.
let transferTypeToTag = (t: transferType): int =>
  switch t {
  | Ascii => 0
  | Binary => 1
  }

// ===========================================================================
// Data Mode (FTPABI.Layout.DataModeTag, tags 0-1)
// ===========================================================================

/// FTP data connection modes (Active or Passive).
/// Matches DataModeTag in FTPABI.Layout.
type dataMode =
  | @as(0) Active
  | @as(1) Passive

/// Decode from C-ABI tag value.
let dataModeFromTag = (tag: int): option<dataMode> =>
  switch tag {
  | 0 => Some(Active)
  | 1 => Some(Passive)
  | _ => None
  }

/// Encode to C-ABI tag value.
let dataModeToTag = (m: dataMode): int =>
  switch m {
  | Active => 0
  | Passive => 1
  }

// ===========================================================================
// Transfer State (FTPABI.Layout.TransferStateTag, tags 0-3)
// ===========================================================================

/// FTP data transfer lifecycle states.
/// Matches TransferStateTag in FTPABI.Layout.
type transferState =
  | @as(0) Idle
  | @as(1) InProgress
  | @as(2) Completed
  | @as(3) Aborted

/// Decode from C-ABI tag value.
let transferStateFromTag = (tag: int): option<transferState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(InProgress)
  | 2 => Some(Completed)
  | 3 => Some(Aborted)
  | _ => None
  }

/// Encode to C-ABI tag value.
let transferStateToTag = (s: transferState): int =>
  switch s {
  | Idle => 0
  | InProgress => 1
  | Completed => 2
  | Aborted => 3
  }

// ===========================================================================
// Reply Category (FTPABI.Layout.ReplyCategory, tags 0-4)
// ===========================================================================

/// FTP reply categories (RFC 959 Section 4.2).
/// Matches ReplyCategory in FTP.Reply.
type replyCategory =
  | @as(0) Preliminary
  | @as(1) Completion
  | @as(2) Intermediate
  | @as(3) TransientNeg
  | @as(4) PermanentNeg

/// Decode from C-ABI tag value.
let replyCategoryFromTag = (tag: int): option<replyCategory> =>
  switch tag {
  | 0 => Some(Preliminary)
  | 1 => Some(Completion)
  | 2 => Some(Intermediate)
  | 3 => Some(TransientNeg)
  | 4 => Some(PermanentNeg)
  | _ => None
  }

/// Encode to C-ABI tag value.
let replyCategoryToTag = (cat: replyCategory): int =>
  switch cat {
  | Preliminary => 0
  | Completion => 1
  | Intermediate => 2
  | TransientNeg => 3
  | PermanentNeg => 4
  }

/// Whether this is a success category.
let replyCategoryIsSuccess = (cat: replyCategory): bool =>
  switch cat {
  | Preliminary | Completion => true
  | Intermediate | TransientNeg | PermanentNeg => false
  }

// ===========================================================================
// Command Tag (FTPABI.Layout.CommandTag, tags 0-22)
// ===========================================================================

/// FTP command verbs as a flat enum for ABI transport.
/// Matches CommandTag in FTPABI.Layout.
type commandTag =
  | @as(0) User
  | @as(1) Pass
  | @as(2) Acct
  | @as(3) Cwd
  | @as(4) Cdup
  | @as(5) CmdQuit
  | @as(6) Pasv
  | @as(7) Port
  | @as(8) Type
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
  | @as(19) CmdNoop
  | @as(20) Rnfr
  | @as(21) Rnto
  | @as(22) Size

/// Decode from C-ABI tag value.
let commandTagFromTag = (tag: int): option<commandTag> =>
  switch tag {
  | 0 => Some(User)
  | 1 => Some(Pass)
  | 2 => Some(Acct)
  | 3 => Some(Cwd)
  | 4 => Some(Cdup)
  | 5 => Some(CmdQuit)
  | 6 => Some(Pasv)
  | 7 => Some(Port)
  | 8 => Some(Type)
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
  | 19 => Some(CmdNoop)
  | 20 => Some(Rnfr)
  | 21 => Some(Rnto)
  | 22 => Some(Size)
  | _ => None
  }

/// Encode to C-ABI tag value.
let commandTagToTag = (cmd: commandTag): int =>
  switch cmd {
  | User => 0
  | Pass => 1
  | Acct => 2
  | Cwd => 3
  | Cdup => 4
  | CmdQuit => 5
  | Pasv => 6
  | Port => 7
  | Type => 8
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
  | CmdNoop => 19
  | Rnfr => 20
  | Rnto => 21
  | Size => 22
  }

/// FTP verb keyword string.
let commandTagVerb = (cmd: commandTag): string =>
  switch cmd {
  | User => "USER"
  | Pass => "PASS"
  | Acct => "ACCT"
  | Cwd => "CWD"
  | Cdup => "CDUP"
  | CmdQuit => "QUIT"
  | Pasv => "PASV"
  | Port => "PORT"
  | Type => "TYPE"
  | Retr => "RETR"
  | Stor => "STOR"
  | Dele => "DELE"
  | Rmd => "RMD"
  | Mkd => "MKD"
  | Pwd => "PWD"
  | List => "LIST"
  | Nlst => "NLST"
  | Syst => "SYST"
  | Stat => "STAT"
  | CmdNoop => "NOOP"
  | Rnfr => "RNFR"
  | Rnto => "RNTO"
  | Size => "SIZE"
  }

// ===========================================================================
// Session Transition (FTPABI.Transitions)
// ===========================================================================

/// Named FTP session lifecycle transitions.
/// Each variant corresponds to a constructor of ValidSessionTransition
/// in FTPABI.Transitions.
type sessionTransition =
  | AcceptUser
  | AcceptPass
  | ReUser
  | FileOp
  | BeginRename
  | CompleteRename
  | RenamingNoop
  | ReLogin
  | QuitConnected
  | QuitUserOk
  | QuitAuth
  | QuitRenaming

/// Validate whether an FTP session state transition is legal.
/// Mirrors validateSessionTransition in FTPABI.Transitions.
let validateSessionTransition = (
  from: sessionState,
  to: sessionState,
): option<sessionTransition> =>
  switch (from, to) {
  | (Connected, UserOk) => Some(AcceptUser)
  | (Connected, FtpQuit) => Some(QuitConnected)
  | (UserOk, Authenticated) => Some(AcceptPass)
  | (UserOk, UserOk) => Some(ReUser)
  | (UserOk, FtpQuit) => Some(QuitUserOk)
  | (Authenticated, Authenticated) => Some(FileOp)
  | (Authenticated, Renaming) => Some(BeginRename)
  | (Authenticated, UserOk) => Some(ReLogin)
  | (Authenticated, FtpQuit) => Some(QuitAuth)
  | (Renaming, Authenticated) => Some(CompleteRename)
  | (Renaming, Renaming) => Some(RenamingNoop)
  | (Renaming, FtpQuit) => Some(QuitRenaming)
  | _ => None
  }

// ===========================================================================
// Constants
// ===========================================================================

/// Standard FTP control port (RFC 959).
let ftpPort = 21

/// Standard FTP data port (RFC 959).
let ftpDataPort = 20

/// FTPS (implicit TLS) port.
let ftpsPort = 990
