// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file agentic.hpp
/// @brief Agentic AI protocol types for proven-servers.

#ifndef PROVEN_AGENTIC_HPP
#define PROVEN_AGENTIC_HPP

#include <cstdint>

namespace proven {

/// @brief AgentState matching the Idris2 ABI tags.
enum class AgentState : uint8_t {
    Idle = 0,
    Planning = 1,
    Acting = 2,
    Observing = 3,
    Reflecting = 4,
    Blocked = 5,
    Terminated = 6
};

/// @brief ToolCall matching the Idris2 ABI tags.
enum class ToolCall : uint8_t {
    Execute = 0,
    Query = 1,
    Transform = 2,
    Communicate = 3,
    Delegate = 4,
    Escalate = 5
};

/// @brief PlanStep matching the Idris2 ABI tags.
enum class PlanStep : uint8_t {
    Action = 0,
    Condition = 1,
    Loop = 2,
    Branch = 3,
    Parallel = 4,
    Checkpoint = 5,
    Rollback = 6
};

/// @brief Coordination matching the Idris2 ABI tags.
enum class Coordination : uint8_t {
    Solo = 0,
    Collaborative = 1,
    Competitive = 2,
    Hierarchical = 3,
    Swarm = 4,
    Consensus = 5
};

/// @brief SafetyCheck matching the Idris2 ABI tags.
enum class SafetyCheck : uint8_t {
    Approved = 0,
    Denied = 1,
    Escalated = 2,
    Timeout = 3,
    Sandboxed = 4,
    HumanRequired = 5
};

} // namespace proven

#endif // PROVEN_AGENTIC_HPP
