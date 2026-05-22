//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Agentic AI protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `AgenticABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// AgentState
// ===========================================================================

/// AI agent lifecycle states.
/// 
/// Matches `AgentState` in `AgenticABI.Types`.
pub type AgentState {
  /// Idle (tag 0).
  Idle
  /// Planning (tag 1).
  Planning
  /// Acting (tag 2).
  Acting
  /// Observing (tag 3).
  Observing
  /// Reflecting (tag 4).
  Reflecting
  /// Blocked (tag 5).
  Blocked
  /// Terminated (tag 6).
  Terminated
}

/// Convert a `AgentState` to its C-ABI tag value.
pub fn agent_state_to_int(value: AgentState) -> Int {
  case value {
    Idle -> 0
    Planning -> 1
    Acting -> 2
    Observing -> 3
    Reflecting -> 4
    Blocked -> 5
    Terminated -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn agent_state_from_int(tag: Int) -> Result(AgentState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Planning)
    2 -> Ok(Acting)
    3 -> Ok(Observing)
    4 -> Ok(Reflecting)
    5 -> Ok(Blocked)
    6 -> Ok(Terminated)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ToolCall
// ===========================================================================

/// Agent tool call types.
/// 
/// Matches `ToolCall` in `AgenticABI.Types`.
pub type ToolCall {
  /// Execute (tag 0).
  Execute
  /// Query (tag 1).
  Query
  /// Transform (tag 2).
  Transform
  /// Communicate (tag 3).
  Communicate
  /// Delegate (tag 4).
  Delegate
  /// Escalate (tag 5).
  Escalate
}

/// Convert a `ToolCall` to its C-ABI tag value.
pub fn tool_call_to_int(value: ToolCall) -> Int {
  case value {
    Execute -> 0
    Query -> 1
    Transform -> 2
    Communicate -> 3
    Delegate -> 4
    Escalate -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn tool_call_from_int(tag: Int) -> Result(ToolCall, Nil) {
  case tag {
    0 -> Ok(Execute)
    1 -> Ok(Query)
    2 -> Ok(Transform)
    3 -> Ok(Communicate)
    4 -> Ok(Delegate)
    5 -> Ok(Escalate)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PlanStep
// ===========================================================================

/// Agent plan step types.
/// 
/// Matches `PlanStep` in `AgenticABI.Types`.
pub type PlanStep {
  /// Action (tag 0).
  Action
  /// Condition (tag 1).
  Condition
  /// Loop (tag 2).
  Loop
  /// Branch (tag 3).
  Branch
  /// Parallel (tag 4).
  Parallel
  /// Checkpoint (tag 5).
  Checkpoint
  /// Rollback (tag 6).
  Rollback
}

/// Convert a `PlanStep` to its C-ABI tag value.
pub fn plan_step_to_int(value: PlanStep) -> Int {
  case value {
    Action -> 0
    Condition -> 1
    Loop -> 2
    Branch -> 3
    Parallel -> 4
    Checkpoint -> 5
    Rollback -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn plan_step_from_int(tag: Int) -> Result(PlanStep, Nil) {
  case tag {
    0 -> Ok(Action)
    1 -> Ok(Condition)
    2 -> Ok(Loop)
    3 -> Ok(Branch)
    4 -> Ok(Parallel)
    5 -> Ok(Checkpoint)
    6 -> Ok(Rollback)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Coordination
// ===========================================================================

/// Multi-agent coordination modes.
/// 
/// Matches `Coordination` in `AgenticABI.Types`.
pub type Coordination {
  /// Solo (tag 0).
  Solo
  /// Collaborative (tag 1).
  Collaborative
  /// Competitive (tag 2).
  Competitive
  /// Hierarchical (tag 3).
  Hierarchical
  /// Swarm (tag 4).
  Swarm
  /// Consensus (tag 5).
  Consensus
}

/// Convert a `Coordination` to its C-ABI tag value.
pub fn coordination_to_int(value: Coordination) -> Int {
  case value {
    Solo -> 0
    Collaborative -> 1
    Competitive -> 2
    Hierarchical -> 3
    Swarm -> 4
    Consensus -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn coordination_from_int(tag: Int) -> Result(Coordination, Nil) {
  case tag {
    0 -> Ok(Solo)
    1 -> Ok(Collaborative)
    2 -> Ok(Competitive)
    3 -> Ok(Hierarchical)
    4 -> Ok(Swarm)
    5 -> Ok(Consensus)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SafetyCheck
// ===========================================================================

/// Agent safety check results.
/// 
/// Matches `SafetyCheck` in `AgenticABI.Types`.
pub type SafetyCheck {
  /// Approved (tag 0).
  Approved
  /// Denied (tag 1).
  Denied
  /// Escalated (tag 2).
  Escalated
  /// Timeout (tag 3).
  Timeout
  /// Sandboxed (tag 4).
  Sandboxed
  /// HumanRequired (tag 5).
  HumanRequired
}

/// Convert a `SafetyCheck` to its C-ABI tag value.
pub fn safety_check_to_int(value: SafetyCheck) -> Int {
  case value {
    Approved -> 0
    Denied -> 1
    Escalated -> 2
    Timeout -> 3
    Sandboxed -> 4
    HumanRequired -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn safety_check_from_int(tag: Int) -> Result(SafetyCheck, Nil) {
  case tag {
    0 -> Ok(Approved)
    1 -> Ok(Denied)
    2 -> Ok(Escalated)
    3 -> Ok(Timeout)
    4 -> Ok(Sandboxed)
    5 -> Ok(HumanRequired)
    _ -> Error(Nil)
  }
}

