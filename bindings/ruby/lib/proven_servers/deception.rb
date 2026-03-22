# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Deception protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Deception protocol types for proven-servers.
  module Deception
    # DecoyType matching the Idris2 ABI tags.
    module DecoyType
      SERVICE = 0
      CREDENTIAL = 1
      FILE = 2
      NETWORK = 3
      TOKEN = 4
      BREADCRUMB = 5
    end

    # TriggerEvent matching the Idris2 ABI tags.
    module TriggerEvent
      ACCESS = 0
      LOGIN = 1
      READ = 2
      WRITE = 3
      EXECUTE = 4
      SCAN = 5
    end

    # AlertPriority matching the Idris2 ABI tags.
    module AlertPriority
      LOW = 0
      MEDIUM = 1
      HIGH = 2
      CRITICAL = 3
    end

    # DecoyState matching the Idris2 ABI tags.
    module DecoyState
      ACTIVE = 0
      TRIGGERED = 1
      DISABLED = 2
      EXPIRED = 3
    end

    # ResponseAction matching the Idris2 ABI tags.
    module ResponseAction
      ALERT = 0
      REDIRECT = 1
      DELAY = 2
      FINGERPRINT = 3
      ISOLATE = 4
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      CONFIGURED = 1
      MONITORING = 2
      RESPONDING = 3
      SHUTDOWN = 4
    end

  end
end
