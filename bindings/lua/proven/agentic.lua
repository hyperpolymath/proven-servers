-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Agentic AI protocol types for proven-servers.

local M = {}

--- AgentState matching the Idris2 ABI tags.
M.AgentState = {
    IDLE = 0,
    PLANNING = 1,
    ACTING = 2,
    OBSERVING = 3,
    REFLECTING = 4,
    BLOCKED = 5,
    TERMINATED = 6,
}

--- ToolCall matching the Idris2 ABI tags.
M.ToolCall = {
    EXECUTE = 0,
    QUERY = 1,
    TRANSFORM = 2,
    COMMUNICATE = 3,
    DELEGATE = 4,
    ESCALATE = 5,
}

--- PlanStep matching the Idris2 ABI tags.
M.PlanStep = {
    ACTION = 0,
    CONDITION = 1,
    LOOP = 2,
    BRANCH = 3,
    PARALLEL = 4,
    CHECKPOINT = 5,
    ROLLBACK = 6,
}

--- Coordination matching the Idris2 ABI tags.
M.Coordination = {
    SOLO = 0,
    COLLABORATIVE = 1,
    COMPETITIVE = 2,
    HIERARCHICAL = 3,
    SWARM = 4,
    CONSENSUS = 5,
}

--- SafetyCheck matching the Idris2 ABI tags.
M.SafetyCheck = {
    APPROVED = 0,
    DENIED = 1,
    ESCALATED = 2,
    TIMEOUT = 3,
    SANDBOXED = 4,
    HUMAN_REQUIRED = 5,
}

return M
