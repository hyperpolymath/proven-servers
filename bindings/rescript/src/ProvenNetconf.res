// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF types for the proven-servers ABI.
//
// Mirrors the Idris2 module NetconfABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard NETCONF SSH port.
let netconfPort = 830

// ===========================================================================
// NetconfOperation (tags 0-11)
// ===========================================================================

/// Standard NETCONF SSH port.
type netconfOperation =
  | @as(0) Get
  | @as(1) GetConfig
  | @as(2) EditConfig
  | @as(3) CopyConfig
  | @as(4) DeleteConfig
  | @as(5) Lock
  | @as(6) Unlock
  | @as(7) CloseSession
  | @as(8) KillSession
  | @as(9) Commit
  | @as(10) Validate
  | @as(11) DiscardChanges

/// Decode from the C-ABI tag value.
let netconfOperationFromTag = (tag: int): option<netconfOperation> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(GetConfig)
  | 2 => Some(EditConfig)
  | 3 => Some(CopyConfig)
  | 4 => Some(DeleteConfig)
  | 5 => Some(Lock)
  | 6 => Some(Unlock)
  | 7 => Some(CloseSession)
  | 8 => Some(KillSession)
  | 9 => Some(Commit)
  | 10 => Some(Validate)
  | 11 => Some(DiscardChanges)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let netconfOperationToTag = (v: netconfOperation): int =>
  switch v {
  | Get => 0
  | GetConfig => 1
  | EditConfig => 2
  | CopyConfig => 3
  | DeleteConfig => 4
  | Lock => 5
  | Unlock => 6
  | CloseSession => 7
  | KillSession => 8
  | Commit => 9
  | Validate => 10
  | DiscardChanges => 11
  }

// ===========================================================================
// Datastore (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type datastore =
  | @as(0) Running
  | @as(1) Startup
  | @as(2) Candidate

/// Decode from the C-ABI tag value.
let datastoreFromTag = (tag: int): option<datastore> =>
  switch tag {
  | 0 => Some(Running)
  | 1 => Some(Startup)
  | 2 => Some(Candidate)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let datastoreToTag = (v: datastore): int =>
  switch v {
  | Running => 0
  | Startup => 1
  | Candidate => 2
  }

// ===========================================================================
// EditOperation (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type editOperation =
  | @as(0) Merge
  | @as(1) Replace
  | @as(2) Create
  | @as(3) Delete
  | @as(4) Remove

/// Decode from the C-ABI tag value.
let editOperationFromTag = (tag: int): option<editOperation> =>
  switch tag {
  | 0 => Some(Merge)
  | 1 => Some(Replace)
  | 2 => Some(Create)
  | 3 => Some(Delete)
  | 4 => Some(Remove)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let editOperationToTag = (v: editOperation): int =>
  switch v {
  | Merge => 0
  | Replace => 1
  | Create => 2
  | Delete => 3
  | Remove => 4
  }

// ===========================================================================
// NetconfErrorType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type netconfErrorType =
  | @as(0) Transport
  | @as(1) Rpc
  | @as(2) Protocol
  | @as(3) Application

/// Decode from the C-ABI tag value.
let netconfErrorTypeFromTag = (tag: int): option<netconfErrorType> =>
  switch tag {
  | 0 => Some(Transport)
  | 1 => Some(Rpc)
  | 2 => Some(Protocol)
  | 3 => Some(Application)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let netconfErrorTypeToTag = (v: netconfErrorType): int =>
  switch v {
  | Transport => 0
  | Rpc => 1
  | Protocol => 2
  | Application => 3
  }

// ===========================================================================
// ErrorSeverity (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type errorSeverity =
  | @as(0) Error
  | @as(1) Warning

/// Decode from the C-ABI tag value.
let errorSeverityFromTag = (tag: int): option<errorSeverity> =>
  switch tag {
  | 0 => Some(Error)
  | 1 => Some(Warning)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorSeverityToTag = (v: errorSeverity): int =>
  switch v {
  | Error => 0
  | Warning => 1
  }

// ===========================================================================
// NetconfState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type netconfState =
  | @as(0) Idle
  | @as(1) Connected
  | @as(2) Locked
  | @as(3) Editing
  | @as(4) Closing
  | @as(5) Terminated

/// Decode from the C-ABI tag value.
let netconfStateFromTag = (tag: int): option<netconfState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connected)
  | 2 => Some(Locked)
  | 3 => Some(Editing)
  | 4 => Some(Closing)
  | 5 => Some(Terminated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let netconfStateToTag = (v: netconfState): int =>
  switch v {
  | Idle => 0
  | Connected => 1
  | Locked => 2
  | Editing => 3
  | Closing => 4
  | Terminated => 5
  }

