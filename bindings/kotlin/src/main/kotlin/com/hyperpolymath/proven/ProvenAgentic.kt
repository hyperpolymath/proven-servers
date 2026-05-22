// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

package com.hyperpolymath.proven

/** AgentState matching the Idris2 ABI tags. */
enum class AgentState(val tag: Int) {
    IDLE(0),
    PLANNING(1),
    ACTING(2),
    OBSERVING(3),
    REFLECTING(4),
    BLOCKED(5),
    TERMINATED(6);

    companion object {
        fun fromTag(tag: Int): AgentState? = entries.find { it.tag == tag }
    }
}

/** ToolCall matching the Idris2 ABI tags. */
enum class ToolCall(val tag: Int) {
    EXECUTE(0),
    QUERY(1),
    TRANSFORM(2),
    COMMUNICATE(3),
    DELEGATE(4),
    ESCALATE(5);

    companion object {
        fun fromTag(tag: Int): ToolCall? = entries.find { it.tag == tag }
    }
}

/** PlanStep matching the Idris2 ABI tags. */
enum class PlanStep(val tag: Int) {
    ACTION(0),
    CONDITION(1),
    LOOP(2),
    BRANCH(3),
    PARALLEL(4),
    CHECKPOINT(5),
    ROLLBACK(6);

    companion object {
        fun fromTag(tag: Int): PlanStep? = entries.find { it.tag == tag }
    }
}

/** Coordination matching the Idris2 ABI tags. */
enum class Coordination(val tag: Int) {
    SOLO(0),
    COLLABORATIVE(1),
    COMPETITIVE(2),
    HIERARCHICAL(3),
    SWARM(4),
    CONSENSUS(5);

    companion object {
        fun fromTag(tag: Int): Coordination? = entries.find { it.tag == tag }
    }
}

/** SafetyCheck matching the Idris2 ABI tags. */
enum class SafetyCheck(val tag: Int) {
    APPROVED(0),
    DENIED(1),
    ESCALATED(2),
    TIMEOUT(3),
    SANDBOXED(4),
    HUMAN_REQUIRED(5);

    companion object {
        fun fromTag(tag: Int): SafetyCheck? = entries.find { it.tag == tag }
    }
}
