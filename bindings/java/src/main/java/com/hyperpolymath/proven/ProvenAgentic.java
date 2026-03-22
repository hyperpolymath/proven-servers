// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Agentic AI protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenAgentic {
    private ProvenAgentic() {}

    /** AgentState (tags 0-6). */
    public enum AgentState {
        IDLE(0),
        PLANNING(1),
        ACTING(2),
        OBSERVING(3),
        REFLECTING(4),
        BLOCKED(5),
        TERMINATED(6);

        private final int tag;
        AgentState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AgentState fromTag(int tag) {
            for (AgentState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ToolCall (tags 0-5). */
    public enum ToolCall {
        EXECUTE(0),
        QUERY(1),
        TRANSFORM(2),
        COMMUNICATE(3),
        DELEGATE(4),
        ESCALATE(5);

        private final int tag;
        ToolCall(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ToolCall fromTag(int tag) {
            for (ToolCall v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PlanStep (tags 0-6). */
    public enum PlanStep {
        ACTION(0),
        CONDITION(1),
        LOOP(2),
        BRANCH(3),
        PARALLEL(4),
        CHECKPOINT(5),
        ROLLBACK(6);

        private final int tag;
        PlanStep(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PlanStep fromTag(int tag) {
            for (PlanStep v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Coordination (tags 0-5). */
    public enum Coordination {
        SOLO(0),
        COLLABORATIVE(1),
        COMPETITIVE(2),
        HIERARCHICAL(3),
        SWARM(4),
        CONSENSUS(5);

        private final int tag;
        Coordination(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Coordination fromTag(int tag) {
            for (Coordination v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SafetyCheck (tags 0-5). */
    public enum SafetyCheck {
        APPROVED(0),
        DENIED(1),
        ESCALATED(2),
        TIMEOUT(3),
        SANDBOXED(4),
        HUMAN_REQUIRED(5);

        private final int tag;
        SafetyCheck(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SafetyCheck fromTag(int tag) {
            for (SafetyCheck v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
