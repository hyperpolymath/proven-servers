# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Honeypot protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Honeypot protocol types for proven-servers.
  module Honeypot
    # ServiceEmulation matching the Idris2 ABI tags.
    module ServiceEmulation
      SSH = 0
      HTTP = 1
      FTP = 2
      SMTP = 3
      TELNET = 4
      MYSQL = 5
      RDP = 6
    end

    # InteractionLevel matching the Idris2 ABI tags.
    module InteractionLevel
      LOW = 0
      MEDIUM = 1
      HIGH = 2
    end

    # HoneypotAlertSeverity matching the Idris2 ABI tags.
    module HoneypotAlertSeverity
      INFO = 0
      AS_LOW = 1
      AS_MEDIUM = 2
      AS_HIGH = 3
      CRITICAL = 4
    end

    # AttackerAction matching the Idris2 ABI tags.
    module AttackerAction
      SCAN = 0
      BRUTE_FORCE = 1
      EXPLOIT = 2
      PAYLOAD = 3
      LATERAL = 4
      EXFILTRATION = 5
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      DEPLOYED = 1
      ENGAGED = 2
      SHUTDOWN = 3
    end

  end
end
