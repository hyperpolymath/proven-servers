-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AgenticABI.Types: C-ABI-compatible numeric representations of Agentic types.
--
-- Maps every constructor of the core Agentic sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/agentic.zig) exactly.
--
-- Types covered:
--   AgentState                (7 constructors, tags 0-6)
--   ToolCall                  (6 constructors, tags 0-5)
--   PlanStep                  (7 constructors, tags 0-6)
--   Coordination              (6 constructors, tags 0-5)
--   SafetyCheck               (6 constructors, tags 0-5)
--   MemoryType                (5 constructors, tags 0-4)
--   AgenticError              (8 constructors, tags 0-7)

module AgenticABI.Types

%default total

---------------------------------------------------------------------------
-- AgentState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
agent_stateSize : Nat
agent_stateSize = 1

||| AgentState sum type for ABI encoding.
public export
data AgentState : Type where
  Idle : AgentState
  Planning : AgentState
  Acting : AgentState
  Observing : AgentState
  Reflecting : AgentState
  Blocked : AgentState
  Terminated : AgentState

||| Encode a AgentState to its ABI tag value.
public export
agent_stateToTag : AgentState -> Bits8
agent_stateToTag Idle = 0
agent_stateToTag Planning = 1
agent_stateToTag Acting = 2
agent_stateToTag Observing = 3
agent_stateToTag Reflecting = 4
agent_stateToTag Blocked = 5
agent_stateToTag Terminated = 6

||| Decode an ABI tag to a AgentState.
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

||| Roundtrip proof: decoding an encoded AgentState yields the original.
public export
agent_stateRoundtrip : (x : AgentState) -> tagToAgentState (agent_stateToTag x) = Just x
agent_stateRoundtrip Idle = Refl
agent_stateRoundtrip Planning = Refl
agent_stateRoundtrip Acting = Refl
agent_stateRoundtrip Observing = Refl
agent_stateRoundtrip Reflecting = Refl
agent_stateRoundtrip Blocked = Refl
agent_stateRoundtrip Terminated = Refl

---------------------------------------------------------------------------
-- ToolCall (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
tool_callSize : Nat
tool_callSize = 1

||| ToolCall sum type for ABI encoding.
public export
data ToolCall : Type where
  Execute : ToolCall
  Query : ToolCall
  Transform : ToolCall
  Communicate : ToolCall
  Delegate : ToolCall
  Escalate : ToolCall

||| Encode a ToolCall to its ABI tag value.
public export
tool_callToTag : ToolCall -> Bits8
tool_callToTag Execute = 0
tool_callToTag Query = 1
tool_callToTag Transform = 2
tool_callToTag Communicate = 3
tool_callToTag Delegate = 4
tool_callToTag Escalate = 5

||| Decode an ABI tag to a ToolCall.
public export
tagToToolCall : Bits8 -> Maybe ToolCall
tagToToolCall 0 = Just Execute
tagToToolCall 1 = Just Query
tagToToolCall 2 = Just Transform
tagToToolCall 3 = Just Communicate
tagToToolCall 4 = Just Delegate
tagToToolCall 5 = Just Escalate
tagToToolCall _ = Nothing

||| Roundtrip proof: decoding an encoded ToolCall yields the original.
public export
tool_callRoundtrip : (x : ToolCall) -> tagToToolCall (tool_callToTag x) = Just x
tool_callRoundtrip Execute = Refl
tool_callRoundtrip Query = Refl
tool_callRoundtrip Transform = Refl
tool_callRoundtrip Communicate = Refl
tool_callRoundtrip Delegate = Refl
tool_callRoundtrip Escalate = Refl

---------------------------------------------------------------------------
-- PlanStep (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
plan_stepSize : Nat
plan_stepSize = 1

||| PlanStep sum type for ABI encoding.
public export
data PlanStep : Type where
  Action : PlanStep
  Condition : PlanStep
  Loop : PlanStep
  Branch : PlanStep
  Parallel : PlanStep
  Checkpoint : PlanStep
  Rollback : PlanStep

||| Encode a PlanStep to its ABI tag value.
public export
plan_stepToTag : PlanStep -> Bits8
plan_stepToTag Action = 0
plan_stepToTag Condition = 1
plan_stepToTag Loop = 2
plan_stepToTag Branch = 3
plan_stepToTag Parallel = 4
plan_stepToTag Checkpoint = 5
plan_stepToTag Rollback = 6

||| Decode an ABI tag to a PlanStep.
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

||| Roundtrip proof: decoding an encoded PlanStep yields the original.
public export
plan_stepRoundtrip : (x : PlanStep) -> tagToPlanStep (plan_stepToTag x) = Just x
plan_stepRoundtrip Action = Refl
plan_stepRoundtrip Condition = Refl
plan_stepRoundtrip Loop = Refl
plan_stepRoundtrip Branch = Refl
plan_stepRoundtrip Parallel = Refl
plan_stepRoundtrip Checkpoint = Refl
plan_stepRoundtrip Rollback = Refl

---------------------------------------------------------------------------
-- Coordination (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
coordinationSize : Nat
coordinationSize = 1

||| Coordination sum type for ABI encoding.
public export
data Coordination : Type where
  Solo : Coordination
  Collaborative : Coordination
  Competitive : Coordination
  Hierarchical : Coordination
  Swarm : Coordination
  Consensus : Coordination

||| Encode a Coordination to its ABI tag value.
public export
coordinationToTag : Coordination -> Bits8
coordinationToTag Solo = 0
coordinationToTag Collaborative = 1
coordinationToTag Competitive = 2
coordinationToTag Hierarchical = 3
coordinationToTag Swarm = 4
coordinationToTag Consensus = 5

||| Decode an ABI tag to a Coordination.
public export
tagToCoordination : Bits8 -> Maybe Coordination
tagToCoordination 0 = Just Solo
tagToCoordination 1 = Just Collaborative
tagToCoordination 2 = Just Competitive
tagToCoordination 3 = Just Hierarchical
tagToCoordination 4 = Just Swarm
tagToCoordination 5 = Just Consensus
tagToCoordination _ = Nothing

||| Roundtrip proof: decoding an encoded Coordination yields the original.
public export
coordinationRoundtrip : (x : Coordination) -> tagToCoordination (coordinationToTag x) = Just x
coordinationRoundtrip Solo = Refl
coordinationRoundtrip Collaborative = Refl
coordinationRoundtrip Competitive = Refl
coordinationRoundtrip Hierarchical = Refl
coordinationRoundtrip Swarm = Refl
coordinationRoundtrip Consensus = Refl

---------------------------------------------------------------------------
-- SafetyCheck (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
safety_checkSize : Nat
safety_checkSize = 1

||| SafetyCheck sum type for ABI encoding.
public export
data SafetyCheck : Type where
  Approved : SafetyCheck
  Denied : SafetyCheck
  Escalated : SafetyCheck
  Timeout : SafetyCheck
  Sandboxed : SafetyCheck
  HumanRequired : SafetyCheck

||| Encode a SafetyCheck to its ABI tag value.
public export
safety_checkToTag : SafetyCheck -> Bits8
safety_checkToTag Approved = 0
safety_checkToTag Denied = 1
safety_checkToTag Escalated = 2
safety_checkToTag Timeout = 3
safety_checkToTag Sandboxed = 4
safety_checkToTag HumanRequired = 5

||| Decode an ABI tag to a SafetyCheck.
public export
tagToSafetyCheck : Bits8 -> Maybe SafetyCheck
tagToSafetyCheck 0 = Just Approved
tagToSafetyCheck 1 = Just Denied
tagToSafetyCheck 2 = Just Escalated
tagToSafetyCheck 3 = Just Timeout
tagToSafetyCheck 4 = Just Sandboxed
tagToSafetyCheck 5 = Just HumanRequired
tagToSafetyCheck _ = Nothing

||| Roundtrip proof: decoding an encoded SafetyCheck yields the original.
public export
safety_checkRoundtrip : (x : SafetyCheck) -> tagToSafetyCheck (safety_checkToTag x) = Just x
safety_checkRoundtrip Approved = Refl
safety_checkRoundtrip Denied = Refl
safety_checkRoundtrip Escalated = Refl
safety_checkRoundtrip Timeout = Refl
safety_checkRoundtrip Sandboxed = Refl
safety_checkRoundtrip HumanRequired = Refl

---------------------------------------------------------------------------
-- MemoryType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
memory_typeSize : Nat
memory_typeSize = 1

||| MemoryType sum type for ABI encoding.
public export
data MemoryType : Type where
  Working : MemoryType
  Episodic : MemoryType
  Semantic : MemoryType
  Procedural : MemoryType
  Shared : MemoryType

||| Encode a MemoryType to its ABI tag value.
public export
memory_typeToTag : MemoryType -> Bits8
memory_typeToTag Working = 0
memory_typeToTag Episodic = 1
memory_typeToTag Semantic = 2
memory_typeToTag Procedural = 3
memory_typeToTag Shared = 4

||| Decode an ABI tag to a MemoryType.
public export
tagToMemoryType : Bits8 -> Maybe MemoryType
tagToMemoryType 0 = Just Working
tagToMemoryType 1 = Just Episodic
tagToMemoryType 2 = Just Semantic
tagToMemoryType 3 = Just Procedural
tagToMemoryType 4 = Just Shared
tagToMemoryType _ = Nothing

||| Roundtrip proof: decoding an encoded MemoryType yields the original.
public export
memory_typeRoundtrip : (x : MemoryType) -> tagToMemoryType (memory_typeToTag x) = Just x
memory_typeRoundtrip Working = Refl
memory_typeRoundtrip Episodic = Refl
memory_typeRoundtrip Semantic = Refl
memory_typeRoundtrip Procedural = Refl
memory_typeRoundtrip Shared = Refl

---------------------------------------------------------------------------
-- AgenticError (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
agentic_errorSize : Nat
agentic_errorSize = 1

||| AgenticError sum type for ABI encoding.
public export
data AgenticError : Type where
  Ok : AgenticError
  InvalidSlot : AgenticError
  NotActive : AgenticError
  InvalidTransition : AgenticError
  Blocked : AgenticError
  ToolLimitExceeded : AgenticError
  PlanDepthExceeded : AgenticError
  SafetyDenied : AgenticError

||| Encode a AgenticError to its ABI tag value.
public export
agentic_errorToTag : AgenticError -> Bits8
agentic_errorToTag Ok = 0
agentic_errorToTag InvalidSlot = 1
agentic_errorToTag NotActive = 2
agentic_errorToTag InvalidTransition = 3
agentic_errorToTag Blocked = 4
agentic_errorToTag ToolLimitExceeded = 5
agentic_errorToTag PlanDepthExceeded = 6
agentic_errorToTag SafetyDenied = 7

||| Decode an ABI tag to a AgenticError.
public export
tagToAgenticError : Bits8 -> Maybe AgenticError
tagToAgenticError 0 = Just Ok
tagToAgenticError 1 = Just InvalidSlot
tagToAgenticError 2 = Just NotActive
tagToAgenticError 3 = Just InvalidTransition
tagToAgenticError 4 = Just Blocked
tagToAgenticError 5 = Just ToolLimitExceeded
tagToAgenticError 6 = Just PlanDepthExceeded
tagToAgenticError 7 = Just SafetyDenied
tagToAgenticError _ = Nothing

||| Roundtrip proof: decoding an encoded AgenticError yields the original.
public export
agentic_errorRoundtrip : (x : AgenticError) -> tagToAgenticError (agentic_errorToTag x) = Just x
agentic_errorRoundtrip Ok = Refl
agentic_errorRoundtrip InvalidSlot = Refl
agentic_errorRoundtrip NotActive = Refl
agentic_errorRoundtrip InvalidTransition = Refl
agentic_errorRoundtrip Blocked = Refl
agentic_errorRoundtrip ToolLimitExceeded = Refl
agentic_errorRoundtrip PlanDepthExceeded = Refl
agentic_errorRoundtrip SafetyDenied = Refl
