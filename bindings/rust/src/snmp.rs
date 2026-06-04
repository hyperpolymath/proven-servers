// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! SNMP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `SNMPABI.Types` and its type definitions:
//! - `Version`     — SNMP protocol versions (3 constructors, tags 0-2)
//! - `PduType`     — SNMP PDU types (7 constructors, tags 0-6)
//! - `ErrorStatus` — SNMP error status codes (16 constructors, tags 0-15)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SNMP Constants
// ===========================================================================

/// Standard SNMP agent port (RFC 3411).
pub const SNMP_PORT: u16 = 161;

/// Standard SNMP trap port (RFC 3411).
pub const SNMP_TRAP_PORT: u16 = 162;

// ===========================================================================
// Version (tags 0-2)
// ===========================================================================

/// SNMP protocol versions.
///
/// Matches `Version` in `SNMPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum Version {
    /// SNMPv1 (RFC 1157) (tag 0).
    V1 = 0,
    /// SNMPv2c — community-based SNMPv2 (RFC 3584) (tag 1).
    V2c = 1,
    /// SNMPv3 — user-based security model (RFC 3414) (tag 2).
    V3 = 2,
}

impl Version {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::V1),
            1 => Some(Self::V2c),
            2 => Some(Self::V3),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this version supports the User-based Security Model (USM).
    pub fn has_usm(self) -> bool {
        matches!(self, Self::V3)
    }

    /// Whether this version uses community strings for authentication.
    pub fn uses_community_strings(self) -> bool {
        matches!(self, Self::V1 | Self::V2c)
    }

    /// Whether this version supports GetBulkRequest.
    pub fn supports_get_bulk(self) -> bool {
        !matches!(self, Self::V1)
    }
}

impl fmt::Display for Version {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::V1 => "SNMPv1",
            Self::V2c => "SNMPv2c",
            Self::V3 => "SNMPv3",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// PduType (tags 0-6)
// ===========================================================================

/// SNMP PDU (Protocol Data Unit) types.
///
/// Matches `PDUType` in `SNMPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PduType {
    /// Get value of specific OIDs (tag 0).
    GetRequest = 0,
    /// Get next OID in MIB tree (tag 1).
    GetNextRequest = 1,
    /// Response to a request (tag 2).
    GetResponse = 2,
    /// Set value of specific OIDs (tag 3).
    SetRequest = 3,
    /// Bulk retrieval — SNMPv2c/v3 only (tag 4).
    GetBulkRequest = 4,
    /// Manager-to-manager notification (tag 5).
    InformRequest = 5,
    /// SNMPv2 trap notification (tag 6).
    SnmpV2Trap = 6,
}

impl PduType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::GetRequest),
            1 => Some(Self::GetNextRequest),
            2 => Some(Self::GetResponse),
            3 => Some(Self::SetRequest),
            4 => Some(Self::GetBulkRequest),
            5 => Some(Self::InformRequest),
            6 => Some(Self::SnmpV2Trap),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this PDU is a request from manager to agent.
    pub fn is_request(self) -> bool {
        matches!(
            self,
            Self::GetRequest
                | Self::GetNextRequest
                | Self::SetRequest
                | Self::GetBulkRequest
        )
    }

    /// Whether this PDU is a notification (trap or inform).
    pub fn is_notification(self) -> bool {
        matches!(self, Self::InformRequest | Self::SnmpV2Trap)
    }

    /// Whether this PDU modifies agent state.
    pub fn is_write(self) -> bool {
        matches!(self, Self::SetRequest)
    }

    /// The minimum SNMP version required for this PDU type.
    pub fn min_version(self) -> Version {
        match self {
            Self::GetBulkRequest | Self::InformRequest | Self::SnmpV2Trap => Version::V2c,
            _ => Version::V1,
        }
    }

    /// All supported PDU types.
    pub const ALL: [PduType; 7] = [
        Self::GetRequest, Self::GetNextRequest, Self::GetResponse,
        Self::SetRequest, Self::GetBulkRequest, Self::InformRequest,
        Self::SnmpV2Trap,
    ];
}

impl fmt::Display for PduType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorStatus (tags 0-15)
// ===========================================================================

/// SNMP error status codes.
///
/// Matches `ErrorStatus` in `SNMPABI.Types`.
/// Includes both SNMPv1 errors (0-5) and SNMPv2c/v3 extensions (6-15).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorStatus {
    /// No error occurred (tag 0).
    NoError = 0,
    /// Response too large for transport (tag 1).
    TooBig = 1,
    /// OID not found — SNMPv1 (tag 2).
    NoSuchName = 2,
    /// Invalid value in set request — SNMPv1 (tag 3).
    BadValue = 3,
    /// Object is read-only — SNMPv1 (tag 4).
    ReadOnly = 4,
    /// Generic error (tag 5).
    GenErr = 5,
    /// No access to the object (tag 6).
    NoAccess = 6,
    /// Wrong ASN.1 type for the object (tag 7).
    WrongType = 7,
    /// Wrong value length (tag 8).
    WrongLength = 8,
    /// Wrong encoding of value (tag 9).
    WrongValue = 9,
    /// Object cannot be created (tag 10).
    NoCreation = 10,
    /// Value inconsistent with other managed objects (tag 11).
    InconsistentValue = 11,
    /// Required resource is unavailable (tag 12).
    ResourceUnavailable = 12,
    /// Set operation commit failed (tag 13).
    CommitFailed = 13,
    /// Set operation undo failed (tag 14).
    UndoFailed = 14,
    /// Authorization error (tag 15).
    AuthorizationError = 15,
}

impl ErrorStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoError),
            1 => Some(Self::TooBig),
            2 => Some(Self::NoSuchName),
            3 => Some(Self::BadValue),
            4 => Some(Self::ReadOnly),
            5 => Some(Self::GenErr),
            6 => Some(Self::NoAccess),
            7 => Some(Self::WrongType),
            8 => Some(Self::WrongLength),
            9 => Some(Self::WrongValue),
            10 => Some(Self::NoCreation),
            11 => Some(Self::InconsistentValue),
            12 => Some(Self::ResourceUnavailable),
            13 => Some(Self::CommitFailed),
            14 => Some(Self::UndoFailed),
            15 => Some(Self::AuthorizationError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this status indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::NoError)
    }

    /// Whether this is an SNMPv1-only error code.
    pub fn is_v1_only(self) -> bool {
        matches!(self, Self::NoSuchName | Self::BadValue | Self::ReadOnly)
    }

    /// Whether this error relates to authorisation/access control.
    pub fn is_auth_error(self) -> bool {
        matches!(self, Self::NoAccess | Self::AuthorizationError)
    }

    /// All supported error status codes.
    pub const ALL: [ErrorStatus; 16] = [
        Self::NoError, Self::TooBig, Self::NoSuchName, Self::BadValue,
        Self::ReadOnly, Self::GenErr, Self::NoAccess, Self::WrongType,
        Self::WrongLength, Self::WrongValue, Self::NoCreation,
        Self::InconsistentValue, Self::ResourceUnavailable,
        Self::CommitFailed, Self::UndoFailed, Self::AuthorizationError,
    ];
}

impl fmt::Display for ErrorStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for ErrorStatus {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn version_roundtrip() {
        for tag in 0u8..=2 {
            let ver = Version::from_tag(tag).expect("valid tag");
            assert_eq!(ver.to_tag(), tag);
        }
        assert!(Version::from_tag(3).is_none());
    }

    #[test]
    fn version_ordering() {
        assert!(Version::V1 < Version::V2c);
        assert!(Version::V2c < Version::V3);
    }

    #[test]
    fn version_features() {
        assert!(!Version::V1.has_usm());
        assert!(!Version::V2c.has_usm());
        assert!(Version::V3.has_usm());

        assert!(Version::V1.uses_community_strings());
        assert!(Version::V2c.uses_community_strings());
        assert!(!Version::V3.uses_community_strings());

        assert!(!Version::V1.supports_get_bulk());
        assert!(Version::V2c.supports_get_bulk());
        assert!(Version::V3.supports_get_bulk());
    }

    #[test]
    fn pdu_type_roundtrip() {
        for pdu in PduType::ALL {
            let tag = pdu.to_tag();
            let decoded = PduType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, pdu);
        }
        assert!(PduType::from_tag(7).is_none());
    }

    #[test]
    fn pdu_type_classification() {
        assert!(PduType::GetRequest.is_request());
        assert!(PduType::GetNextRequest.is_request());
        assert!(PduType::SetRequest.is_request());
        assert!(PduType::GetBulkRequest.is_request());
        assert!(!PduType::GetResponse.is_request());
        assert!(!PduType::SnmpV2Trap.is_request());

        assert!(PduType::SnmpV2Trap.is_notification());
        assert!(PduType::InformRequest.is_notification());
        assert!(!PduType::GetRequest.is_notification());

        assert!(PduType::SetRequest.is_write());
        assert!(!PduType::GetRequest.is_write());
    }

    #[test]
    fn pdu_type_min_version() {
        assert_eq!(PduType::GetRequest.min_version(), Version::V1);
        assert_eq!(PduType::GetBulkRequest.min_version(), Version::V2c);
        assert_eq!(PduType::SnmpV2Trap.min_version(), Version::V2c);
    }

    #[test]
    fn error_status_roundtrip() {
        for es in ErrorStatus::ALL {
            let tag = es.to_tag();
            let decoded = ErrorStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, es);
        }
        assert!(ErrorStatus::from_tag(16).is_none());
    }

    #[test]
    fn error_status_classification() {
        assert!(ErrorStatus::NoError.is_success());
        assert!(!ErrorStatus::TooBig.is_success());

        assert!(ErrorStatus::NoSuchName.is_v1_only());
        assert!(ErrorStatus::BadValue.is_v1_only());
        assert!(ErrorStatus::ReadOnly.is_v1_only());
        assert!(!ErrorStatus::NoAccess.is_v1_only());

        assert!(ErrorStatus::NoAccess.is_auth_error());
        assert!(ErrorStatus::AuthorizationError.is_auth_error());
        assert!(!ErrorStatus::GenErr.is_auth_error());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SNMP_PORT, 161);
        assert_eq!(SNMP_TRAP_PORT, 162);
    }
}
