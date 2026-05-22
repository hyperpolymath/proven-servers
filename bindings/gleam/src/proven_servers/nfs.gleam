//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// NFS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `NfsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// NFS Constants
// ===========================================================================

/// Nfs Port constant.
pub const nfs_port = 2049

// ===========================================================================
// Operation
// ===========================================================================

/// NFSv4 operations (RFC 7530).
/// 
/// Matches `Operation` in `NFSABI.Types`.
pub type Operation {
  /// Check access permissions (tag 0).
  OperationAccess
  /// Close a stateful file handle (tag 1).
  Close
  /// Commit cached data to stable storage (tag 2).
  Commit
  /// Create a file or directory (tag 3).
  Create
  /// Get file attributes (tag 4).
  GetAttr
  /// Create a hard link (tag 5).
  OperationLink
  /// Lock a byte range (tag 6).
  Lock
  /// Look up a name in a directory (tag 7).
  Lookup
  /// Open a file (tag 8).
  Open
  /// Read file data (tag 9).
  Read
  /// List directory entries (tag 10).
  ReadDir
  /// Remove a file or directory (tag 11).
  Remove
  /// Rename a file or directory (tag 12).
  Rename
  /// Set file attributes (tag 13).
  SetAttr
  /// Write file data (tag 14).
  Write
}

/// Convert a `Operation` to its C-ABI tag value.
pub fn operation_to_int(value: Operation) -> Int {
  case value {
    OperationAccess -> 0
    Close -> 1
    Commit -> 2
    Create -> 3
    GetAttr -> 4
    OperationLink -> 5
    Lock -> 6
    Lookup -> 7
    Open -> 8
    Read -> 9
    ReadDir -> 10
    Remove -> 11
    Rename -> 12
    SetAttr -> 13
    Write -> 14
  }
}

/// Decode from a C-ABI tag value.
pub fn operation_from_int(tag: Int) -> Result(Operation, Nil) {
  case tag {
    0 -> Ok(OperationAccess)
    1 -> Ok(Close)
    2 -> Ok(Commit)
    3 -> Ok(Create)
    4 -> Ok(GetAttr)
    5 -> Ok(OperationLink)
    6 -> Ok(Lock)
    7 -> Ok(Lookup)
    8 -> Ok(Open)
    9 -> Ok(Read)
    10 -> Ok(ReadDir)
    11 -> Ok(Remove)
    12 -> Ok(Rename)
    13 -> Ok(SetAttr)
    14 -> Ok(Write)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FileType
// ===========================================================================

/// NFS file types (RFC 7530 Section 5.8).
/// 
/// Matches `FileType` in `NFSABI.Types`.
pub type FileType {
  /// Regular file (tag 0).
  Regular
  /// Directory (tag 1).
  Directory
  /// Block device (tag 2).
  BlockDevice
  /// Character device (tag 3).
  CharDevice
  /// Symbolic link (tag 4).
  FileTypeLink
  /// Unix domain socket (tag 5).
  Socket
  /// Named pipe / FIFO (tag 6).
  Fifo
}

/// Convert a `FileType` to its C-ABI tag value.
pub fn file_type_to_int(value: FileType) -> Int {
  case value {
    Regular -> 0
    Directory -> 1
    BlockDevice -> 2
    CharDevice -> 3
    FileTypeLink -> 4
    Socket -> 5
    Fifo -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn file_type_from_int(tag: Int) -> Result(FileType, Nil) {
  case tag {
    0 -> Ok(Regular)
    1 -> Ok(Directory)
    2 -> Ok(BlockDevice)
    3 -> Ok(CharDevice)
    4 -> Ok(FileTypeLink)
    5 -> Ok(Socket)
    6 -> Ok(Fifo)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Status
// ===========================================================================

/// NFS status codes (RFC 7530 Section 13).
/// 
/// Matches `Status` in `NFSABI.Types`.
pub type Status {
  /// Success (tag 0).
  StatusOk
  /// Permission denied (tag 1).
  Perm
  /// No such file or directory (tag 2).
  NoEnt
  /// I/O error (tag 3).
  Io
  /// No such device or address (tag 4).
  NxIo
  /// Access denied (tag 5).
  StatusAccess
  /// File or directory already exists (tag 6).
  Exist
  /// Not a directory (tag 7).
  NotDir
  /// Is a directory (tag 8).
  IsDir
  /// File too large (tag 9).
  FBig
  /// No space left on device (tag 10).
  NoSpc
  /// Read-only file system (tag 11).
  ROfs
  /// Directory not empty (tag 12).
  NotEmpty
  /// Stale file handle (tag 13).
  Stale
}

/// Convert a `Status` to its C-ABI tag value.
pub fn status_to_int(value: Status) -> Int {
  case value {
    StatusOk -> 0
    Perm -> 1
    NoEnt -> 2
    Io -> 3
    NxIo -> 4
    StatusAccess -> 5
    Exist -> 6
    NotDir -> 7
    IsDir -> 8
    FBig -> 9
    NoSpc -> 10
    ROfs -> 11
    NotEmpty -> 12
    Stale -> 13
  }
}

/// Decode from a C-ABI tag value.
pub fn status_from_int(tag: Int) -> Result(Status, Nil) {
  case tag {
    0 -> Ok(StatusOk)
    1 -> Ok(Perm)
    2 -> Ok(NoEnt)
    3 -> Ok(Io)
    4 -> Ok(NxIo)
    5 -> Ok(StatusAccess)
    6 -> Ok(Exist)
    7 -> Ok(NotDir)
    8 -> Ok(IsDir)
    9 -> Ok(FBig)
    10 -> Ok(NoSpc)
    11 -> Ok(ROfs)
    12 -> Ok(NotEmpty)
    13 -> Ok(Stale)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NfsState
// ===========================================================================

/// NFS server lifecycle states for the FFI layer.
/// 
/// Matches `NFSState` in `NFSABI.Types`.
pub type NfsState {
  /// Not mounted (tag 0).
  Idle
  /// Connected to server, mount established (tag 1).
  Mounted
  /// File handle is open (tag 2).
  FileOpen
  /// Lock held on a file region (tag 3).
  Locked
  /// I/O in progress (tag 4).
  Busy
  /// Unmounting (tag 5).
  Unmounting
}

/// Convert a `NfsState` to its C-ABI tag value.
pub fn nfs_state_to_int(value: NfsState) -> Int {
  case value {
    Idle -> 0
    Mounted -> 1
    FileOpen -> 2
    Locked -> 3
    Busy -> 4
    Unmounting -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn nfs_state_from_int(tag: Int) -> Result(NfsState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Mounted)
    2 -> Ok(FileOpen)
    3 -> Ok(Locked)
    4 -> Ok(Busy)
    5 -> Ok(Unmounting)
    _ -> Error(Nil)
  }
}

