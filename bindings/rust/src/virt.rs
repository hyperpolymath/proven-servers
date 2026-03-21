// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Virtualization types for the proven-servers ABI.
//!
//! Formally verified virtualization/hypervisor types.
//! Mirrors the Idris2 module `VirtABI.Types`.
//!
//! - `VmState` -- VM lifecycle states.
//! - `VirtOperation` -- VM operations.
//! - `DiskFormat` -- Virtual disk formats.
//! - `NetworkType` -- VM network types.
//! - `BootDevice` -- VM boot devices.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// VmState (tags 0-7)
// ===========================================================================

/// VM lifecycle states.
///
/// Matches `VmState` in `VirtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum VmState {
    /// Creating (tag 0).
    Creating = 0,
    /// Running (tag 1).
    Running = 1,
    /// Paused (tag 2).
    Paused = 2,
    /// Suspended (tag 3).
    Suspended = 3,
    /// ShuttingDown (tag 4).
    ShuttingDown = 4,
    /// Stopped (tag 5).
    Stopped = 5,
    /// Crashed (tag 6).
    Crashed = 6,
    /// Migrating (tag 7).
    Migrating = 7,
}

impl VmState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Creating),
            1 => Some(Self::Running),
            2 => Some(Self::Paused),
            3 => Some(Self::Suspended),
            4 => Some(Self::ShuttingDown),
            5 => Some(Self::Stopped),
            6 => Some(Self::Crashed),
            7 => Some(Self::Migrating),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [VmState; 8] = [
        Self::Creating, Self::Running, Self::Paused, Self::Suspended, Self::ShuttingDown, Self::Stopped, Self::Crashed, Self::Migrating,
    ];
}

impl fmt::Display for VmState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// VirtOperation (tags 0-10)
// ===========================================================================

/// VM operations.
///
/// Matches `VirtOperation` in `VirtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum VirtOperation {
    /// Create (tag 0).
    Create = 0,
    /// Start (tag 1).
    Start = 1,
    /// Stop (tag 2).
    Stop = 2,
    /// Restart (tag 3).
    Restart = 3,
    /// Pause (tag 4).
    Pause = 4,
    /// Resume (tag 5).
    Resume = 5,
    /// Suspend (tag 6).
    Suspend = 6,
    /// Migrate (tag 7).
    Migrate = 7,
    /// Snapshot (tag 8).
    Snapshot = 8,
    /// Clone (tag 9).
    Clone = 9,
    /// Delete (tag 10).
    Delete = 10,
}

impl VirtOperation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Create),
            1 => Some(Self::Start),
            2 => Some(Self::Stop),
            3 => Some(Self::Restart),
            4 => Some(Self::Pause),
            5 => Some(Self::Resume),
            6 => Some(Self::Suspend),
            7 => Some(Self::Migrate),
            8 => Some(Self::Snapshot),
            9 => Some(Self::Clone),
            10 => Some(Self::Delete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [VirtOperation; 11] = [
        Self::Create, Self::Start, Self::Stop, Self::Restart, Self::Pause, Self::Resume, Self::Suspend, Self::Migrate, Self::Snapshot, Self::Clone, Self::Delete,
    ];
}

impl fmt::Display for VirtOperation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DiskFormat (tags 0-4)
// ===========================================================================

/// Virtual disk formats.
///
/// Matches `DiskFormat` in `VirtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DiskFormat {
    /// Raw (tag 0).
    Raw = 0,
    /// QCOW2 (tag 1).
    Qcow2 = 1,
    /// VDI (tag 2).
    Vdi = 2,
    /// VMDK (tag 3).
    Vmdk = 3,
    /// VHD (tag 4).
    Vhd = 4,
}

impl DiskFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Raw),
            1 => Some(Self::Qcow2),
            2 => Some(Self::Vdi),
            3 => Some(Self::Vmdk),
            4 => Some(Self::Vhd),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DiskFormat; 5] = [
        Self::Raw, Self::Qcow2, Self::Vdi, Self::Vmdk, Self::Vhd,
    ];
}

impl fmt::Display for DiskFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NetworkType (tags 0-3)
// ===========================================================================

/// VM network types.
///
/// Matches `NetworkType` in `VirtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NetworkType {
    /// NAT (tag 0).
    Nat = 0,
    /// Bridged (tag 1).
    Bridged = 1,
    /// Internal (tag 2).
    Internal = 2,
    /// HostOnly (tag 3).
    HostOnly = 3,
}

impl NetworkType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Nat),
            1 => Some(Self::Bridged),
            2 => Some(Self::Internal),
            3 => Some(Self::HostOnly),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NetworkType; 4] = [
        Self::Nat, Self::Bridged, Self::Internal, Self::HostOnly,
    ];
}

impl fmt::Display for NetworkType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// BootDevice (tags 0-3)
// ===========================================================================

/// VM boot devices.
///
/// Matches `BootDevice` in `VirtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BootDevice {
    /// HardDisk (tag 0).
    HardDisk = 0,
    /// CD-ROM (tag 1).
    Cdrom = 1,
    /// Network (tag 2).
    Network = 2,
    /// USB (tag 3).
    Usb = 3,
}

impl BootDevice {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::HardDisk),
            1 => Some(Self::Cdrom),
            2 => Some(Self::Network),
            3 => Some(Self::Usb),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [BootDevice; 4] = [
        Self::HardDisk, Self::Cdrom, Self::Network, Self::Usb,
    ];
}

impl fmt::Display for BootDevice {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn vm_state_roundtrip() {
        for v in VmState::ALL {
            let tag = v.to_tag();
            let decoded = VmState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(VmState::from_tag(8).is_none());
    }

    #[test]
    fn virt_operation_roundtrip() {
        for v in VirtOperation::ALL {
            let tag = v.to_tag();
            let decoded = VirtOperation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(VirtOperation::from_tag(11).is_none());
    }

    #[test]
    fn disk_format_roundtrip() {
        for v in DiskFormat::ALL {
            let tag = v.to_tag();
            let decoded = DiskFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DiskFormat::from_tag(5).is_none());
    }

    #[test]
    fn network_type_roundtrip() {
        for v in NetworkType::ALL {
            let tag = v.to_tag();
            let decoded = NetworkType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NetworkType::from_tag(4).is_none());
    }

    #[test]
    fn boot_device_roundtrip() {
        for v in BootDevice::ALL {
            let tag = v.to_tag();
            let decoded = BootDevice::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(BootDevice::from_tag(4).is_none());
    }

}
