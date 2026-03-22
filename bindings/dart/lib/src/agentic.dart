// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

/// AgentState matching the Idris2 ABI tags.
enum AgentState {
  idle(0),
  planning(1),
  acting(2),
  observing(3),
  reflecting(4),
  blocked(5),
  terminated(6);

  const AgentState(this.tag);
  final int tag;

  static AgentState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ToolCall matching the Idris2 ABI tags.
enum ToolCall {
  execute(0),
  query(1),
  transform(2),
  communicate(3),
  delegate(4),
  escalate(5);

  const ToolCall(this.tag);
  final int tag;

  static ToolCall? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PlanStep matching the Idris2 ABI tags.
enum PlanStep {
  action(0),
  condition(1),
  loop(2),
  branch(3),
  parallel(4),
  checkpoint(5),
  rollback(6);

  const PlanStep(this.tag);
  final int tag;

  static PlanStep? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Coordination matching the Idris2 ABI tags.
enum Coordination {
  solo(0),
  collaborative(1),
  competitive(2),
  hierarchical(3),
  swarm(4),
  consensus(5);

  const Coordination(this.tag);
  final int tag;

  static Coordination? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SafetyCheck matching the Idris2 ABI tags.
enum SafetyCheck {
  approved(0),
  denied(1),
  escalated(2),
  timeout(3),
  sandboxed(4),
  humanRequired(5);

  const SafetyCheck(this.tag);
  final int tag;

  static SafetyCheck? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
