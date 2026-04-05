-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NesySolverAPIABI.Layout: C-ABI-compatible numeric representations.
--
-- Maps every constructor of the six core sum types (ProverKind,
-- InputLanguage, ObligationClass, ProveOutcome, SessionState, SurfaceKind)
-- to a fixed Bits8 value for C interop.  Each type gets:
--   * a size constant (1 byte for each enumeration)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving decode(encode(x)) = Just x
--
-- The roundtrip proofs are formal verification: they guarantee at compile
-- time that encoding/decoding never loses information.  These proofs
-- compile away to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/nesy_solver_api.h)
-- and the Zig FFI enums (ffi/zig/src/nesy_solver_api.zig) exactly.

module NesySolverAPIABI.Layout

import NesySolverAPI.Types

%default total

---------------------------------------------------------------------------
-- ProverKind (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
proverKindSize : Nat
proverKindSize = 1

||| Tag assignments:
|||   Z3=0, CVC5=1, Coq=2, Lean=3, Idris2=4, Agda=5, Isabelle=6, Dafny=7, FStar=8
public export
proverKindToTag : ProverKind -> Bits8
proverKindToTag Z3       = 0
proverKindToTag CVC5     = 1
proverKindToTag Coq      = 2
proverKindToTag Lean     = 3
proverKindToTag Idris2   = 4
proverKindToTag Agda     = 5
proverKindToTag Isabelle = 6
proverKindToTag Dafny    = 7
proverKindToTag FStar    = 8

public export
tagToProverKind : Bits8 -> Maybe ProverKind
tagToProverKind 0 = Just Z3
tagToProverKind 1 = Just CVC5
tagToProverKind 2 = Just Coq
tagToProverKind 3 = Just Lean
tagToProverKind 4 = Just Idris2
tagToProverKind 5 = Just Agda
tagToProverKind 6 = Just Isabelle
tagToProverKind 7 = Just Dafny
tagToProverKind 8 = Just FStar
tagToProverKind _ = Nothing

||| Proof: encoding then decoding ProverKind is the identity.
public export
proverKindRoundtrip : (p : ProverKind) -> tagToProverKind (proverKindToTag p) = Just p
proverKindRoundtrip Z3       = Refl
proverKindRoundtrip CVC5     = Refl
proverKindRoundtrip Coq      = Refl
proverKindRoundtrip Lean     = Refl
proverKindRoundtrip Idris2   = Refl
proverKindRoundtrip Agda     = Refl
proverKindRoundtrip Isabelle = Refl
proverKindRoundtrip Dafny    = Refl
proverKindRoundtrip FStar    = Refl

---------------------------------------------------------------------------
-- InputLanguage (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
inputLanguageSize : Nat
inputLanguageSize = 1

public export
inputLanguageToTag : InputLanguage -> Bits8
inputLanguageToTag SMTLib  = 0
inputLanguageToTag LeanL   = 1
inputLanguageToTag CoqL    = 2
inputLanguageToTag Idris2L = 3
inputLanguageToTag AgdaL   = 4

public export
tagToInputLanguage : Bits8 -> Maybe InputLanguage
tagToInputLanguage 0 = Just SMTLib
tagToInputLanguage 1 = Just LeanL
tagToInputLanguage 2 = Just CoqL
tagToInputLanguage 3 = Just Idris2L
tagToInputLanguage 4 = Just AgdaL
tagToInputLanguage _ = Nothing

public export
inputLanguageRoundtrip : (l : InputLanguage) -> tagToInputLanguage (inputLanguageToTag l) = Just l
inputLanguageRoundtrip SMTLib  = Refl
inputLanguageRoundtrip LeanL   = Refl
inputLanguageRoundtrip CoqL    = Refl
inputLanguageRoundtrip Idris2L = Refl
inputLanguageRoundtrip AgdaL   = Refl

---------------------------------------------------------------------------
-- ObligationClass (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
obligationClassSize : Nat
obligationClassSize = 1

||| Tag assignments match the ClickHouse Enum8 order in verisimdb.
public export
obligationClassToTag : ObligationClass -> Bits8
obligationClassToTag Safety      = 0
obligationClassToTag Linearity   = 1
obligationClassToTag Termination = 2
obligationClassToTag Equiv       = 3
obligationClassToTag Correctness = 4
obligationClassToTag Confluence  = 5
obligationClassToTag Totality    = 6
obligationClassToTag Invariant   = 7
obligationClassToTag Refinement  = 8
obligationClassToTag ModelCheck  = 9
obligationClassToTag OtherClass  = 10

public export
tagToObligationClass : Bits8 -> Maybe ObligationClass
tagToObligationClass 0  = Just Safety
tagToObligationClass 1  = Just Linearity
tagToObligationClass 2  = Just Termination
tagToObligationClass 3  = Just Equiv
tagToObligationClass 4  = Just Correctness
tagToObligationClass 5  = Just Confluence
tagToObligationClass 6  = Just Totality
tagToObligationClass 7  = Just Invariant
tagToObligationClass 8  = Just Refinement
tagToObligationClass 9  = Just ModelCheck
tagToObligationClass 10 = Just OtherClass
tagToObligationClass _  = Nothing

public export
obligationClassRoundtrip : (c : ObligationClass) -> tagToObligationClass (obligationClassToTag c) = Just c
obligationClassRoundtrip Safety      = Refl
obligationClassRoundtrip Linearity   = Refl
obligationClassRoundtrip Termination = Refl
obligationClassRoundtrip Equiv       = Refl
obligationClassRoundtrip Correctness = Refl
obligationClassRoundtrip Confluence  = Refl
obligationClassRoundtrip Totality    = Refl
obligationClassRoundtrip Invariant   = Refl
obligationClassRoundtrip Refinement  = Refl
obligationClassRoundtrip ModelCheck  = Refl
obligationClassRoundtrip OtherClass  = Refl

---------------------------------------------------------------------------
-- ProveOutcome (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
proveOutcomeSize : Nat
proveOutcomeSize = 1

public export
proveOutcomeToTag : ProveOutcome -> Bits8
proveOutcomeToTag Success = 0
proveOutcomeToTag Failure = 1
proveOutcomeToTag Timeout = 2
proveOutcomeToTag Unknown = 3

public export
tagToProveOutcome : Bits8 -> Maybe ProveOutcome
tagToProveOutcome 0 = Just Success
tagToProveOutcome 1 = Just Failure
tagToProveOutcome 2 = Just Timeout
tagToProveOutcome 3 = Just Unknown
tagToProveOutcome _ = Nothing

public export
proveOutcomeRoundtrip : (o : ProveOutcome) -> tagToProveOutcome (proveOutcomeToTag o) = Just o
proveOutcomeRoundtrip Success = Refl
proveOutcomeRoundtrip Failure = Refl
proveOutcomeRoundtrip Timeout = Refl
proveOutcomeRoundtrip Unknown = Refl

---------------------------------------------------------------------------
-- SessionState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Idle        = 0
sessionStateToTag Dispatching = 1
sessionStateToTag Recording   = 2
sessionStateToTag FailedS     = 3

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Idle
tagToSessionState 1 = Just Dispatching
tagToSessionState 2 = Just Recording
tagToSessionState 3 = Just FailedS
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Idle        = Refl
sessionStateRoundtrip Dispatching = Refl
sessionStateRoundtrip Recording   = Refl
sessionStateRoundtrip FailedS     = Refl

---------------------------------------------------------------------------
-- SurfaceKind (16 constructors, tags 0-15)
---------------------------------------------------------------------------

public export
surfaceKindSize : Nat
surfaceKindSize = 1

public export
surfaceKindToTag : SurfaceKind -> Bits8
surfaceKindToTag SREST       = 0
surfaceKindToTag SGraphQL    = 1
surfaceKindToTag SWebSocket  = 2
surfaceKindToTag SSSE        = 3
surfaceKindToTag SGRPC       = 4
surfaceKindToTag SJSONRPC    = 5
surfaceKindToTag SMsgPackRPC = 6
surfaceKindToTag SCBOR       = 7
surfaceKindToTag SFlatbuf    = 8
surfaceKindToTag SCapnProto  = 9
surfaceKindToTag SBebop      = 10
surfaceKindToTag STRPC       = 11
surfaceKindToTag SMQTT       = 12
surfaceKindToTag SAMQP       = 13
surfaceKindToTag SSOAP       = 14
surfaceKindToTag SVerisimDB  = 15

public export
tagToSurfaceKind : Bits8 -> Maybe SurfaceKind
tagToSurfaceKind 0  = Just SREST
tagToSurfaceKind 1  = Just SGraphQL
tagToSurfaceKind 2  = Just SWebSocket
tagToSurfaceKind 3  = Just SSSE
tagToSurfaceKind 4  = Just SGRPC
tagToSurfaceKind 5  = Just SJSONRPC
tagToSurfaceKind 6  = Just SMsgPackRPC
tagToSurfaceKind 7  = Just SCBOR
tagToSurfaceKind 8  = Just SFlatbuf
tagToSurfaceKind 9  = Just SCapnProto
tagToSurfaceKind 10 = Just SBebop
tagToSurfaceKind 11 = Just STRPC
tagToSurfaceKind 12 = Just SMQTT
tagToSurfaceKind 13 = Just SAMQP
tagToSurfaceKind 14 = Just SSOAP
tagToSurfaceKind 15 = Just SVerisimDB
tagToSurfaceKind _  = Nothing

public export
surfaceKindRoundtrip : (s : SurfaceKind) -> tagToSurfaceKind (surfaceKindToTag s) = Just s
surfaceKindRoundtrip SREST       = Refl
surfaceKindRoundtrip SGraphQL    = Refl
surfaceKindRoundtrip SWebSocket  = Refl
surfaceKindRoundtrip SSSE        = Refl
surfaceKindRoundtrip SGRPC       = Refl
surfaceKindRoundtrip SJSONRPC    = Refl
surfaceKindRoundtrip SMsgPackRPC = Refl
surfaceKindRoundtrip SCBOR       = Refl
surfaceKindRoundtrip SFlatbuf    = Refl
surfaceKindRoundtrip SCapnProto  = Refl
surfaceKindRoundtrip SBebop      = Refl
surfaceKindRoundtrip STRPC       = Refl
surfaceKindRoundtrip SMQTT       = Refl
surfaceKindRoundtrip SAMQP       = Refl
surfaceKindRoundtrip SSOAP       = Refl
surfaceKindRoundtrip SVerisimDB  = Refl
