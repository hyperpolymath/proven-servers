//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SMB2/3 protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SmbABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// SMB2/3 Constants
// ===========================================================================

/// Smb Port constant.
pub const smb_port = 445

/// Smb Netbios Port constant.
pub const smb_netbios_port = 139

// ===========================================================================
// Command
// ===========================================================================

/// SMB2/3 command codes (MS-SMB2 Section 2.2).
/// 
/// Matches `Command` in `SMBABI.Types`.
pub type Command {
  /// Negotiate protocol dialect (tag 0).
  Negotiate
  /// Set up an authenticated session (tag 1).
  SessionSetup
  /// Log off a session (tag 2).
  Logoff
  /// Connect to a share (tag 3).
  TreeConnect
  /// Disconnect from a share (tag 4).
  TreeDisconnect
  /// Create or open a file/directory (tag 5).
  Create
  /// Close a file handle (tag 6).
  Close
  /// Read from a file (tag 7).
  Read
  /// Write to a file (tag 8).
  Write
  /// Lock a byte range (tag 9).
  Lock
  /// Send an I/O control code (tag 10).
  Ioctl
  /// Cancel a pending request (tag 11).
  Cancel
  /// List directory contents (tag 12).
  QueryDirectory
  /// Register for change notifications (tag 13).
  ChangeNotify
  /// Query file or filesystem information (tag 14).
  QueryInfo
  /// Set file or filesystem information (tag 15).
  SetInfo
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    Negotiate -> 0
    SessionSetup -> 1
    Logoff -> 2
    TreeConnect -> 3
    TreeDisconnect -> 4
    Create -> 5
    Close -> 6
    Read -> 7
    Write -> 8
    Lock -> 9
    Ioctl -> 10
    Cancel -> 11
    QueryDirectory -> 12
    ChangeNotify -> 13
    QueryInfo -> 14
    SetInfo -> 15
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(Negotiate)
    1 -> Ok(SessionSetup)
    2 -> Ok(Logoff)
    3 -> Ok(TreeConnect)
    4 -> Ok(TreeDisconnect)
    5 -> Ok(Create)
    6 -> Ok(Close)
    7 -> Ok(Read)
    8 -> Ok(Write)
    9 -> Ok(Lock)
    10 -> Ok(Ioctl)
    11 -> Ok(Cancel)
    12 -> Ok(QueryDirectory)
    13 -> Ok(ChangeNotify)
    14 -> Ok(QueryInfo)
    15 -> Ok(SetInfo)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Dialect
// ===========================================================================

/// SMB protocol dialect versions (MS-SMB2 Section 3.3.5.4).
/// 
/// Matches `Dialect` in `SMBABI.Types`.
pub type Dialect {
  /// SMB 2.0.2 (tag 0).
  Smb202
  /// SMB 2.1 (tag 1).
  Smb21
  /// SMB 3.0 (tag 2).
  Smb30
  /// SMB 3.0.2 (tag 3).
  Smb302
  /// SMB 3.1.1 (tag 4).
  Smb311
}

/// Convert a `Dialect` to its C-ABI tag value.
pub fn dialect_to_int(value: Dialect) -> Int {
  case value {
    Smb202 -> 0
    Smb21 -> 1
    Smb30 -> 2
    Smb302 -> 3
    Smb311 -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn dialect_from_int(tag: Int) -> Result(Dialect, Nil) {
  case tag {
    0 -> Ok(Smb202)
    1 -> Ok(Smb21)
    2 -> Ok(Smb30)
    3 -> Ok(Smb302)
    4 -> Ok(Smb311)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ShareType
// ===========================================================================

/// SMB share types (MS-SMB2 Section 2.2.10).
/// 
/// Matches `ShareType` in `SMBABI.Types`.
pub type ShareType {
  /// Disk share — file system access (tag 0).
  Disk
  /// Named pipe share — IPC (tag 1).
  Pipe
  /// Print share — printer access (tag 2).
  Print
}

/// Convert a `ShareType` to its C-ABI tag value.
pub fn share_type_to_int(value: ShareType) -> Int {
  case value {
    Disk -> 0
    Pipe -> 1
    Print -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn share_type_from_int(tag: Int) -> Result(ShareType, Nil) {
  case tag {
    0 -> Ok(Disk)
    1 -> Ok(Pipe)
    2 -> Ok(Print)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// SMB session lifecycle states for the FFI layer.
/// 
/// Matches `SessionState` in `SMBABI.Types`.
/// Combines connection, tree, and file handle states into a single enum.
pub type SessionState {
  /// No connection established (tag 0).
  Idle
  /// Dialect negotiated, session not yet authenticated (tag 1).
  Negotiated
  /// Session authenticated, no tree connections (tag 2).
  Authenticated
  /// At least one tree connection is active (tag 3).
  TreeConnected
  /// At least one file handle is open (tag 4).
  FileOpen
  /// Connection closing (logoff in progress) (tag 5).
  Disconnecting
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Negotiated -> 1
    Authenticated -> 2
    TreeConnected -> 3
    FileOpen -> 4
    Disconnecting -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Negotiated)
    2 -> Ok(Authenticated)
    3 -> Ok(TreeConnected)
    4 -> Ok(FileOpen)
    5 -> Ok(Disconnecting)
    _ -> Error(Nil)
  }
}

