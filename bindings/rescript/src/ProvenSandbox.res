// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox types for the proven-servers ABI.
//
// Mirrors the Idris2 module SandboxABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ExecutionPolicy (tags 0-4)
// ===========================================================================

/// Sandbox execution policies.
type executionPolicy =
  | @as(0) Unrestricted
  | @as(1) ReadOnly
  | @as(2) NetworkDenied
  | @as(3) Isolated
  | @as(4) Ephemeral

/// Decode from the C-ABI tag value.
let executionPolicyFromTag = (tag: int): option<executionPolicy> =>
  switch tag {
  | 0 => Some(Unrestricted)
  | 1 => Some(ReadOnly)
  | 2 => Some(NetworkDenied)
  | 3 => Some(Isolated)
  | 4 => Some(Ephemeral)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let executionPolicyToTag = (v: executionPolicy): int =>
  switch v {
  | Unrestricted => 0
  | ReadOnly => 1
  | NetworkDenied => 2
  | Isolated => 3
  | Ephemeral => 4
  }

// ===========================================================================
// ResourceLimit (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type resourceLimit =
  | @as(0) CpuTime
  | @as(1) Memory
  | @as(2) DiskIo
  | @as(3) NetworkIo
  | @as(4) FileDescriptors
  | @as(5) Processes

/// Decode from the C-ABI tag value.
let resourceLimitFromTag = (tag: int): option<resourceLimit> =>
  switch tag {
  | 0 => Some(CpuTime)
  | 1 => Some(Memory)
  | 2 => Some(DiskIo)
  | 3 => Some(NetworkIo)
  | 4 => Some(FileDescriptors)
  | 5 => Some(Processes)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let resourceLimitToTag = (v: resourceLimit): int =>
  switch v {
  | CpuTime => 0
  | Memory => 1
  | DiskIo => 2
  | NetworkIo => 3
  | FileDescriptors => 4
  | Processes => 5
  }

// ===========================================================================
// SandboxState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type sandboxState =
  | @as(0) Creating
  | @as(1) Ready
  | @as(2) Running
  | @as(3) Suspended
  | @as(4) Terminated
  | @as(5) Destroyed

/// Decode from the C-ABI tag value.
let sandboxStateFromTag = (tag: int): option<sandboxState> =>
  switch tag {
  | 0 => Some(Creating)
  | 1 => Some(Ready)
  | 2 => Some(Running)
  | 3 => Some(Suspended)
  | 4 => Some(Terminated)
  | 5 => Some(Destroyed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sandboxStateToTag = (v: sandboxState): int =>
  switch v {
  | Creating => 0
  | Ready => 1
  | Running => 2
  | Suspended => 3
  | Terminated => 4
  | Destroyed => 5
  }

// ===========================================================================
// ExitReason (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type exitReason =
  | @as(0) Normal
  | @as(1) Timeout
  | @as(2) MemoryExceeded
  | @as(3) PolicyViolation
  | @as(4) Killed
  | @as(5) Error

/// Decode from the C-ABI tag value.
let exitReasonFromTag = (tag: int): option<exitReason> =>
  switch tag {
  | 0 => Some(Normal)
  | 1 => Some(Timeout)
  | 2 => Some(MemoryExceeded)
  | 3 => Some(PolicyViolation)
  | 4 => Some(Killed)
  | 5 => Some(Error)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let exitReasonToTag = (v: exitReason): int =>
  switch v {
  | Normal => 0
  | Timeout => 1
  | MemoryExceeded => 2
  | PolicyViolation => 3
  | Killed => 4
  | Error => 5
  }

// ===========================================================================
// SyscallPolicy (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type syscallPolicy =
  | @as(0) Allow
  | @as(1) Deny
  | @as(2) Log
  | @as(3) Trap

/// Decode from the C-ABI tag value.
let syscallPolicyFromTag = (tag: int): option<syscallPolicy> =>
  switch tag {
  | 0 => Some(Allow)
  | 1 => Some(Deny)
  | 2 => Some(Log)
  | 3 => Some(Trap)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let syscallPolicyToTag = (v: syscallPolicy): int =>
  switch v {
  | Allow => 0
  | Deny => 1
  | Log => 2
  | Trap => 3
  }

