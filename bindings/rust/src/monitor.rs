// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Monitor types for the proven-servers ABI.
//!
//! Formally verified monitoring/uptime types.
//! Mirrors the Idris2 module `MonitorABI.Types`.
//!
//! - `CheckType` -- Monitor check types.
//! - `Status` -- Monitor status values.
//! - `AlertChannel` -- Alert notification channels.
//! - `Severity` -- Monitor severity levels.
//! - `CheckState` -- Monitor check execution states.
//! - `MonitorState` -- Monitor service states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// CheckType (tags 0-10)
// ===========================================================================

/// Monitor check types.
///
/// Matches `CheckType` in `MonitorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CheckType {
    /// HTTP (tag 0).
    Http = 0,
    /// TCP (tag 1).
    Tcp = 1,
    /// UDP (tag 2).
    Udp = 2,
    /// ICMP (tag 3).
    Icmp = 3,
    /// DNS (tag 4).
    Dns = 4,
    /// Certificate (tag 5).
    Certificate = 5,
    /// Disk (tag 6).
    Disk = 6,
    /// CPU (tag 7).
    Cpu = 7,
    /// Memory (tag 8).
    Memory = 8,
    /// Process (tag 9).
    Process = 9,
    /// Custom (tag 10).
    Custom = 10,
}

impl CheckType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Http),
            1 => Some(Self::Tcp),
            2 => Some(Self::Udp),
            3 => Some(Self::Icmp),
            4 => Some(Self::Dns),
            5 => Some(Self::Certificate),
            6 => Some(Self::Disk),
            7 => Some(Self::Cpu),
            8 => Some(Self::Memory),
            9 => Some(Self::Process),
            10 => Some(Self::Custom),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CheckType; 11] = [
        Self::Http, Self::Tcp, Self::Udp, Self::Icmp, Self::Dns, Self::Certificate, Self::Disk, Self::Cpu, Self::Memory, Self::Process, Self::Custom,
    ];
}

impl fmt::Display for CheckType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Status (tags 0-4)
// ===========================================================================

/// Monitor status values.
///
/// Matches `Status` in `MonitorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Status {
    /// Up (tag 0).
    Up = 0,
    /// Down (tag 1).
    Down = 1,
    /// Degraded (tag 2).
    Degraded = 2,
    /// Unknown (tag 3).
    Unknown = 3,
    /// Maintenance (tag 4).
    Maintenance = 4,
}

impl Status {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Up),
            1 => Some(Self::Down),
            2 => Some(Self::Degraded),
            3 => Some(Self::Unknown),
            4 => Some(Self::Maintenance),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Status; 5] = [
        Self::Up, Self::Down, Self::Degraded, Self::Unknown, Self::Maintenance,
    ];
}

impl fmt::Display for Status {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AlertChannel (tags 0-4)
// ===========================================================================

/// Alert notification channels.
///
/// Matches `AlertChannel` in `MonitorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AlertChannel {
    /// Email (tag 0).
    Email = 0,
    /// SMS (tag 1).
    Sms = 1,
    /// Webhook (tag 2).
    Webhook = 2,
    /// Slack (tag 3).
    Slack = 3,
    /// PagerDuty (tag 4).
    PagerDuty = 4,
}

impl AlertChannel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Email),
            1 => Some(Self::Sms),
            2 => Some(Self::Webhook),
            3 => Some(Self::Slack),
            4 => Some(Self::PagerDuty),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AlertChannel; 5] = [
        Self::Email, Self::Sms, Self::Webhook, Self::Slack, Self::PagerDuty,
    ];
}

impl fmt::Display for AlertChannel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Severity (tags 0-3)
// ===========================================================================

/// Monitor severity levels.
///
/// Matches `Severity` in `MonitorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Severity {
    /// Info (tag 0).
    Info = 0,
    /// Warning (tag 1).
    Warning = 1,
    /// Error (tag 2).
    Error = 2,
    /// Critical (tag 3).
    Critical = 3,
}

impl Severity {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Info),
            1 => Some(Self::Warning),
            2 => Some(Self::Error),
            3 => Some(Self::Critical),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Severity; 4] = [
        Self::Info, Self::Warning, Self::Error, Self::Critical,
    ];
}

impl fmt::Display for Severity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CheckState (tags 0-5)
// ===========================================================================

/// Monitor check execution states.
///
/// Matches `CheckState` in `MonitorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CheckState {
    /// Pending (tag 0).
    Pending = 0,
    /// Running (tag 1).
    Running = 1,
    /// Passed (tag 2).
    Passed = 2,
    /// Failed (tag 3).
    Failed = 3,
    /// Timeout (tag 4).
    Timeout = 4,
    /// Error (tag 5).
    CsError = 5,
}

impl CheckState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pending),
            1 => Some(Self::Running),
            2 => Some(Self::Passed),
            3 => Some(Self::Failed),
            4 => Some(Self::Timeout),
            5 => Some(Self::CsError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CheckState; 6] = [
        Self::Pending, Self::Running, Self::Passed, Self::Failed, Self::Timeout, Self::CsError,
    ];
}

impl fmt::Display for CheckState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MonitorState (tags 0-5)
// ===========================================================================

/// Monitor service states.
///
/// Matches `MonitorState` in `MonitorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MonitorState {
    /// Idle (tag 0).
    Idle = 0,
    /// Configured (tag 1).
    Configured = 1,
    /// Running (tag 2).
    Running = 2,
    /// Paused (tag 3).
    MonPaused = 3,
    /// Alerting (tag 4).
    Alerting = 4,
    /// Shutdown (tag 5).
    Shutdown = 5,
}

impl MonitorState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Configured),
            2 => Some(Self::Running),
            3 => Some(Self::MonPaused),
            4 => Some(Self::Alerting),
            5 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MonitorState; 6] = [
        Self::Idle, Self::Configured, Self::Running, Self::MonPaused, Self::Alerting, Self::Shutdown,
    ];
}

impl fmt::Display for MonitorState {
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
    fn check_type_roundtrip() {
        for v in CheckType::ALL {
            let tag = v.to_tag();
            let decoded = CheckType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CheckType::from_tag(11).is_none());
    }

    #[test]
    fn status_roundtrip() {
        for v in Status::ALL {
            let tag = v.to_tag();
            let decoded = Status::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Status::from_tag(5).is_none());
    }

    #[test]
    fn alert_channel_roundtrip() {
        for v in AlertChannel::ALL {
            let tag = v.to_tag();
            let decoded = AlertChannel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AlertChannel::from_tag(5).is_none());
    }

    #[test]
    fn severity_roundtrip() {
        for v in Severity::ALL {
            let tag = v.to_tag();
            let decoded = Severity::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Severity::from_tag(4).is_none());
    }

    #[test]
    fn check_state_roundtrip() {
        for v in CheckState::ALL {
            let tag = v.to_tag();
            let decoded = CheckState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CheckState::from_tag(6).is_none());
    }

    #[test]
    fn monitor_state_roundtrip() {
        for v in MonitorState::ALL {
            let tag = v.to_tag();
            let decoded = MonitorState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MonitorState::from_tag(6).is_none());
    }

}
