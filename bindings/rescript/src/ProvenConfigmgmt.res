// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Configuration Management types for the proven-servers ABI.
//
// Mirrors the Idris2 module ConfigmgmtABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ResourceType (tags 0-8)
// ===========================================================================

/// Managed resource types.
type resourceType =
  | @as(0) File
  | @as(1) Package
  | @as(2) Service
  | @as(3) User
  | @as(4) Group
  | @as(5) Cron
  | @as(6) Mount
  | @as(7) Firewall
  | @as(8) Registry

/// Decode from the C-ABI tag value.
let resourceTypeFromTag = (tag: int): option<resourceType> =>
  switch tag {
  | 0 => Some(File)
  | 1 => Some(Package)
  | 2 => Some(Service)
  | 3 => Some(User)
  | 4 => Some(Group)
  | 5 => Some(Cron)
  | 6 => Some(Mount)
  | 7 => Some(Firewall)
  | 8 => Some(Registry)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let resourceTypeToTag = (v: resourceType): int =>
  switch v {
  | File => 0
  | Package => 1
  | Service => 2
  | User => 3
  | Group => 4
  | Cron => 5
  | Mount => 6
  | Firewall => 7
  | Registry => 8
  }

// ===========================================================================
// ResourceState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type resourceState =
  | @as(0) Present
  | @as(1) Absent
  | @as(2) Running
  | @as(3) Stopped
  | @as(4) Enabled
  | @as(5) Disabled

/// Decode from the C-ABI tag value.
let resourceStateFromTag = (tag: int): option<resourceState> =>
  switch tag {
  | 0 => Some(Present)
  | 1 => Some(Absent)
  | 2 => Some(Running)
  | 3 => Some(Stopped)
  | 4 => Some(Enabled)
  | 5 => Some(Disabled)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let resourceStateToTag = (v: resourceState): int =>
  switch v {
  | Present => 0
  | Absent => 1
  | Running => 2
  | Stopped => 3
  | Enabled => 4
  | Disabled => 5
  }

// ===========================================================================
// ChangeAction (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type changeAction =
  | @as(0) Create
  | @as(1) Modify
  | @as(2) Delete
  | @as(3) Restart
  | @as(4) Reload
  | @as(5) Skip

/// Decode from the C-ABI tag value.
let changeActionFromTag = (tag: int): option<changeAction> =>
  switch tag {
  | 0 => Some(Create)
  | 1 => Some(Modify)
  | 2 => Some(Delete)
  | 3 => Some(Restart)
  | 4 => Some(Reload)
  | 5 => Some(Skip)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let changeActionToTag = (v: changeAction): int =>
  switch v {
  | Create => 0
  | Modify => 1
  | Delete => 2
  | Restart => 3
  | Reload => 4
  | Skip => 5
  }

// ===========================================================================
// DriftStatus (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type driftStatus =
  | @as(0) InSync
  | @as(1) Drifted
  | @as(2) DUnknown
  | @as(3) Unmanaged

/// Decode from the C-ABI tag value.
let driftStatusFromTag = (tag: int): option<driftStatus> =>
  switch tag {
  | 0 => Some(InSync)
  | 1 => Some(Drifted)
  | 2 => Some(DUnknown)
  | 3 => Some(Unmanaged)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let driftStatusToTag = (v: driftStatus): int =>
  switch v {
  | InSync => 0
  | Drifted => 1
  | DUnknown => 2
  | Unmanaged => 3
  }

// ===========================================================================
// ApplyMode (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type applyMode =
  | @as(0) Enforce
  | @as(1) DryRun
  | @as(2) Audit

/// Decode from the C-ABI tag value.
let applyModeFromTag = (tag: int): option<applyMode> =>
  switch tag {
  | 0 => Some(Enforce)
  | 1 => Some(DryRun)
  | 2 => Some(Audit)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let applyModeToTag = (v: applyMode): int =>
  switch v {
  | Enforce => 0
  | DryRun => 1
  | Audit => 2
  }

