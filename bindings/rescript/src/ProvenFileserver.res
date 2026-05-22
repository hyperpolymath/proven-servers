// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module FileserverABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// FileOperation (tags 0-9)
// ===========================================================================

/// File server operations.
type fileOperation =
  | @as(0) Read
  | @as(1) Write
  | @as(2) Create
  | @as(3) Delete
  | @as(4) Rename
  | @as(5) List
  | @as(6) Stat
  | @as(7) Lock
  | @as(8) Unlock
  | @as(9) Watch

/// Decode from the C-ABI tag value.
let fileOperationFromTag = (tag: int): option<fileOperation> =>
  switch tag {
  | 0 => Some(Read)
  | 1 => Some(Write)
  | 2 => Some(Create)
  | 3 => Some(Delete)
  | 4 => Some(Rename)
  | 5 => Some(List)
  | 6 => Some(Stat)
  | 7 => Some(Lock)
  | 8 => Some(Unlock)
  | 9 => Some(Watch)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let fileOperationToTag = (v: fileOperation): int =>
  switch v {
  | Read => 0
  | Write => 1
  | Create => 2
  | Delete => 3
  | Rename => 4
  | List => 5
  | Stat => 6
  | Lock => 7
  | Unlock => 8
  | Watch => 9
  }

// ===========================================================================
// FileType (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type fileType =
  | @as(0) Regular
  | @as(1) Directory
  | @as(2) Symlink
  | @as(3) BlockDevice
  | @as(4) CharDevice
  | @as(5) Fifo
  | @as(6) Socket

/// Decode from the C-ABI tag value.
let fileTypeFromTag = (tag: int): option<fileType> =>
  switch tag {
  | 0 => Some(Regular)
  | 1 => Some(Directory)
  | 2 => Some(Symlink)
  | 3 => Some(BlockDevice)
  | 4 => Some(CharDevice)
  | 5 => Some(Fifo)
  | 6 => Some(Socket)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let fileTypeToTag = (v: fileType): int =>
  switch v {
  | Regular => 0
  | Directory => 1
  | Symlink => 2
  | BlockDevice => 3
  | CharDevice => 4
  | Fifo => 5
  | Socket => 6
  }

// ===========================================================================
// FilePermission (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type filePermission =
  | @as(0) OwnerRead
  | @as(1) OwnerWrite
  | @as(2) OwnerExecute
  | @as(3) GroupRead
  | @as(4) GroupWrite
  | @as(5) GroupExecute
  | @as(6) OtherRead
  | @as(7) OtherWrite
  | @as(8) OtherExecute

/// Decode from the C-ABI tag value.
let filePermissionFromTag = (tag: int): option<filePermission> =>
  switch tag {
  | 0 => Some(OwnerRead)
  | 1 => Some(OwnerWrite)
  | 2 => Some(OwnerExecute)
  | 3 => Some(GroupRead)
  | 4 => Some(GroupWrite)
  | 5 => Some(GroupExecute)
  | 6 => Some(OtherRead)
  | 7 => Some(OtherWrite)
  | 8 => Some(OtherExecute)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let filePermissionToTag = (v: filePermission): int =>
  switch v {
  | OwnerRead => 0
  | OwnerWrite => 1
  | OwnerExecute => 2
  | GroupRead => 3
  | GroupWrite => 4
  | GroupExecute => 5
  | OtherRead => 6
  | OtherWrite => 7
  | OtherExecute => 8
  }

// ===========================================================================
// LockType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type lockType =
  | @as(0) Shared
  | @as(1) Exclusive
  | @as(2) Advisory
  | @as(3) Mandatory

/// Decode from the C-ABI tag value.
let lockTypeFromTag = (tag: int): option<lockType> =>
  switch tag {
  | 0 => Some(Shared)
  | 1 => Some(Exclusive)
  | 2 => Some(Advisory)
  | 3 => Some(Mandatory)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let lockTypeToTag = (v: lockType): int =>
  switch v {
  | Shared => 0
  | Exclusive => 1
  | Advisory => 2
  | Mandatory => 3
  }

// ===========================================================================
// FileErrorCode (tags 0-9)
// ===========================================================================

/// Decode from an ABI tag value.
type fileErrorCode =
  | @as(0) NotFound
  | @as(1) PermissionDenied
  | @as(2) AlreadyExists
  | @as(3) NotEmpty
  | @as(4) IsDirectory
  | @as(5) NotDirectory
  | @as(6) NoSpace
  | @as(7) ReadOnly
  | @as(8) Locked
  | @as(9) IoError

/// Decode from the C-ABI tag value.
let fileErrorCodeFromTag = (tag: int): option<fileErrorCode> =>
  switch tag {
  | 0 => Some(NotFound)
  | 1 => Some(PermissionDenied)
  | 2 => Some(AlreadyExists)
  | 3 => Some(NotEmpty)
  | 4 => Some(IsDirectory)
  | 5 => Some(NotDirectory)
  | 6 => Some(NoSpace)
  | 7 => Some(ReadOnly)
  | 8 => Some(Locked)
  | 9 => Some(IoError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let fileErrorCodeToTag = (v: fileErrorCode): int =>
  switch v {
  | NotFound => 0
  | PermissionDenied => 1
  | AlreadyExists => 2
  | NotEmpty => 3
  | IsDirectory => 4
  | NotDirectory => 5
  | NoSpace => 6
  | ReadOnly => 7
  | Locked => 8
  | IoError => 9
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Connected
  | @as(2) Operating
  | @as(3) FsLocked
  | @as(4) Disconnecting

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connected)
  | 2 => Some(Operating)
  | 3 => Some(FsLocked)
  | 4 => Some(Disconnecting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Connected => 1
  | Operating => 2
  | FsLocked => 3
  | Disconnecting => 4
  }

