//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Virtualisation protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `VirtABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// VmState
// ===========================================================================

/// VM lifecycle states.
/// 
/// Matches `VmState` in `VirtABI.Types`.
pub type VmState {
  /// Creating (tag 0).
  Creating
  /// Running (tag 1).
  Running
  /// Paused (tag 2).
  Paused
  /// Suspended (tag 3).
  Suspended
  /// ShuttingDown (tag 4).
  ShuttingDown
  /// Stopped (tag 5).
  Stopped
  /// Crashed (tag 6).
  Crashed
  /// Migrating (tag 7).
  Migrating
}

/// Convert a `VmState` to its C-ABI tag value.
pub fn vm_state_to_int(value: VmState) -> Int {
  case value {
    Creating -> 0
    Running -> 1
    Paused -> 2
    Suspended -> 3
    ShuttingDown -> 4
    Stopped -> 5
    Crashed -> 6
    Migrating -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn vm_state_from_int(tag: Int) -> Result(VmState, Nil) {
  case tag {
    0 -> Ok(Creating)
    1 -> Ok(Running)
    2 -> Ok(Paused)
    3 -> Ok(Suspended)
    4 -> Ok(ShuttingDown)
    5 -> Ok(Stopped)
    6 -> Ok(Crashed)
    7 -> Ok(Migrating)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// VirtOperation
// ===========================================================================

/// VM operations.
/// 
/// Matches `VirtOperation` in `VirtABI.Types`.
pub type VirtOperation {
  /// Create (tag 0).
  Create
  /// Start (tag 1).
  Start
  /// Stop (tag 2).
  Stop
  /// Restart (tag 3).
  Restart
  /// Pause (tag 4).
  Pause
  /// Resume (tag 5).
  Resume
  /// Suspend (tag 6).
  Suspend
  /// Migrate (tag 7).
  Migrate
  /// Snapshot (tag 8).
  Snapshot
  /// Clone (tag 9).
  Clone
  /// Delete (tag 10).
  Delete
}

/// Convert a `VirtOperation` to its C-ABI tag value.
pub fn virt_operation_to_int(value: VirtOperation) -> Int {
  case value {
    Create -> 0
    Start -> 1
    Stop -> 2
    Restart -> 3
    Pause -> 4
    Resume -> 5
    Suspend -> 6
    Migrate -> 7
    Snapshot -> 8
    Clone -> 9
    Delete -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn virt_operation_from_int(tag: Int) -> Result(VirtOperation, Nil) {
  case tag {
    0 -> Ok(Create)
    1 -> Ok(Start)
    2 -> Ok(Stop)
    3 -> Ok(Restart)
    4 -> Ok(Pause)
    5 -> Ok(Resume)
    6 -> Ok(Suspend)
    7 -> Ok(Migrate)
    8 -> Ok(Snapshot)
    9 -> Ok(Clone)
    10 -> Ok(Delete)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DiskFormat
// ===========================================================================

/// Virtual disk formats.
/// 
/// Matches `DiskFormat` in `VirtABI.Types`.
pub type DiskFormat {
  /// Raw (tag 0).
  Raw
  /// QCOW2 (tag 1).
  Qcow2
  /// VDI (tag 2).
  Vdi
  /// VMDK (tag 3).
  Vmdk
  /// VHD (tag 4).
  Vhd
}

/// Convert a `DiskFormat` to its C-ABI tag value.
pub fn disk_format_to_int(value: DiskFormat) -> Int {
  case value {
    Raw -> 0
    Qcow2 -> 1
    Vdi -> 2
    Vmdk -> 3
    Vhd -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn disk_format_from_int(tag: Int) -> Result(DiskFormat, Nil) {
  case tag {
    0 -> Ok(Raw)
    1 -> Ok(Qcow2)
    2 -> Ok(Vdi)
    3 -> Ok(Vmdk)
    4 -> Ok(Vhd)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NetworkType
// ===========================================================================

/// VM network types.
/// 
/// Matches `NetworkType` in `VirtABI.Types`.
pub type NetworkType {
  /// NAT (tag 0).
  Nat
  /// Bridged (tag 1).
  Bridged
  /// Internal (tag 2).
  Internal
  /// HostOnly (tag 3).
  HostOnly
}

/// Convert a `NetworkType` to its C-ABI tag value.
pub fn network_type_to_int(value: NetworkType) -> Int {
  case value {
    Nat -> 0
    Bridged -> 1
    Internal -> 2
    HostOnly -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn network_type_from_int(tag: Int) -> Result(NetworkType, Nil) {
  case tag {
    0 -> Ok(Nat)
    1 -> Ok(Bridged)
    2 -> Ok(Internal)
    3 -> Ok(HostOnly)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// BootDevice
// ===========================================================================

/// VM boot devices.
/// 
/// Matches `BootDevice` in `VirtABI.Types`.
pub type BootDevice {
  /// HardDisk (tag 0).
  HardDisk
  /// CD-ROM (tag 1).
  Cdrom
  /// Network (tag 2).
  Network
  /// USB (tag 3).
  Usb
}

/// Convert a `BootDevice` to its C-ABI tag value.
pub fn boot_device_to_int(value: BootDevice) -> Int {
  case value {
    HardDisk -> 0
    Cdrom -> 1
    Network -> 2
    Usb -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn boot_device_from_int(tag: Int) -> Result(BootDevice, Nil) {
  case tag {
    0 -> Ok(HardDisk)
    1 -> Ok(Cdrom)
    2 -> Ok(Network)
    3 -> Ok(Usb)
    _ -> Error(Nil)
  }
}

