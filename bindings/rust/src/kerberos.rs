// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Kerberos protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `KerberosABI.Types` and its type definitions:
//! - `MessageType`       — Kerberos message types (10 constructors, tags 0-9)
//! - `EncryptionType`    — Encryption algorithms (5 constructors, tags 0-4)
//! - `PrincipalType`     — Principal name types (7 constructors, tags 0-6)
//! - `TicketFlag`        — Ticket flags (7 constructors, tags 0-6)
//! - `ErrorCode`         — KDC error codes (10 constructors, tags 0-9)
//! - `AuthState`         — Authentication state machine (5 constructors, tags 0-4)
//! - `EncStrength`       — Encryption strength levels (3 constructors, tags 0-2)
//! - `PreAuthType`       — Pre-authentication types (4 constructors, tags 0-3)
//! - `NegotiationState`  — Negotiation state machine (4 constructors, tags 0-3)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Kerberos Constants
// ===========================================================================

/// Standard Kerberos KDC port (RFC 4120).
pub const KERBEROS_PORT: u16 = 88;

// ===========================================================================
// MessageType (tags 0-9)
// ===========================================================================

/// Kerberos message types (RFC 4120).
///
/// Matches `MessageType` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// AS-REQ — Authentication Service request (tag 0).
    AsReq = 0,
    /// AS-REP — Authentication Service reply (tag 1).
    AsRep = 1,
    /// TGS-REQ — Ticket-Granting Service request (tag 2).
    TgsReq = 2,
    /// TGS-REP — Ticket-Granting Service reply (tag 3).
    TgsRep = 3,
    /// AP-REQ — Application request (tag 4).
    ApReq = 4,
    /// AP-REP — Application reply (tag 5).
    ApRep = 5,
    /// KRB-ERROR — Error message (tag 6).
    KrbError = 6,
    /// KRB-SAFE — Safe (authenticated) message (tag 7).
    KrbSafe = 7,
    /// KRB-PRIV — Private (encrypted) message (tag 8).
    KrbPriv = 8,
    /// KRB-CRED — Credential forwarding (tag 9).
    KrbCred = 9,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AsReq),
            1 => Some(Self::AsRep),
            2 => Some(Self::TgsReq),
            3 => Some(Self::TgsRep),
            4 => Some(Self::ApReq),
            5 => Some(Self::ApRep),
            6 => Some(Self::KrbError),
            7 => Some(Self::KrbSafe),
            8 => Some(Self::KrbPriv),
            9 => Some(Self::KrbCred),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this message is a request.
    pub fn is_request(self) -> bool {
        matches!(self, Self::AsReq | Self::TgsReq | Self::ApReq)
    }

    /// Whether this message is a reply.
    pub fn is_reply(self) -> bool {
        matches!(self, Self::AsRep | Self::TgsRep | Self::ApRep)
    }

    /// All supported message types.
    pub const ALL: [MessageType; 10] = [
        Self::AsReq, Self::AsRep, Self::TgsReq, Self::TgsRep,
        Self::ApReq, Self::ApRep, Self::KrbError, Self::KrbSafe,
        Self::KrbPriv, Self::KrbCred,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EncryptionType (tags 0-4)
// ===========================================================================

/// Kerberos encryption types (RFC 3961).
///
/// Matches `EncryptionType` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EncryptionType {
    /// AES256-CTS-HMAC-SHA1-96 (tag 0).
    Aes256CtsHmacSha1 = 0,
    /// AES128-CTS-HMAC-SHA1-96 (tag 1).
    Aes128CtsHmacSha1 = 1,
    /// AES256-CTS-HMAC-SHA384-192 (tag 2).
    Aes256CtsHmacSha384 = 2,
    /// RC4-HMAC (legacy, tag 3).
    Rc4Hmac = 3,
    /// DES3-CBC-SHA1 (legacy, tag 4).
    Des3CbcSha1 = 4,
}

impl EncryptionType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Aes256CtsHmacSha1),
            1 => Some(Self::Aes128CtsHmacSha1),
            2 => Some(Self::Aes256CtsHmacSha384),
            3 => Some(Self::Rc4Hmac),
            4 => Some(Self::Des3CbcSha1),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The encryption strength classification.
    pub fn strength(self) -> EncStrength {
        match self {
            Self::Aes256CtsHmacSha1 | Self::Aes256CtsHmacSha384 => EncStrength::Strong,
            Self::Aes128CtsHmacSha1 => EncStrength::Medium,
            Self::Rc4Hmac | Self::Des3CbcSha1 => EncStrength::Weak,
        }
    }

    /// Whether this encryption type is considered legacy/deprecated.
    pub fn is_legacy(self) -> bool {
        matches!(self, Self::Rc4Hmac | Self::Des3CbcSha1)
    }

    /// All supported encryption types.
    pub const ALL: [EncryptionType; 5] = [
        Self::Aes256CtsHmacSha1, Self::Aes128CtsHmacSha1,
        Self::Aes256CtsHmacSha384, Self::Rc4Hmac, Self::Des3CbcSha1,
    ];
}

impl fmt::Display for EncryptionType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PrincipalType (tags 0-6)
// ===========================================================================

/// Kerberos principal name types (RFC 4120).
///
/// Matches `PrincipalType` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PrincipalType {
    /// NT-UNKNOWN (tag 0).
    NtUnknown = 0,
    /// NT-PRINCIPAL — general principal (tag 1).
    NtPrincipal = 1,
    /// NT-SRV-INST — service instance (tag 2).
    NtSrvInst = 2,
    /// NT-SRV-HST — service with host (tag 3).
    NtSrvHst = 3,
    /// NT-UID — unique ID (tag 4).
    NtUid = 4,
    /// NT-X500-PRINCIPAL — X.500 principal (tag 5).
    NtX500 = 5,
    /// NT-ENTERPRISE — enterprise principal (tag 6).
    NtEnterprise = 6,
}

impl PrincipalType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NtUnknown),
            1 => Some(Self::NtPrincipal),
            2 => Some(Self::NtSrvInst),
            3 => Some(Self::NtSrvHst),
            4 => Some(Self::NtUid),
            5 => Some(Self::NtX500),
            6 => Some(Self::NtEnterprise),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported principal types.
    pub const ALL: [PrincipalType; 7] = [
        Self::NtUnknown, Self::NtPrincipal, Self::NtSrvInst,
        Self::NtSrvHst, Self::NtUid, Self::NtX500, Self::NtEnterprise,
    ];
}

impl fmt::Display for PrincipalType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TicketFlag (tags 0-6)
// ===========================================================================

/// Kerberos ticket flags (RFC 4120).
///
/// Matches `TicketFlag` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TicketFlag {
    /// Ticket may be forwarded (tag 0).
    Forwardable = 0,
    /// Ticket has been forwarded (tag 1).
    Forwarded = 1,
    /// Ticket may be proxied (tag 2).
    Proxiable = 2,
    /// Ticket is a proxy (tag 3).
    Proxy = 3,
    /// Ticket may be renewed (tag 4).
    Renewable = 4,
    /// Client was pre-authenticated (tag 5).
    PreAuthent = 5,
    /// Hardware authentication was used (tag 6).
    HwAuthent = 6,
}

impl TicketFlag {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Forwardable),
            1 => Some(Self::Forwarded),
            2 => Some(Self::Proxiable),
            3 => Some(Self::Proxy),
            4 => Some(Self::Renewable),
            5 => Some(Self::PreAuthent),
            6 => Some(Self::HwAuthent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this flag relates to delegation.
    pub fn is_delegation(self) -> bool {
        matches!(
            self,
            Self::Forwardable | Self::Forwarded | Self::Proxiable | Self::Proxy
        )
    }

    /// All supported ticket flags.
    pub const ALL: [TicketFlag; 7] = [
        Self::Forwardable, Self::Forwarded, Self::Proxiable, Self::Proxy,
        Self::Renewable, Self::PreAuthent, Self::HwAuthent,
    ];
}

impl fmt::Display for TicketFlag {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-9)
// ===========================================================================

/// Kerberos KDC error codes (RFC 4120).
///
/// Matches `ErrorCode` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// KDC_ERR_NONE — no error (tag 0).
    KdcErrNone = 0,
    /// KDC_ERR_NAME_EXP — client name expired (tag 1).
    KdcErrNameExp = 1,
    /// KDC_ERR_SERVICE_EXP — service name expired (tag 2).
    KdcErrServiceExp = 2,
    /// KDC_ERR_BAD_PVNO — bad protocol version (tag 3).
    KdcErrBadPvno = 3,
    /// KDC_ERR_C_OLD_MAST_KVNO — client key version too old (tag 4).
    KdcErrCOldMastKvno = 4,
    /// KDC_ERR_S_OLD_MAST_KVNO — server key version too old (tag 5).
    KdcErrSOldMastKvno = 5,
    /// KDC_ERR_C_PRINCIPAL_UNKNOWN — client principal not found (tag 6).
    KdcErrCPrincipalUnknown = 6,
    /// KDC_ERR_S_PRINCIPAL_UNKNOWN — service principal not found (tag 7).
    KdcErrSPrincipalUnknown = 7,
    /// KDC_ERR_PREAUTH_FAILED — pre-authentication failed (tag 8).
    KdcErrPreauthFailed = 8,
    /// KDC_ERR_PREAUTH_REQUIRED — pre-authentication required (tag 9).
    KdcErrPreauthRequired = 9,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::KdcErrNone),
            1 => Some(Self::KdcErrNameExp),
            2 => Some(Self::KdcErrServiceExp),
            3 => Some(Self::KdcErrBadPvno),
            4 => Some(Self::KdcErrCOldMastKvno),
            5 => Some(Self::KdcErrSOldMastKvno),
            6 => Some(Self::KdcErrCPrincipalUnknown),
            7 => Some(Self::KdcErrSPrincipalUnknown),
            8 => Some(Self::KdcErrPreauthFailed),
            9 => Some(Self::KdcErrPreauthRequired),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this code indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::KdcErrNone)
    }

    /// All supported error codes.
    pub const ALL: [ErrorCode; 10] = [
        Self::KdcErrNone, Self::KdcErrNameExp, Self::KdcErrServiceExp,
        Self::KdcErrBadPvno, Self::KdcErrCOldMastKvno, Self::KdcErrSOldMastKvno,
        Self::KdcErrCPrincipalUnknown, Self::KdcErrSPrincipalUnknown,
        Self::KdcErrPreauthFailed, Self::KdcErrPreauthRequired,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for ErrorCode {}

// ===========================================================================
// AuthState (tags 0-4)
// ===========================================================================

/// Kerberos authentication state machine.
///
/// Matches `AuthState` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthState {
    /// Initial — no tickets (tag 0).
    Initial = 0,
    /// TGT obtained from AS (tag 1).
    TgtObtained = 1,
    /// Service ticket obtained from TGS (tag 2).
    ServiceTicketObtained = 2,
    /// Authenticated — AP-REP received (tag 3).
    Authenticated = 3,
    /// Authentication failed (tag 4).
    AuthFailed = 4,
}

impl AuthState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initial),
            1 => Some(Self::TgtObtained),
            2 => Some(Self::ServiceTicketObtained),
            3 => Some(Self::Authenticated),
            4 => Some(Self::AuthFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: AuthState) -> bool {
        matches!(
            (self, next),
            (Self::Initial, Self::TgtObtained)
                | (Self::TgtObtained, Self::ServiceTicketObtained)
                | (Self::ServiceTicketObtained, Self::Authenticated)
                | (Self::Initial, Self::AuthFailed)
                | (Self::TgtObtained, Self::AuthFailed)
                | (Self::ServiceTicketObtained, Self::AuthFailed)
        )
    }

    /// All supported states.
    pub const ALL: [AuthState; 5] = [
        Self::Initial, Self::TgtObtained, Self::ServiceTicketObtained,
        Self::Authenticated, Self::AuthFailed,
    ];
}

impl fmt::Display for AuthState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EncStrength (tags 0-2)
// ===========================================================================

/// Encryption strength classification.
///
/// Matches `EncStrength` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum EncStrength {
    /// Strong — recommended (tag 0).
    Strong = 0,
    /// Medium — acceptable (tag 1).
    Medium = 1,
    /// Weak — deprecated (tag 2).
    Weak = 2,
}

impl EncStrength {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Strong),
            1 => Some(Self::Medium),
            2 => Some(Self::Weak),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for EncStrength {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PreAuthType (tags 0-3)
// ===========================================================================

/// Kerberos pre-authentication types.
///
/// Matches `PreAuthType` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PreAuthType {
    /// PA-ENC-TIMESTAMP — encrypted timestamp (tag 0).
    PaEncTimestamp = 0,
    /// PA-ETYPE-INFO2 — encryption type info (tag 1).
    PaEtypeInfo2 = 1,
    /// PA-FX-FAST — Flexible Authentication (tag 2).
    PaFxFast = 2,
    /// PA-FX-COOKIE — FAST cookie (tag 3).
    PaFxCookie = 3,
}

impl PreAuthType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::PaEncTimestamp),
            1 => Some(Self::PaEtypeInfo2),
            2 => Some(Self::PaFxFast),
            3 => Some(Self::PaFxCookie),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported pre-auth types.
    pub const ALL: [PreAuthType; 4] = [
        Self::PaEncTimestamp, Self::PaEtypeInfo2, Self::PaFxFast, Self::PaFxCookie,
    ];
}

impl fmt::Display for PreAuthType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NegotiationState (tags 0-3)
// ===========================================================================

/// Kerberos encryption negotiation state.
///
/// Matches `NegotiationState` in `KerberosABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NegotiationState {
    /// No negotiation started (tag 0).
    NegIdle = 0,
    /// Client proposed encryption types (tag 1).
    Proposed = 1,
    /// Server selected an encryption type (tag 2).
    Selected = 2,
    /// Negotiation failed — no common type (tag 3).
    NegFailed = 3,
}

impl NegotiationState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NegIdle),
            1 => Some(Self::Proposed),
            2 => Some(Self::Selected),
            3 => Some(Self::NegFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported states.
    pub const ALL: [NegotiationState; 4] = [
        Self::NegIdle, Self::Proposed, Self::Selected, Self::NegFailed,
    ];
}

impl fmt::Display for NegotiationState {
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
    fn message_type_roundtrip() {
        for mt in MessageType::ALL {
            let tag = mt.to_tag();
            let decoded = MessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, mt);
        }
        assert!(MessageType::from_tag(10).is_none());
    }

    #[test]
    fn message_type_classification() {
        assert!(MessageType::AsReq.is_request());
        assert!(MessageType::AsRep.is_reply());
        assert!(!MessageType::KrbError.is_request());
    }

    #[test]
    fn encryption_type_roundtrip() {
        for et in EncryptionType::ALL {
            let tag = et.to_tag();
            let decoded = EncryptionType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, et);
        }
        assert!(EncryptionType::from_tag(5).is_none());
    }

    #[test]
    fn encryption_type_strength() {
        assert_eq!(EncryptionType::Aes256CtsHmacSha1.strength(), EncStrength::Strong);
        assert_eq!(EncryptionType::Aes128CtsHmacSha1.strength(), EncStrength::Medium);
        assert_eq!(EncryptionType::Rc4Hmac.strength(), EncStrength::Weak);
        assert!(EncryptionType::Rc4Hmac.is_legacy());
    }

    #[test]
    fn principal_type_roundtrip() {
        for pt in PrincipalType::ALL {
            let tag = pt.to_tag();
            let decoded = PrincipalType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, pt);
        }
        assert!(PrincipalType::from_tag(7).is_none());
    }

    #[test]
    fn ticket_flag_roundtrip() {
        for tf in TicketFlag::ALL {
            let tag = tf.to_tag();
            let decoded = TicketFlag::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, tf);
        }
        assert!(TicketFlag::from_tag(7).is_none());
    }

    #[test]
    fn ticket_flag_delegation() {
        assert!(TicketFlag::Forwardable.is_delegation());
        assert!(TicketFlag::Proxy.is_delegation());
        assert!(!TicketFlag::Renewable.is_delegation());
    }

    #[test]
    fn error_code_roundtrip() {
        for ec in ErrorCode::ALL {
            let tag = ec.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ec);
        }
        assert!(ErrorCode::from_tag(10).is_none());
    }

    #[test]
    fn auth_state_roundtrip() {
        for state in AuthState::ALL {
            let tag = state.to_tag();
            let decoded = AuthState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, state);
        }
        assert!(AuthState::from_tag(5).is_none());
    }

    #[test]
    fn auth_state_transitions() {
        assert!(AuthState::Initial.can_transition_to(AuthState::TgtObtained));
        assert!(AuthState::TgtObtained.can_transition_to(AuthState::ServiceTicketObtained));
        assert!(AuthState::ServiceTicketObtained.can_transition_to(AuthState::Authenticated));
        assert!(AuthState::Initial.can_transition_to(AuthState::AuthFailed));
        assert!(!AuthState::Initial.can_transition_to(AuthState::Authenticated));
    }

    #[test]
    fn enc_strength_roundtrip() {
        for tag in 0u8..=2 {
            let s = EncStrength::from_tag(tag).expect("valid tag");
            assert_eq!(s.to_tag(), tag);
        }
        assert!(EncStrength::from_tag(3).is_none());
    }

    #[test]
    fn pre_auth_type_roundtrip() {
        for pat in PreAuthType::ALL {
            let tag = pat.to_tag();
            let decoded = PreAuthType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, pat);
        }
        assert!(PreAuthType::from_tag(4).is_none());
    }

    #[test]
    fn negotiation_state_roundtrip() {
        for ns in NegotiationState::ALL {
            let tag = ns.to_tag();
            let decoded = NegotiationState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ns);
        }
        assert!(NegotiationState::from_tag(4).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(KERBEROS_PORT, 88);
    }
}
