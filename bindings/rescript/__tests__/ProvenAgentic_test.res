// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenAgentic protocol bindings.

open ProvenAgentic

let test_agentState_roundtrip = () => {
  assert(agentStateFromTag(0) == Some(Idle))
  assert(agentStateFromTag(1) == Some(Planning))
  assert(agentStateFromTag(2) == Some(Acting))
  assert(agentStateFromTag(3) == Some(Observing))
  assert(agentStateFromTag(4) == Some(Reflecting))
  assert(agentStateFromTag(5) == Some(Blocked))
  assert(agentStateFromTag(6) == Some(Terminated))
  assert(agentStateFromTag(7) == None)
}

let test_agentState_toTag = () => {
  assert(agentStateToTag(Idle) == 0)
  assert(agentStateToTag(Planning) == 1)
  assert(agentStateToTag(Acting) == 2)
  assert(agentStateToTag(Observing) == 3)
  assert(agentStateToTag(Reflecting) == 4)
  assert(agentStateToTag(Blocked) == 5)
  assert(agentStateToTag(Terminated) == 6)
}

let test_toolCall_roundtrip = () => {
  assert(toolCallFromTag(0) == Some(Execute))
  assert(toolCallFromTag(1) == Some(Query))
  assert(toolCallFromTag(2) == Some(Transform))
  assert(toolCallFromTag(3) == Some(Communicate))
  assert(toolCallFromTag(4) == Some(Delegate))
  assert(toolCallFromTag(5) == Some(Escalate))
  assert(toolCallFromTag(6) == None)
}

let test_toolCall_toTag = () => {
  assert(toolCallToTag(Execute) == 0)
  assert(toolCallToTag(Query) == 1)
  assert(toolCallToTag(Transform) == 2)
  assert(toolCallToTag(Communicate) == 3)
  assert(toolCallToTag(Delegate) == 4)
  assert(toolCallToTag(Escalate) == 5)
}

let test_planStep_roundtrip = () => {
  assert(planStepFromTag(0) == Some(Action))
  assert(planStepFromTag(1) == Some(Condition))
  assert(planStepFromTag(2) == Some(Loop))
  assert(planStepFromTag(3) == Some(Branch))
  assert(planStepFromTag(4) == Some(Parallel))
  assert(planStepFromTag(5) == Some(Checkpoint))
  assert(planStepFromTag(6) == Some(Rollback))
  assert(planStepFromTag(7) == None)
}

let test_planStep_toTag = () => {
  assert(planStepToTag(Action) == 0)
  assert(planStepToTag(Condition) == 1)
  assert(planStepToTag(Loop) == 2)
  assert(planStepToTag(Branch) == 3)
  assert(planStepToTag(Parallel) == 4)
  assert(planStepToTag(Checkpoint) == 5)
  assert(planStepToTag(Rollback) == 6)
}

let test_coordination_roundtrip = () => {
  assert(coordinationFromTag(0) == Some(Solo))
  assert(coordinationFromTag(1) == Some(Collaborative))
  assert(coordinationFromTag(2) == Some(Competitive))
  assert(coordinationFromTag(3) == Some(Hierarchical))
  assert(coordinationFromTag(4) == Some(Swarm))
  assert(coordinationFromTag(5) == Some(Consensus))
  assert(coordinationFromTag(6) == None)
}

let test_coordination_toTag = () => {
  assert(coordinationToTag(Solo) == 0)
  assert(coordinationToTag(Collaborative) == 1)
  assert(coordinationToTag(Competitive) == 2)
  assert(coordinationToTag(Hierarchical) == 3)
  assert(coordinationToTag(Swarm) == 4)
  assert(coordinationToTag(Consensus) == 5)
}

let test_safetyCheck_roundtrip = () => {
  assert(safetyCheckFromTag(0) == Some(Approved))
  assert(safetyCheckFromTag(1) == Some(Denied))
  assert(safetyCheckFromTag(2) == Some(Escalated))
  assert(safetyCheckFromTag(3) == Some(Timeout))
  assert(safetyCheckFromTag(4) == Some(Sandboxed))
  assert(safetyCheckFromTag(5) == Some(HumanRequired))
  assert(safetyCheckFromTag(6) == None)
}

let test_safetyCheck_toTag = () => {
  assert(safetyCheckToTag(Approved) == 0)
  assert(safetyCheckToTag(Denied) == 1)
  assert(safetyCheckToTag(Escalated) == 2)
  assert(safetyCheckToTag(Timeout) == 3)
  assert(safetyCheckToTag(Sandboxed) == 4)
  assert(safetyCheckToTag(HumanRequired) == 5)
}

// Run all tests
test_agentState_roundtrip()
test_agentState_toTag()
test_toolCall_roundtrip()
test_toolCall_toTag()
test_planStep_roundtrip()
test_planStep_toTag()
test_coordination_roundtrip()
test_coordination_toTag()
test_safetyCheck_roundtrip()
test_safetyCheck_toTag()
