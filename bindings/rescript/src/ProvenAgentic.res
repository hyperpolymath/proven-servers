// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI types for the proven-servers ABI.
//
// Mirrors the Idris2 module AgenticABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// AgentState (tags 0-6)
// ===========================================================================

/// AI agent lifecycle states.
type agentState =
  | @as(0) Idle
  | @as(1) Planning
  | @as(2) Acting
  | @as(3) Observing
  | @as(4) Reflecting
  | @as(5) Blocked
  | @as(6) Terminated

/// Decode from the C-ABI tag value.
let agentStateFromTag = (tag: int): option<agentState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Planning)
  | 2 => Some(Acting)
  | 3 => Some(Observing)
  | 4 => Some(Reflecting)
  | 5 => Some(Blocked)
  | 6 => Some(Terminated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let agentStateToTag = (v: agentState): int =>
  switch v {
  | Idle => 0
  | Planning => 1
  | Acting => 2
  | Observing => 3
  | Reflecting => 4
  | Blocked => 5
  | Terminated => 6
  }

/// Whether the agent is actively working.
let agentStateIsActive = (v: agentState): bool =>
  switch v {
  | Planning | Acting | Observing | Reflecting => true
  | _ => false
  }

// ===========================================================================
// ToolCall (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type toolCall =
  | @as(0) Execute
  | @as(1) Query
  | @as(2) Transform
  | @as(3) Communicate
  | @as(4) Delegate
  | @as(5) Escalate

/// Decode from the C-ABI tag value.
let toolCallFromTag = (tag: int): option<toolCall> =>
  switch tag {
  | 0 => Some(Execute)
  | 1 => Some(Query)
  | 2 => Some(Transform)
  | 3 => Some(Communicate)
  | 4 => Some(Delegate)
  | 5 => Some(Escalate)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let toolCallToTag = (v: toolCall): int =>
  switch v {
  | Execute => 0
  | Query => 1
  | Transform => 2
  | Communicate => 3
  | Delegate => 4
  | Escalate => 5
  }

// ===========================================================================
// PlanStep (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type planStep =
  | @as(0) Action
  | @as(1) Condition
  | @as(2) Loop
  | @as(3) Branch
  | @as(4) Parallel
  | @as(5) Checkpoint
  | @as(6) Rollback

/// Decode from the C-ABI tag value.
let planStepFromTag = (tag: int): option<planStep> =>
  switch tag {
  | 0 => Some(Action)
  | 1 => Some(Condition)
  | 2 => Some(Loop)
  | 3 => Some(Branch)
  | 4 => Some(Parallel)
  | 5 => Some(Checkpoint)
  | 6 => Some(Rollback)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let planStepToTag = (v: planStep): int =>
  switch v {
  | Action => 0
  | Condition => 1
  | Loop => 2
  | Branch => 3
  | Parallel => 4
  | Checkpoint => 5
  | Rollback => 6
  }

// ===========================================================================
// Coordination (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type coordination =
  | @as(0) Solo
  | @as(1) Collaborative
  | @as(2) Competitive
  | @as(3) Hierarchical
  | @as(4) Swarm
  | @as(5) Consensus

/// Decode from the C-ABI tag value.
let coordinationFromTag = (tag: int): option<coordination> =>
  switch tag {
  | 0 => Some(Solo)
  | 1 => Some(Collaborative)
  | 2 => Some(Competitive)
  | 3 => Some(Hierarchical)
  | 4 => Some(Swarm)
  | 5 => Some(Consensus)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let coordinationToTag = (v: coordination): int =>
  switch v {
  | Solo => 0
  | Collaborative => 1
  | Competitive => 2
  | Hierarchical => 3
  | Swarm => 4
  | Consensus => 5
  }

// ===========================================================================
// SafetyCheck (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type safetyCheck =
  | @as(0) Approved
  | @as(1) Denied
  | @as(2) Escalated
  | @as(3) Timeout
  | @as(4) Sandboxed
  | @as(5) HumanRequired

/// Decode from the C-ABI tag value.
let safetyCheckFromTag = (tag: int): option<safetyCheck> =>
  switch tag {
  | 0 => Some(Approved)
  | 1 => Some(Denied)
  | 2 => Some(Escalated)
  | 3 => Some(Timeout)
  | 4 => Some(Sandboxed)
  | 5 => Some(HumanRequired)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let safetyCheckToTag = (v: safetyCheck): int =>
  switch v {
  | Approved => 0
  | Denied => 1
  | Escalated => 2
  | Timeout => 3
  | Sandboxed => 4
  | HumanRequired => 5
  }

/// Whether the action is approved to proceed.
let safetyCheckIsSafe = (v: safetyCheck): bool =>
  switch v {
  | Approved | Sandboxed => true
  | _ => false
  }

