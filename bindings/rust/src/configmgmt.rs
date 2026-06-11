// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Configuration Management types for the proven-servers ABI.
//!
//! Formally verified configuration management types.
//! Mirrors the Idris2 module `ConfigmgmtABI.Types`.
//!
//! - `ResourceType` -- Managed resource types.
//! - `ResourceState` -- Desired resource states.
//! - `ChangeAction` -- Configuration change actions.
//! - `DriftStatus` -- Configuration drift status.
//! - `ApplyMode` -- Configuration apply modes.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ResourceType (tags 0-8)
// ===========================================================================

/// Managed resource types.
///
/// Matches `ResourceType` in `ConfigmgmtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResourceType {
    /// File (tag 0).
    File = 0,
    /// Package (tag 1).
    Package = 1,
    /// Service (tag 2).
    Service = 2,
    /// User (tag 3).
    User = 3,
    /// Group (tag 4).
    Group = 4,
    /// Cron (tag 5).
    Cron = 5,
    /// Mount (tag 6).
    Mount = 6,
    /// Firewall (tag 7).
    Firewall = 7,
    /// Registry (tag 8).
    Registry = 8,
}

impl ResourceType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::File),
            1 => Some(Self::Package),
            2 => Some(Self::Service),
            3 => Some(Self::User),
            4 => Some(Self::Group),
            5 => Some(Self::Cron),
            6 => Some(Self::Mount),
            7 => Some(Self::Firewall),
            8 => Some(Self::Registry),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResourceType; 9] = [
        Self::File, Self::Package, Self::Service, Self::User, Self::Group, Self::Cron, Self::Mount, Self::Firewall, Self::Registry,
    ];
}

impl fmt::Display for ResourceType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResourceState (tags 0-5)
// ===========================================================================

/// Desired resource states.
///
/// Matches `ResourceState` in `ConfigmgmtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResourceState {
    /// Present (tag 0).
    Present = 0,
    /// Absent (tag 1).
    Absent = 1,
    /// Running (tag 2).
    Running = 2,
    /// Stopped (tag 3).
    Stopped = 3,
    /// Enabled (tag 4).
    Enabled = 4,
    /// Disabled (tag 5).
    Disabled = 5,
}

impl ResourceState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Present),
            1 => Some(Self::Absent),
            2 => Some(Self::Running),
            3 => Some(Self::Stopped),
            4 => Some(Self::Enabled),
            5 => Some(Self::Disabled),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResourceState; 6] = [
        Self::Present, Self::Absent, Self::Running, Self::Stopped, Self::Enabled, Self::Disabled,
    ];
}

impl fmt::Display for ResourceState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ChangeAction (tags 0-5)
// ===========================================================================

/// Configuration change actions.
///
/// Matches `ChangeAction` in `ConfigmgmtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChangeAction {
    /// Create (tag 0).
    Create = 0,
    /// Modify (tag 1).
    Modify = 1,
    /// Delete (tag 2).
    Delete = 2,
    /// Restart (tag 3).
    Restart = 3,
    /// Reload (tag 4).
    Reload = 4,
    /// Skip (tag 5).
    Skip = 5,
}

impl ChangeAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Create),
            1 => Some(Self::Modify),
            2 => Some(Self::Delete),
            3 => Some(Self::Restart),
            4 => Some(Self::Reload),
            5 => Some(Self::Skip),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ChangeAction; 6] = [
        Self::Create, Self::Modify, Self::Delete, Self::Restart, Self::Reload, Self::Skip,
    ];
}

impl fmt::Display for ChangeAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DriftStatus (tags 0-3)
// ===========================================================================

/// Configuration drift status.
///
/// Matches `DriftStatus` in `ConfigmgmtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DriftStatus {
    /// InSync (tag 0).
    InSync = 0,
    /// Drifted (tag 1).
    Drifted = 1,
    /// Unknown (tag 2).
    DUnknown = 2,
    /// Unmanaged (tag 3).
    Unmanaged = 3,
}

impl DriftStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::InSync),
            1 => Some(Self::Drifted),
            2 => Some(Self::DUnknown),
            3 => Some(Self::Unmanaged),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DriftStatus; 4] = [
        Self::InSync, Self::Drifted, Self::DUnknown, Self::Unmanaged,
    ];
}

impl fmt::Display for DriftStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ApplyMode (tags 0-2)
// ===========================================================================

/// Configuration apply modes.
///
/// Matches `ApplyMode` in `ConfigmgmtABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ApplyMode {
    /// Enforce (tag 0).
    Enforce = 0,
    /// DryRun (tag 1).
    DryRun = 1,
    /// Audit (tag 2).
    Audit = 2,
}

impl ApplyMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Enforce),
            1 => Some(Self::DryRun),
            2 => Some(Self::Audit),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ApplyMode; 3] = [
        Self::Enforce, Self::DryRun, Self::Audit,
    ];
}

impl fmt::Display for ApplyMode {
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
    fn resource_type_roundtrip() {
        for v in ResourceType::ALL {
            let tag = v.to_tag();
            let decoded = ResourceType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResourceType::from_tag(9).is_none());
    }

    #[test]
    fn resource_state_roundtrip() {
        for v in ResourceState::ALL {
            let tag = v.to_tag();
            let decoded = ResourceState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResourceState::from_tag(6).is_none());
    }

    #[test]
    fn change_action_roundtrip() {
        for v in ChangeAction::ALL {
            let tag = v.to_tag();
            let decoded = ChangeAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ChangeAction::from_tag(6).is_none());
    }

    #[test]
    fn drift_status_roundtrip() {
        for v in DriftStatus::ALL {
            let tag = v.to_tag();
            let decoded = DriftStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DriftStatus::from_tag(4).is_none());
    }

    #[test]
    fn apply_mode_roundtrip() {
        for v in ApplyMode::ALL {
            let tag = v.to_tag();
            let decoded = ApplyMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ApplyMode::from_tag(3).is_none());
    }

}
