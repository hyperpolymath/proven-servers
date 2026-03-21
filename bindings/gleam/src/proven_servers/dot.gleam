//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// DNS-over-TLS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DotABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// DNS-over-TLS Constants
// ===========================================================================

/// Dot Port constant.
pub const dot_port = 853

// ===========================================================================
// SessionState
// ===========================================================================

/// DoT session lifecycle states.
/// 
/// Matches `SessionState` in `DotABI.Types`.
pub type SessionState {
  /// Connecting (tag 0).
  Connecting
  /// Handshaking (tag 1).
  Handshaking
  /// Established (tag 2).
  Established
  /// Closing (tag 3).
  Closing
  /// Closed (tag 4).
  Closed
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Connecting -> 0
    Handshaking -> 1
    Established -> 2
    Closing -> 3
    Closed -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Connecting)
    1 -> Ok(Handshaking)
    2 -> Ok(Established)
    3 -> Ok(Closing)
    4 -> Ok(Closed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PaddingStrategy
// ===========================================================================

/// DoT padding strategies (RFC 7830).
/// 
/// Matches `PaddingStrategy` in `DotABI.Types`.
pub type PaddingStrategy {
  /// NoPadding (tag 0).
  NoPadding
  /// BlockPadding (tag 1).
  BlockPadding
  /// RandomPadding (tag 2).
  RandomPadding
}

/// Convert a `PaddingStrategy` to its C-ABI tag value.
pub fn padding_strategy_to_int(value: PaddingStrategy) -> Int {
  case value {
    NoPadding -> 0
    BlockPadding -> 1
    RandomPadding -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn padding_strategy_from_int(tag: Int) -> Result(PaddingStrategy, Nil) {
  case tag {
    0 -> Ok(NoPadding)
    1 -> Ok(BlockPadding)
    2 -> Ok(RandomPadding)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorReason
// ===========================================================================

/// DoT error reasons.
/// 
/// Matches `ErrorReason` in `DotABI.Types`.
pub type ErrorReason {
  /// HandshakeFailed (tag 0).
  HandshakeFailed
  /// CertificateInvalid (tag 1).
  CertificateInvalid
  /// Timeout (tag 2).
  Timeout
  /// UpstreamError (tag 3).
  UpstreamError
}

/// Convert a `ErrorReason` to its C-ABI tag value.
pub fn error_reason_to_int(value: ErrorReason) -> Int {
  case value {
    HandshakeFailed -> 0
    CertificateInvalid -> 1
    Timeout -> 2
    UpstreamError -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn error_reason_from_int(tag: Int) -> Result(ErrorReason, Nil) {
  case tag {
    0 -> Ok(HandshakeFailed)
    1 -> Ok(CertificateInvalid)
    2 -> Ok(Timeout)
    3 -> Ok(UpstreamError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// DoT server lifecycle states.
/// 
/// Matches `ServerState` in `DotABI.Types`.
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

