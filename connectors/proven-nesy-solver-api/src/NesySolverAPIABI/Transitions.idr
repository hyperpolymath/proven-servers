-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NesySolverAPIABI.Transitions: Valid state transition proofs for a single
-- playground prove-dispatch session.
--
-- The session state machine:
--
--   Idle ----Submit----> Dispatching ----Verdict----> Recording
--    ^                       |                            |
--    |                       |                            |
--    +-------Reset-----------+                            |
--    |                       |                            |
--    |                       +-----DispatchFail----->  FailedS
--    |                                                    |
--    +-----------------Reset------------------------------+
--    |                                                    |
--    +-----<-----Done-----<-----  Recording               |
--                                                         |
--                                                 (Recording -> Idle
--                                                   via RecordDone)
--
-- Every legal arrow has exactly one ValidTransition constructor; the
-- type checker prevents any other transition.

module NesySolverAPIABI.Transitions

import NesySolverAPI.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition: exhaustive enumeration of legal session transitions.
---------------------------------------------------------------------------

||| Proof witness that a session-state transition is valid.
public export
data ValidTransition : SessionState -> SessionState -> Type where
  ||| Idle -> Dispatching (user submitted an obligation).
  Submit         : ValidTransition Idle Dispatching
  ||| Dispatching -> Recording (prover returned a verdict, ready to log).
  Verdict        : ValidTransition Dispatching Recording
  ||| Dispatching -> FailedS (echidna unreachable or malformed response).
  DispatchFail   : ValidTransition Dispatching FailedS
  ||| Recording -> Idle (proof_attempt row written, session ready for reuse).
  RecordDone     : ValidTransition Recording Idle
  ||| FailedS -> Idle (operator/user reset after a failure).
  Reset          : ValidTransition FailedS Idle

public export
Show (ValidTransition from to) where
  show Submit       = "Submit"
  show Verdict      = "Verdict"
  show DispatchFail = "DispatchFail"
  show RecordDone   = "RecordDone"
  show Reset        = "Reset"

---------------------------------------------------------------------------
-- CanDispatch: a state permits submitting new work.
---------------------------------------------------------------------------

||| Proof witness that a session in state `s` can accept a Submit.
||| Only Idle qualifies.
public export
data CanDispatch : SessionState -> Type where
  DispatchFromIdle : CanDispatch Idle

public export
Show (CanDispatch s) where
  show DispatchFromIdle = "CanDispatch Idle"

---------------------------------------------------------------------------
-- CanRecord: a state permits writing a proof_attempt row.
---------------------------------------------------------------------------

||| Proof witness that a session in state `s` can perform a Recording step.
||| Only Dispatching -> Recording is valid (via Verdict), so Recording
||| itself is the only state where a write is permitted.
public export
data CanRecord : SessionState -> Type where
  RecordFromRecording : CanRecord Recording

public export
Show (CanRecord s) where
  show RecordFromRecording = "CanRecord Recording"

---------------------------------------------------------------------------
-- Impossibility proofs.
---------------------------------------------------------------------------

||| You cannot Submit from Dispatching — the session is already busy.
public export
cannotSubmitFromDispatching : ValidTransition Dispatching Idle -> Void
cannotSubmitFromDispatching _ impossible

||| You cannot skip Recording — Dispatching -> Idle is not legal.
public export
cannotSkipRecording : ValidTransition Dispatching Idle -> Void
cannotSkipRecording _ impossible

||| You cannot transition from FailedS to anything except Idle (via Reset).
public export
cannotLeaveFailedSExceptReset : ValidTransition FailedS Recording -> Void
cannotLeaveFailedSExceptReset _ impossible

---------------------------------------------------------------------------
-- Decidability: given two states, decide whether a transition exists.
---------------------------------------------------------------------------

||| Decision procedure: is there a legal transition from `from` to `to`?
||| Returns either a proof witness or a contradiction.
public export
decideTransition : (from, to : SessionState) -> Dec (ValidTransition from to)
decideTransition Idle        Dispatching = Yes Submit
decideTransition Dispatching Recording   = Yes Verdict
decideTransition Dispatching FailedS     = Yes DispatchFail
decideTransition Recording   Idle        = Yes RecordDone
decideTransition FailedS     Idle        = Yes Reset
-- All other pairs: no valid transition.
decideTransition Idle        Idle        = No (\p => case p of _ impossible)
decideTransition Idle        Recording   = No (\p => case p of _ impossible)
decideTransition Idle        FailedS     = No (\p => case p of _ impossible)
decideTransition Dispatching Idle        = No (\p => case p of _ impossible)
decideTransition Dispatching Dispatching = No (\p => case p of _ impossible)
decideTransition Recording   Dispatching = No (\p => case p of _ impossible)
decideTransition Recording   Recording   = No (\p => case p of _ impossible)
decideTransition Recording   FailedS     = No (\p => case p of _ impossible)
decideTransition FailedS     Dispatching = No (\p => case p of _ impossible)
decideTransition FailedS     Recording   = No (\p => case p of _ impossible)
decideTransition FailedS     FailedS     = No (\p => case p of _ impossible)
