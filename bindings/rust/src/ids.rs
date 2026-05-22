// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Intrusion Detection System types for the proven-servers ABI.
//!
//! Formally verified IDS types.
//! Mirrors the Idris2 module `IdsABI.Types`.
//!
//! - `AlertSeverity` -- Alert severity levels.
//! - `DetectionMethod` -- Intrusion detection methods.
//! - `IdsProtocol` -- Monitored network protocols.
//! - `IdsAction` -- IDS response actions.
//! - `Direction` -- Traffic direction.
//! - `ThreatLevel` -- Threat assessment levels.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// AlertSeverity (tags 0-3)
// ===========================================================================

/// Alert severity levels.
///
/// Matches `AlertSeverity` in `IdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AlertSeverity {
    /// Low (tag 0).
    Low = 0,
    /// Medium (tag 1).
    Medium = 1,
    /// High (tag 2).
    High = 2,
    /// Critical (tag 3).
    Critical = 3,
}

impl AlertSeverity {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Low),
            1 => Some(Self::Medium),
            2 => Some(Self::High),
            3 => Some(Self::Critical),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AlertSeverity; 4] = [
        Self::Low, Self::Medium, Self::High, Self::Critical,
    ];
}

impl fmt::Display for AlertSeverity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DetectionMethod (tags 0-3)
// ===========================================================================

/// Intrusion detection methods.
///
/// Matches `DetectionMethod` in `IdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DetectionMethod {
    /// Signature (tag 0).
    Signature = 0,
    /// Anomaly (tag 1).
    Anomaly = 1,
    /// Stateful (tag 2).
    Stateful = 2,
    /// Heuristic (tag 3).
    Heuristic = 3,
}

impl DetectionMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Signature),
            1 => Some(Self::Anomaly),
            2 => Some(Self::Stateful),
            3 => Some(Self::Heuristic),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DetectionMethod; 4] = [
        Self::Signature, Self::Anomaly, Self::Stateful, Self::Heuristic,
    ];
}

impl fmt::Display for DetectionMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IdsProtocol (tags 0-6)
// ===========================================================================

/// Monitored network protocols.
///
/// Matches `IdsProtocol` in `IdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IdsProtocol {
    /// TCP (tag 0).
    Tcp = 0,
    /// UDP (tag 1).
    Udp = 1,
    /// ICMP (tag 2).
    Icmp = 2,
    /// DNS (tag 3).
    Dns = 3,
    /// HTTP (tag 4).
    Http = 4,
    /// TLS (tag 5).
    Tls = 5,
    /// SSH (tag 6).
    Ssh = 6,
}

impl IdsProtocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Tcp),
            1 => Some(Self::Udp),
            2 => Some(Self::Icmp),
            3 => Some(Self::Dns),
            4 => Some(Self::Http),
            5 => Some(Self::Tls),
            6 => Some(Self::Ssh),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [IdsProtocol; 7] = [
        Self::Tcp, Self::Udp, Self::Icmp, Self::Dns, Self::Http, Self::Tls, Self::Ssh,
    ];
}

impl fmt::Display for IdsProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IdsAction (tags 0-4)
// ===========================================================================

/// IDS response actions.
///
/// Matches `IdsAction` in `IdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IdsAction {
    /// Alert (tag 0).
    Alert = 0,
    /// Drop (tag 1).
    Drop = 1,
    /// Log (tag 2).
    Log = 2,
    /// Block (tag 3).
    Block = 3,
    /// Pass (tag 4).
    Pass = 4,
}

impl IdsAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Alert),
            1 => Some(Self::Drop),
            2 => Some(Self::Log),
            3 => Some(Self::Block),
            4 => Some(Self::Pass),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [IdsAction; 5] = [
        Self::Alert, Self::Drop, Self::Log, Self::Block, Self::Pass,
    ];
}

impl fmt::Display for IdsAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Direction (tags 0-2)
// ===========================================================================

/// Traffic direction.
///
/// Matches `Direction` in `IdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Direction {
    /// Inbound (tag 0).
    Inbound = 0,
    /// Outbound (tag 1).
    Outbound = 1,
    /// Both (tag 2).
    Both = 2,
}

impl Direction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Inbound),
            1 => Some(Self::Outbound),
            2 => Some(Self::Both),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Direction; 3] = [
        Self::Inbound, Self::Outbound, Self::Both,
    ];
}

impl fmt::Display for Direction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ThreatLevel (tags 0-4)
// ===========================================================================

/// Threat assessment levels.
///
/// Matches `ThreatLevel` in `IdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ThreatLevel {
    /// Info (tag 0).
    Info = 0,
    /// Low (tag 1).
    Low = 1,
    /// Medium (tag 2).
    Medium = 2,
    /// High (tag 3).
    High = 3,
    /// Critical (tag 4).
    Critical = 4,
}

impl ThreatLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Info),
            1 => Some(Self::Low),
            2 => Some(Self::Medium),
            3 => Some(Self::High),
            4 => Some(Self::Critical),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ThreatLevel; 5] = [
        Self::Info, Self::Low, Self::Medium, Self::High, Self::Critical,
    ];
}

impl fmt::Display for ThreatLevel {
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
    fn alert_severity_roundtrip() {
        for v in AlertSeverity::ALL {
            let tag = v.to_tag();
            let decoded = AlertSeverity::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AlertSeverity::from_tag(4).is_none());
    }

    #[test]
    fn detection_method_roundtrip() {
        for v in DetectionMethod::ALL {
            let tag = v.to_tag();
            let decoded = DetectionMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DetectionMethod::from_tag(4).is_none());
    }

    #[test]
    fn ids_protocol_roundtrip() {
        for v in IdsProtocol::ALL {
            let tag = v.to_tag();
            let decoded = IdsProtocol::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(IdsProtocol::from_tag(7).is_none());
    }

    #[test]
    fn ids_action_roundtrip() {
        for v in IdsAction::ALL {
            let tag = v.to_tag();
            let decoded = IdsAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(IdsAction::from_tag(5).is_none());
    }

    #[test]
    fn direction_roundtrip() {
        for v in Direction::ALL {
            let tag = v.to_tag();
            let decoded = Direction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Direction::from_tag(3).is_none());
    }

    #[test]
    fn threat_level_roundtrip() {
        for v in ThreatLevel::ALL {
            let tag = v.to_tag();
            let decoded = ThreatLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ThreatLevel::from_tag(5).is_none());
    }

}
