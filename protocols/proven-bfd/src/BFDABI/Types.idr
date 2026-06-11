-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- BFDABI.Types: C-ABI-compatible numeric representations of BFD types.
--
-- Maps every constructor of the core BFD sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/bfd.h) and the
-- Zig FFI enums (ffi/zig/src/bfd.zig) exactly.
--
-- Types covered:
--   State       (4 constructors, tags 0-3)
--   Diagnostic  (9 constructors, tags 0-8)
--   SessionMode (2 constructors, tags 0-1)
--   SessionState (5 constructors, tags 0-4)

module BFDABI.Types

import BFD.Types

%default total

---------------------------------------------------------------------------
-- State (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
stateToTag : State -> Bits8
stateToTag AdminDown = 0
stateToTag Down      = 1
stateToTag Init      = 2
stateToTag Up        = 3

public export
tagToState : Bits8 -> Maybe State
tagToState 0 = Just AdminDown
tagToState 1 = Just Down
tagToState 2 = Just Init
tagToState 3 = Just Up
tagToState _ = Nothing

public export
stateRoundtrip : (s : State) -> tagToState (stateToTag s) = Just s
stateRoundtrip AdminDown = Refl
stateRoundtrip Down      = Refl
stateRoundtrip Init      = Refl
stateRoundtrip Up        = Refl

---------------------------------------------------------------------------
-- Diagnostic (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
diagnosticToTag : Diagnostic -> Bits8
diagnosticToTag NoDiagnostic                = 0
diagnosticToTag ControlDetectionTimeExpired = 1
diagnosticToTag EchoFunctionFailed          = 2
diagnosticToTag NeighborSignaledSessionDown = 3
diagnosticToTag ForwardingPlaneReset        = 4
diagnosticToTag PathDown                    = 5
diagnosticToTag ConcatenatedPathDown        = 6
diagnosticToTag AdministrativelyDown        = 7
diagnosticToTag ReverseConcatenatedPathDown = 8

public export
tagToDiagnostic : Bits8 -> Maybe Diagnostic
tagToDiagnostic 0 = Just NoDiagnostic
tagToDiagnostic 1 = Just ControlDetectionTimeExpired
tagToDiagnostic 2 = Just EchoFunctionFailed
tagToDiagnostic 3 = Just NeighborSignaledSessionDown
tagToDiagnostic 4 = Just ForwardingPlaneReset
tagToDiagnostic 5 = Just PathDown
tagToDiagnostic 6 = Just ConcatenatedPathDown
tagToDiagnostic 7 = Just AdministrativelyDown
tagToDiagnostic 8 = Just ReverseConcatenatedPathDown
tagToDiagnostic _ = Nothing

public export
diagnosticRoundtrip : (d : Diagnostic) -> tagToDiagnostic (diagnosticToTag d) = Just d
diagnosticRoundtrip NoDiagnostic                = Refl
diagnosticRoundtrip ControlDetectionTimeExpired = Refl
diagnosticRoundtrip EchoFunctionFailed          = Refl
diagnosticRoundtrip NeighborSignaledSessionDown = Refl
diagnosticRoundtrip ForwardingPlaneReset        = Refl
diagnosticRoundtrip PathDown                    = Refl
diagnosticRoundtrip ConcatenatedPathDown        = Refl
diagnosticRoundtrip AdministrativelyDown        = Refl
diagnosticRoundtrip ReverseConcatenatedPathDown = Refl

---------------------------------------------------------------------------
-- SessionMode (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
sessionModeToTag : SessionMode -> Bits8
sessionModeToTag AsyncMode  = 0
sessionModeToTag DemandMode = 1

public export
tagToSessionMode : Bits8 -> Maybe SessionMode
tagToSessionMode 0 = Just AsyncMode
tagToSessionMode 1 = Just DemandMode
tagToSessionMode _ = Nothing

public export
sessionModeRoundtrip : (m : SessionMode) -> tagToSessionMode (sessionModeToTag m) = Just m
sessionModeRoundtrip AsyncMode  = Refl
sessionModeRoundtrip DemandMode = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- BFD session lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| BFD session lifecycle states for the FFI layer.
public export
data SessionState : Type where
  ||| No session. Initial and terminal state.
  SSIdle         : SessionState
  ||| Session created, in Down state awaiting peer.
  SSDown         : SessionState
  ||| Init sent, awaiting peer confirmation.
  SSNegotiating  : SessionState
  ||| Session established (both peers Up).
  SSEstablished  : SessionState
  ||| Session shutting down (AdminDown or error).
  SSTeardown     : SessionState

public export
Eq SessionState where
  SSIdle        == SSIdle        = True
  SSDown        == SSDown        = True
  SSNegotiating == SSNegotiating = True
  SSEstablished == SSEstablished = True
  SSTeardown    == SSTeardown    = True
  _             == _             = False

public export
Show SessionState where
  show SSIdle        = "Idle"
  show SSDown        = "Down"
  show SSNegotiating = "Negotiating"
  show SSEstablished = "Established"
  show SSTeardown    = "Teardown"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle        = 0
sessionStateToTag SSDown        = 1
sessionStateToTag SSNegotiating = 2
sessionStateToTag SSEstablished = 3
sessionStateToTag SSTeardown    = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSDown
tagToSessionState 2 = Just SSNegotiating
tagToSessionState 3 = Just SSEstablished
tagToSessionState 4 = Just SSTeardown
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle        = Refl
sessionStateRoundtrip SSDown        = Refl
sessionStateRoundtrip SSNegotiating = Refl
sessionStateRoundtrip SSEstablished = Refl
sessionStateRoundtrip SSTeardown    = Refl
