// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Container Runtime types for the proven-servers ABI.
//!
//! Formally verified container runtime types.
//! Mirrors the Idris2 module `ContainerABI.Types`.
//!
//! - `ContainerState` -- Container lifecycle states.
//! - `ContainerOperation` -- Container operations.
//! - `NetworkMode` -- Container network modes.
//! - `VolumeType` -- Container volume types.
//! - `RestartPolicy` -- Container restart policies.
//! - `HealthStatus` -- Container health check status.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ContainerState (tags 0-6)
// ===========================================================================

/// Container lifecycle states.
///
/// Matches `ContainerState` in `ContainerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContainerState {
    /// Creating (tag 0).
    Creating = 0,
    /// Running (tag 1).
    Running = 1,
    /// Paused (tag 2).
    Paused = 2,
    /// Restarting (tag 3).
    Restarting = 3,
    /// Stopped (tag 4).
    Stopped = 4,
    /// Removing (tag 5).
    Removing = 5,
    /// Dead (tag 6).
    Dead = 6,
}

impl ContainerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Creating),
            1 => Some(Self::Running),
            2 => Some(Self::Paused),
            3 => Some(Self::Restarting),
            4 => Some(Self::Stopped),
            5 => Some(Self::Removing),
            6 => Some(Self::Dead),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ContainerState; 7] = [
        Self::Creating, Self::Running, Self::Paused, Self::Restarting, Self::Stopped, Self::Removing, Self::Dead,
    ];
}

impl fmt::Display for ContainerState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ContainerOperation (tags 0-10)
// ===========================================================================

/// Container operations.
///
/// Matches `ContainerOperation` in `ContainerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContainerOperation {
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
    /// Unpause (tag 5).
    Unpause = 5,
    /// Kill (tag 6).
    Kill = 6,
    /// Remove (tag 7).
    Remove = 7,
    /// Exec (tag 8).
    Exec = 8,
    /// Logs (tag 9).
    Logs = 9,
    /// Inspect (tag 10).
    Inspect = 10,
}

impl ContainerOperation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Create),
            1 => Some(Self::Start),
            2 => Some(Self::Stop),
            3 => Some(Self::Restart),
            4 => Some(Self::Pause),
            5 => Some(Self::Unpause),
            6 => Some(Self::Kill),
            7 => Some(Self::Remove),
            8 => Some(Self::Exec),
            9 => Some(Self::Logs),
            10 => Some(Self::Inspect),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ContainerOperation; 11] = [
        Self::Create, Self::Start, Self::Stop, Self::Restart, Self::Pause, Self::Unpause, Self::Kill, Self::Remove, Self::Exec, Self::Logs, Self::Inspect,
    ];
}

impl fmt::Display for ContainerOperation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NetworkMode (tags 0-4)
// ===========================================================================

/// Container network modes.
///
/// Matches `NetworkMode` in `ContainerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NetworkMode {
    /// Bridge (tag 0).
    Bridge = 0,
    /// Host (tag 1).
    Host = 1,
    /// None (tag 2).
    None = 2,
    /// Overlay (tag 3).
    Overlay = 3,
    /// Macvlan (tag 4).
    Macvlan = 4,
}

impl NetworkMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Bridge),
            1 => Some(Self::Host),
            2 => Some(Self::None),
            3 => Some(Self::Overlay),
            4 => Some(Self::Macvlan),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NetworkMode; 5] = [
        Self::Bridge, Self::Host, Self::None, Self::Overlay, Self::Macvlan,
    ];
}

impl fmt::Display for NetworkMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// VolumeType (tags 0-2)
// ===========================================================================

/// Container volume types.
///
/// Matches `VolumeType` in `ContainerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum VolumeType {
    /// Bind (tag 0).
    Bind = 0,
    /// Named (tag 1).
    Named = 1,
    /// Tmpfs (tag 2).
    Tmpfs = 2,
}

impl VolumeType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Bind),
            1 => Some(Self::Named),
            2 => Some(Self::Tmpfs),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [VolumeType; 3] = [
        Self::Bind, Self::Named, Self::Tmpfs,
    ];
}

impl fmt::Display for VolumeType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RestartPolicy (tags 0-3)
// ===========================================================================

/// Container restart policies.
///
/// Matches `RestartPolicy` in `ContainerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RestartPolicy {
    /// No (tag 0).
    No = 0,
    /// Always (tag 1).
    Always = 1,
    /// OnFailure (tag 2).
    OnFailure = 2,
    /// UnlessStopped (tag 3).
    UnlessStopped = 3,
}

impl RestartPolicy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::No),
            1 => Some(Self::Always),
            2 => Some(Self::OnFailure),
            3 => Some(Self::UnlessStopped),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RestartPolicy; 4] = [
        Self::No, Self::Always, Self::OnFailure, Self::UnlessStopped,
    ];
}

impl fmt::Display for RestartPolicy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HealthStatus (tags 0-3)
// ===========================================================================

/// Container health check status.
///
/// Matches `HealthStatus` in `ContainerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HealthStatus {
    /// Starting (tag 0).
    Starting = 0,
    /// Healthy (tag 1).
    Healthy = 1,
    /// Unhealthy (tag 2).
    Unhealthy = 2,
    /// NoCheck (tag 3).
    NoCheck = 3,
}

impl HealthStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Starting),
            1 => Some(Self::Healthy),
            2 => Some(Self::Unhealthy),
            3 => Some(Self::NoCheck),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HealthStatus; 4] = [
        Self::Starting, Self::Healthy, Self::Unhealthy, Self::NoCheck,
    ];
}

impl fmt::Display for HealthStatus {
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
    fn container_state_roundtrip() {
        for v in ContainerState::ALL {
            let tag = v.to_tag();
            let decoded = ContainerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ContainerState::from_tag(7).is_none());
    }

    #[test]
    fn container_operation_roundtrip() {
        for v in ContainerOperation::ALL {
            let tag = v.to_tag();
            let decoded = ContainerOperation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ContainerOperation::from_tag(11).is_none());
    }

    #[test]
    fn network_mode_roundtrip() {
        for v in NetworkMode::ALL {
            let tag = v.to_tag();
            let decoded = NetworkMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NetworkMode::from_tag(5).is_none());
    }

    #[test]
    fn volume_type_roundtrip() {
        for v in VolumeType::ALL {
            let tag = v.to_tag();
            let decoded = VolumeType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(VolumeType::from_tag(3).is_none());
    }

    #[test]
    fn restart_policy_roundtrip() {
        for v in RestartPolicy::ALL {
            let tag = v.to_tag();
            let decoded = RestartPolicy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RestartPolicy::from_tag(4).is_none());
    }

    #[test]
    fn health_status_roundtrip() {
        for v in HealthStatus::ALL {
            let tag = v.to_tag();
            let decoded = HealthStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HealthStatus::from_tag(4).is_none());
    }

}
