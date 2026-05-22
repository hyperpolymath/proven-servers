// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! SIEM types for the proven-servers ABI.
//!
//! Formally verified SIEM (Security Information and Event Management) types.
//! Mirrors the Idris2 module `SiemABI.Types`.
//!
//! - `EventSeverity` -- Security event severity.
//! - `EventCategory` -- Security event categories.
//! - `CorrelationRule` -- Event correlation rule types.
//! - `AlertState` -- SIEM alert states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// EventSeverity (tags 0-4)
// ===========================================================================

/// Security event severity.
///
/// Matches `EventSeverity` in `SiemABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EventSeverity {
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

impl EventSeverity {
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
    pub const ALL: [EventSeverity; 5] = [
        Self::Info, Self::Low, Self::Medium, Self::High, Self::Critical,
    ];
}

impl fmt::Display for EventSeverity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EventCategory (tags 0-6)
// ===========================================================================

/// Security event categories.
///
/// Matches `EventCategory` in `SiemABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EventCategory {
    /// Authentication (tag 0).
    Authentication = 0,
    /// NetworkTraffic (tag 1).
    NetworkTraffic = 1,
    /// FileActivity (tag 2).
    FileActivity = 2,
    /// ProcessExecution (tag 3).
    ProcessExecution = 3,
    /// PolicyViolation (tag 4).
    PolicyViolation = 4,
    /// Malware (tag 5).
    Malware = 5,
    /// DataExfiltration (tag 6).
    DataExfiltration = 6,
}

impl EventCategory {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Authentication),
            1 => Some(Self::NetworkTraffic),
            2 => Some(Self::FileActivity),
            3 => Some(Self::ProcessExecution),
            4 => Some(Self::PolicyViolation),
            5 => Some(Self::Malware),
            6 => Some(Self::DataExfiltration),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [EventCategory; 7] = [
        Self::Authentication, Self::NetworkTraffic, Self::FileActivity, Self::ProcessExecution, Self::PolicyViolation, Self::Malware, Self::DataExfiltration,
    ];
}

impl fmt::Display for EventCategory {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CorrelationRule (tags 0-4)
// ===========================================================================

/// Event correlation rule types.
///
/// Matches `CorrelationRule` in `SiemABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CorrelationRule {
    /// Threshold (tag 0).
    Threshold = 0,
    /// Sequence (tag 1).
    Sequence = 1,
    /// Aggregation (tag 2).
    Aggregation = 2,
    /// Absence (tag 3).
    Absence = 3,
    /// Statistical (tag 4).
    Statistical = 4,
}

impl CorrelationRule {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Threshold),
            1 => Some(Self::Sequence),
            2 => Some(Self::Aggregation),
            3 => Some(Self::Absence),
            4 => Some(Self::Statistical),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CorrelationRule; 5] = [
        Self::Threshold, Self::Sequence, Self::Aggregation, Self::Absence, Self::Statistical,
    ];
}

impl fmt::Display for CorrelationRule {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AlertState (tags 0-4)
// ===========================================================================

/// SIEM alert states.
///
/// Matches `AlertState` in `SiemABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AlertState {
    /// New (tag 0).
    New = 0,
    /// Acknowledged (tag 1).
    Acknowledged = 1,
    /// InProgress (tag 2).
    InProgress = 2,
    /// Resolved (tag 3).
    Resolved = 3,
    /// FalsePositive (tag 4).
    FalsePositive = 4,
}

impl AlertState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::New),
            1 => Some(Self::Acknowledged),
            2 => Some(Self::InProgress),
            3 => Some(Self::Resolved),
            4 => Some(Self::FalsePositive),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AlertState; 5] = [
        Self::New, Self::Acknowledged, Self::InProgress, Self::Resolved, Self::FalsePositive,
    ];
}

impl fmt::Display for AlertState {
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
    fn event_severity_roundtrip() {
        for v in EventSeverity::ALL {
            let tag = v.to_tag();
            let decoded = EventSeverity::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(EventSeverity::from_tag(5).is_none());
    }

    #[test]
    fn event_category_roundtrip() {
        for v in EventCategory::ALL {
            let tag = v.to_tag();
            let decoded = EventCategory::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(EventCategory::from_tag(7).is_none());
    }

    #[test]
    fn correlation_rule_roundtrip() {
        for v in CorrelationRule::ALL {
            let tag = v.to_tag();
            let decoded = CorrelationRule::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CorrelationRule::from_tag(5).is_none());
    }

    #[test]
    fn alert_state_roundtrip() {
        for v in AlertState::ALL {
            let tag = v.to_tag();
            let decoded = AlertState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AlertState::from_tag(5).is_none());
    }

}
