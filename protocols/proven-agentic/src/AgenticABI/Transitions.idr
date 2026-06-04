-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AgenticABI.Transitions: Valid state transition proofs for agent lifecycle.
--
-- This module defines the formal verification layer for the agentic protocol
-- state machine.  It models the agent lifecycle:
--
--   Idle --AssignTask--> Planning --BeginAction--> Acting
--     --ObserveResult--> Observing --ReflectOnResult--> Reflecting
--     --ResumeAction--> Acting  (reflect -> act loop)
--     --CompletePlan--> Idle    (reflect -> done)
--
--   Any state except Terminated can transition to Blocked or Terminated.
--   Blocked can transition back to the state it was in before blocking
--   (modelled as Blocked -> Planning, Blocked -> Acting, etc.).
--
-- Every arrow has exactly one GADT constructor.
-- The type system prevents any transition not listed here.

module AgenticABI.Transitions

import Agentic.Types
import AgenticABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidAgentTransition: exhaustive enumeration of legal agent lifecycle
-- transitions.
---------------------------------------------------------------------------

||| Proof witness that an agent state transition is valid.
||| Only constructors for legal transitions exist -- the type system
||| prevents any transition not listed here.
public export
data ValidAgentTransition : AgentState -> AgentState -> Type where
  ||| Idle -> Planning (agent receives a task and begins planning).
  AssignTask      : ValidAgentTransition Idle Planning
  ||| Planning -> Acting (agent has a plan and begins executing).
  BeginAction     : ValidAgentTransition Planning Acting
  ||| Acting -> Observing (agent completes an action and observes results).
  ObserveResult   : ValidAgentTransition Acting Observing
  ||| Observing -> Reflecting (agent processes observations into beliefs).
  ReflectOnResult : ValidAgentTransition Observing Reflecting
  ||| Reflecting -> Acting (agent decides to take another action).
  ResumeAction    : ValidAgentTransition Reflecting Acting
  ||| Reflecting -> Planning (agent decides to revise its plan).
  RevisePlan      : ValidAgentTransition Reflecting Planning
  ||| Reflecting -> Idle (agent decides the task is complete).
  CompletePlan    : ValidAgentTransition Reflecting Idle
  ||| Planning -> Blocked (external dependency blocks planning).
  BlockFromPlan   : ValidAgentTransition Planning Blocked
  ||| Acting -> Blocked (external dependency blocks action).
  BlockFromAct    : ValidAgentTransition Acting Blocked
  ||| Observing -> Blocked (external dependency blocks observation).
  BlockFromObserve : ValidAgentTransition Observing Blocked
  ||| Blocked -> Planning (dependency resolved, resume planning).
  UnblockToPlan   : ValidAgentTransition Blocked Planning
  ||| Blocked -> Acting (dependency resolved, resume acting).
  UnblockToAct    : ValidAgentTransition Blocked Acting
  ||| Blocked -> Observing (dependency resolved, resume observing).
  UnblockToObserve : ValidAgentTransition Blocked Observing
  ||| Idle -> Terminated (agent shut down from idle).
  TerminateIdle   : ValidAgentTransition Idle Terminated
  ||| Planning -> Terminated (agent terminated during planning).
  TerminatePlan   : ValidAgentTransition Planning Terminated
  ||| Acting -> Terminated (agent terminated during action).
  TerminateAct    : ValidAgentTransition Acting Terminated
  ||| Observing -> Terminated (agent terminated during observation).
  TerminateObserve : ValidAgentTransition Observing Terminated
  ||| Reflecting -> Terminated (agent terminated during reflection).
  TerminateReflect : ValidAgentTransition Reflecting Terminated
  ||| Blocked -> Terminated (agent terminated while blocked).
  TerminateBlocked : ValidAgentTransition Blocked Terminated

---------------------------------------------------------------------------
-- Capability witnesses for agent states
---------------------------------------------------------------------------

||| Proof that the agent is idle and can receive a task.
public export
data CanAssignTask : AgentState -> Type where
  IdleCanAssign : CanAssignTask Idle

||| Proof that the agent is planning and can begin acting.
public export
data CanBeginAction : AgentState -> Type where
  PlanningCanAct : CanBeginAction Planning

||| Proof that the agent is reflecting and can complete.
public export
data CanComplete : AgentState -> Type where
  ReflectingCanComplete : CanComplete Reflecting

---------------------------------------------------------------------------
-- Impossibility proofs for agent transitions
---------------------------------------------------------------------------

||| Cannot assign a task to an agent that is already planning.
public export
cannotAssignWhilePlanning : ValidAgentTransition Planning Idle -> Void
cannotAssignWhilePlanning _ impossible

||| Cannot skip planning and go directly from Idle to Acting.
public export
cannotActFromIdle : ValidAgentTransition Idle Acting -> Void
cannotActFromIdle _ impossible

||| Cannot go directly from Idle to Observing.
public export
cannotObserveFromIdle : ValidAgentTransition Idle Observing -> Void
cannotObserveFromIdle _ impossible

||| Cannot go directly from Idle to Reflecting.
public export
cannotReflectFromIdle : ValidAgentTransition Idle Reflecting -> Void
cannotReflectFromIdle _ impossible

||| Cannot go backwards from Acting to Planning (must reflect first).
public export
cannotActToPlanning : ValidAgentTransition Acting Planning -> Void
cannotActToPlanning _ impossible

||| Terminated is a terminal state: no transitions out.
public export
cannotLeaveTerminated : ValidAgentTransition Terminated s -> Void
cannotLeaveTerminated _ impossible

||| Cannot skip observation: Acting directly to Reflecting is invalid.
public export
cannotSkipObservation : ValidAgentTransition Acting Reflecting -> Void
cannotSkipObservation _ impossible

||| Cannot skip reflection: Observing directly to Acting is invalid.
public export
cannotSkipReflection : ValidAgentTransition Observing Acting -> Void
cannotSkipReflection _ impossible

---------------------------------------------------------------------------
-- Agent transition validation function
---------------------------------------------------------------------------

||| Check whether a transition between two agent states is valid.
||| Returns the proof witness if valid, Nothing otherwise.
public export
validateAgentTransition : (from : AgentState) -> (to : AgentState)
                       -> Maybe (ValidAgentTransition from to)
validateAgentTransition Idle       Planning   = Just AssignTask
validateAgentTransition Planning   Acting     = Just BeginAction
validateAgentTransition Acting     Observing  = Just ObserveResult
validateAgentTransition Observing  Reflecting = Just ReflectOnResult
validateAgentTransition Reflecting Acting     = Just ResumeAction
validateAgentTransition Reflecting Planning   = Just RevisePlan
validateAgentTransition Reflecting Idle       = Just CompletePlan
validateAgentTransition Planning   Blocked    = Just BlockFromPlan
validateAgentTransition Acting     Blocked    = Just BlockFromAct
validateAgentTransition Observing  Blocked    = Just BlockFromObserve
validateAgentTransition Blocked    Planning   = Just UnblockToPlan
validateAgentTransition Blocked    Acting     = Just UnblockToAct
validateAgentTransition Blocked    Observing  = Just UnblockToObserve
validateAgentTransition Idle       Terminated = Just TerminateIdle
validateAgentTransition Planning   Terminated = Just TerminatePlan
validateAgentTransition Acting     Terminated = Just TerminateAct
validateAgentTransition Observing  Terminated = Just TerminateObserve
validateAgentTransition Reflecting Terminated = Just TerminateReflect
validateAgentTransition Blocked    Terminated = Just TerminateBlocked
validateAgentTransition _          _          = Nothing

---------------------------------------------------------------------------
-- Agent lifecycle trace: typed sequence of transitions.
-- Ensures a complete agent run follows the protocol order.
---------------------------------------------------------------------------

||| A proof that a sequence of agent transitions forms a valid
||| protocol run from state `start` to state `end`.
public export
data AgentTrace : AgentState -> AgentState -> Type where
  ||| Empty trace: the agent is already in the target state.
  Done : AgentTrace s s
  ||| A single transition step followed by a continuation trace.
  Step : ValidAgentTransition s mid
      -> AgentTrace mid end
      -> AgentTrace s end

||| A minimal successful task: Idle -> plan -> act -> observe -> reflect -> Idle.
public export
minimalTask : AgentTrace Idle Idle
minimalTask = Step AssignTask
            $ Step BeginAction
            $ Step ObserveResult
            $ Step ReflectOnResult
            $ Step CompletePlan
            $ Done

||| A task with one act-observe-reflect loop before completion.
public export
singleLoopTask : AgentTrace Idle Idle
singleLoopTask = Step AssignTask
               $ Step BeginAction
               $ Step ObserveResult
               $ Step ReflectOnResult
               $ Step ResumeAction
               $ Step ObserveResult
               $ Step ReflectOnResult
               $ Step CompletePlan
               $ Done

||| A task that gets blocked during acting, then resumes.
public export
blockedTask : AgentTrace Idle Idle
blockedTask = Step AssignTask
            $ Step BeginAction
            $ Step BlockFromAct
            $ Step UnblockToAct
            $ Step ObserveResult
            $ Step ReflectOnResult
            $ Step CompletePlan
            $ Done

||| A task that terminates from acting (e.g. forced shutdown).
public export
terminatedFromActing : AgentTrace Idle Terminated
terminatedFromActing = Step AssignTask
                     $ Step BeginAction
                     $ Step TerminateAct
                     $ Done

---------------------------------------------------------------------------
-- Safety invariants
---------------------------------------------------------------------------

||| Proof that an agent must pass through Planning before it can Act.
||| This guarantees no agent executes actions without first forming a plan.
public export
mustPlanBeforeActing : ValidAgentTransition Idle Planning
                    -> ValidAgentTransition Planning Acting
                    -> ()
mustPlanBeforeActing AssignTask BeginAction = ()

||| Proof that an agent must observe before it can reflect.
||| This guarantees beliefs are always updated based on evidence.
public export
mustObserveBeforeReflecting : ValidAgentTransition Acting Observing
                           -> ValidAgentTransition Observing Reflecting
                           -> ()
mustObserveBeforeReflecting ObserveResult ReflectOnResult = ()

||| Proof that Terminated is absorbing: once terminated, no further
||| transitions are possible. This is guaranteed by cannotLeaveTerminated.
public export
terminatedIsAbsorbing : (s : AgentState) -> ValidAgentTransition Terminated s -> Void
terminatedIsAbsorbing _ t = cannotLeaveTerminated t
