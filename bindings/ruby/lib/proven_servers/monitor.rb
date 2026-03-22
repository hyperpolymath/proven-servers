# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Monitor protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Monitor protocol types for proven-servers.
  module Monitor
    # CheckType matching the Idris2 ABI tags.
    module CheckType
      HTTP = 0
      TCP = 1
      UDP = 2
      ICMP = 3
      DNS = 4
      CERTIFICATE = 5
      DISK = 6
      CPU = 7
      MEMORY = 8
      PROCESS = 9
      CUSTOM = 10
    end

    # Status matching the Idris2 ABI tags.
    module Status
      UP = 0
      DOWN = 1
      DEGRADED = 2
      UNKNOWN = 3
      MAINTENANCE = 4
    end

    # AlertChannel matching the Idris2 ABI tags.
    module AlertChannel
      EMAIL = 0
      SMS = 1
      WEBHOOK = 2
      SLACK = 3
      PAGER_DUTY = 4
    end

    # Severity matching the Idris2 ABI tags.
    module Severity
      INFO = 0
      WARNING = 1
      ERROR = 2
      CRITICAL = 3
    end

    # CheckState matching the Idris2 ABI tags.
    module CheckState
      PENDING = 0
      CHECK_STATE_RUNNING = 1
      PASSED = 2
      FAILED = 3
      TIMEOUT = 4
      CS_ERROR = 5
    end

    # MonitorState matching the Idris2 ABI tags.
    module MonitorState
      IDLE = 0
      CONFIGURED = 1
      MONITOR_STATE_RUNNING = 2
      MON_PAUSED = 3
      ALERTING = 4
      SHUTDOWN = 5
    end

  end
end
