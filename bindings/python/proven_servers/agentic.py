# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-agentic protocol types.

"""Agentic AI protocol types for proven-servers."""

from enum import IntEnum


class AgentState(IntEnum):
    """AgentState matching the Idris2 ABI tags."""
    IDLE = 0
    PLANNING = 1
    ACTING = 2
    OBSERVING = 3
    REFLECTING = 4
    BLOCKED = 5
    TERMINATED = 6


class ToolCall(IntEnum):
    """ToolCall matching the Idris2 ABI tags."""
    EXECUTE = 0
    QUERY = 1
    TRANSFORM = 2
    COMMUNICATE = 3
    DELEGATE = 4
    ESCALATE = 5


class PlanStep(IntEnum):
    """PlanStep matching the Idris2 ABI tags."""
    ACTION = 0
    CONDITION = 1
    LOOP = 2
    BRANCH = 3
    PARALLEL = 4
    CHECKPOINT = 5
    ROLLBACK = 6


class Coordination(IntEnum):
    """Coordination matching the Idris2 ABI tags."""
    SOLO = 0
    COLLABORATIVE = 1
    COMPETITIVE = 2
    HIERARCHICAL = 3
    SWARM = 4
    CONSENSUS = 5


class SafetyCheck(IntEnum):
    """SafetyCheck matching the Idris2 ABI tags."""
    APPROVED = 0
    DENIED = 1
    ESCALATED = 2
    TIMEOUT = 3
    SANDBOXED = 4
    HUMAN_REQUIRED = 5
