// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

/** AgentState matching the Idris2 ABI tags. */
export const AgentState = Object.freeze({
  IDLE: 0,
  PLANNING: 1,
  ACTING: 2,
  OBSERVING: 3,
  REFLECTING: 4,
  BLOCKED: 5,
  TERMINATED: 6,
});

/** ToolCall matching the Idris2 ABI tags. */
export const ToolCall = Object.freeze({
  EXECUTE: 0,
  QUERY: 1,
  TRANSFORM: 2,
  COMMUNICATE: 3,
  DELEGATE: 4,
  ESCALATE: 5,
});

/** PlanStep matching the Idris2 ABI tags. */
export const PlanStep = Object.freeze({
  ACTION: 0,
  CONDITION: 1,
  LOOP: 2,
  BRANCH: 3,
  PARALLEL: 4,
  CHECKPOINT: 5,
  ROLLBACK: 6,
});

/** Coordination matching the Idris2 ABI tags. */
export const Coordination = Object.freeze({
  SOLO: 0,
  COLLABORATIVE: 1,
  COMPETITIVE: 2,
  HIERARCHICAL: 3,
  SWARM: 4,
  CONSENSUS: 5,
});

/** SafetyCheck matching the Idris2 ABI tags. */
export const SafetyCheck = Object.freeze({
  APPROVED: 0,
  DENIED: 1,
  ESCALATED: 2,
  TIMEOUT: 3,
  SANDBOXED: 4,
  HUMAN_REQUIRED: 5,
});
