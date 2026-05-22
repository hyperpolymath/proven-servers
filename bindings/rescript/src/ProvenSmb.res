// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMB (Server Message Block) protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module SMBABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SMB port (TCP).
let smbPort = 445

/// Legacy NetBIOS over TCP port (used by older SMB implementations).
let smbNetbiosPort = 139

// ===========================================================================
// Command (tags 0-15)
// ===========================================================================

/// Standard SMB port (TCP).
type command =
  | @as(0) Negotiate
  | @as(1) SessionSetup
  | @as(2) Logoff
  | @as(3) TreeConnect
  | @as(4) TreeDisconnect
  | @as(5) Create
  | @as(6) Close
  | @as(7) Read
  | @as(8) Write
  | @as(9) Lock
  | @as(10) Ioctl
  | @as(11) Cancel
  | @as(12) QueryDirectory
  | @as(13) ChangeNotify
  | @as(14) QueryInfo
  | @as(15) SetInfo

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(Negotiate)
  | 1 => Some(SessionSetup)
  | 2 => Some(Logoff)
  | 3 => Some(TreeConnect)
  | 4 => Some(TreeDisconnect)
  | 5 => Some(Create)
  | 6 => Some(Close)
  | 7 => Some(Read)
  | 8 => Some(Write)
  | 9 => Some(Lock)
  | 10 => Some(Ioctl)
  | 11 => Some(Cancel)
  | 12 => Some(QueryDirectory)
  | 13 => Some(ChangeNotify)
  | 14 => Some(QueryInfo)
  | 15 => Some(SetInfo)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | Negotiate => 0
  | SessionSetup => 1
  | Logoff => 2
  | TreeConnect => 3
  | TreeDisconnect => 4
  | Create => 5
  | Close => 6
  | Read => 7
  | Write => 8
  | Lock => 9
  | Ioctl => 10
  | Cancel => 11
  | QueryDirectory => 12
  | ChangeNotify => 13
  | QueryInfo => 14
  | SetInfo => 15
  }

/// Whether this command is a session/connection management operation.
let commandIsSessionManagement = (v: command): bool =>
  switch v {
  | Negotiate | SessionSetup | Logoff | TreeConnect | TreeDisconnect => true
  | _ => false
  }

/// Whether this command operates on file data.
let commandIsFileIo = (v: command): bool =>
  switch v {
  | Read | Write | Lock | Ioctl => true
  | _ => false
  }

/// Whether this command modifies server state.
let commandIsWrite = (v: command): bool =>
  switch v {
  | Create | Write | SetInfo | Lock => true
  | _ => false
  }

// ===========================================================================
// Dialect (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type dialect =
  | @as(0) Smb2_0_2
  | @as(1) Smb2_1
  | @as(2) Smb3_0
  | @as(3) Smb3_0_2
  | @as(4) Smb3_1_1

/// Decode from the C-ABI tag value.
let dialectFromTag = (tag: int): option<dialect> =>
  switch tag {
  | 0 => Some(Smb2_0_2)
  | 1 => Some(Smb2_1)
  | 2 => Some(Smb3_0)
  | 3 => Some(Smb3_0_2)
  | 4 => Some(Smb3_1_1)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dialectToTag = (v: dialect): int =>
  switch v {
  | Smb2_0_2 => 0
  | Smb2_1 => 1
  | Smb3_0 => 2
  | Smb3_0_2 => 3
  | Smb3_1_1 => 4
  }

/// Whether this dialect supports encryption.
let dialectSupportsEncryption = (v: dialect): bool =>
  switch v {
  | Smb3_0 | Smb3_0_2 | Smb3_1_1 => true
  | _ => false
  }

/// Whether this is an SMB3 dialect.
let dialectIsSmb3 = (v: dialect): bool =>
  switch v {
  | Smb3_0 | Smb3_0_2 | Smb3_1_1 => true
  | _ => false
  }

// ===========================================================================
// ShareType (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type shareType =
  | @as(0) Disk
  | @as(1) Pipe
  | @as(2) Print

/// Decode from the C-ABI tag value.
let shareTypeFromTag = (tag: int): option<shareType> =>
  switch tag {
  | 0 => Some(Disk)
  | 1 => Some(Pipe)
  | 2 => Some(Print)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let shareTypeToTag = (v: shareType): int =>
  switch v {
  | Disk => 0
  | Pipe => 1
  | Print => 2
  }

/// Whether this share provides file system access.
let shareTypeIsFilesystem = (v: shareType): bool =>
  switch v {
  | Disk => true
  | _ => false
  }

// ===========================================================================
// SessionState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Negotiated
  | @as(2) Authenticated
  | @as(3) TreeConnected
  | @as(4) FileOpen
  | @as(5) Disconnecting

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Negotiated)
  | 2 => Some(Authenticated)
  | 3 => Some(TreeConnected)
  | 4 => Some(FileOpen)
  | 5 => Some(Disconnecting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Negotiated => 1
  | Authenticated => 2
  | TreeConnected => 3
  | FileOpen => 4
  | Disconnecting => 5
  }

/// Whether the session is authenticated (can perform operations).
let sessionStateIsAuthenticated = (v: sessionState): bool =>
  switch v {
  | Authenticated | TreeConnected | FileOpen => true
  | _ => false
  }

/// Whether file operations are possible.
let sessionStateCanDoFileIo = (v: sessionState): bool =>
  switch v {
  | FileOpen => true
  | _ => false
  }

