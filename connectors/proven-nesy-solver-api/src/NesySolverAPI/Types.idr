-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- NesySolverAPI.Types: Core type definitions for the neurosymbolic proof
-- playground interface.  Closed sum types for prover kinds, input languages,
-- obligation classes, prove outcomes, and session states.  These types
-- enforce that the boundary between the frontend and the prover backends
-- is type-safe — no raw enum strings flow across the ABI.
--
-- ObligationClass MUST stay in sync with the ClickHouse Enum8 in
-- verisimdb (proof_attempts table): safety, linearity, termination, equiv,
-- correctness, confluence, totality, invariant, refinement, model-check, other.

module NesySolverAPI.Types

%default total

---------------------------------------------------------------------------
-- ProverKind — the 9 theorem provers the playground can dispatch to.
---------------------------------------------------------------------------

||| A prover backend that echidna can orchestrate.  Names here MUST match
||| the strings echidna accepts at POST /api/verify ("prover" field).
public export
data ProverKind : Type where
  Z3       : ProverKind
  CVC5     : ProverKind
  Coq      : ProverKind
  Lean     : ProverKind
  Idris2   : ProverKind
  Agda     : ProverKind
  Isabelle : ProverKind
  Dafny    : ProverKind
  FStar    : ProverKind

public export
Show ProverKind where
  show Z3       = "Z3"
  show CVC5     = "CVC5"
  show Coq      = "Coq"
  show Lean     = "Lean"
  show Idris2   = "Idris2"
  show Agda     = "Agda"
  show Isabelle = "Isabelle"
  show Dafny    = "Dafny"
  show FStar    = "FStar"

public export
Eq ProverKind where
  Z3       == Z3       = True
  CVC5     == CVC5     = True
  Coq      == Coq      = True
  Lean     == Lean     = True
  Idris2   == Idris2   = True
  Agda     == Agda     = True
  Isabelle == Isabelle = True
  Dafny    == Dafny    = True
  FStar    == FStar    = True
  _        == _        = False

---------------------------------------------------------------------------
-- InputLanguage — the 5 input-text languages the playground accepts.
---------------------------------------------------------------------------

||| The source language of an obligation the user submits.  These are the
-- shapes CodeMirror highlights and that the dispatcher routes on.
public export
data InputLanguage : Type where
  SMTLib : InputLanguage
  LeanL  : InputLanguage
  CoqL   : InputLanguage
  Idris2L: InputLanguage
  AgdaL  : InputLanguage

public export
Show InputLanguage where
  show SMTLib  = "smtlib"
  show LeanL   = "lean"
  show CoqL    = "coq"
  show Idris2L = "idris2"
  show AgdaL   = "agda"

---------------------------------------------------------------------------
-- ObligationClass — mirrors the ClickHouse Enum8 in verisimdb.
---------------------------------------------------------------------------

||| The category of proof obligation.  This classification drives
||| strategy recommendations: different classes have different top-prover
||| distributions in the proof_attempts table.
|||
||| Must stay in sync with:
|||   verisimdb/rust-core/verisim-api/src/proof_attempts.rs (Enum8 definition)
public export
data ObligationClass : Type where
  Safety       : ObligationClass
  Linearity    : ObligationClass
  Termination  : ObligationClass
  Equiv        : ObligationClass
  Correctness  : ObligationClass
  Confluence   : ObligationClass
  Totality     : ObligationClass
  Invariant    : ObligationClass
  Refinement   : ObligationClass
  ModelCheck   : ObligationClass
  OtherClass   : ObligationClass

public export
Show ObligationClass where
  show Safety       = "safety"
  show Linearity    = "linearity"
  show Termination  = "termination"
  show Equiv        = "equiv"
  show Correctness  = "correctness"
  show Confluence   = "confluence"
  show Totality     = "totality"
  show Invariant    = "invariant"
  show Refinement   = "refinement"
  show ModelCheck   = "model-check"
  show OtherClass   = "other"

---------------------------------------------------------------------------
-- ProveOutcome — verdict categories aligned with verisim-api.
---------------------------------------------------------------------------

||| The four possible outcomes of a proof attempt.  Matches the "outcome"
||| field in the proof_attempts table.
public export
data ProveOutcome : Type where
  Success : ProveOutcome
  Failure : ProveOutcome
  Timeout : ProveOutcome
  Unknown : ProveOutcome

public export
Show ProveOutcome where
  show Success = "success"
  show Failure = "failure"
  show Timeout = "timeout"
  show Unknown = "unknown"

---------------------------------------------------------------------------
-- SessionState — state machine for a playground session.
---------------------------------------------------------------------------

||| The lifecycle state of a single prove-dispatch session.  Transitions:
|||
|||   Idle --(submit)--> Dispatching --(verdict)--> Recording --(done)--> Idle
|||   Idle --(submit)--> Dispatching --(error)--> Failed --(reset)--> Idle
|||
||| See NesySolverAPIABI.Transitions for the formal ValidTransition GADT.
public export
data SessionState : Type where
  Idle        : SessionState
  Dispatching : SessionState
  Recording   : SessionState
  FailedS     : SessionState

public export
Show SessionState where
  show Idle        = "Idle"
  show Dispatching = "Dispatching"
  show Recording   = "Recording"
  show FailedS     = "FailedS"

---------------------------------------------------------------------------
-- SurfaceKind — which of the 16 hexadeca surfaces a request arrived on.
---------------------------------------------------------------------------

||| Which zig protocol surface a request came in on.  The 16 surfaces
||| from v_api_interfaces/ that the proven-nesy-solver-api wraps.
public export
data SurfaceKind : Type where
  SREST       : SurfaceKind
  SGraphQL    : SurfaceKind
  SWebSocket  : SurfaceKind
  SSSE        : SurfaceKind
  SGRPC       : SurfaceKind
  SJSONRPC    : SurfaceKind
  SMsgPackRPC : SurfaceKind
  SCBOR       : SurfaceKind
  SFlatbuf    : SurfaceKind
  SCapnProto  : SurfaceKind
  SBebop      : SurfaceKind
  STRPC       : SurfaceKind
  SMQTT       : SurfaceKind
  SAMQP       : SurfaceKind
  SSOAP       : SurfaceKind
  SVerisimDB  : SurfaceKind

public export
Show SurfaceKind where
  show SREST       = "rest"
  show SGraphQL    = "graphql"
  show SWebSocket  = "websocket"
  show SSSE        = "sse"
  show SGRPC       = "grpc"
  show SJSONRPC    = "jsonrpc"
  show SMsgPackRPC = "msgpack-rpc"
  show SCBOR       = "cbor"
  show SFlatbuf    = "flatbuffers"
  show SCapnProto  = "capnproto"
  show SBebop      = "bebop"
  show STRPC       = "trpc"
  show SMQTT       = "mqtt"
  show SAMQP       = "amqp"
  show SSOAP       = "soap"
  show SVerisimDB  = "verisimdb"
