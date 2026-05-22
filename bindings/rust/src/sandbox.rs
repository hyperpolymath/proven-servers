// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Sandbox types for the proven-servers ABI.
//!
//! Formally verified sandbox/isolation types.
//! Mirrors the Idris2 module `SandboxABI.Types`.
//!
//! - `ExecutionPolicy` -- Sandbox execution policies.
//! - `ResourceLimit` -- Sandbox resource limits.
//! - `SandboxState` -- Sandbox lifecycle states.
//! - `ExitReason` -- Sandbox exit reasons.
//! - `SyscallPolicy` -- System call filter policies.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ExecutionPolicy (tags 0-4)
// ===========================================================================

/// Sandbox execution policies.
///
/// Matches `ExecutionPolicy` in `SandboxABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ExecutionPolicy {
    /// Unrestricted (tag 0).
    Unrestricted = 0,
    /// ReadOnly (tag 1).
    ReadOnly = 1,
    /// NetworkDenied (tag 2).
    NetworkDenied = 2,
    /// Isolated (tag 3).
    Isolated = 3,
    /// Ephemeral (tag 4).
    Ephemeral = 4,
}

impl ExecutionPolicy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unrestricted),
            1 => Some(Self::ReadOnly),
            2 => Some(Self::NetworkDenied),
            3 => Some(Self::Isolated),
            4 => Some(Self::Ephemeral),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ExecutionPolicy; 5] = [
        Self::Unrestricted, Self::ReadOnly, Self::NetworkDenied, Self::Isolated, Self::Ephemeral,
    ];
}

impl fmt::Display for ExecutionPolicy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResourceLimit (tags 0-5)
// ===========================================================================

/// Sandbox resource limits.
///
/// Matches `ResourceLimit` in `SandboxABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResourceLimit {
    /// CPU time (tag 0).
    CpuTime = 0,
    /// Memory (tag 1).
    Memory = 1,
    /// Disk I/O (tag 2).
    DiskIo = 2,
    /// Network I/O (tag 3).
    NetworkIo = 3,
    /// FileDescriptors (tag 4).
    FileDescriptors = 4,
    /// Processes (tag 5).
    Processes = 5,
}

impl ResourceLimit {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::CpuTime),
            1 => Some(Self::Memory),
            2 => Some(Self::DiskIo),
            3 => Some(Self::NetworkIo),
            4 => Some(Self::FileDescriptors),
            5 => Some(Self::Processes),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResourceLimit; 6] = [
        Self::CpuTime, Self::Memory, Self::DiskIo, Self::NetworkIo, Self::FileDescriptors, Self::Processes,
    ];
}

impl fmt::Display for ResourceLimit {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SandboxState (tags 0-5)
// ===========================================================================

/// Sandbox lifecycle states.
///
/// Matches `SandboxState` in `SandboxABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SandboxState {
    /// Creating (tag 0).
    Creating = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// Running (tag 2).
    Running = 2,
    /// Suspended (tag 3).
    Suspended = 3,
    /// Terminated (tag 4).
    Terminated = 4,
    /// Destroyed (tag 5).
    Destroyed = 5,
}

impl SandboxState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Creating),
            1 => Some(Self::Ready),
            2 => Some(Self::Running),
            3 => Some(Self::Suspended),
            4 => Some(Self::Terminated),
            5 => Some(Self::Destroyed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SandboxState; 6] = [
        Self::Creating, Self::Ready, Self::Running, Self::Suspended, Self::Terminated, Self::Destroyed,
    ];
}

impl fmt::Display for SandboxState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ExitReason (tags 0-5)
// ===========================================================================

/// Sandbox exit reasons.
///
/// Matches `ExitReason` in `SandboxABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ExitReason {
    /// Normal (tag 0).
    Normal = 0,
    /// Timeout (tag 1).
    Timeout = 1,
    /// MemoryExceeded (tag 2).
    MemoryExceeded = 2,
    /// PolicyViolation (tag 3).
    PolicyViolation = 3,
    /// Killed (tag 4).
    Killed = 4,
    /// Error (tag 5).
    Error = 5,
}

impl ExitReason {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Normal),
            1 => Some(Self::Timeout),
            2 => Some(Self::MemoryExceeded),
            3 => Some(Self::PolicyViolation),
            4 => Some(Self::Killed),
            5 => Some(Self::Error),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ExitReason; 6] = [
        Self::Normal, Self::Timeout, Self::MemoryExceeded, Self::PolicyViolation, Self::Killed, Self::Error,
    ];
}

impl fmt::Display for ExitReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SyscallPolicy (tags 0-3)
// ===========================================================================

/// System call filter policies.
///
/// Matches `SyscallPolicy` in `SandboxABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SyscallPolicy {
    /// Allow (tag 0).
    Allow = 0,
    /// Deny (tag 1).
    Deny = 1,
    /// Log (tag 2).
    Log = 2,
    /// Trap (tag 3).
    Trap = 3,
}

impl SyscallPolicy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Allow),
            1 => Some(Self::Deny),
            2 => Some(Self::Log),
            3 => Some(Self::Trap),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SyscallPolicy; 4] = [
        Self::Allow, Self::Deny, Self::Log, Self::Trap,
    ];
}

impl fmt::Display for SyscallPolicy {
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
    fn execution_policy_roundtrip() {
        for v in ExecutionPolicy::ALL {
            let tag = v.to_tag();
            let decoded = ExecutionPolicy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ExecutionPolicy::from_tag(5).is_none());
    }

    #[test]
    fn resource_limit_roundtrip() {
        for v in ResourceLimit::ALL {
            let tag = v.to_tag();
            let decoded = ResourceLimit::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResourceLimit::from_tag(6).is_none());
    }

    #[test]
    fn sandbox_state_roundtrip() {
        for v in SandboxState::ALL {
            let tag = v.to_tag();
            let decoded = SandboxState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SandboxState::from_tag(6).is_none());
    }

    #[test]
    fn exit_reason_roundtrip() {
        for v in ExitReason::ALL {
            let tag = v.to_tag();
            let decoded = ExitReason::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ExitReason::from_tag(6).is_none());
    }

    #[test]
    fn syscall_policy_roundtrip() {
        for v in SyscallPolicy::ALL {
            let tag = v.to_tag();
            let decoded = SyscallPolicy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SyscallPolicy::from_tag(4).is_none());
    }

}
