// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Hardened Server types for the proven-servers ABI.
//!
//! Formally verified hardened server types.
//! Mirrors the Idris2 module `HardenedABI.Types`.
//!
//! - `HardeningLevel` -- System hardening levels.
//! - `SecurityControl` -- Security controls.
//! - `ComplianceStandard` -- Security compliance standards.
//! - `AuditEvent` -- Audit event types.
//! - `HardenedHealthStatus` -- Hardened system health.
//! - `ServerState` -- Hardened server states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// HardeningLevel (tags 0-3)
// ===========================================================================

/// System hardening levels.
///
/// Matches `HardeningLevel` in `HardenedABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HardeningLevel {
    /// Minimal (tag 0).
    Minimal = 0,
    /// Standard (tag 1).
    Standard = 1,
    /// High (tag 2).
    High = 2,
    /// Maximum (tag 3).
    Maximum = 3,
}

impl HardeningLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Minimal),
            1 => Some(Self::Standard),
            2 => Some(Self::High),
            3 => Some(Self::Maximum),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HardeningLevel; 4] = [
        Self::Minimal, Self::Standard, Self::High, Self::Maximum,
    ];
}

impl fmt::Display for HardeningLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SecurityControl (tags 0-6)
// ===========================================================================

/// Security controls.
///
/// Matches `SecurityControl` in `HardenedABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SecurityControl {
    /// ASLR (tag 0).
    Aslr = 0,
    /// DEP (tag 1).
    Dep = 1,
    /// StackCanary (tag 2).
    StackCanary = 2,
    /// CFI (tag 3).
    Cfi = 3,
    /// Sandboxing (tag 4).
    Sandboxing = 4,
    /// SecureBoot (tag 5).
    SecureBoot = 5,
    /// AuditLog (tag 6).
    AuditLog = 6,
}

impl SecurityControl {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Aslr),
            1 => Some(Self::Dep),
            2 => Some(Self::StackCanary),
            3 => Some(Self::Cfi),
            4 => Some(Self::Sandboxing),
            5 => Some(Self::SecureBoot),
            6 => Some(Self::AuditLog),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SecurityControl; 7] = [
        Self::Aslr, Self::Dep, Self::StackCanary, Self::Cfi, Self::Sandboxing, Self::SecureBoot, Self::AuditLog,
    ];
}

impl fmt::Display for SecurityControl {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ComplianceStandard (tags 0-4)
// ===========================================================================

/// Security compliance standards.
///
/// Matches `ComplianceStandard` in `HardenedABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ComplianceStandard {
    /// CIS Benchmark (tag 0).
    Cis = 0,
    /// DISA STIG (tag 1).
    Stig = 1,
    /// NIST 800-53 (tag 2).
    Nist80053 = 2,
    /// PCI-DSS (tag 3).
    PciDss = 3,
    /// FIPS 140 (tag 4).
    Fips140 = 4,
}

impl ComplianceStandard {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Cis),
            1 => Some(Self::Stig),
            2 => Some(Self::Nist80053),
            3 => Some(Self::PciDss),
            4 => Some(Self::Fips140),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ComplianceStandard; 5] = [
        Self::Cis, Self::Stig, Self::Nist80053, Self::PciDss, Self::Fips140,
    ];
}

impl fmt::Display for ComplianceStandard {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuditEvent (tags 0-5)
// ===========================================================================

/// Audit event types.
///
/// Matches `AuditEvent` in `HardenedABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuditEvent {
    /// ProcessStart (tag 0).
    ProcessStart = 0,
    /// FileAccess (tag 1).
    FileAccess = 1,
    /// NetworkConn (tag 2).
    NetworkConn = 2,
    /// PrivilegeEscalation (tag 3).
    PrivilegeEscalation = 3,
    /// ConfigChange (tag 4).
    ConfigChange = 4,
    /// AuthAttempt (tag 5).
    AuthAttempt = 5,
}

impl AuditEvent {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ProcessStart),
            1 => Some(Self::FileAccess),
            2 => Some(Self::NetworkConn),
            3 => Some(Self::PrivilegeEscalation),
            4 => Some(Self::ConfigChange),
            5 => Some(Self::AuthAttempt),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AuditEvent; 6] = [
        Self::ProcessStart, Self::FileAccess, Self::NetworkConn, Self::PrivilegeEscalation, Self::ConfigChange, Self::AuthAttempt,
    ];
}

impl fmt::Display for AuditEvent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HardenedHealthStatus (tags 0-3)
// ===========================================================================

/// Hardened system health.
///
/// Matches `HardenedHealthStatus` in `HardenedABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HardenedHealthStatus {
    /// Healthy (tag 0).
    Healthy = 0,
    /// Degraded (tag 1).
    Degraded = 1,
    /// Compromised (tag 2).
    Compromised = 2,
    /// Unresponsive (tag 3).
    Unresponsive = 3,
}

impl HardenedHealthStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Healthy),
            1 => Some(Self::Degraded),
            2 => Some(Self::Compromised),
            3 => Some(Self::Unresponsive),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HardenedHealthStatus; 4] = [
        Self::Healthy, Self::Degraded, Self::Compromised, Self::Unresponsive,
    ];
}

impl fmt::Display for HardenedHealthStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Hardened server states.
///
/// Matches `ServerState` in `HardenedABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Hardening (tag 1).
    Hardening = 1,
    /// Active (tag 2).
    Active = 2,
    /// Auditing (tag 3).
    Auditing = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Hardening),
            2 => Some(Self::Active),
            3 => Some(Self::Auditing),
            4 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServerState; 5] = [
        Self::Idle, Self::Hardening, Self::Active, Self::Auditing, Self::Shutdown,
    ];
}

impl fmt::Display for ServerState {
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
    fn hardening_level_roundtrip() {
        for v in HardeningLevel::ALL {
            let tag = v.to_tag();
            let decoded = HardeningLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HardeningLevel::from_tag(4).is_none());
    }

    #[test]
    fn security_control_roundtrip() {
        for v in SecurityControl::ALL {
            let tag = v.to_tag();
            let decoded = SecurityControl::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SecurityControl::from_tag(7).is_none());
    }

    #[test]
    fn compliance_standard_roundtrip() {
        for v in ComplianceStandard::ALL {
            let tag = v.to_tag();
            let decoded = ComplianceStandard::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ComplianceStandard::from_tag(5).is_none());
    }

    #[test]
    fn audit_event_roundtrip() {
        for v in AuditEvent::ALL {
            let tag = v.to_tag();
            let decoded = AuditEvent::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AuditEvent::from_tag(6).is_none());
    }

    #[test]
    fn hardened_health_status_roundtrip() {
        for v in HardenedHealthStatus::ALL {
            let tag = v.to_tag();
            let decoded = HardenedHealthStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HardenedHealthStatus::from_tag(4).is_none());
    }

    #[test]
    fn server_state_roundtrip() {
        for v in ServerState::ALL {
            let tag = v.to_tag();
            let decoded = ServerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServerState::from_tag(5).is_none());
    }

}
