-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AgenticABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into agentic_abi_gen.zig for the comptime guard.

module AgenticABI.Emit

import Agentic.Types
import AgenticABI.Layout
import AgenticABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "STATE" "IDLE"       (agentStateToTag Idle)
  , line "STATE" "PLANNING"   (agentStateToTag Planning)
  , line "STATE" "ACTING"     (agentStateToTag Acting)
  , line "STATE" "OBSERVING"  (agentStateToTag Observing)
  , line "STATE" "REFLECTING" (agentStateToTag Reflecting)
  , line "STATE" "BLOCKED"    (agentStateToTag Blocked)
  , line "STATE" "TERMINATED" (agentStateToTag Terminated)
  , line "TOOL" "EXECUTE"     (toolCallToTag Execute)
  , line "TOOL" "QUERY"       (toolCallToTag Query)
  , line "TOOL" "TRANSFORM"   (toolCallToTag Transform)
  , line "TOOL" "COMMUNICATE" (toolCallToTag Communicate)
  , line "TOOL" "DELEGATE"    (toolCallToTag Delegate)
  , line "TOOL" "ESCALATE"    (toolCallToTag Escalate)
  , line "STEP" "ACTION"     (planStepToTag Action)
  , line "STEP" "CONDITION"  (planStepToTag Condition)
  , line "STEP" "LOOP"       (planStepToTag Loop)
  , line "STEP" "BRANCH"     (planStepToTag Branch)
  , line "STEP" "PARALLEL"   (planStepToTag Parallel)
  , line "STEP" "CHECKPOINT" (planStepToTag Checkpoint)
  , line "STEP" "ROLLBACK"   (planStepToTag Rollback)
  , line "COORD" "SOLO"          (coordinationToTag Solo)
  , line "COORD" "COLLABORATIVE" (coordinationToTag Collaborative)
  , line "COORD" "COMPETITIVE"   (coordinationToTag Competitive)
  , line "COORD" "HIERARCHICAL"  (coordinationToTag Hierarchical)
  , line "COORD" "SWARM"         (coordinationToTag Swarm)
  , line "COORD" "CONSENSUS"     (coordinationToTag Consensus)
  , line "SAFETY" "APPROVED"       (safetyCheckToTag Approved)
  , line "SAFETY" "DENIED"         (safetyCheckToTag Denied)
  , line "SAFETY" "ESCALATED"      (safetyCheckToTag Escalated)
  , line "SAFETY" "TIMEOUT"        (safetyCheckToTag Timeout)
  , line "SAFETY" "SANDBOXED"      (safetyCheckToTag Sandboxed)
  , line "SAFETY" "HUMAN_REQUIRED" (safetyCheckToTag HumanRequired)
  , line "MEM" "WORKING"    (memoryTypeToTag Working)
  , line "MEM" "EPISODIC"   (memoryTypeToTag Episodic)
  , line "MEM" "SEMANTIC"   (memoryTypeToTag Semantic)
  , line "MEM" "PROCEDURAL" (memoryTypeToTag Procedural)
  , line "MEM" "SHARED"     (memoryTypeToTag Shared)
  , line "ERR" "OK"                  (agenticErrorToTag AgOk)
  , line "ERR" "INVALID_SLOT"        (agenticErrorToTag AgInvalidSlot)
  , line "ERR" "NOT_ACTIVE"          (agenticErrorToTag AgNotActive)
  , line "ERR" "INVALID_TRANSITION"  (agenticErrorToTag AgInvalidTransition)
  , line "ERR" "BLOCKED"             (agenticErrorToTag AgBlocked)
  , line "ERR" "TOOL_LIMIT_EXCEEDED" (agenticErrorToTag AgToolLimitExceeded)
  , line "ERR" "PLAN_DEPTH_EXCEEDED" (agenticErrorToTag AgPlanDepthExceeded)
  , line "ERR" "SAFETY_DENIED"       (agenticErrorToTag AgSafetyDenied)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
