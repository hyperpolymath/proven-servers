<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** AgentState matching the Idris2 ABI tags. */
enum AgentState: int
{
    case Idle = 0;
    case Planning = 1;
    case Acting = 2;
    case Observing = 3;
    case Reflecting = 4;
    case Blocked = 5;
    case Terminated = 6;
}

/** ToolCall matching the Idris2 ABI tags. */
enum ToolCall: int
{
    case Execute = 0;
    case Query = 1;
    case Transform = 2;
    case Communicate = 3;
    case Delegate = 4;
    case Escalate = 5;
}

/** PlanStep matching the Idris2 ABI tags. */
enum PlanStep: int
{
    case Action = 0;
    case Condition = 1;
    case Loop = 2;
    case Branch = 3;
    case Parallel = 4;
    case Checkpoint = 5;
    case Rollback = 6;
}

/** Coordination matching the Idris2 ABI tags. */
enum Coordination: int
{
    case Solo = 0;
    case Collaborative = 1;
    case Competitive = 2;
    case Hierarchical = 3;
    case Swarm = 4;
    case Consensus = 5;
}

/** SafetyCheck matching the Idris2 ABI tags. */
enum SafetyCheck: int
{
    case Approved = 0;
    case Denied = 1;
    case Escalated = 2;
    case Timeout = 3;
    case Sandboxed = 4;
    case HumanRequired = 5;
}
