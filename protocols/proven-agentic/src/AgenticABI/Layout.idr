-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AgenticABI.Layout: C-ABI-compatible numeric representations of agentic types.
--
-- Maps every constructor of the agentic domain types (AgentState, ToolCall,
-- PlanStep, Coordination, SafetyCheck, MemoryType) to fixed Bits8 values
-- for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/agentic.h) and the
-- Zig FFI enums (ffi/zig/src/agentic.zig) exactly.

module AgenticABI.Layout

import Agentic.Types

%default total

---------------------------------------------------------------------------
-- AgentState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| C-ABI representation size for AgentState (1 byte).
public export
agentStateSize : Nat
agentStateSize = 1

||| Map AgentState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Idle       = 0
|||   Planning   = 1
|||   Acting     = 2
|||   Observing  = 3
|||   Reflecting = 4
|||   Blocked    = 5
|||   Terminated = 6
public export
agentStateToTag : AgentState -> Bits8
agentStateToTag Idle       = 0
agentStateToTag Planning   = 1
agentStateToTag Acting     = 2
agentStateToTag Observing  = 3
agentStateToTag Reflecting = 4
agentStateToTag Blocked    = 5
agentStateToTag Terminated = 6

||| Recover AgentState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-6.
public export
tagToAgentState : Bits8 -> Maybe AgentState
tagToAgentState 0 = Just Idle
tagToAgentState 1 = Just Planning
tagToAgentState 2 = Just Acting
tagToAgentState 3 = Just Observing
tagToAgentState 4 = Just Reflecting
tagToAgentState 5 = Just Blocked
tagToAgentState 6 = Just Terminated
tagToAgentState _ = Nothing

||| Proof: encoding then decoding AgentState is the identity.
public export
agentStateRoundtrip : (s : AgentState) -> tagToAgentState (agentStateToTag s) = Just s
agentStateRoundtrip Idle       = Refl
agentStateRoundtrip Planning   = Refl
agentStateRoundtrip Acting     = Refl
agentStateRoundtrip Observing  = Refl
agentStateRoundtrip Reflecting = Refl
agentStateRoundtrip Blocked    = Refl
agentStateRoundtrip Terminated = Refl

---------------------------------------------------------------------------
-- ToolCall (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for ToolCall (1 byte).
public export
toolCallSize : Nat
toolCallSize = 1

||| Map ToolCall to its C-ABI byte value.
|||
||| Tag assignments:
|||   Execute     = 0
|||   Query       = 1
|||   Transform   = 2
|||   Communicate = 3
|||   Delegate    = 4
|||   Escalate    = 5
public export
toolCallToTag : ToolCall -> Bits8
toolCallToTag Execute     = 0
toolCallToTag Query       = 1
toolCallToTag Transform   = 2
toolCallToTag Communicate = 3
toolCallToTag Delegate    = 4
toolCallToTag Escalate    = 5

||| Recover ToolCall from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToToolCall : Bits8 -> Maybe ToolCall
tagToToolCall 0 = Just Execute
tagToToolCall 1 = Just Query
tagToToolCall 2 = Just Transform
tagToToolCall 3 = Just Communicate
tagToToolCall 4 = Just Delegate
tagToToolCall 5 = Just Escalate
tagToToolCall _ = Nothing

||| Proof: encoding then decoding ToolCall is the identity.
public export
toolCallRoundtrip : (t : ToolCall) -> tagToToolCall (toolCallToTag t) = Just t
toolCallRoundtrip Execute     = Refl
toolCallRoundtrip Query       = Refl
toolCallRoundtrip Transform   = Refl
toolCallRoundtrip Communicate = Refl
toolCallRoundtrip Delegate    = Refl
toolCallRoundtrip Escalate    = Refl

---------------------------------------------------------------------------
-- PlanStep (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| C-ABI representation size for PlanStep (1 byte).
public export
planStepSize : Nat
planStepSize = 1

||| Map PlanStep to its C-ABI byte value.
|||
||| Tag assignments:
|||   Action     = 0
|||   Condition  = 1
|||   Loop       = 2
|||   Branch     = 3
|||   Parallel   = 4
|||   Checkpoint = 5
|||   Rollback   = 6
public export
planStepToTag : PlanStep -> Bits8
planStepToTag Action     = 0
planStepToTag Condition  = 1
planStepToTag Loop       = 2
planStepToTag Branch     = 3
planStepToTag Parallel   = 4
planStepToTag Checkpoint = 5
planStepToTag Rollback   = 6

||| Recover PlanStep from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-6.
public export
tagToPlanStep : Bits8 -> Maybe PlanStep
tagToPlanStep 0 = Just Action
tagToPlanStep 1 = Just Condition
tagToPlanStep 2 = Just Loop
tagToPlanStep 3 = Just Branch
tagToPlanStep 4 = Just Parallel
tagToPlanStep 5 = Just Checkpoint
tagToPlanStep 6 = Just Rollback
tagToPlanStep _ = Nothing

||| Proof: encoding then decoding PlanStep is the identity.
public export
planStepRoundtrip : (p : PlanStep) -> tagToPlanStep (planStepToTag p) = Just p
planStepRoundtrip Action     = Refl
planStepRoundtrip Condition  = Refl
planStepRoundtrip Loop       = Refl
planStepRoundtrip Branch     = Refl
planStepRoundtrip Parallel   = Refl
planStepRoundtrip Checkpoint = Refl
planStepRoundtrip Rollback   = Refl

---------------------------------------------------------------------------
-- Coordination (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for Coordination (1 byte).
public export
coordinationSize : Nat
coordinationSize = 1

||| Map Coordination to its C-ABI byte value.
|||
||| Tag assignments:
|||   Solo          = 0
|||   Collaborative = 1
|||   Competitive   = 2
|||   Hierarchical  = 3
|||   Swarm         = 4
|||   Consensus     = 5
public export
coordinationToTag : Coordination -> Bits8
coordinationToTag Solo          = 0
coordinationToTag Collaborative = 1
coordinationToTag Competitive   = 2
coordinationToTag Hierarchical  = 3
coordinationToTag Swarm         = 4
coordinationToTag Consensus     = 5

||| Recover Coordination from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToCoordination : Bits8 -> Maybe Coordination
tagToCoordination 0 = Just Solo
tagToCoordination 1 = Just Collaborative
tagToCoordination 2 = Just Competitive
tagToCoordination 3 = Just Hierarchical
tagToCoordination 4 = Just Swarm
tagToCoordination 5 = Just Consensus
tagToCoordination _ = Nothing

||| Proof: encoding then decoding Coordination is the identity.
public export
coordinationRoundtrip : (c : Coordination) -> tagToCoordination (coordinationToTag c) = Just c
coordinationRoundtrip Solo          = Refl
coordinationRoundtrip Collaborative = Refl
coordinationRoundtrip Competitive   = Refl
coordinationRoundtrip Hierarchical  = Refl
coordinationRoundtrip Swarm         = Refl
coordinationRoundtrip Consensus     = Refl

---------------------------------------------------------------------------
-- SafetyCheck (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for SafetyCheck (1 byte).
public export
safetyCheckSize : Nat
safetyCheckSize = 1

||| Map SafetyCheck to its C-ABI byte value.
|||
||| Tag assignments:
|||   Approved      = 0
|||   Denied        = 1
|||   Escalated     = 2
|||   Timeout       = 3
|||   Sandboxed     = 4
|||   HumanRequired = 5
public export
safetyCheckToTag : SafetyCheck -> Bits8
safetyCheckToTag Approved      = 0
safetyCheckToTag Denied        = 1
safetyCheckToTag Escalated     = 2
safetyCheckToTag Timeout       = 3
safetyCheckToTag Sandboxed     = 4
safetyCheckToTag HumanRequired = 5

||| Recover SafetyCheck from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToSafetyCheck : Bits8 -> Maybe SafetyCheck
tagToSafetyCheck 0 = Just Approved
tagToSafetyCheck 1 = Just Denied
tagToSafetyCheck 2 = Just Escalated
tagToSafetyCheck 3 = Just Timeout
tagToSafetyCheck 4 = Just Sandboxed
tagToSafetyCheck 5 = Just HumanRequired
tagToSafetyCheck _ = Nothing

||| Proof: encoding then decoding SafetyCheck is the identity.
public export
safetyCheckRoundtrip : (s : SafetyCheck) -> tagToSafetyCheck (safetyCheckToTag s) = Just s
safetyCheckRoundtrip Approved      = Refl
safetyCheckRoundtrip Denied        = Refl
safetyCheckRoundtrip Escalated     = Refl
safetyCheckRoundtrip Timeout       = Refl
safetyCheckRoundtrip Sandboxed     = Refl
safetyCheckRoundtrip HumanRequired = Refl

---------------------------------------------------------------------------
-- MemoryType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for MemoryType (1 byte).
public export
memoryTypeSize : Nat
memoryTypeSize = 1

||| Map MemoryType to its C-ABI byte value.
|||
||| Tag assignments:
|||   Working    = 0
|||   Episodic   = 1
|||   Semantic   = 2
|||   Procedural = 3
|||   Shared     = 4
public export
memoryTypeToTag : MemoryType -> Bits8
memoryTypeToTag Working    = 0
memoryTypeToTag Episodic   = 1
memoryTypeToTag Semantic   = 2
memoryTypeToTag Procedural = 3
memoryTypeToTag Shared     = 4

||| Recover MemoryType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToMemoryType : Bits8 -> Maybe MemoryType
tagToMemoryType 0 = Just Working
tagToMemoryType 1 = Just Episodic
tagToMemoryType 2 = Just Semantic
tagToMemoryType 3 = Just Procedural
tagToMemoryType 4 = Just Shared
tagToMemoryType _ = Nothing

||| Proof: encoding then decoding MemoryType is the identity.
public export
memoryTypeRoundtrip : (m : MemoryType) -> tagToMemoryType (memoryTypeToTag m) = Just m
memoryTypeRoundtrip Working    = Refl
memoryTypeRoundtrip Episodic   = Refl
memoryTypeRoundtrip Semantic   = Refl
memoryTypeRoundtrip Procedural = Refl
memoryTypeRoundtrip Shared     = Refl

---------------------------------------------------------------------------
-- AgenticError (8 constructors, tags 0-7)
-- Error codes returned by agentic FFI operations.
---------------------------------------------------------------------------

||| Error codes for agentic FFI operations.
public export
data AgenticError : Type where
  ||| No error.
  AgOk               : AgenticError
  ||| Invalid slot index.
  AgInvalidSlot      : AgenticError
  ||| Agent not active.
  AgNotActive        : AgenticError
  ||| Invalid state transition.
  AgInvalidTransition : AgenticError
  ||| Agent is blocked and cannot proceed.
  AgBlocked          : AgenticError
  ||| Tool call limit exceeded.
  AgToolLimitExceeded : AgenticError
  ||| Plan depth limit exceeded.
  AgPlanDepthExceeded : AgenticError
  ||| Safety check denied the action.
  AgSafetyDenied     : AgenticError

public export
Eq AgenticError where
  AgOk                == AgOk                = True
  AgInvalidSlot       == AgInvalidSlot       = True
  AgNotActive         == AgNotActive         = True
  AgInvalidTransition == AgInvalidTransition = True
  AgBlocked           == AgBlocked           = True
  AgToolLimitExceeded == AgToolLimitExceeded = True
  AgPlanDepthExceeded == AgPlanDepthExceeded = True
  AgSafetyDenied      == AgSafetyDenied      = True
  _                   == _                   = False

public export
Show AgenticError where
  show AgOk                = "Ok"
  show AgInvalidSlot       = "InvalidSlot"
  show AgNotActive         = "NotActive"
  show AgInvalidTransition = "InvalidTransition"
  show AgBlocked           = "Blocked"
  show AgToolLimitExceeded = "ToolLimitExceeded"
  show AgPlanDepthExceeded = "PlanDepthExceeded"
  show AgSafetyDenied      = "SafetyDenied"

||| C-ABI representation size for AgenticError (1 byte).
public export
agenticErrorSize : Nat
agenticErrorSize = 1

||| Map AgenticError to its C-ABI byte value.
|||
||| Tag assignments:
|||   AgOk                = 0
|||   AgInvalidSlot       = 1
|||   AgNotActive         = 2
|||   AgInvalidTransition = 3
|||   AgBlocked           = 4
|||   AgToolLimitExceeded = 5
|||   AgPlanDepthExceeded = 6
|||   AgSafetyDenied      = 7
public export
agenticErrorToTag : AgenticError -> Bits8
agenticErrorToTag AgOk                = 0
agenticErrorToTag AgInvalidSlot       = 1
agenticErrorToTag AgNotActive         = 2
agenticErrorToTag AgInvalidTransition = 3
agenticErrorToTag AgBlocked           = 4
agenticErrorToTag AgToolLimitExceeded = 5
agenticErrorToTag AgPlanDepthExceeded = 6
agenticErrorToTag AgSafetyDenied      = 7

||| Recover AgenticError from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToAgenticError : Bits8 -> Maybe AgenticError
tagToAgenticError 0 = Just AgOk
tagToAgenticError 1 = Just AgInvalidSlot
tagToAgenticError 2 = Just AgNotActive
tagToAgenticError 3 = Just AgInvalidTransition
tagToAgenticError 4 = Just AgBlocked
tagToAgenticError 5 = Just AgToolLimitExceeded
tagToAgenticError 6 = Just AgPlanDepthExceeded
tagToAgenticError 7 = Just AgSafetyDenied
tagToAgenticError _ = Nothing

||| Proof: encoding then decoding AgenticError is the identity.
public export
agenticErrorRoundtrip : (e : AgenticError) -> tagToAgenticError (agenticErrorToTag e) = Just e
agenticErrorRoundtrip AgOk                = Refl
agenticErrorRoundtrip AgInvalidSlot       = Refl
agenticErrorRoundtrip AgNotActive         = Refl
agenticErrorRoundtrip AgInvalidTransition = Refl
agenticErrorRoundtrip AgBlocked           = Refl
agenticErrorRoundtrip AgToolLimitExceeded = Refl
agenticErrorRoundtrip AgPlanDepthExceeded = Refl
agenticErrorRoundtrip AgSafetyDenied      = Refl
