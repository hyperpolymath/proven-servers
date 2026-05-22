//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// File Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `FileserverABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// FileOperation
// ===========================================================================

/// File server operations.
/// 
/// Matches `FileOperation` in `FileserverABI.Types`.
pub type FileOperation {
  /// Read (tag 0).
  Read
  /// Write (tag 1).
  Write
  /// Create (tag 2).
  Create
  /// Delete (tag 3).
  Delete
  /// Rename (tag 4).
  Rename
  /// List (tag 5).
  List
  /// Stat (tag 6).
  Stat
  /// Lock (tag 7).
  Lock
  /// Unlock (tag 8).
  Unlock
  /// Watch (tag 9).
  Watch
}

/// Convert a `FileOperation` to its C-ABI tag value.
pub fn file_operation_to_int(value: FileOperation) -> Int {
  case value {
    Read -> 0
    Write -> 1
    Create -> 2
    Delete -> 3
    Rename -> 4
    List -> 5
    Stat -> 6
    Lock -> 7
    Unlock -> 8
    Watch -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn file_operation_from_int(tag: Int) -> Result(FileOperation, Nil) {
  case tag {
    0 -> Ok(Read)
    1 -> Ok(Write)
    2 -> Ok(Create)
    3 -> Ok(Delete)
    4 -> Ok(Rename)
    5 -> Ok(List)
    6 -> Ok(Stat)
    7 -> Ok(Lock)
    8 -> Ok(Unlock)
    9 -> Ok(Watch)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FileType
// ===========================================================================

/// File types.
/// 
/// Matches `FileType` in `FileserverABI.Types`.
pub type FileType {
  /// Regular (tag 0).
  Regular
  /// Directory (tag 1).
  Directory
  /// Symlink (tag 2).
  Symlink
  /// BlockDevice (tag 3).
  BlockDevice
  /// CharDevice (tag 4).
  CharDevice
  /// FIFO (tag 5).
  Fifo
  /// Socket (tag 6).
  Socket
}

/// Convert a `FileType` to its C-ABI tag value.
pub fn file_type_to_int(value: FileType) -> Int {
  case value {
    Regular -> 0
    Directory -> 1
    Symlink -> 2
    BlockDevice -> 3
    CharDevice -> 4
    Fifo -> 5
    Socket -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn file_type_from_int(tag: Int) -> Result(FileType, Nil) {
  case tag {
    0 -> Ok(Regular)
    1 -> Ok(Directory)
    2 -> Ok(Symlink)
    3 -> Ok(BlockDevice)
    4 -> Ok(CharDevice)
    5 -> Ok(Fifo)
    6 -> Ok(Socket)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FilePermission
// ===========================================================================

/// POSIX file permissions.
/// 
/// Matches `FilePermission` in `FileserverABI.Types`.
pub type FilePermission {
  /// OwnerRead (tag 0).
  OwnerRead
  /// OwnerWrite (tag 1).
  OwnerWrite
  /// OwnerExecute (tag 2).
  OwnerExecute
  /// GroupRead (tag 3).
  GroupRead
  /// GroupWrite (tag 4).
  GroupWrite
  /// GroupExecute (tag 5).
  GroupExecute
  /// OtherRead (tag 6).
  OtherRead
  /// OtherWrite (tag 7).
  OtherWrite
  /// OtherExecute (tag 8).
  OtherExecute
}

/// Convert a `FilePermission` to its C-ABI tag value.
pub fn file_permission_to_int(value: FilePermission) -> Int {
  case value {
    OwnerRead -> 0
    OwnerWrite -> 1
    OwnerExecute -> 2
    GroupRead -> 3
    GroupWrite -> 4
    GroupExecute -> 5
    OtherRead -> 6
    OtherWrite -> 7
    OtherExecute -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn file_permission_from_int(tag: Int) -> Result(FilePermission, Nil) {
  case tag {
    0 -> Ok(OwnerRead)
    1 -> Ok(OwnerWrite)
    2 -> Ok(OwnerExecute)
    3 -> Ok(GroupRead)
    4 -> Ok(GroupWrite)
    5 -> Ok(GroupExecute)
    6 -> Ok(OtherRead)
    7 -> Ok(OtherWrite)
    8 -> Ok(OtherExecute)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LockType
// ===========================================================================

/// File lock types.
/// 
/// Matches `LockType` in `FileserverABI.Types`.
pub type LockType {
  /// Shared (tag 0).
  Shared
  /// Exclusive (tag 1).
  Exclusive
  /// Advisory (tag 2).
  Advisory
  /// Mandatory (tag 3).
  Mandatory
}

/// Convert a `LockType` to its C-ABI tag value.
pub fn lock_type_to_int(value: LockType) -> Int {
  case value {
    Shared -> 0
    Exclusive -> 1
    Advisory -> 2
    Mandatory -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn lock_type_from_int(tag: Int) -> Result(LockType, Nil) {
  case tag {
    0 -> Ok(Shared)
    1 -> Ok(Exclusive)
    2 -> Ok(Advisory)
    3 -> Ok(Mandatory)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FileErrorCode
// ===========================================================================

/// File server error codes.
/// 
/// Matches `FileErrorCode` in `FileserverABI.Types`.
pub type FileErrorCode {
  /// NotFound (tag 0).
  NotFound
  /// PermissionDenied (tag 1).
  PermissionDenied
  /// AlreadyExists (tag 2).
  AlreadyExists
  /// NotEmpty (tag 3).
  NotEmpty
  /// IsDirectory (tag 4).
  IsDirectory
  /// NotDirectory (tag 5).
  NotDirectory
  /// NoSpace (tag 6).
  NoSpace
  /// ReadOnly (tag 7).
  ReadOnly
  /// Locked (tag 8).
  Locked
  /// I/O error (tag 9).
  IoError
}

/// Convert a `FileErrorCode` to its C-ABI tag value.
pub fn file_error_code_to_int(value: FileErrorCode) -> Int {
  case value {
    NotFound -> 0
    PermissionDenied -> 1
    AlreadyExists -> 2
    NotEmpty -> 3
    IsDirectory -> 4
    NotDirectory -> 5
    NoSpace -> 6
    ReadOnly -> 7
    Locked -> 8
    IoError -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn file_error_code_from_int(tag: Int) -> Result(FileErrorCode, Nil) {
  case tag {
    0 -> Ok(NotFound)
    1 -> Ok(PermissionDenied)
    2 -> Ok(AlreadyExists)
    3 -> Ok(NotEmpty)
    4 -> Ok(IsDirectory)
    5 -> Ok(NotDirectory)
    6 -> Ok(NoSpace)
    7 -> Ok(ReadOnly)
    8 -> Ok(Locked)
    9 -> Ok(IoError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// File server session states.
/// 
/// Matches `SessionState` in `FileserverABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Connected (tag 1).
  Connected
  /// Operating (tag 2).
  Operating
  /// Locked (tag 3).
  FsLocked
  /// Disconnecting (tag 4).
  Disconnecting
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Connected -> 1
    Operating -> 2
    FsLocked -> 3
    Disconnecting -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connected)
    2 -> Ok(Operating)
    3 -> Ok(FsLocked)
    4 -> Ok(Disconnecting)
    _ -> Error(Nil)
  }
}

