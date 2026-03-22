# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Agentic AI protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Agentic AI protocol types for proven-servers.
  module Agentic
    # AgentState matching the Idris2 ABI tags.
    module AgentState
      IDLE = 0
      PLANNING = 1
      ACTING = 2
      OBSERVING = 3
      REFLECTING = 4
      BLOCKED = 5
      TERMINATED = 6
    end

    # ToolCall matching the Idris2 ABI tags.
    module ToolCall
      EXECUTE = 0
      QUERY = 1
      TRANSFORM = 2
      COMMUNICATE = 3
      DELEGATE = 4
      ESCALATE = 5
    end

    # PlanStep matching the Idris2 ABI tags.
    module PlanStep
      ACTION = 0
      CONDITION = 1
      LOOP = 2
      BRANCH = 3
      PARALLEL = 4
      CHECKPOINT = 5
      ROLLBACK = 6
    end

    # Coordination matching the Idris2 ABI tags.
    module Coordination
      SOLO = 0
      COLLABORATIVE = 1
      COMPETITIVE = 2
      HIERARCHICAL = 3
      SWARM = 4
      CONSENSUS = 5
    end

    # SafetyCheck matching the Idris2 ABI tags.
    module SafetyCheck
      APPROVED = 0
      DENIED = 1
      ESCALATED = 2
      TIMEOUT = 3
      SANDBOXED = 4
      HUMAN_REQUIRED = 5
    end

  end
end
