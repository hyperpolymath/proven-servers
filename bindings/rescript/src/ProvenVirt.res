// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization types for the proven-servers ABI.
//
// Mirrors the Idris2 module VirtABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// VmState (tags 0-7)
// ===========================================================================

/// VM lifecycle states.
type vmState =
  | @as(0) Creating
  | @as(1) Running
  | @as(2) Paused
  | @as(3) Suspended
  | @as(4) ShuttingDown
  | @as(5) Stopped
  | @as(6) Crashed
  | @as(7) Migrating

/// Decode from the C-ABI tag value.
let vmStateFromTag = (tag: int): option<vmState> =>
  switch tag {
  | 0 => Some(Creating)
  | 1 => Some(Running)
  | 2 => Some(Paused)
  | 3 => Some(Suspended)
  | 4 => Some(ShuttingDown)
  | 5 => Some(Stopped)
  | 6 => Some(Crashed)
  | 7 => Some(Migrating)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let vmStateToTag = (v: vmState): int =>
  switch v {
  | Creating => 0
  | Running => 1
  | Paused => 2
  | Suspended => 3
  | ShuttingDown => 4
  | Stopped => 5
  | Crashed => 6
  | Migrating => 7
  }

// ===========================================================================
// VirtOperation (tags 0-10)
// ===========================================================================

/// Decode from an ABI tag value.
type virtOperation =
  | @as(0) Create
  | @as(1) Start
  | @as(2) Stop
  | @as(3) Restart
  | @as(4) Pause
  | @as(5) Resume
  | @as(6) Suspend
  | @as(7) Migrate
  | @as(8) Snapshot
  | @as(9) Clone
  | @as(10) Delete

/// Decode from the C-ABI tag value.
let virtOperationFromTag = (tag: int): option<virtOperation> =>
  switch tag {
  | 0 => Some(Create)
  | 1 => Some(Start)
  | 2 => Some(Stop)
  | 3 => Some(Restart)
  | 4 => Some(Pause)
  | 5 => Some(Resume)
  | 6 => Some(Suspend)
  | 7 => Some(Migrate)
  | 8 => Some(Snapshot)
  | 9 => Some(Clone)
  | 10 => Some(Delete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let virtOperationToTag = (v: virtOperation): int =>
  switch v {
  | Create => 0
  | Start => 1
  | Stop => 2
  | Restart => 3
  | Pause => 4
  | Resume => 5
  | Suspend => 6
  | Migrate => 7
  | Snapshot => 8
  | Clone => 9
  | Delete => 10
  }

// ===========================================================================
// DiskFormat (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type diskFormat =
  | @as(0) Raw
  | @as(1) Qcow2
  | @as(2) Vdi
  | @as(3) Vmdk
  | @as(4) Vhd

/// Decode from the C-ABI tag value.
let diskFormatFromTag = (tag: int): option<diskFormat> =>
  switch tag {
  | 0 => Some(Raw)
  | 1 => Some(Qcow2)
  | 2 => Some(Vdi)
  | 3 => Some(Vmdk)
  | 4 => Some(Vhd)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let diskFormatToTag = (v: diskFormat): int =>
  switch v {
  | Raw => 0
  | Qcow2 => 1
  | Vdi => 2
  | Vmdk => 3
  | Vhd => 4
  }

// ===========================================================================
// NetworkType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type networkType =
  | @as(0) Nat
  | @as(1) Bridged
  | @as(2) Internal
  | @as(3) HostOnly

/// Decode from the C-ABI tag value.
let networkTypeFromTag = (tag: int): option<networkType> =>
  switch tag {
  | 0 => Some(Nat)
  | 1 => Some(Bridged)
  | 2 => Some(Internal)
  | 3 => Some(HostOnly)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let networkTypeToTag = (v: networkType): int =>
  switch v {
  | Nat => 0
  | Bridged => 1
  | Internal => 2
  | HostOnly => 3
  }

// ===========================================================================
// BootDevice (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type bootDevice =
  | @as(0) HardDisk
  | @as(1) Cdrom
  | @as(2) Network
  | @as(3) Usb

/// Decode from the C-ABI tag value.
let bootDeviceFromTag = (tag: int): option<bootDevice> =>
  switch tag {
  | 0 => Some(HardDisk)
  | 1 => Some(Cdrom)
  | 2 => Some(Network)
  | 3 => Some(Usb)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let bootDeviceToTag = (v: bootDevice): int =>
  switch v {
  | HardDisk => 0
  | Cdrom => 1
  | Network => 2
  | Usb => 3
  }

