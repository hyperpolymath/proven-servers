# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# SIEM protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # SIEM protocol types for proven-servers.
  module Siem
    # EventSeverity matching the Idris2 ABI tags.
    module EventSeverity
      INFO = 0
      LOW = 1
      MEDIUM = 2
      HIGH = 3
      CRITICAL = 4
    end

    # EventCategory matching the Idris2 ABI tags.
    module EventCategory
      AUTHENTICATION = 0
      NETWORK_TRAFFIC = 1
      FILE_ACTIVITY = 2
      PROCESS_EXECUTION = 3
      POLICY_VIOLATION = 4
      MALWARE = 5
      DATA_EXFILTRATION = 6
    end

    # CorrelationRule matching the Idris2 ABI tags.
    module CorrelationRule
      THRESHOLD = 0
      SEQUENCE = 1
      AGGREGATION = 2
      ABSENCE = 3
      STATISTICAL = 4
    end

    # AlertState matching the Idris2 ABI tags.
    module AlertState
      NEW = 0
      ACKNOWLEDGED = 1
      IN_PROGRESS = 2
      RESOLVED = 3
      FALSE_POSITIVE = 4
    end

  end
end
