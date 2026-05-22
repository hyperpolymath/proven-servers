//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// DNS-over-QUIC protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DoqABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// DNS-over-QUIC Constants
// ===========================================================================

/// Doq Port constant.
pub const doq_port = 853

// ===========================================================================
// StreamType
// ===========================================================================

/// QUIC stream types.
/// 
/// Matches `StreamType` in `DoqABI.Types`.
pub type StreamType {
  /// Unidirectional (tag 0).
  Unidirectional
  /// Bidirectional (tag 1).
  Bidirectional
}

/// Convert a `StreamType` to its C-ABI tag value.
pub fn stream_type_to_int(value: StreamType) -> Int {
  case value {
    Unidirectional -> 0
    Bidirectional -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn stream_type_from_int(tag: Int) -> Result(StreamType, Nil) {
  case tag {
    0 -> Ok(Unidirectional)
    1 -> Ok(Bidirectional)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// DoQ error codes.
/// 
/// Matches `ErrorCode` in `DoqABI.Types`.
pub type ErrorCode {
  /// NoError (tag 0).
  NoError
  /// InternalError (tag 1).
  InternalError
  /// ExcessiveLoad (tag 2).
  ExcessiveLoad
  /// ProtocolError (tag 3).
  ProtocolError
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    NoError -> 0
    InternalError -> 1
    ExcessiveLoad -> 2
    ProtocolError -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(NoError)
    1 -> Ok(InternalError)
    2 -> Ok(ExcessiveLoad)
    3 -> Ok(ProtocolError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// DoQ session lifecycle states.
/// 
/// Matches `SessionState` in `DoqABI.Types`.
pub type SessionState {
  /// Initial (tag 0).
  Initial
  /// Handshaking (tag 1).
  Handshaking
  /// Ready (tag 2).
  Ready
  /// Draining (tag 3).
  Draining
  /// Closed (tag 4).
  Closed
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Initial -> 0
    Handshaking -> 1
    Ready -> 2
    Draining -> 3
    Closed -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Initial)
    1 -> Ok(Handshaking)
    2 -> Ok(Ready)
    3 -> Ok(Draining)
    4 -> Ok(Closed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// DoQ server lifecycle states.
/// 
/// Matches `ServerState` in `DoqABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Bound (tag 1).
  Bound
  /// Listening (tag 2).
  Listening
  /// Processing (tag 3).
  Processing
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Bound -> 1
    Listening -> 2
    Processing -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Bound)
    2 -> Ok(Listening)
    3 -> Ok(Processing)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

