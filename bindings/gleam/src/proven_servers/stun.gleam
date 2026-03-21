//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// STUN/TURN protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `StunABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// STUN/TURN Constants
// ===========================================================================

/// Stun Port constant.
pub const stun_port = 3478

/// Stun Tls Port constant.
pub const stun_tls_port = 5349

// ===========================================================================
// MessageType
// ===========================================================================

/// STUN/TURN message types.
/// 
/// Matches `MessageType` in `StunABI.Types`.
pub type MessageType {
  /// BindingRequest (tag 0).
  BindingRequest
  /// BindingResponse (tag 1).
  BindingResponse
  /// BindingError (tag 2).
  BindingError
  /// AllocateRequest (tag 3).
  AllocateRequest
  /// AllocateResponse (tag 4).
  AllocateResponse
  /// AllocateError (tag 5).
  AllocateError
  /// RefreshRequest (tag 6).
  RefreshRequest
  /// RefreshResponse (tag 7).
  RefreshResponse
  /// SendIndication (tag 8).
  SendIndication
  /// DataIndication (tag 9).
  DataIndication
  /// CreatePermission (tag 10).
  CreatePermission
  /// ChannelBind (tag 11).
  ChannelBind
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    BindingRequest -> 0
    BindingResponse -> 1
    BindingError -> 2
    AllocateRequest -> 3
    AllocateResponse -> 4
    AllocateError -> 5
    RefreshRequest -> 6
    RefreshResponse -> 7
    SendIndication -> 8
    DataIndication -> 9
    CreatePermission -> 10
    ChannelBind -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(BindingRequest)
    1 -> Ok(BindingResponse)
    2 -> Ok(BindingError)
    3 -> Ok(AllocateRequest)
    4 -> Ok(AllocateResponse)
    5 -> Ok(AllocateError)
    6 -> Ok(RefreshRequest)
    7 -> Ok(RefreshResponse)
    8 -> Ok(SendIndication)
    9 -> Ok(DataIndication)
    10 -> Ok(CreatePermission)
    11 -> Ok(ChannelBind)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransportProtocol
// ===========================================================================

/// STUN transport protocols.
/// 
/// Matches `TransportProtocol` in `StunABI.Types`.
pub type TransportProtocol {
  /// UDP (tag 0).
  Udp
  /// TCP (tag 1).
  Tcp
  /// TLS (tag 2).
  Tls
  /// DTLS (tag 3).
  Dtls
}

/// Convert a `TransportProtocol` to its C-ABI tag value.
pub fn transport_protocol_to_int(value: TransportProtocol) -> Int {
  case value {
    Udp -> 0
    Tcp -> 1
    Tls -> 2
    Dtls -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn transport_protocol_from_int(tag: Int) -> Result(TransportProtocol, Nil) {
  case tag {
    0 -> Ok(Udp)
    1 -> Ok(Tcp)
    2 -> Ok(Tls)
    3 -> Ok(Dtls)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// STUN error codes.
/// 
/// Matches `ErrorCode` in `StunABI.Types`.
pub type ErrorCode {
  /// TryAlternate (tag 0).
  TryAlternate
  /// BadRequest (tag 1).
  BadRequest
  /// Unauthorized (tag 2).
  Unauthorized
  /// Forbidden (tag 3).
  Forbidden
  /// MobilityForbidden (tag 4).
  MobilityForbidden
  /// StaleNonce (tag 5).
  StaleNonce
  /// ServerError (tag 6).
  ServerError
  /// InsufficientCapacity (tag 7).
  InsufficientCapacity
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    TryAlternate -> 0
    BadRequest -> 1
    Unauthorized -> 2
    Forbidden -> 3
    MobilityForbidden -> 4
    StaleNonce -> 5
    ServerError -> 6
    InsufficientCapacity -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(TryAlternate)
    1 -> Ok(BadRequest)
    2 -> Ok(Unauthorized)
    3 -> Ok(Forbidden)
    4 -> Ok(MobilityForbidden)
    5 -> Ok(StaleNonce)
    6 -> Ok(ServerError)
    7 -> Ok(InsufficientCapacity)
    _ -> Error(Nil)
  }
}

