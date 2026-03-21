//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// BFD protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `BfdABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// BFD Constants
// ===========================================================================

/// Bfd Port constant.
pub const bfd_port = 3784

// ===========================================================================
// BfdState
// ===========================================================================

/// BFD session states (RFC 5880 Section 4.1).
/// 
/// Matches `BfdState` in `BfdABI.Types`.
pub type BfdState {
  /// AdminDown (tag 0).
  AdminDown
  /// Down (tag 1).
  Down
  /// Init (tag 2).
  Init
  /// Up (tag 3).
  Up
}

/// Convert a `BfdState` to its C-ABI tag value.
pub fn bfd_state_to_int(value: BfdState) -> Int {
  case value {
    AdminDown -> 0
    Down -> 1
    Init -> 2
    Up -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn bfd_state_from_int(tag: Int) -> Result(BfdState, Nil) {
  case tag {
    0 -> Ok(AdminDown)
    1 -> Ok(Down)
    2 -> Ok(Init)
    3 -> Ok(Up)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Diagnostic
// ===========================================================================

/// BFD diagnostic codes (RFC 5880 Section 4.1).
/// 
/// Matches `Diagnostic` in `BfdABI.Types`.
pub type Diagnostic {
  /// NoDiagnostic (tag 0).
  NoDiagnostic
  /// ControlDetectionTimeExpired (tag 1).
  ControlDetectionTimeExpired
  /// EchoFunctionFailed (tag 2).
  EchoFunctionFailed
  /// NeighborSignaledSessionDown (tag 3).
  NeighborSignaledSessionDown
  /// ForwardingPlaneReset (tag 4).
  ForwardingPlaneReset
  /// PathDown (tag 5).
  PathDown
  /// ConcatenatedPathDown (tag 6).
  ConcatenatedPathDown
  /// AdministrativelyDown (tag 7).
  AdministrativelyDown
  /// ReverseConcatenatedPathDown (tag 8).
  ReverseConcatenatedPathDown
}

/// Convert a `Diagnostic` to its C-ABI tag value.
pub fn diagnostic_to_int(value: Diagnostic) -> Int {
  case value {
    NoDiagnostic -> 0
    ControlDetectionTimeExpired -> 1
    EchoFunctionFailed -> 2
    NeighborSignaledSessionDown -> 3
    ForwardingPlaneReset -> 4
    PathDown -> 5
    ConcatenatedPathDown -> 6
    AdministrativelyDown -> 7
    ReverseConcatenatedPathDown -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn diagnostic_from_int(tag: Int) -> Result(Diagnostic, Nil) {
  case tag {
    0 -> Ok(NoDiagnostic)
    1 -> Ok(ControlDetectionTimeExpired)
    2 -> Ok(EchoFunctionFailed)
    3 -> Ok(NeighborSignaledSessionDown)
    4 -> Ok(ForwardingPlaneReset)
    5 -> Ok(PathDown)
    6 -> Ok(ConcatenatedPathDown)
    7 -> Ok(AdministrativelyDown)
    8 -> Ok(ReverseConcatenatedPathDown)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionMode
// ===========================================================================

/// BFD session modes.
/// 
/// Matches `SessionMode` in `BfdABI.Types`.
pub type SessionMode {
  /// AsyncMode (tag 0).
  AsyncMode
  /// DemandMode (tag 1).
  DemandMode
}

/// Convert a `SessionMode` to its C-ABI tag value.
pub fn session_mode_to_int(value: SessionMode) -> Int {
  case value {
    AsyncMode -> 0
    DemandMode -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn session_mode_from_int(tag: Int) -> Result(SessionMode, Nil) {
  case tag {
    0 -> Ok(AsyncMode)
    1 -> Ok(DemandMode)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// BFD session lifecycle states.
/// 
/// Matches `SessionState` in `BfdABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Down (tag 1).
  SsDown
  /// Negotiating (tag 2).
  Negotiating
  /// Established (tag 3).
  Established
  /// Teardown (tag 4).
  Teardown
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    SsDown -> 1
    Negotiating -> 2
    Established -> 3
    Teardown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(SsDown)
    2 -> Ok(Negotiating)
    3 -> Ok(Established)
    4 -> Ok(Teardown)
    _ -> Error(Nil)
  }
}

