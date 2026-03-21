// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NFS (Network File System) types for the proven-servers ABI.
//
// Mirrors the Idris2 module NFSABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard NFS port (RFC 7530).
let nfsPort = 2049

// ===========================================================================
// Operation (tags 0-14)
// ===========================================================================

/// Standard NFS port (RFC 7530).
type operation =
  | @as(0) Access
  | @as(1) Close
  | @as(2) Commit
  | @as(3) Create
  | @as(4) GetAttr
  | @as(5) Link
  | @as(6) Lock
  | @as(7) Lookup
  | @as(8) Open
  | @as(9) Read
  | @as(10) ReadDir
  | @as(11) Remove
  | @as(12) Rename
  | @as(13) SetAttr
  | @as(14) Write

/// Decode from the C-ABI tag value.
let operationFromTag = (tag: int): option<operation> =>
  switch tag {
  | 0 => Some(Access)
  | 1 => Some(Close)
  | 2 => Some(Commit)
  | 3 => Some(Create)
  | 4 => Some(GetAttr)
  | 5 => Some(Link)
  | 6 => Some(Lock)
  | 7 => Some(Lookup)
  | 8 => Some(Open)
  | 9 => Some(Read)
  | 10 => Some(ReadDir)
  | 11 => Some(Remove)
  | 12 => Some(Rename)
  | 13 => Some(SetAttr)
  | 14 => Some(Write)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let operationToTag = (v: operation): int =>
  switch v {
  | Access => 0
  | Close => 1
  | Commit => 2
  | Create => 3
  | GetAttr => 4
  | Link => 5
  | Lock => 6
  | Lookup => 7
  | Open => 8
  | Read => 9
  | ReadDir => 10
  | Remove => 11
  | Rename => 12
  | SetAttr => 13
  | Write => 14
  }

/// Whether this operation modifies the filesystem.
let operationIsWrite = (v: operation): bool =>
  switch v {
  | Create | Link | Remove | Rename | SetAttr | Write | Commit => true
  | _ => false
  }

/// Whether this operation is read-only.
let operationIsRead = (v: operation): bool =>
  switch v {
  | Access | GetAttr | Lookup | Read | ReadDir => true
  | _ => false
  }

// ===========================================================================
// FileType (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type fileType =
  | @as(0) Regular
  | @as(1) Directory
  | @as(2) BlockDevice
  | @as(3) CharDevice
  | @as(4) Link
  | @as(5) Socket
  | @as(6) Fifo

/// Decode from the C-ABI tag value.
let fileTypeFromTag = (tag: int): option<fileType> =>
  switch tag {
  | 0 => Some(Regular)
  | 1 => Some(Directory)
  | 2 => Some(BlockDevice)
  | 3 => Some(CharDevice)
  | 4 => Some(Link)
  | 5 => Some(Socket)
  | 6 => Some(Fifo)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let fileTypeToTag = (v: fileType): int =>
  switch v {
  | Regular => 0
  | Directory => 1
  | BlockDevice => 2
  | CharDevice => 3
  | Link => 4
  | Socket => 5
  | Fifo => 6
  }

/// Whether this file type is a regular data file.
let fileTypeIsRegular = (v: fileType): bool =>
  switch v {
  | Regular => true
  | _ => false
  }

/// Whether this file type is a special device node.
let fileTypeIsDevice = (v: fileType): bool =>
  switch v {
  | BlockDevice | CharDevice => true
  | _ => false
  }

// ===========================================================================
// Status (tags 0-13)
// ===========================================================================

/// Decode from an ABI tag value.
type status =
  | @as(0) Ok
  | @as(1) Perm
  | @as(2) NoEnt
  | @as(3) Io
  | @as(4) NxIo
  | @as(5) Access
  | @as(6) Exist
  | @as(7) NotDir
  | @as(8) IsDir
  | @as(9) FBig
  | @as(10) NoSpc
  | @as(11) ROfs
  | @as(12) NotEmpty
  | @as(13) Stale

/// Decode from the C-ABI tag value.
let statusFromTag = (tag: int): option<status> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(Perm)
  | 2 => Some(NoEnt)
  | 3 => Some(Io)
  | 4 => Some(NxIo)
  | 5 => Some(Access)
  | 6 => Some(Exist)
  | 7 => Some(NotDir)
  | 8 => Some(IsDir)
  | 9 => Some(FBig)
  | 10 => Some(NoSpc)
  | 11 => Some(ROfs)
  | 12 => Some(NotEmpty)
  | 13 => Some(Stale)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusToTag = (v: status): int =>
  switch v {
  | Ok => 0
  | Perm => 1
  | NoEnt => 2
  | Io => 3
  | NxIo => 4
  | Access => 5
  | Exist => 6
  | NotDir => 7
  | IsDir => 8
  | FBig => 9
  | NoSpc => 10
  | ROfs => 11
  | NotEmpty => 12
  | Stale => 13
  }

/// Whether this status indicates success.
let statusIsOk = (v: status): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

/// Whether this error relates to access control.
let statusIsAccessError = (v: status): bool =>
  switch v {
  | Perm | Access | ROfs => true
  | _ => false
  }

/// Whether this error is likely transient and retryable.
let statusIsRetryable = (v: status): bool =>
  switch v {
  | Io | NxIo | Stale => true
  | _ => false
  }

// ===========================================================================
// NfsState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type nfsState =
  | @as(0) Idle
  | @as(1) Mounted
  | @as(2) FileOpen
  | @as(3) Locked
  | @as(4) Busy
  | @as(5) Unmounting

/// Decode from the C-ABI tag value.
let nfsStateFromTag = (tag: int): option<nfsState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Mounted)
  | 2 => Some(FileOpen)
  | 3 => Some(Locked)
  | 4 => Some(Busy)
  | 5 => Some(Unmounting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let nfsStateToTag = (v: nfsState): int =>
  switch v {
  | Idle => 0
  | Mounted => 1
  | FileOpen => 2
  | Locked => 3
  | Busy => 4
  | Unmounting => 5
  }

/// Whether the NFS mount is active.
let nfsStateIsMounted = (v: nfsState): bool =>
  switch v {
  | Idle | Unmounting => false
  | _ => true
  }

