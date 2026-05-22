//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Kerberos protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `KerberosABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Kerberos Constants
// ===========================================================================

/// Kerberos Port constant.
pub const kerberos_port = 88

// ===========================================================================
// MessageType
// ===========================================================================

/// Kerberos message types (RFC 4120).
/// 
/// Matches `MessageType` in `KerberosABI.Types`.
pub type MessageType {
  /// AS-REQ — Authentication Service request (tag 0).
  AsReq
  /// AS-REP — Authentication Service reply (tag 1).
  AsRep
  /// TGS-REQ — Ticket-Granting Service request (tag 2).
  TgsReq
  /// TGS-REP — Ticket-Granting Service reply (tag 3).
  TgsRep
  /// AP-REQ — Application request (tag 4).
  ApReq
  /// AP-REP — Application reply (tag 5).
  ApRep
  /// KRB-ERROR — Error message (tag 6).
  KrbError
  /// KRB-SAFE — Safe (authenticated) message (tag 7).
  KrbSafe
  /// KRB-PRIV — Private (encrypted) message (tag 8).
  KrbPriv
  /// KRB-CRED — Credential forwarding (tag 9).
  KrbCred
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    AsReq -> 0
    AsRep -> 1
    TgsReq -> 2
    TgsRep -> 3
    ApReq -> 4
    ApRep -> 5
    KrbError -> 6
    KrbSafe -> 7
    KrbPriv -> 8
    KrbCred -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(AsReq)
    1 -> Ok(AsRep)
    2 -> Ok(TgsReq)
    3 -> Ok(TgsRep)
    4 -> Ok(ApReq)
    5 -> Ok(ApRep)
    6 -> Ok(KrbError)
    7 -> Ok(KrbSafe)
    8 -> Ok(KrbPriv)
    9 -> Ok(KrbCred)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EncryptionType
// ===========================================================================

/// Kerberos encryption types (RFC 3961).
/// 
/// Matches `EncryptionType` in `KerberosABI.Types`.
pub type EncryptionType {
  /// AES256-CTS-HMAC-SHA1-96 (tag 0).
  Aes256CtsHmacSha1
  /// AES128-CTS-HMAC-SHA1-96 (tag 1).
  Aes128CtsHmacSha1
  /// AES256-CTS-HMAC-SHA384-192 (tag 2).
  Aes256CtsHmacSha384
  /// RC4-HMAC (legacy, tag 3).
  Rc4Hmac
  /// DES3-CBC-SHA1 (legacy, tag 4).
  Des3CbcSha1
}

/// Convert a `EncryptionType` to its C-ABI tag value.
pub fn encryption_type_to_int(value: EncryptionType) -> Int {
  case value {
    Aes256CtsHmacSha1 -> 0
    Aes128CtsHmacSha1 -> 1
    Aes256CtsHmacSha384 -> 2
    Rc4Hmac -> 3
    Des3CbcSha1 -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn encryption_type_from_int(tag: Int) -> Result(EncryptionType, Nil) {
  case tag {
    0 -> Ok(Aes256CtsHmacSha1)
    1 -> Ok(Aes128CtsHmacSha1)
    2 -> Ok(Aes256CtsHmacSha384)
    3 -> Ok(Rc4Hmac)
    4 -> Ok(Des3CbcSha1)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PrincipalType
// ===========================================================================

/// Kerberos principal name types (RFC 4120).
/// 
/// Matches `PrincipalType` in `KerberosABI.Types`.
pub type PrincipalType {
  /// NT-UNKNOWN (tag 0).
  NtUnknown
  /// NT-PRINCIPAL — general principal (tag 1).
  NtPrincipal
  /// NT-SRV-INST — service instance (tag 2).
  NtSrvInst
  /// NT-SRV-HST — service with host (tag 3).
  NtSrvHst
  /// NT-UID — unique ID (tag 4).
  NtUid
  /// NT-X500-PRINCIPAL — X.500 principal (tag 5).
  NtX500
  /// NT-ENTERPRISE — enterprise principal (tag 6).
  NtEnterprise
}

/// Convert a `PrincipalType` to its C-ABI tag value.
pub fn principal_type_to_int(value: PrincipalType) -> Int {
  case value {
    NtUnknown -> 0
    NtPrincipal -> 1
    NtSrvInst -> 2
    NtSrvHst -> 3
    NtUid -> 4
    NtX500 -> 5
    NtEnterprise -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn principal_type_from_int(tag: Int) -> Result(PrincipalType, Nil) {
  case tag {
    0 -> Ok(NtUnknown)
    1 -> Ok(NtPrincipal)
    2 -> Ok(NtSrvInst)
    3 -> Ok(NtSrvHst)
    4 -> Ok(NtUid)
    5 -> Ok(NtX500)
    6 -> Ok(NtEnterprise)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TicketFlag
// ===========================================================================

/// Kerberos ticket flags (RFC 4120).
/// 
/// Matches `TicketFlag` in `KerberosABI.Types`.
pub type TicketFlag {
  /// Ticket may be forwarded (tag 0).
  Forwardable
  /// Ticket has been forwarded (tag 1).
  Forwarded
  /// Ticket may be proxied (tag 2).
  Proxiable
  /// Ticket is a proxy (tag 3).
  Proxy
  /// Ticket may be renewed (tag 4).
  Renewable
  /// Client was pre-authenticated (tag 5).
  PreAuthent
  /// Hardware authentication was used (tag 6).
  HwAuthent
}

/// Convert a `TicketFlag` to its C-ABI tag value.
pub fn ticket_flag_to_int(value: TicketFlag) -> Int {
  case value {
    Forwardable -> 0
    Forwarded -> 1
    Proxiable -> 2
    Proxy -> 3
    Renewable -> 4
    PreAuthent -> 5
    HwAuthent -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn ticket_flag_from_int(tag: Int) -> Result(TicketFlag, Nil) {
  case tag {
    0 -> Ok(Forwardable)
    1 -> Ok(Forwarded)
    2 -> Ok(Proxiable)
    3 -> Ok(Proxy)
    4 -> Ok(Renewable)
    5 -> Ok(PreAuthent)
    6 -> Ok(HwAuthent)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// Kerberos KDC error codes (RFC 4120).
/// 
/// Matches `ErrorCode` in `KerberosABI.Types`.
pub type ErrorCode {
  /// KDCERRNONE — no error (tag 0).
  KdcErrNone
  /// KDCERRNAMEEXP — client name expired (tag 1).
  KdcErrNameExp
  /// KDCERRSERVICEEXP — service name expired (tag 2).
  KdcErrServiceExp
  /// KDCERRBADPVNO — bad protocol version (tag 3).
  KdcErrBadPvno
  /// KDCERRCOLDMASTKVNO — client key version too old (tag 4).
  KdcErrCOldMastKvno
  /// KDCERRSOLDMASTKVNO — server key version too old (tag 5).
  KdcErrSOldMastKvno
  /// KDCERRCPRINCIPALUNKNOWN — client principal not found (tag 6).
  KdcErrCPrincipalUnknown
  /// KDCERRSPRINCIPALUNKNOWN — service principal not found (tag 7).
  KdcErrSPrincipalUnknown
  /// KDCERRPREAUTHFAILED — pre-authentication failed (tag 8).
  KdcErrPreauthFailed
  /// KDCERRPREAUTHREQUIRED — pre-authentication required (tag 9).
  KdcErrPreauthRequired
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    KdcErrNone -> 0
    KdcErrNameExp -> 1
    KdcErrServiceExp -> 2
    KdcErrBadPvno -> 3
    KdcErrCOldMastKvno -> 4
    KdcErrSOldMastKvno -> 5
    KdcErrCPrincipalUnknown -> 6
    KdcErrSPrincipalUnknown -> 7
    KdcErrPreauthFailed -> 8
    KdcErrPreauthRequired -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(KdcErrNone)
    1 -> Ok(KdcErrNameExp)
    2 -> Ok(KdcErrServiceExp)
    3 -> Ok(KdcErrBadPvno)
    4 -> Ok(KdcErrCOldMastKvno)
    5 -> Ok(KdcErrSOldMastKvno)
    6 -> Ok(KdcErrCPrincipalUnknown)
    7 -> Ok(KdcErrSPrincipalUnknown)
    8 -> Ok(KdcErrPreauthFailed)
    9 -> Ok(KdcErrPreauthRequired)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthState
// ===========================================================================

/// Kerberos authentication state machine.
/// 
/// Matches `AuthState` in `KerberosABI.Types`.
pub type AuthState {
  /// Initial — no tickets (tag 0).
  Initial
  /// TGT obtained from AS (tag 1).
  TgtObtained
  /// Service ticket obtained from TGS (tag 2).
  ServiceTicketObtained
  /// Authenticated — AP-REP received (tag 3).
  Authenticated
  /// Authentication failed (tag 4).
  AuthFailed
}

/// Convert a `AuthState` to its C-ABI tag value.
pub fn auth_state_to_int(value: AuthState) -> Int {
  case value {
    Initial -> 0
    TgtObtained -> 1
    ServiceTicketObtained -> 2
    Authenticated -> 3
    AuthFailed -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_state_from_int(tag: Int) -> Result(AuthState, Nil) {
  case tag {
    0 -> Ok(Initial)
    1 -> Ok(TgtObtained)
    2 -> Ok(ServiceTicketObtained)
    3 -> Ok(Authenticated)
    4 -> Ok(AuthFailed)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn auth_state_can_transition_to(from: AuthState, to: AuthState) -> Bool {
  case from, to {
    Initial, TgtObtained -> True
    TgtObtained, ServiceTicketObtained -> True
    ServiceTicketObtained, Authenticated -> True
    Initial, AuthFailed -> True
    TgtObtained, AuthFailed -> True
    ServiceTicketObtained, AuthFailed -> True
    _, _ -> False
  }
}

// ===========================================================================
// EncStrength
// ===========================================================================

/// Encryption strength classification.
/// 
/// Matches `EncStrength` in `KerberosABI.Types`.
pub type EncStrength {
  /// Strong — recommended (tag 0).
  Strong
  /// Medium — acceptable (tag 1).
  Medium
  /// Weak — deprecated (tag 2).
  Weak
}

/// Convert a `EncStrength` to its C-ABI tag value.
pub fn enc_strength_to_int(value: EncStrength) -> Int {
  case value {
    Strong -> 0
    Medium -> 1
    Weak -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn enc_strength_from_int(tag: Int) -> Result(EncStrength, Nil) {
  case tag {
    0 -> Ok(Strong)
    1 -> Ok(Medium)
    2 -> Ok(Weak)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PreAuthType
// ===========================================================================

/// Kerberos pre-authentication types.
/// 
/// Matches `PreAuthType` in `KerberosABI.Types`.
pub type PreAuthType {
  /// PA-ENC-TIMESTAMP — encrypted timestamp (tag 0).
  PaEncTimestamp
  /// PA-ETYPE-INFO2 — encryption type info (tag 1).
  PaEtypeInfo2
  /// PA-FX-FAST — Flexible Authentication (tag 2).
  PaFxFast
  /// PA-FX-COOKIE — FAST cookie (tag 3).
  PaFxCookie
}

/// Convert a `PreAuthType` to its C-ABI tag value.
pub fn pre_auth_type_to_int(value: PreAuthType) -> Int {
  case value {
    PaEncTimestamp -> 0
    PaEtypeInfo2 -> 1
    PaFxFast -> 2
    PaFxCookie -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn pre_auth_type_from_int(tag: Int) -> Result(PreAuthType, Nil) {
  case tag {
    0 -> Ok(PaEncTimestamp)
    1 -> Ok(PaEtypeInfo2)
    2 -> Ok(PaFxFast)
    3 -> Ok(PaFxCookie)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NegotiationState
// ===========================================================================

/// Kerberos encryption negotiation state.
/// 
/// Matches `NegotiationState` in `KerberosABI.Types`.
pub type NegotiationState {
  /// No negotiation started (tag 0).
  NegIdle
  /// Client proposed encryption types (tag 1).
  Proposed
  /// Server selected an encryption type (tag 2).
  Selected
  /// Negotiation failed — no common type (tag 3).
  NegFailed
}

/// Convert a `NegotiationState` to its C-ABI tag value.
pub fn negotiation_state_to_int(value: NegotiationState) -> Int {
  case value {
    NegIdle -> 0
    Proposed -> 1
    Selected -> 2
    NegFailed -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn negotiation_state_from_int(tag: Int) -> Result(NegotiationState, Nil) {
  case tag {
    0 -> Ok(NegIdle)
    1 -> Ok(Proposed)
    2 -> Ok(Selected)
    3 -> Ok(NegFailed)
    _ -> Error(Nil)
  }
}

