// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Data Diode types for the proven-servers ABI.
//!
//! Formally verified data diode (unidirectional network) types.
//! Mirrors the Idris2 module `DiodeABI.Types`.
//!
//! - `Direction` -- Diode data flow direction.
//! - `DiodeProtocol` -- Diode transfer protocols.
//! - `TransferState` -- Diode transfer states.
//! - `ValidationResult` -- Data validation results.
//! - `IntegrityCheck` -- Integrity verification methods.
//! - `GatewayState` -- Diode gateway states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Direction (tags 0-1)
// ===========================================================================

/// Diode data flow direction.
///
/// Matches `Direction` in `DiodeABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Direction {
    /// HighToLow (tag 0).
    HighToLow = 0,
    /// LowToHigh (tag 1).
    LowToHigh = 1,
}

impl Direction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::HighToLow),
            1 => Some(Self::LowToHigh),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Direction; 2] = [
        Self::HighToLow, Self::LowToHigh,
    ];
}

impl fmt::Display for Direction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DiodeProtocol (tags 0-4)
// ===========================================================================

/// Diode transfer protocols.
///
/// Matches `DiodeProtocol` in `DiodeABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DiodeProtocol {
    /// UDP (tag 0).
    Udp = 0,
    /// TCP (tag 1).
    Tcp = 1,
    /// FileTransfer (tag 2).
    FileTransfer = 2,
    /// Syslog (tag 3).
    Syslog = 3,
    /// SNMP (tag 4).
    Snmp = 4,
}

impl DiodeProtocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Udp),
            1 => Some(Self::Tcp),
            2 => Some(Self::FileTransfer),
            3 => Some(Self::Syslog),
            4 => Some(Self::Snmp),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DiodeProtocol; 5] = [
        Self::Udp, Self::Tcp, Self::FileTransfer, Self::Syslog, Self::Snmp,
    ];
}

impl fmt::Display for DiodeProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransferState (tags 0-4)
// ===========================================================================

/// Diode transfer states.
///
/// Matches `TransferState` in `DiodeABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferState {
    /// Queued (tag 0).
    Queued = 0,
    /// Sending (tag 1).
    Sending = 1,
    /// Confirming (tag 2).
    Confirming = 2,
    /// Complete (tag 3).
    Complete = 3,
    /// Failed (tag 4).
    Failed = 4,
}

impl TransferState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Queued),
            1 => Some(Self::Sending),
            2 => Some(Self::Confirming),
            3 => Some(Self::Complete),
            4 => Some(Self::Failed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TransferState; 5] = [
        Self::Queued, Self::Sending, Self::Confirming, Self::Complete, Self::Failed,
    ];
}

impl fmt::Display for TransferState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ValidationResult (tags 0-3)
// ===========================================================================

/// Data validation results.
///
/// Matches `ValidationResult` in `DiodeABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ValidationResult {
    /// Passed (tag 0).
    Passed = 0,
    /// FormatError (tag 1).
    FormatError = 1,
    /// SizeExceeded (tag 2).
    SizeExceeded = 2,
    /// PolicyBlocked (tag 3).
    PolicyBlocked = 3,
}

impl ValidationResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Passed),
            1 => Some(Self::FormatError),
            2 => Some(Self::SizeExceeded),
            3 => Some(Self::PolicyBlocked),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ValidationResult; 4] = [
        Self::Passed, Self::FormatError, Self::SizeExceeded, Self::PolicyBlocked,
    ];
}

impl fmt::Display for ValidationResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IntegrityCheck (tags 0-2)
// ===========================================================================

/// Integrity verification methods.
///
/// Matches `IntegrityCheck` in `DiodeABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IntegrityCheck {
    /// CRC-32 (tag 0).
    Crc32 = 0,
    /// SHA-256 (tag 1).
    Sha256 = 1,
    /// HMAC (tag 2).
    Hmac = 2,
}

impl IntegrityCheck {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Crc32),
            1 => Some(Self::Sha256),
            2 => Some(Self::Hmac),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [IntegrityCheck; 3] = [
        Self::Crc32, Self::Sha256, Self::Hmac,
    ];
}

impl fmt::Display for IntegrityCheck {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// GatewayState (tags 0-4)
// ===========================================================================

/// Diode gateway states.
///
/// Matches `GatewayState` in `DiodeABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum GatewayState {
    /// Idle (tag 0).
    Idle = 0,
    /// Configured (tag 1).
    Configured = 1,
    /// Transferring (tag 2).
    Transferring = 2,
    /// Validating (tag 3).
    Validating = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl GatewayState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Configured),
            2 => Some(Self::Transferring),
            3 => Some(Self::Validating),
            4 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [GatewayState; 5] = [
        Self::Idle, Self::Configured, Self::Transferring, Self::Validating, Self::Shutdown,
    ];
}

impl fmt::Display for GatewayState {
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
    fn direction_roundtrip() {
        for v in Direction::ALL {
            let tag = v.to_tag();
            let decoded = Direction::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Direction::from_tag(2).is_none());
    }

    #[test]
    fn diode_protocol_roundtrip() {
        for v in DiodeProtocol::ALL {
            let tag = v.to_tag();
            let decoded = DiodeProtocol::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DiodeProtocol::from_tag(5).is_none());
    }

    #[test]
    fn transfer_state_roundtrip() {
        for v in TransferState::ALL {
            let tag = v.to_tag();
            let decoded = TransferState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TransferState::from_tag(5).is_none());
    }

    #[test]
    fn validation_result_roundtrip() {
        for v in ValidationResult::ALL {
            let tag = v.to_tag();
            let decoded = ValidationResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ValidationResult::from_tag(4).is_none());
    }

    #[test]
    fn integrity_check_roundtrip() {
        for v in IntegrityCheck::ALL {
            let tag = v.to_tag();
            let decoded = IntegrityCheck::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(IntegrityCheck::from_tag(3).is_none());
    }

    #[test]
    fn gateway_state_roundtrip() {
        for v in GatewayState::ALL {
            let tag = v.to_tag();
            let decoded = GatewayState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(GatewayState::from_tag(5).is_none());
    }

}
