// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Agentic AI protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// AgentState represents the AgentState type (Idris2 ABI tags).
type AgentState uint8

const (
	AgentStateIdle AgentState = iota
	AgentStatePlanning
	AgentStateActing
	AgentStateObserving
	AgentStateReflecting
	AgentStateBlocked
	AgentStateTerminated
)

// ToolCall represents the ToolCall type (Idris2 ABI tags).
type ToolCall uint8

const (
	ToolCallExecute ToolCall = iota
	ToolCallQuery
	ToolCallTransform
	ToolCallCommunicate
	ToolCallDelegate
	ToolCallEscalate
)

// PlanStep represents the PlanStep type (Idris2 ABI tags).
type PlanStep uint8

const (
	PlanStepAction PlanStep = iota
	PlanStepCondition
	PlanStepLoop
	PlanStepBranch
	PlanStepParallel
	PlanStepCheckpoint
	PlanStepRollback
)

// Coordination represents the Coordination type (Idris2 ABI tags).
type Coordination uint8

const (
	CoordinationSolo Coordination = iota
	CoordinationCollaborative
	CoordinationCompetitive
	CoordinationHierarchical
	CoordinationSwarm
	CoordinationConsensus
)

// SafetyCheck represents the SafetyCheck type (Idris2 ABI tags).
type SafetyCheck uint8

const (
	SafetyCheckApproved SafetyCheck = iota
	SafetyCheckDenied
	SafetyCheckEscalated
	SafetyCheckTimeout
	SafetyCheckSandboxed
	SafetyCheckHumanRequired
)
