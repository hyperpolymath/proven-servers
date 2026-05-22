// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Honeypot types for the proven-servers ABI.
//!
//! Formally verified honeypot/deception types.
//! Mirrors the Idris2 module `HoneypotABI.Types`.
//!
//! - `ServiceEmulation` -- Emulated service types.
//! - `InteractionLevel` -- Honeypot interaction levels.
//! - `HoneypotAlertSeverity` -- Honeypot alert severity levels.
//! - `AttackerAction` -- Observed attacker actions.
//! - `ServerState` -- Honeypot server states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ServiceEmulation (tags 0-6)
// ===========================================================================

/// Emulated service types.
///
/// Matches `ServiceEmulation` in `HoneypotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServiceEmulation {
    /// SSH (tag 0).
    Ssh = 0,
    /// HTTP (tag 1).
    Http = 1,
    /// FTP (tag 2).
    Ftp = 2,
    /// SMTP (tag 3).
    Smtp = 3,
    /// Telnet (tag 4).
    Telnet = 4,
    /// MySQL (tag 5).
    Mysql = 5,
    /// RDP (tag 6).
    Rdp = 6,
}

impl ServiceEmulation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ssh),
            1 => Some(Self::Http),
            2 => Some(Self::Ftp),
            3 => Some(Self::Smtp),
            4 => Some(Self::Telnet),
            5 => Some(Self::Mysql),
            6 => Some(Self::Rdp),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServiceEmulation; 7] = [
        Self::Ssh, Self::Http, Self::Ftp, Self::Smtp, Self::Telnet, Self::Mysql, Self::Rdp,
    ];
}

impl fmt::Display for ServiceEmulation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// InteractionLevel (tags 0-2)
// ===========================================================================

/// Honeypot interaction levels.
///
/// Matches `InteractionLevel` in `HoneypotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum InteractionLevel {
    /// Low (tag 0).
    Low = 0,
    /// Medium (tag 1).
    Medium = 1,
    /// High (tag 2).
    High = 2,
}

impl InteractionLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Low),
            1 => Some(Self::Medium),
            2 => Some(Self::High),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [InteractionLevel; 3] = [
        Self::Low, Self::Medium, Self::High,
    ];
}

impl fmt::Display for InteractionLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HoneypotAlertSeverity (tags 0-4)
// ===========================================================================

/// Honeypot alert severity levels.
///
/// Matches `HoneypotAlertSeverity` in `HoneypotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HoneypotAlertSeverity {
    /// Info (tag 0).
    Info = 0,
    /// Low (tag 1).
    AsLow = 1,
    /// Medium (tag 2).
    AsMedium = 2,
    /// High (tag 3).
    AsHigh = 3,
    /// Critical (tag 4).
    Critical = 4,
}

impl HoneypotAlertSeverity {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Info),
            1 => Some(Self::AsLow),
            2 => Some(Self::AsMedium),
            3 => Some(Self::AsHigh),
            4 => Some(Self::Critical),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HoneypotAlertSeverity; 5] = [
        Self::Info, Self::AsLow, Self::AsMedium, Self::AsHigh, Self::Critical,
    ];
}

impl fmt::Display for HoneypotAlertSeverity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AttackerAction (tags 0-5)
// ===========================================================================

/// Observed attacker actions.
///
/// Matches `AttackerAction` in `HoneypotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AttackerAction {
    /// Scan (tag 0).
    Scan = 0,
    /// BruteForce (tag 1).
    BruteForce = 1,
    /// Exploit (tag 2).
    Exploit = 2,
    /// Payload (tag 3).
    Payload = 3,
    /// Lateral (tag 4).
    Lateral = 4,
    /// Exfiltration (tag 5).
    Exfiltration = 5,
}

impl AttackerAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Scan),
            1 => Some(Self::BruteForce),
            2 => Some(Self::Exploit),
            3 => Some(Self::Payload),
            4 => Some(Self::Lateral),
            5 => Some(Self::Exfiltration),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AttackerAction; 6] = [
        Self::Scan, Self::BruteForce, Self::Exploit, Self::Payload, Self::Lateral, Self::Exfiltration,
    ];
}

impl fmt::Display for AttackerAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-3)
// ===========================================================================

/// Honeypot server states.
///
/// Matches `ServerState` in `HoneypotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Deployed (tag 1).
    Deployed = 1,
    /// Engaged (tag 2).
    Engaged = 2,
    /// Shutdown (tag 3).
    Shutdown = 3,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Deployed),
            2 => Some(Self::Engaged),
            3 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServerState; 4] = [
        Self::Idle, Self::Deployed, Self::Engaged, Self::Shutdown,
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
    fn service_emulation_roundtrip() {
        for v in ServiceEmulation::ALL {
            let tag = v.to_tag();
            let decoded = ServiceEmulation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServiceEmulation::from_tag(7).is_none());
    }

    #[test]
    fn interaction_level_roundtrip() {
        for v in InteractionLevel::ALL {
            let tag = v.to_tag();
            let decoded = InteractionLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(InteractionLevel::from_tag(3).is_none());
    }

    #[test]
    fn honeypot_alert_severity_roundtrip() {
        for v in HoneypotAlertSeverity::ALL {
            let tag = v.to_tag();
            let decoded = HoneypotAlertSeverity::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HoneypotAlertSeverity::from_tag(5).is_none());
    }

    #[test]
    fn attacker_action_roundtrip() {
        for v in AttackerAction::ALL {
            let tag = v.to_tag();
            let decoded = AttackerAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AttackerAction::from_tag(6).is_none());
    }

    #[test]
    fn server_state_roundtrip() {
        for v in ServerState::ALL {
            let tag = v.to_tag();
            let decoded = ServerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServerState::from_tag(4).is_none());
    }

}
