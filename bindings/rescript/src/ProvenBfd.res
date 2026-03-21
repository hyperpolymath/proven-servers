// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD types for the proven-servers ABI.
//
// Mirrors the Idris2 module BfdABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard BFD port.
let bfdPort = 3784

// ===========================================================================
// BfdState (tags 0-3)
// ===========================================================================

/// Standard BFD port.
type bfdState =
  | @as(0) AdminDown
  | @as(1) Down
  | @as(2) Init
  | @as(3) Up

/// Decode from the C-ABI tag value.
let bfdStateFromTag = (tag: int): option<bfdState> =>
  switch tag {
  | 0 => Some(AdminDown)
  | 1 => Some(Down)
  | 2 => Some(Init)
  | 3 => Some(Up)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let bfdStateToTag = (v: bfdState): int =>
  switch v {
  | AdminDown => 0
  | Down => 1
  | Init => 2
  | Up => 3
  }

// ===========================================================================
// Diagnostic (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type diagnostic =
  | @as(0) NoDiagnostic
  | @as(1) ControlDetectionTimeExpired
  | @as(2) EchoFunctionFailed
  | @as(3) NeighborSignaledSessionDown
  | @as(4) ForwardingPlaneReset
  | @as(5) PathDown
  | @as(6) ConcatenatedPathDown
  | @as(7) AdministrativelyDown
  | @as(8) ReverseConcatenatedPathDown

/// Decode from the C-ABI tag value.
let diagnosticFromTag = (tag: int): option<diagnostic> =>
  switch tag {
  | 0 => Some(NoDiagnostic)
  | 1 => Some(ControlDetectionTimeExpired)
  | 2 => Some(EchoFunctionFailed)
  | 3 => Some(NeighborSignaledSessionDown)
  | 4 => Some(ForwardingPlaneReset)
  | 5 => Some(PathDown)
  | 6 => Some(ConcatenatedPathDown)
  | 7 => Some(AdministrativelyDown)
  | 8 => Some(ReverseConcatenatedPathDown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let diagnosticToTag = (v: diagnostic): int =>
  switch v {
  | NoDiagnostic => 0
  | ControlDetectionTimeExpired => 1
  | EchoFunctionFailed => 2
  | NeighborSignaledSessionDown => 3
  | ForwardingPlaneReset => 4
  | PathDown => 5
  | ConcatenatedPathDown => 6
  | AdministrativelyDown => 7
  | ReverseConcatenatedPathDown => 8
  }

// ===========================================================================
// SessionMode (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionMode =
  | @as(0) AsyncMode
  | @as(1) DemandMode

/// Decode from the C-ABI tag value.
let sessionModeFromTag = (tag: int): option<sessionMode> =>
  switch tag {
  | 0 => Some(AsyncMode)
  | 1 => Some(DemandMode)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionModeToTag = (v: sessionMode): int =>
  switch v {
  | AsyncMode => 0
  | DemandMode => 1
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) SsDown
  | @as(2) Negotiating
  | @as(3) Established
  | @as(4) Teardown

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(SsDown)
  | 2 => Some(Negotiating)
  | 3 => Some(Established)
  | 4 => Some(Teardown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | SsDown => 1
  | Negotiating => 2
  | Established => 3
  | Teardown => 4
  }

