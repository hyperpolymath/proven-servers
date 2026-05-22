// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! NTP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `NtpABI.Types` and its type definitions:
//! - `LeapIndicator`       — leap second indicator (4 constructors, tags 0-3)
//! - `NtpMode`             — NTP association modes (8 constructors, tags 0-7)
//! - `ExchangeState`       — NTP request/response state machine (4 constructors, tags 0-3)
//! - `ClockDisciplineState` — clock discipline algorithm states (5 constructors, tags 0-4)
//! - `KissCode`            — Kiss-o'-Death codes (4 constructors, tags 0-3)
//! - `NtpError`            — NTP error codes (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// NTP Constants
// ===========================================================================

/// Standard NTP port (RFC 5905).
pub const NTP_PORT: u16 = 123;

/// NTP epoch: 1 January 1900.
/// Offset from Unix epoch (1 January 1970) in seconds.
pub const NTP_EPOCH_OFFSET: u64 = 2_208_988_800;

// ===========================================================================
// LeapIndicator (tags 0-3)
// ===========================================================================

/// NTP leap second indicator (RFC 5905 Section 7.3).
///
/// Matches `LeapIndicator` in `NtpABI.Types`.
/// Uses the NTP wire values (LI field, 2 bits).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LeapIndicator {
    /// No warning (tag 0).
    NoWarning = 0,
    /// Last minute of the day has 61 seconds (positive leap second) (tag 1).
    LastMinute61 = 1,
    /// Last minute of the day has 59 seconds (negative leap second) (tag 2).
    LastMinute59 = 2,
    /// Clock not synchronised (alarm condition) (tag 3).
    Unsynchronised = 3,
}

impl LeapIndicator {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoWarning),
            1 => Some(Self::LastMinute61),
            2 => Some(Self::LastMinute59),
            3 => Some(Self::Unsynchronised),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the clock is considered synchronised.
    pub fn is_synchronised(self) -> bool {
        !matches!(self, Self::Unsynchronised)
    }

    /// Whether a leap second adjustment is pending.
    pub fn has_leap_second(self) -> bool {
        matches!(self, Self::LastMinute61 | Self::LastMinute59)
    }
}

impl fmt::Display for LeapIndicator {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NtpMode (tags 0-7)
// ===========================================================================

/// NTP association mode (RFC 5905 Section 7.3, Mode field).
///
/// Matches `NTPMode` in `NtpABI.Types`.
/// Uses the 3-bit NTP mode values from the wire protocol.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NtpMode {
    /// Reserved (tag 0).
    Reserved = 0,
    /// Symmetric active (tag 1).
    SymmetricActive = 1,
    /// Symmetric passive (tag 2).
    SymmetricPassive = 2,
    /// Client (tag 3).
    Client = 3,
    /// Server (tag 4).
    Server = 4,
    /// Broadcast (tag 5).
    Broadcast = 5,
    /// NTP control message (tag 6).
    ControlMessage = 6,
    /// Reserved for private use (tag 7).
    Private = 7,
}

impl NtpMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Reserved),
            1 => Some(Self::SymmetricActive),
            2 => Some(Self::SymmetricPassive),
            3 => Some(Self::Client),
            4 => Some(Self::Server),
            5 => Some(Self::Broadcast),
            6 => Some(Self::ControlMessage),
            7 => Some(Self::Private),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this mode is used for time synchronisation
    /// (as opposed to control or reserved).
    pub fn is_time_sync(self) -> bool {
        matches!(
            self,
            Self::SymmetricActive
                | Self::SymmetricPassive
                | Self::Client
                | Self::Server
                | Self::Broadcast
        )
    }

    /// All supported modes.
    pub const ALL: [NtpMode; 8] = [
        Self::Reserved,
        Self::SymmetricActive,
        Self::SymmetricPassive,
        Self::Client,
        Self::Server,
        Self::Broadcast,
        Self::ControlMessage,
        Self::Private,
    ];
}

impl fmt::Display for NtpMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ExchangeState (tags 0-3)
// ===========================================================================

/// NTP request/response exchange state machine.
///
/// Matches `ExchangeState` in `NtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ExchangeState {
    /// Idle, awaiting next request (tag 0).
    Idle = 0,
    /// Client request received (tag 1).
    RequestReceived = 1,
    /// Timestamps calculated for response (tag 2).
    TimestampCalculated = 2,
    /// Response sent to client (tag 3).
    ResponseSent = 3,
}

impl ExchangeState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::RequestReceived),
            2 => Some(Self::TimestampCalculated),
            3 => Some(Self::ResponseSent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: ExchangeState) -> bool {
        matches!(
            (self, next),
            (Self::Idle, Self::RequestReceived)
                | (Self::RequestReceived, Self::TimestampCalculated)
                | (Self::TimestampCalculated, Self::ResponseSent)
                | (Self::ResponseSent, Self::Idle) // Ready for next exchange
        )
    }
}

impl fmt::Display for ExchangeState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ClockDisciplineState (tags 0-4)
// ===========================================================================

/// Clock discipline algorithm states (RFC 5905 Section 12).
///
/// Matches `ClockDisciplineState` in `NtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ClockDisciplineState {
    /// Clock has not been set (tag 0).
    Unset = 0,
    /// Detected a clock spike (large offset) (tag 1).
    Spike = 1,
    /// Frequency-only discipline mode (tag 2).
    Freq = 2,
    /// Fully synchronised (phase + frequency locked) (tag 3).
    Sync = 3,
    /// Panic condition — offset too large to correct (tag 4).
    Panic = 4,
}

impl ClockDisciplineState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unset),
            1 => Some(Self::Spike),
            2 => Some(Self::Freq),
            3 => Some(Self::Sync),
            4 => Some(Self::Panic),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the clock is in a healthy state.
    pub fn is_healthy(self) -> bool {
        matches!(self, Self::Freq | Self::Sync)
    }

    /// Whether the clock requires operator intervention.
    pub fn needs_intervention(self) -> bool {
        matches!(self, Self::Panic)
    }
}

impl fmt::Display for ClockDisciplineState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KissCode (tags 0-3)
// ===========================================================================

/// NTP Kiss-o'-Death codes (RFC 5905 Section 7.4).
///
/// Matches `KissCode` in `NtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KissCode {
    /// Access denied (DENY) (tag 0).
    Deny = 0,
    /// Access restricted (RSTR) (tag 1).
    Rstr = 1,
    /// Rate exceeded (RATE) (tag 2).
    Rate = 2,
    /// Other/unknown kiss code (tag 3).
    Other = 3,
}

impl KissCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Deny),
            1 => Some(Self::Rstr),
            2 => Some(Self::Rate),
            3 => Some(Self::Other),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The 4-character ASCII kiss code string.
    pub fn code_str(self) -> &'static str {
        match self {
            Self::Deny => "DENY",
            Self::Rstr => "RSTR",
            Self::Rate => "RATE",
            Self::Other => "????",
        }
    }

    /// Whether the client should stop querying this server.
    pub fn should_stop(self) -> bool {
        matches!(self, Self::Deny | Self::Rstr)
    }
}

impl fmt::Display for KissCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.code_str())
    }
}

// ===========================================================================
// NtpError (tags 0-5)
// ===========================================================================

/// NTP error codes.
///
/// Matches `NtpError` in `NtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NtpError {
    /// No error (tag 0).
    Ok = 0,
    /// Invalid peer slot reference (tag 1).
    InvalidSlot = 1,
    /// Peer association not active (tag 2).
    NotActive = 2,
    /// Malformed NTP packet (tag 3).
    InvalidPacket = 3,
    /// Received Kiss-o'-Death from server (tag 4).
    KissOfDeath = 4,
    /// Server stratum exceeds maximum (tag 5).
    StratumTooHigh = 5,
}

impl NtpError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::InvalidSlot),
            2 => Some(Self::NotActive),
            3 => Some(Self::InvalidPacket),
            4 => Some(Self::KissOfDeath),
            5 => Some(Self::StratumTooHigh),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this represents a successful outcome.
    pub fn is_ok(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// Whether this error indicates a problem with the remote server.
    pub fn is_remote_error(self) -> bool {
        matches!(self, Self::KissOfDeath | Self::StratumTooHigh)
    }
}

impl fmt::Display for NtpError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for NtpError {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn leap_indicator_roundtrip() {
        for tag in 0u8..=3 {
            let li = LeapIndicator::from_tag(tag).expect("valid tag");
            assert_eq!(li.to_tag(), tag);
        }
        assert!(LeapIndicator::from_tag(4).is_none());
    }

    #[test]
    fn leap_indicator_sync() {
        assert!(LeapIndicator::NoWarning.is_synchronised());
        assert!(LeapIndicator::LastMinute61.is_synchronised());
        assert!(!LeapIndicator::Unsynchronised.is_synchronised());
    }

    #[test]
    fn leap_indicator_leap() {
        assert!(!LeapIndicator::NoWarning.has_leap_second());
        assert!(LeapIndicator::LastMinute61.has_leap_second());
        assert!(LeapIndicator::LastMinute59.has_leap_second());
        assert!(!LeapIndicator::Unsynchronised.has_leap_second());
    }

    #[test]
    fn ntp_mode_roundtrip() {
        for mode in NtpMode::ALL {
            let tag = mode.to_tag();
            let decoded = NtpMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, mode);
        }
        assert!(NtpMode::from_tag(8).is_none());
    }

    #[test]
    fn ntp_mode_time_sync() {
        assert!(NtpMode::Client.is_time_sync());
        assert!(NtpMode::Server.is_time_sync());
        assert!(NtpMode::Broadcast.is_time_sync());
        assert!(!NtpMode::Reserved.is_time_sync());
        assert!(!NtpMode::ControlMessage.is_time_sync());
        assert!(!NtpMode::Private.is_time_sync());
    }

    #[test]
    fn exchange_state_roundtrip() {
        for tag in 0u8..=3 {
            let es = ExchangeState::from_tag(tag).expect("valid tag");
            assert_eq!(es.to_tag(), tag);
        }
        assert!(ExchangeState::from_tag(4).is_none());
    }

    #[test]
    fn exchange_state_transitions() {
        assert!(ExchangeState::Idle.can_transition_to(ExchangeState::RequestReceived));
        assert!(ExchangeState::RequestReceived.can_transition_to(ExchangeState::TimestampCalculated));
        assert!(ExchangeState::TimestampCalculated.can_transition_to(ExchangeState::ResponseSent));
        assert!(ExchangeState::ResponseSent.can_transition_to(ExchangeState::Idle));
        assert!(!ExchangeState::Idle.can_transition_to(ExchangeState::ResponseSent));
    }

    #[test]
    fn clock_discipline_roundtrip() {
        for tag in 0u8..=4 {
            let cd = ClockDisciplineState::from_tag(tag).expect("valid tag");
            assert_eq!(cd.to_tag(), tag);
        }
        assert!(ClockDisciplineState::from_tag(5).is_none());
    }

    #[test]
    fn clock_discipline_health() {
        assert!(!ClockDisciplineState::Unset.is_healthy());
        assert!(!ClockDisciplineState::Spike.is_healthy());
        assert!(ClockDisciplineState::Freq.is_healthy());
        assert!(ClockDisciplineState::Sync.is_healthy());
        assert!(!ClockDisciplineState::Panic.is_healthy());
        assert!(ClockDisciplineState::Panic.needs_intervention());
        assert!(!ClockDisciplineState::Sync.needs_intervention());
    }

    #[test]
    fn kiss_code_roundtrip() {
        for tag in 0u8..=3 {
            let kc = KissCode::from_tag(tag).expect("valid tag");
            assert_eq!(kc.to_tag(), tag);
        }
        assert!(KissCode::from_tag(4).is_none());
    }

    #[test]
    fn kiss_code_stop() {
        assert!(KissCode::Deny.should_stop());
        assert!(KissCode::Rstr.should_stop());
        assert!(!KissCode::Rate.should_stop());
        assert!(!KissCode::Other.should_stop());
    }

    #[test]
    fn ntp_error_roundtrip() {
        for tag in 0u8..=5 {
            let ne = NtpError::from_tag(tag).expect("valid tag");
            assert_eq!(ne.to_tag(), tag);
        }
        assert!(NtpError::from_tag(6).is_none());
    }

    #[test]
    fn ntp_error_classification() {
        assert!(NtpError::Ok.is_ok());
        assert!(!NtpError::InvalidPacket.is_ok());
        assert!(NtpError::KissOfDeath.is_remote_error());
        assert!(NtpError::StratumTooHigh.is_remote_error());
        assert!(!NtpError::InvalidSlot.is_remote_error());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(NTP_PORT, 123);
        assert_eq!(NTP_EPOCH_OFFSET, 2_208_988_800);
    }
}
