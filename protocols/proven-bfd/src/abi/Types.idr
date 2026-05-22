-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BfdABI.Types: C-ABI-compatible numeric representations of Bfd types.
--
-- Maps every constructor of the core Bfd sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/bfd.zig) exactly.
--
-- Types covered:
--   BfdState                  (4 constructors, tags 0-3)
--   Diagnostic                (9 constructors, tags 0-8)
--   SessionMode               (2 constructors, tags 0-1)
--   SessionState              (5 constructors, tags 0-4)

module BfdABI.Types

%default total

---------------------------------------------------------------------------
-- BfdState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
bfd_stateSize : Nat
bfd_stateSize = 1

||| BfdState sum type for ABI encoding.
public export
data BfdState : Type where
  AdminDown : BfdState
  Down : BfdState
  Init : BfdState
  Up : BfdState

||| Encode a BfdState to its ABI tag value.
public export
bfd_stateToTag : BfdState -> Bits8
bfd_stateToTag AdminDown = 0
bfd_stateToTag Down = 1
bfd_stateToTag Init = 2
bfd_stateToTag Up = 3

||| Decode an ABI tag to a BfdState.
public export
tagToBfdState : Bits8 -> Maybe BfdState
tagToBfdState 0 = Just AdminDown
tagToBfdState 1 = Just Down
tagToBfdState 2 = Just Init
tagToBfdState 3 = Just Up
tagToBfdState _ = Nothing

||| Roundtrip proof: decoding an encoded BfdState yields the original.
public export
bfd_stateRoundtrip : (x : BfdState) -> tagToBfdState (bfd_stateToTag x) = Just x
bfd_stateRoundtrip AdminDown = Refl
bfd_stateRoundtrip Down = Refl
bfd_stateRoundtrip Init = Refl
bfd_stateRoundtrip Up = Refl

---------------------------------------------------------------------------
-- Diagnostic (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
diagnosticSize : Nat
diagnosticSize = 1

||| Diagnostic sum type for ABI encoding.
public export
data Diagnostic : Type where
  NoDiagnostic : Diagnostic
  ControlDetectionTimeExpired : Diagnostic
  EchoFunctionFailed : Diagnostic
  NeighborSignaledSessionDown : Diagnostic
  ForwardingPlaneReset : Diagnostic
  PathDown : Diagnostic
  ConcatenatedPathDown : Diagnostic
  AdministrativelyDown : Diagnostic
  ReverseConcatenatedPathDown : Diagnostic

||| Encode a Diagnostic to its ABI tag value.
public export
diagnosticToTag : Diagnostic -> Bits8
diagnosticToTag NoDiagnostic = 0
diagnosticToTag ControlDetectionTimeExpired = 1
diagnosticToTag EchoFunctionFailed = 2
diagnosticToTag NeighborSignaledSessionDown = 3
diagnosticToTag ForwardingPlaneReset = 4
diagnosticToTag PathDown = 5
diagnosticToTag ConcatenatedPathDown = 6
diagnosticToTag AdministrativelyDown = 7
diagnosticToTag ReverseConcatenatedPathDown = 8

||| Decode an ABI tag to a Diagnostic.
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

||| Roundtrip proof: decoding an encoded Diagnostic yields the original.
public export
diagnosticRoundtrip : (x : Diagnostic) -> tagToDiagnostic (diagnosticToTag x) = Just x
diagnosticRoundtrip NoDiagnostic = Refl
diagnosticRoundtrip ControlDetectionTimeExpired = Refl
diagnosticRoundtrip EchoFunctionFailed = Refl
diagnosticRoundtrip NeighborSignaledSessionDown = Refl
diagnosticRoundtrip ForwardingPlaneReset = Refl
diagnosticRoundtrip PathDown = Refl
diagnosticRoundtrip ConcatenatedPathDown = Refl
diagnosticRoundtrip AdministrativelyDown = Refl
diagnosticRoundtrip ReverseConcatenatedPathDown = Refl

---------------------------------------------------------------------------
-- SessionMode (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
session_modeSize : Nat
session_modeSize = 1

||| SessionMode sum type for ABI encoding.
public export
data SessionMode : Type where
  AsyncMode : SessionMode
  DemandMode : SessionMode

||| Encode a SessionMode to its ABI tag value.
public export
session_modeToTag : SessionMode -> Bits8
session_modeToTag AsyncMode = 0
session_modeToTag DemandMode = 1

||| Decode an ABI tag to a SessionMode.
public export
tagToSessionMode : Bits8 -> Maybe SessionMode
tagToSessionMode 0 = Just AsyncMode
tagToSessionMode 1 = Just DemandMode
tagToSessionMode _ = Nothing

||| Roundtrip proof: decoding an encoded SessionMode yields the original.
public export
session_modeRoundtrip : (x : SessionMode) -> tagToSessionMode (session_modeToTag x) = Just x
session_modeRoundtrip AsyncMode = Refl
session_modeRoundtrip DemandMode = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Idle : SessionState
  SsDown : SessionState
  Negotiating : SessionState
  Established : SessionState
  Teardown : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Idle = 0
session_stateToTag SsDown = 1
session_stateToTag Negotiating = 2
session_stateToTag Established = 3
session_stateToTag Teardown = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Idle
tagToSessionState 1 = Just SsDown
tagToSessionState 2 = Just Negotiating
tagToSessionState 3 = Just Established
tagToSessionState 4 = Just Teardown
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Idle = Refl
session_stateRoundtrip SsDown = Refl
session_stateRoundtrip Negotiating = Refl
session_stateRoundtrip Established = Refl
session_stateRoundtrip Teardown = Refl
