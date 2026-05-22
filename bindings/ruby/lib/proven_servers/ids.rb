# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# IDS protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # IDS protocol types for proven-servers.
  module Ids
    # AlertSeverity matching the Idris2 ABI tags.
    module AlertSeverity
      ALERT_SEVERITY_LOW = 0
      ALERT_SEVERITY_MEDIUM = 1
      ALERT_SEVERITY_HIGH = 2
      ALERT_SEVERITY_CRITICAL = 3
    end

    # DetectionMethod matching the Idris2 ABI tags.
    module DetectionMethod
      SIGNATURE = 0
      ANOMALY = 1
      STATEFUL = 2
      HEURISTIC = 3
    end

    # IdsProtocol matching the Idris2 ABI tags.
    module IdsProtocol
      TCP = 0
      UDP = 1
      ICMP = 2
      DNS = 3
      HTTP = 4
      TLS = 5
      SSH = 6
    end

    # IdsAction matching the Idris2 ABI tags.
    module IdsAction
      ALERT = 0
      DROP = 1
      LOG = 2
      BLOCK = 3
      PASS = 4
    end

    # Direction matching the Idris2 ABI tags.
    module Direction
      INBOUND = 0
      OUTBOUND = 1
      BOTH = 2
    end

    # ThreatLevel matching the Idris2 ABI tags.
    module ThreatLevel
      INFO = 0
      THREAT_LEVEL_LOW = 1
      THREAT_LEVEL_MEDIUM = 2
      THREAT_LEVEL_HIGH = 3
      THREAT_LEVEL_CRITICAL = 4
    end

  end
end
