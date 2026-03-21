//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// NTS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `NtsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// NTS Constants
// ===========================================================================

/// Nts Ke Port constant.
pub const nts_ke_port = 4460

// ===========================================================================
// RecordType
// ===========================================================================

/// NTS-KE record types.
/// 
/// Matches `RecordType` in `NtsABI.Types`.
pub type RecordType {
  /// EndOfMessage (tag 0).
  EndOfMessage
  /// NextProtocol (tag 1).
  NextProtocol
  /// Error (tag 2).
  RecordTypeError
  /// Warning (tag 3).
  Warning
  /// AEAD algorithm negotiation (tag 4).
  AeadAlgorithm
  /// Cookie (tag 5).
  Cookie
  /// CookiePlaceholder (tag 6).
  CookiePlaceholder
  /// NTS-KE server (tag 7).
  NtskeServer
  /// NTS-KE port (tag 8).
  NtskePort
}

/// Convert a `RecordType` to its C-ABI tag value.
pub fn record_type_to_int(value: RecordType) -> Int {
  case value {
    EndOfMessage -> 0
    NextProtocol -> 1
    RecordTypeError -> 2
    Warning -> 3
    AeadAlgorithm -> 4
    Cookie -> 5
    CookiePlaceholder -> 6
    NtskeServer -> 7
    NtskePort -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn record_type_from_int(tag: Int) -> Result(RecordType, Nil) {
  case tag {
    0 -> Ok(EndOfMessage)
    1 -> Ok(NextProtocol)
    2 -> Ok(RecordTypeError)
    3 -> Ok(Warning)
    4 -> Ok(AeadAlgorithm)
    5 -> Ok(Cookie)
    6 -> Ok(CookiePlaceholder)
    7 -> Ok(NtskeServer)
    8 -> Ok(NtskePort)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// NTS error codes.
/// 
/// Matches `ErrorCode` in `NtsABI.Types`.
pub type ErrorCode {
  /// UnrecognizedCritical (tag 0).
  UnrecognizedCritical
  /// BadRequest (tag 1).
  BadRequest
  /// InternalError (tag 2).
  InternalError
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    UnrecognizedCritical -> 0
    BadRequest -> 1
    InternalError -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(UnrecognizedCritical)
    1 -> Ok(BadRequest)
    2 -> Ok(InternalError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AeadAlgorithm
// ===========================================================================

/// AEAD algorithms for NTS.
/// 
/// Matches `AeadAlgorithm` in `NtsABI.Types`.
pub type AeadAlgorithm {
  /// AEAD-AES-128-GCM (tag 0).
  AeadAes128Gcm
  /// AEAD-AES-256-GCM (tag 1).
  AeadAes256Gcm
  /// AEAD-AES-SIV-CMAC-256 (tag 2).
  AeadAesSivCmac256
}

/// Convert a `AeadAlgorithm` to its C-ABI tag value.
pub fn aead_algorithm_to_int(value: AeadAlgorithm) -> Int {
  case value {
    AeadAes128Gcm -> 0
    AeadAes256Gcm -> 1
    AeadAesSivCmac256 -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn aead_algorithm_from_int(tag: Int) -> Result(AeadAlgorithm, Nil) {
  case tag {
    0 -> Ok(AeadAes128Gcm)
    1 -> Ok(AeadAes256Gcm)
    2 -> Ok(AeadAesSivCmac256)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HandshakeState
// ===========================================================================

/// NTS handshake states.
/// 
/// Matches `HandshakeState` in `NtsABI.Types`.
pub type HandshakeState {
  /// Initial (tag 0).
  Initial
  /// Negotiating (tag 1).
  HandshakeStateNegotiating
  /// Established (tag 2).
  HandshakeStateEstablished
  /// Failed (tag 3).
  Failed
}

/// Convert a `HandshakeState` to its C-ABI tag value.
pub fn handshake_state_to_int(value: HandshakeState) -> Int {
  case value {
    Initial -> 0
    HandshakeStateNegotiating -> 1
    HandshakeStateEstablished -> 2
    Failed -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn handshake_state_from_int(tag: Int) -> Result(HandshakeState, Nil) {
  case tag {
    0 -> Ok(Initial)
    1 -> Ok(HandshakeStateNegotiating)
    2 -> Ok(HandshakeStateEstablished)
    3 -> Ok(Failed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// NTS session lifecycle states.
/// 
/// Matches `SessionState` in `NtsABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Handshaking (tag 1).
  Handshaking
  /// Negotiating (tag 2).
  SessionStateNegotiating
  /// Established (tag 3).
  SessionStateEstablished
  /// Closing (tag 4).
  Closing
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Handshaking -> 1
    SessionStateNegotiating -> 2
    SessionStateEstablished -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Handshaking)
    2 -> Ok(SessionStateNegotiating)
    3 -> Ok(SessionStateEstablished)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

