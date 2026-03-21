//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// RADIUS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `RadiusABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// RADIUS Constants
// ===========================================================================

/// Radius Auth Port constant.
pub const radius_auth_port = 1812

/// Radius Acct Port constant.
pub const radius_acct_port = 1813

// ===========================================================================
// PacketType
// ===========================================================================

/// RADIUS packet types (RFC 2865).
/// 
/// Matches `PacketType` in `RadiusABI.Types`.
/// Tag values match the RADIUS Code field from the wire protocol.
pub type PacketType {
  /// Access-Request (Code 1) (tag 1).
  AccessRequest
  /// Access-Accept (Code 2) (tag 2).
  AccessAccept
  /// Access-Reject (Code 3) (tag 3).
  AccessReject
  /// Accounting-Request (Code 4) (tag 4).
  AccountingRequest
  /// Accounting-Response (Code 5) (tag 5).
  AccountingResponse
  /// Access-Challenge (Code 11) (tag 11).
  AccessChallenge
}

/// Convert a `PacketType` to its C-ABI tag value.
pub fn packet_type_to_int(value: PacketType) -> Int {
  case value {
    AccessRequest -> 1
    AccessAccept -> 2
    AccessReject -> 3
    AccountingRequest -> 4
    AccountingResponse -> 5
    AccessChallenge -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn packet_type_from_int(tag: Int) -> Result(PacketType, Nil) {
  case tag {
    1 -> Ok(AccessRequest)
    2 -> Ok(AccessAccept)
    3 -> Ok(AccessReject)
    4 -> Ok(AccountingRequest)
    5 -> Ok(AccountingResponse)
    11 -> Ok(AccessChallenge)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AttributeType
// ===========================================================================

/// RADIUS attribute types (RFC 2865).
/// 
/// Matches `AttributeType` in `RadiusABI.Types`.
/// Tag values match the actual RADIUS Attribute-Type numbers.
pub type AttributeType {
  /// User-Name (Type 1) (tag 1).
  UserName
  /// User-Password (Type 2) (tag 2).
  UserPassword
  /// NAS-IP-Address (Type 4) (tag 4).
  NasIpAddress
  /// NAS-Port (Type 5) (tag 5).
  NasPort
  /// Service-Type (Type 6) (tag 6).
  ServiceType
  /// Framed-Protocol (Type 7) (tag 7).
  FramedProtocol
  /// Framed-IP-Address (Type 8) (tag 8).
  FramedIpAddress
  /// Reply-Message (Type 18) (tag 18).
  ReplyMessage
  /// Session-Timeout (Type 27) (tag 27).
  SessionTimeout
}

/// Convert a `AttributeType` to its C-ABI tag value.
pub fn attribute_type_to_int(value: AttributeType) -> Int {
  case value {
    UserName -> 1
    UserPassword -> 2
    NasIpAddress -> 4
    NasPort -> 5
    ServiceType -> 6
    FramedProtocol -> 7
    FramedIpAddress -> 8
    ReplyMessage -> 18
    SessionTimeout -> 27
  }
}

/// Decode from a C-ABI tag value.
pub fn attribute_type_from_int(tag: Int) -> Result(AttributeType, Nil) {
  case tag {
    1 -> Ok(UserName)
    2 -> Ok(UserPassword)
    4 -> Ok(NasIpAddress)
    5 -> Ok(NasPort)
    6 -> Ok(ServiceType)
    7 -> Ok(FramedProtocol)
    8 -> Ok(FramedIpAddress)
    18 -> Ok(ReplyMessage)
    27 -> Ok(SessionTimeout)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServiceType
// ===========================================================================

/// RADIUS Service-Type values (RFC 2865).
/// 
/// Matches `ServiceType` in `RadiusABI.Types`.
pub type ServiceType {
  /// Login (tag 1).
  Login
  /// Framed (tag 2).
  Framed
  /// Callback Login (tag 3).
  CallbackLogin
  /// Callback Framed (tag 4).
  CallbackFramed
  /// Outbound (tag 5).
  Outbound
  /// Administrative (tag 6).
  Administrative
}

/// Convert a `ServiceType` to its C-ABI tag value.
pub fn service_type_to_int(value: ServiceType) -> Int {
  case value {
    Login -> 1
    Framed -> 2
    CallbackLogin -> 3
    CallbackFramed -> 4
    Outbound -> 5
    Administrative -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn service_type_from_int(tag: Int) -> Result(ServiceType, Nil) {
  case tag {
    1 -> Ok(Login)
    2 -> Ok(Framed)
    3 -> Ok(CallbackLogin)
    4 -> Ok(CallbackFramed)
    5 -> Ok(Outbound)
    6 -> Ok(Administrative)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthMethod
// ===========================================================================

/// RADIUS authentication methods.
/// 
/// Matches `AuthMethod` in `RadiusABI.Types`.
pub type AuthMethod {
  /// PAP — Password Authentication Protocol (tag 0).
  Pap
  /// CHAP — Challenge Handshake Authentication Protocol (tag 1).
  Chap
  /// MS-CHAP — Microsoft CHAP v1 (tag 2).
  Mschap
  /// MS-CHAPv2 — Microsoft CHAP v2 (tag 3).
  Mschapv2
  /// EAP — Extensible Authentication Protocol (tag 4).
  Eap
}

/// Convert a `AuthMethod` to its C-ABI tag value.
pub fn auth_method_to_int(value: AuthMethod) -> Int {
  case value {
    Pap -> 0
    Chap -> 1
    Mschap -> 2
    Mschapv2 -> 3
    Eap -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_method_from_int(tag: Int) -> Result(AuthMethod, Nil) {
  case tag {
    0 -> Ok(Pap)
    1 -> Ok(Chap)
    2 -> Ok(Mschap)
    3 -> Ok(Mschapv2)
    4 -> Ok(Eap)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// RADIUS session state machine.
/// 
/// Matches `SessionState` in `RadiusABI.Types`.
pub type SessionState {
  /// Idle — no active session (tag 0).
  Idle
  /// Authenticating — processing auth request (tag 1).
  Authenticating
  /// Authorized — access granted (tag 2).
  Authorized
  /// Rejected — access denied (tag 3).
  Rejected
  /// Challenged — additional auth step required (tag 4).
  Challenged
  /// Accounting — session accounting in progress (tag 5).
  Accounting
  /// Complete — session fully processed (tag 6).
  Complete
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Authenticating -> 1
    Authorized -> 2
    Rejected -> 3
    Challenged -> 4
    Accounting -> 5
    Complete -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Authenticating)
    2 -> Ok(Authorized)
    3 -> Ok(Rejected)
    4 -> Ok(Challenged)
    5 -> Ok(Accounting)
    6 -> Ok(Complete)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RadiusResult
// ===========================================================================

/// RADIUS FFI result codes.
/// 
/// Matches `RadiusResult` in `RadiusABI.Types`.
pub type RadiusResult {
  /// Success (tag 0).
  RadiusResultOk
  /// Generic error (tag 1).
  Err
  /// Invalid parameter (tag 2).
  InvalidParam
  /// Address pool exhausted (tag 3).
  PoolExhausted
  /// Shared secret mismatch (tag 4).
  BadSecret
}

/// Convert a `RadiusResult` to its C-ABI tag value.
pub fn radius_result_to_int(value: RadiusResult) -> Int {
  case value {
    RadiusResultOk -> 0
    Err -> 1
    InvalidParam -> 2
    PoolExhausted -> 3
    BadSecret -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn radius_result_from_int(tag: Int) -> Result(RadiusResult, Nil) {
  case tag {
    0 -> Ok(RadiusResultOk)
    1 -> Ok(Err)
    2 -> Ok(InvalidParam)
    3 -> Ok(PoolExhausted)
    4 -> Ok(BadSecret)
    _ -> Error(Nil)
  }
}

