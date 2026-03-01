-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FSM.Types: Core type definitions for linear finite state machines.
-- Closed sum types representing transition results, validation errors,
-- machine states, and event dispositions. Use-once transitions consume
-- the old state and produce the new one — states cannot be reused.

module FSM.Types

%default total

---------------------------------------------------------------------------
-- Transition result — the outcome of attempting a state transition.
---------------------------------------------------------------------------

||| The result of attempting a state transition.
public export
data TransitionResult : Type where
  ||| The transition was accepted and the state has changed.
  Accepted : TransitionResult
  ||| The transition was rejected (invalid from current state).
  Rejected : TransitionResult
  ||| The transition is valid but deferred for later execution.
  Deferred : TransitionResult

public export
Show TransitionResult where
  show Accepted = "Accepted"
  show Rejected = "Rejected"
  show Deferred = "Deferred"

---------------------------------------------------------------------------
-- Validation error — why a transition was rejected.
---------------------------------------------------------------------------

||| Reasons a transition can fail validation.
public export
data ValidationError : Type where
  ||| The transition is not valid from the current state.
  InvalidTransition   : ValidationError
  ||| A precondition guard was not satisfied.
  PreconditionFailed  : ValidationError
  ||| A postcondition check was not satisfied.
  PostconditionFailed : ValidationError
  ||| A guard function returned false.
  GuardFailed         : ValidationError

public export
Show ValidationError where
  show InvalidTransition   = "InvalidTransition"
  show PreconditionFailed  = "PreconditionFailed"
  show PostconditionFailed = "PostconditionFailed"
  show GuardFailed         = "GuardFailed"

---------------------------------------------------------------------------
-- Machine state — the lifecycle state of the state machine itself.
---------------------------------------------------------------------------

||| The lifecycle state of a finite state machine.
public export
data MachineState : Type where
  ||| The machine has been created but not started.
  Initial  : MachineState
  ||| The machine is running and accepting transitions.
  Running  : MachineState
  ||| The machine has reached a terminal (accepting) state.
  Terminal : MachineState
  ||| The machine has encountered a fatal error.
  Faulted  : MachineState

public export
Show MachineState where
  show Initial  = "Initial"
  show Running  = "Running"
  show Terminal = "Terminal"
  show Faulted  = "Faulted"

---------------------------------------------------------------------------
-- Event disposition — what happened to an event after processing.
---------------------------------------------------------------------------

||| What happened to an event after it was submitted to the machine.
public export
data EventDisposition : Type where
  ||| The event was consumed and triggered a transition.
  Consumed : EventDisposition
  ||| The event was not applicable and was ignored.
  Ignored  : EventDisposition
  ||| The event was queued for later processing.
  Queued   : EventDisposition
  ||| The event was dropped (e.g., queue full).
  Dropped  : EventDisposition

public export
Show EventDisposition where
  show Consumed = "Consumed"
  show Ignored  = "Ignored"
  show Queued   = "Queued"
  show Dropped  = "Dropped"
