// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! CalDAV types for the proven-servers ABI.
//!
//! Formally verified CalDAV types (RFC 4791).
//! Mirrors the Idris2 module `CaldavABI.Types`.
//!
//! - `ComponentType` -- iCalendar component types.
//! - `CalMethod` -- CalDAV methods.
//! - `ScheduleStatus` -- CalDAV scheduling statuses.
//! - `CalError` -- CalDAV error codes.
//! - `ServerState` -- CalDAV server lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// CalDAV Constants
// ===========================================================================

/// Standard CalDAV HTTPS port.
pub const CALDAV_PORT: u16 = 443;

// ===========================================================================
// ComponentType (tags 0-3)
// ===========================================================================

/// iCalendar component types.
///
/// Matches `ComponentType` in `CaldavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ComponentType {
    /// VEVENT (tag 0).
    Vevent = 0,
    /// VTODO (tag 1).
    Vtodo = 1,
    /// VJOURNAL (tag 2).
    Vjournal = 2,
    /// VFREEBUSY (tag 3).
    Vfreebusy = 3,
}

impl ComponentType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Vevent),
            1 => Some(Self::Vtodo),
            2 => Some(Self::Vjournal),
            3 => Some(Self::Vfreebusy),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ComponentType; 4] = [
        Self::Vevent, Self::Vtodo, Self::Vjournal, Self::Vfreebusy,
    ];
}

impl fmt::Display for ComponentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CalMethod (tags 0-6)
// ===========================================================================

/// CalDAV methods.
///
/// Matches `CalMethod` in `CaldavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CalMethod {
    /// Get (tag 0).
    Get = 0,
    /// Put (tag 1).
    Put = 1,
    /// Delete (tag 2).
    Delete = 2,
    /// PROPFIND (tag 3).
    Propfind = 3,
    /// PROPPATCH (tag 4).
    Proppatch = 4,
    /// REPORT (tag 5).
    Report = 5,
    /// MKCALENDAR (tag 6).
    Mkcalendar = 6,
}

impl CalMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Put),
            2 => Some(Self::Delete),
            3 => Some(Self::Propfind),
            4 => Some(Self::Proppatch),
            5 => Some(Self::Report),
            6 => Some(Self::Mkcalendar),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CalMethod; 7] = [
        Self::Get, Self::Put, Self::Delete, Self::Propfind, Self::Proppatch, Self::Report, Self::Mkcalendar,
    ];
}

impl fmt::Display for CalMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ScheduleStatus (tags 0-4)
// ===========================================================================

/// CalDAV scheduling statuses.
///
/// Matches `ScheduleStatus` in `CaldavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ScheduleStatus {
    /// NeedsAction (tag 0).
    NeedsAction = 0,
    /// Accepted (tag 1).
    Accepted = 1,
    /// Declined (tag 2).
    Declined = 2,
    /// Tentative (tag 3).
    Tentative = 3,
    /// Delegated (tag 4).
    Delegated = 4,
}

impl ScheduleStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NeedsAction),
            1 => Some(Self::Accepted),
            2 => Some(Self::Declined),
            3 => Some(Self::Tentative),
            4 => Some(Self::Delegated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ScheduleStatus; 5] = [
        Self::NeedsAction, Self::Accepted, Self::Declined, Self::Tentative, Self::Delegated,
    ];
}

impl fmt::Display for ScheduleStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CalError (tags 0-5)
// ===========================================================================

/// CalDAV error codes.
///
/// Matches `CalError` in `CaldavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CalError {
    /// ValidCalendarData (tag 0).
    ValidCalendarData = 0,
    /// NoResourceTypeChange (tag 1).
    NoResourceTypeChange = 1,
    /// SupportedComponentMismatch (tag 2).
    SupportedComponentMismatch = 2,
    /// MaxResourceSize (tag 3).
    MaxResourceSize = 3,
    /// UidConflict (tag 4).
    UidConflict = 4,
    /// PreconditionFailed (tag 5).
    PreconditionFailed = 5,
}

impl CalError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ValidCalendarData),
            1 => Some(Self::NoResourceTypeChange),
            2 => Some(Self::SupportedComponentMismatch),
            3 => Some(Self::MaxResourceSize),
            4 => Some(Self::UidConflict),
            5 => Some(Self::PreconditionFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CalError; 6] = [
        Self::ValidCalendarData, Self::NoResourceTypeChange, Self::SupportedComponentMismatch, Self::MaxResourceSize, Self::UidConflict, Self::PreconditionFailed,
    ];
}

impl fmt::Display for CalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// CalDAV server lifecycle states.
///
/// Matches `ServerState` in `CaldavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Bound (tag 1).
    Bound = 1,
    /// Serving (tag 2).
    Serving = 2,
    /// Scheduling (tag 3).
    Scheduling = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Bound),
            2 => Some(Self::Serving),
            3 => Some(Self::Scheduling),
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
        Self::Idle, Self::Bound, Self::Serving, Self::Scheduling, Self::Shutdown,
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
    fn component_type_roundtrip() {
        for v in ComponentType::ALL {
            let tag = v.to_tag();
            let decoded = ComponentType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ComponentType::from_tag(4).is_none());
    }

    #[test]
    fn cal_method_roundtrip() {
        for v in CalMethod::ALL {
            let tag = v.to_tag();
            let decoded = CalMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CalMethod::from_tag(7).is_none());
    }

    #[test]
    fn schedule_status_roundtrip() {
        for v in ScheduleStatus::ALL {
            let tag = v.to_tag();
            let decoded = ScheduleStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ScheduleStatus::from_tag(5).is_none());
    }

    #[test]
    fn cal_error_roundtrip() {
        for v in CalError::ALL {
            let tag = v.to_tag();
            let decoded = CalError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CalError::from_tag(6).is_none());
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

    #[test]
    fn constants_match_idris() {
        assert_eq!(CALDAV_PORT, 443);
    }

}
