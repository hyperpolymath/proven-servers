# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Sandbox protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Sandbox protocol types for proven-servers.
  module Sandbox
    # ExecutionPolicy matching the Idris2 ABI tags.
    module ExecutionPolicy
      UNRESTRICTED = 0
      READ_ONLY = 1
      NETWORK_DENIED = 2
      ISOLATED = 3
      EPHEMERAL = 4
    end

    # ResourceLimit matching the Idris2 ABI tags.
    module ResourceLimit
      CPU_TIME = 0
      MEMORY = 1
      DISK_IO = 2
      NETWORK_IO = 3
      FILE_DESCRIPTORS = 4
      PROCESSES = 5
    end

    # SandboxState matching the Idris2 ABI tags.
    module SandboxState
      CREATING = 0
      READY = 1
      RUNNING = 2
      SUSPENDED = 3
      TERMINATED = 4
      DESTROYED = 5
    end

    # ExitReason matching the Idris2 ABI tags.
    module ExitReason
      NORMAL = 0
      TIMEOUT = 1
      MEMORY_EXCEEDED = 2
      POLICY_VIOLATION = 3
      KILLED = 4
      ERROR = 5
    end

    # SyscallPolicy matching the Idris2 ABI tags.
    module SyscallPolicy
      ALLOW = 0
      DENY = 1
      LOG = 2
      TRAP = 3
    end

  end
end
