// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

namespace Proven;

/// <summary>AgentState matching the Idris2 ABI tags (0-6).</summary>
public enum AgentState : byte
{
    Idle = 0,
    Planning = 1,
    Acting = 2,
    Observing = 3,
    Reflecting = 4,
    Blocked = 5,
    Terminated = 6
}

/// <summary>ToolCall matching the Idris2 ABI tags (0-5).</summary>
public enum ToolCall : byte
{
    Execute = 0,
    Query = 1,
    Transform = 2,
    Communicate = 3,
    Delegate = 4,
    Escalate = 5
}

/// <summary>PlanStep matching the Idris2 ABI tags (0-6).</summary>
public enum PlanStep : byte
{
    Action = 0,
    Condition = 1,
    Loop = 2,
    Branch = 3,
    Parallel = 4,
    Checkpoint = 5,
    Rollback = 6
}

/// <summary>Coordination matching the Idris2 ABI tags (0-5).</summary>
public enum Coordination : byte
{
    Solo = 0,
    Collaborative = 1,
    Competitive = 2,
    Hierarchical = 3,
    Swarm = 4,
    Consensus = 5
}

/// <summary>SafetyCheck matching the Idris2 ABI tags (0-5).</summary>
public enum SafetyCheck : byte
{
    Approved = 0,
    Denied = 1,
    Escalated = 2,
    Timeout = 3,
    Sandboxed = 4,
    HumanRequired = 5
}
