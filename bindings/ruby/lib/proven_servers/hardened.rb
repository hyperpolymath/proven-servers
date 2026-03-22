# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Hardened protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Hardened protocol types for proven-servers.
  module Hardened
    # HardeningLevel matching the Idris2 ABI tags.
    module HardeningLevel
      MINIMAL = 0
      STANDARD = 1
      HIGH = 2
      MAXIMUM = 3
    end

    # SecurityControl matching the Idris2 ABI tags.
    module SecurityControl
      ASLR = 0
      DEP = 1
      STACK_CANARY = 2
      CFI = 3
      SANDBOXING = 4
      SECURE_BOOT = 5
      AUDIT_LOG = 6
    end

    # ComplianceStandard matching the Idris2 ABI tags.
    module ComplianceStandard
      CIS = 0
      STIG = 1
      NIST80053 = 2
      PCI_DSS = 3
      FIPS140 = 4
    end

    # AuditEvent matching the Idris2 ABI tags.
    module AuditEvent
      PROCESS_START = 0
      FILE_ACCESS = 1
      NETWORK_CONN = 2
      PRIVILEGE_ESCALATION = 3
      CONFIG_CHANGE = 4
      AUTH_ATTEMPT = 5
    end

    # HardenedHealthStatus matching the Idris2 ABI tags.
    module HardenedHealthStatus
      HEALTHY = 0
      DEGRADED = 1
      COMPROMISED = 2
      UNRESPONSIVE = 3
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      HARDENING = 1
      ACTIVE = 2
      AUDITING = 3
      SHUTDOWN = 4
    end

  end
end
