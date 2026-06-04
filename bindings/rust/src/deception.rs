// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Deception Platform types for the proven-servers ABI.
//!
//! Formally verified cyber deception types.
//! Mirrors the Idris2 module `DeceptionABI.Types`.
//!
//! - `DecoyType` -- Deception decoy types.
//! - `TriggerEvent` -- Decoy trigger events.
//! - `AlertPriority` -- Deception alert priority.
//! - `DecoyState` -- Decoy lifecycle states.
//! - `ResponseAction` -- Deception response actions.
//! - `ServerState` -- Deception server states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// DecoyType (tags 0-5)
// ===========================================================================

/// Deception decoy types.
///
/// Matches `DecoyType` in `DeceptionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DecoyType {
    /// Service (tag 0).
    Service = 0,
    /// Credential (tag 1).
    Credential = 1,
    /// File (tag 2).
    File = 2,
    /// Network (tag 3).
    Network = 3,
    /// Token (tag 4).
    Token = 4,
    /// Breadcrumb (tag 5).
    Breadcrumb = 5,
}

impl DecoyType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Service),
            1 => Some(Self::Credential),
            2 => Some(Self::File),
            3 => Some(Self::Network),
            4 => Some(Self::Token),
            5 => Some(Self::Breadcrumb),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DecoyType; 6] = [
        Self::Service, Self::Credential, Self::File, Self::Network, Self::Token, Self::Breadcrumb,
    ];
}

impl fmt::Display for DecoyType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TriggerEvent (tags 0-5)
// ===========================================================================

/// Decoy trigger events.
///
/// Matches `TriggerEvent` in `DeceptionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TriggerEvent {
    /// Access (tag 0).
    Access = 0,
    /// Login (tag 1).
    Login = 1,
    /// Read (tag 2).
    Read = 2,
    /// Write (tag 3).
    Write = 3,
    /// Execute (tag 4).
    Execute = 4,
    /// Scan (tag 5).
    Scan = 5,
}

impl TriggerEvent {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Access),
            1 => Some(Self::Login),
            2 => Some(Self::Read),
            3 => Some(Self::Write),
            4 => Some(Self::Execute),
            5 => Some(Self::Scan),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TriggerEvent; 6] = [
        Self::Access, Self::Login, Self::Read, Self::Write, Self::Execute, Self::Scan,
    ];
}

impl fmt::Display for TriggerEvent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AlertPriority (tags 0-3)
// ===========================================================================

/// Deception alert priority.
///
/// Matches `AlertPriority` in `DeceptionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AlertPriority {
    /// Low (tag 0).
    Low = 0,
    /// Medium (tag 1).
    Medium = 1,
    /// High (tag 2).
    High = 2,
    /// Critical (tag 3).
    Critical = 3,
}

impl AlertPriority {
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
    pub const ALL: [AlertPriority; 4] = [
        Self::Low, Self::Medium, Self::High, Self::Critical,
    ];
}

impl fmt::Display for AlertPriority {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DecoyState (tags 0-3)
// ===========================================================================

/// Decoy lifecycle states.
///
/// Matches `DecoyState` in `DeceptionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DecoyState {
    /// Active (tag 0).
    Active = 0,
    /// Triggered (tag 1).
    Triggered = 1,
    /// Disabled (tag 2).
    Disabled = 2,
    /// Expired (tag 3).
    Expired = 3,
}

impl DecoyState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Active),
            1 => Some(Self::Triggered),
            2 => Some(Self::Disabled),
            3 => Some(Self::Expired),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DecoyState; 4] = [
        Self::Active, Self::Triggered, Self::Disabled, Self::Expired,
    ];
}

impl fmt::Display for DecoyState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResponseAction (tags 0-4)
// ===========================================================================

/// Deception response actions.
///
/// Matches `ResponseAction` in `DeceptionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponseAction {
    /// Alert (tag 0).
    Alert = 0,
    /// Redirect (tag 1).
    Redirect = 1,
    /// Delay (tag 2).
    Delay = 2,
    /// Fingerprint (tag 3).
    Fingerprint = 3,
    /// Isolate (tag 4).
    Isolate = 4,
}

impl ResponseAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Alert),
            1 => Some(Self::Redirect),
            2 => Some(Self::Delay),
            3 => Some(Self::Fingerprint),
            4 => Some(Self::Isolate),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResponseAction; 5] = [
        Self::Alert, Self::Redirect, Self::Delay, Self::Fingerprint, Self::Isolate,
    ];
}

impl fmt::Display for ResponseAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Deception server states.
///
/// Matches `ServerState` in `DeceptionABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Configured (tag 1).
    Configured = 1,
    /// Monitoring (tag 2).
    Monitoring = 2,
    /// Responding (tag 3).
    Responding = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Configured),
            2 => Some(Self::Monitoring),
            3 => Some(Self::Responding),
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
        Self::Idle, Self::Configured, Self::Monitoring, Self::Responding, Self::Shutdown,
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
    fn decoy_type_roundtrip() {
        for v in DecoyType::ALL {
            let tag = v.to_tag();
            let decoded = DecoyType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DecoyType::from_tag(6).is_none());
    }

    #[test]
    fn trigger_event_roundtrip() {
        for v in TriggerEvent::ALL {
            let tag = v.to_tag();
            let decoded = TriggerEvent::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TriggerEvent::from_tag(6).is_none());
    }

    #[test]
    fn alert_priority_roundtrip() {
        for v in AlertPriority::ALL {
            let tag = v.to_tag();
            let decoded = AlertPriority::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AlertPriority::from_tag(4).is_none());
    }

    #[test]
    fn decoy_state_roundtrip() {
        for v in DecoyState::ALL {
            let tag = v.to_tag();
            let decoded = DecoyState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DecoyState::from_tag(4).is_none());
    }

    #[test]
    fn response_action_roundtrip() {
        for v in ResponseAction::ALL {
            let tag = v.to_tag();
            let decoded = ResponseAction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResponseAction::from_tag(5).is_none());
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
