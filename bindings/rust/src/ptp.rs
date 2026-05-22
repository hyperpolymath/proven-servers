// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! PTP types for the proven-servers ABI.
//!
//! Formally verified PTP (Precision Time Protocol, IEEE 1588) types.
//! Mirrors the Idris2 module `PtpABI.Types`.
//!
//! - `PtpMessageType` -- PTP message types.
//! - `ClockClass` -- PTP clock classes.
//! - `PtpPortState` -- PTP port states (IEEE 1588).
//! - `DelayMechanism` -- PTP delay measurement mechanisms.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// PTP Constants
// ===========================================================================

/// PTP event port.
pub const PTP_EVENT_PORT: u16 = 319;

/// PTP general port.
pub const PTP_GENERAL_PORT: u16 = 320;

// ===========================================================================
// PtpMessageType (tags 0-9)
// ===========================================================================

/// PTP message types.
///
/// Matches `PtpMessageType` in `PtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PtpMessageType {
    /// Sync (tag 0).
    Sync = 0,
    /// DelayReq (tag 1).
    DelayReq = 1,
    /// PdelayReq (tag 2).
    PdelayReq = 2,
    /// PdelayResp (tag 3).
    PdelayResp = 3,
    /// FollowUp (tag 4).
    FollowUp = 4,
    /// DelayResp (tag 5).
    DelayResp = 5,
    /// PdelayRespFollowUp (tag 6).
    PdelayRespFollowUp = 6,
    /// Announce (tag 7).
    Announce = 7,
    /// Signaling (tag 8).
    Signaling = 8,
    /// Management (tag 9).
    Management = 9,
}

impl PtpMessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Sync),
            1 => Some(Self::DelayReq),
            2 => Some(Self::PdelayReq),
            3 => Some(Self::PdelayResp),
            4 => Some(Self::FollowUp),
            5 => Some(Self::DelayResp),
            6 => Some(Self::PdelayRespFollowUp),
            7 => Some(Self::Announce),
            8 => Some(Self::Signaling),
            9 => Some(Self::Management),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PtpMessageType; 10] = [
        Self::Sync, Self::DelayReq, Self::PdelayReq, Self::PdelayResp, Self::FollowUp, Self::DelayResp, Self::PdelayRespFollowUp, Self::Announce, Self::Signaling, Self::Management,
    ];
}

impl fmt::Display for PtpMessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ClockClass (tags 0-3)
// ===========================================================================

/// PTP clock classes.
///
/// Matches `ClockClass` in `PtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ClockClass {
    /// PrimaryClock (tag 0).
    PrimaryClock = 0,
    /// ApplicationSpecific (tag 1).
    ApplicationSpecific = 1,
    /// SlaveOnly (tag 2).
    SlaveOnly = 2,
    /// DefaultClass (tag 3).
    DefaultClass = 3,
}

impl ClockClass {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::PrimaryClock),
            1 => Some(Self::ApplicationSpecific),
            2 => Some(Self::SlaveOnly),
            3 => Some(Self::DefaultClass),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ClockClass; 4] = [
        Self::PrimaryClock, Self::ApplicationSpecific, Self::SlaveOnly, Self::DefaultClass,
    ];
}

impl fmt::Display for ClockClass {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PtpPortState (tags 0-8)
// ===========================================================================

/// PTP port states (IEEE 1588).
///
/// Matches `PtpPortState` in `PtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PtpPortState {
    /// Initializing (tag 0).
    Initializing = 0,
    /// Faulty (tag 1).
    Faulty = 1,
    /// Disabled (tag 2).
    Disabled = 2,
    /// Listening (tag 3).
    Listening = 3,
    /// PreMaster (tag 4).
    PreMaster = 4,
    /// Master (tag 5).
    Master = 5,
    /// Passive (tag 6).
    Passive = 6,
    /// Uncalibrated (tag 7).
    Uncalibrated = 7,
    /// Slave (tag 8).
    Slave = 8,
}

impl PtpPortState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initializing),
            1 => Some(Self::Faulty),
            2 => Some(Self::Disabled),
            3 => Some(Self::Listening),
            4 => Some(Self::PreMaster),
            5 => Some(Self::Master),
            6 => Some(Self::Passive),
            7 => Some(Self::Uncalibrated),
            8 => Some(Self::Slave),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PtpPortState; 9] = [
        Self::Initializing, Self::Faulty, Self::Disabled, Self::Listening, Self::PreMaster, Self::Master, Self::Passive, Self::Uncalibrated, Self::Slave,
    ];
}

impl fmt::Display for PtpPortState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DelayMechanism (tags 0-2)
// ===========================================================================

/// PTP delay measurement mechanisms.
///
/// Matches `DelayMechanism` in `PtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DelayMechanism {
    /// End-to-end (tag 0).
    E2E = 0,
    /// Peer-to-peer (tag 1).
    P2P = 1,
    /// Disabled (tag 2).
    DmDisabled = 2,
}

impl DelayMechanism {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::E2E),
            1 => Some(Self::P2P),
            2 => Some(Self::DmDisabled),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DelayMechanism; 3] = [
        Self::E2E, Self::P2P, Self::DmDisabled,
    ];
}

impl fmt::Display for DelayMechanism {
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
    fn ptp_message_type_roundtrip() {
        for v in PtpMessageType::ALL {
            let tag = v.to_tag();
            let decoded = PtpMessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PtpMessageType::from_tag(10).is_none());
    }

    #[test]
    fn clock_class_roundtrip() {
        for v in ClockClass::ALL {
            let tag = v.to_tag();
            let decoded = ClockClass::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ClockClass::from_tag(4).is_none());
    }

    #[test]
    fn ptp_port_state_roundtrip() {
        for v in PtpPortState::ALL {
            let tag = v.to_tag();
            let decoded = PtpPortState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PtpPortState::from_tag(9).is_none());
    }

    #[test]
    fn delay_mechanism_roundtrip() {
        for v in DelayMechanism::ALL {
            let tag = v.to_tag();
            let decoded = DelayMechanism::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DelayMechanism::from_tag(3).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(PTP_EVENT_PORT, 319);
        assert_eq!(PTP_GENERAL_PORT, 320);
    }

}
