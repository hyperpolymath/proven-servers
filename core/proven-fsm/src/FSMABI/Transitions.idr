-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FSMABI.Transitions: Valid state transition proofs for FSM lifecycle.
--
-- This module defines the heart of the formal verification layer for the
-- generic FSM primitive.  It models the lifecycle of a state machine itself
-- (not the states within a user-defined machine, but the machine's own lifecycle):
--
--   Initial --Start--> Running --Complete--> Terminal
--      |                  |
--      +---Fault--->   Fault---> Faulted
--      |                                    |
--      +---Reset (from Faulted) --> Initial
--
-- Every arrow has exactly one ValidMachineTransition constructor.
-- The type system prevents any transition not listed here.

module FSMABI.Transitions

import FSM.Types

%default total

---------------------------------------------------------------------------
-- ValidMachineTransition: exhaustive enumeration of legal lifecycle transitions.
---------------------------------------------------------------------------

||| Proof witness that a machine lifecycle transition is valid.
||| Only constructors for legal transitions exist — the type system
||| prevents any transition not listed here.
public export
data ValidMachineTransition : MachineState -> MachineState -> Type where
  ||| Initial -> Running (machine has been started).
  StartMachine    : ValidMachineTransition Initial Running
  ||| Running -> Terminal (machine reached an accepting state).
  CompleteMachine : ValidMachineTransition Running Terminal
  ||| Running -> Faulted (machine encountered a fatal error).
  FaultRunning    : ValidMachineTransition Running Faulted
  ||| Initial -> Faulted (machine failed during initialisation).
  FaultInitial    : ValidMachineTransition Initial Faulted
  ||| Faulted -> Initial (machine has been reset after a fault).
  ResetMachine    : ValidMachineTransition Faulted Initial

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a machine is in a state where it can accept events.
||| Only Running machines can process events.
public export
data CanAcceptEvents : MachineState -> Type where
  RunningCanAccept : CanAcceptEvents Running

||| Proof that a machine is in a state where it can be started.
||| Only Initial machines can be started.
public export
data CanStart : MachineState -> Type where
  InitialCanStart : CanStart Initial

||| Proof that a machine is in a state where it can be reset.
||| Only Faulted machines can be reset.
public export
data CanReset : MachineState -> Type where
  FaultedCanReset : CanReset Faulted

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| A Terminal machine cannot transition to Running.
||| Terminal is a sink state — once complete, no more transitions.
public export
terminalCannotRun : ValidMachineTransition Terminal Running -> Void
terminalCannotRun _ impossible

||| A Terminal machine cannot be started.
public export
terminalCannotStart : ValidMachineTransition Terminal Initial -> Void
terminalCannotStart _ impossible

||| A Running machine cannot go back to Initial without faulting first.
public export
runningCannotRestart : ValidMachineTransition Running Initial -> Void
runningCannotRestart _ impossible

---------------------------------------------------------------------------
-- Transition validation function
---------------------------------------------------------------------------

||| Check whether a transition between two machine states is valid.
||| Returns the proof witness if valid, Nothing otherwise.
public export
validateTransition : (from : MachineState) -> (to : MachineState) -> Maybe (ValidMachineTransition from to)
validateTransition Initial Running  = Just StartMachine
validateTransition Running Terminal = Just CompleteMachine
validateTransition Running Faulted  = Just FaultRunning
validateTransition Initial Faulted  = Just FaultInitial
validateTransition Faulted Initial  = Just ResetMachine
validateTransition _ _              = Nothing
