//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Oblivious DNS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `OdnsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Role
// ===========================================================================

/// ODNS participant roles.
/// 
/// Matches `Role` in `OdnsABI.Types`.
pub type Role {
  /// Client (tag 0).
  Client
  /// Proxy (tag 1).
  Proxy
  /// Target (tag 2).
  Target
}

/// Convert a `Role` to its C-ABI tag value.
pub fn role_to_int(value: Role) -> Int {
  case value {
    Client -> 0
    Proxy -> 1
    Target -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn role_from_int(tag: Int) -> Result(Role, Nil) {
  case tag {
    0 -> Ok(Client)
    1 -> Ok(Proxy)
    2 -> Ok(Target)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OdnsMessageType
// ===========================================================================

/// ODNS message types.
/// 
/// Matches `OdnsMessageType` in `OdnsABI.Types`.
pub type OdnsMessageType {
  /// Query (tag 0).
  Query
  /// Response (tag 1).
  Response
}

/// Convert a `OdnsMessageType` to its C-ABI tag value.
pub fn odns_message_type_to_int(value: OdnsMessageType) -> Int {
  case value {
    Query -> 0
    Response -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn odns_message_type_from_int(tag: Int) -> Result(OdnsMessageType, Nil) {
  case tag {
    0 -> Ok(Query)
    1 -> Ok(Response)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OdnsErrorReason
// ===========================================================================

/// ODNS error reasons.
/// 
/// Matches `OdnsErrorReason` in `OdnsABI.Types`.
pub type OdnsErrorReason {
  /// ProxyError (tag 0).
  ProxyError
  /// TargetError (tag 1).
  TargetError
  /// DecryptionFailed (tag 2).
  DecryptionFailed
  /// InvalidConfig (tag 3).
  InvalidConfig
  /// PayloadTooLarge (tag 4).
  PayloadTooLarge
}

/// Convert a `OdnsErrorReason` to its C-ABI tag value.
pub fn odns_error_reason_to_int(value: OdnsErrorReason) -> Int {
  case value {
    ProxyError -> 0
    TargetError -> 1
    DecryptionFailed -> 2
    InvalidConfig -> 3
    PayloadTooLarge -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn odns_error_reason_from_int(tag: Int) -> Result(OdnsErrorReason, Nil) {
  case tag {
    0 -> Ok(ProxyError)
    1 -> Ok(TargetError)
    2 -> Ok(DecryptionFailed)
    3 -> Ok(InvalidConfig)
    4 -> Ok(PayloadTooLarge)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EncapsulationFormat
// ===========================================================================

/// ODNS encapsulation formats.
/// 
/// Matches `EncapsulationFormat` in `OdnsABI.Types`.
pub type EncapsulationFormat {
  /// HPKE (tag 0).
  Hpke
}

/// Convert a `EncapsulationFormat` to its C-ABI tag value.
pub fn encapsulation_format_to_int(value: EncapsulationFormat) -> Int {
  case value {
    Hpke -> 0
  }
}

/// Decode from a C-ABI tag value.
pub fn encapsulation_format_from_int(tag: Int) -> Result(EncapsulationFormat, Nil) {
  case tag {
    0 -> Ok(Hpke)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// ODNS session states.
/// 
/// Matches `SessionState` in `OdnsABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// KeyExchange (tag 1).
  KeyExchange
  /// Ready (tag 2).
  Ready
  /// Processing (tag 3).
  Processing
  /// Closing (tag 4).
  Closing
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    KeyExchange -> 1
    Ready -> 2
    Processing -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(KeyExchange)
    2 -> Ok(Ready)
    3 -> Ok(Processing)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

