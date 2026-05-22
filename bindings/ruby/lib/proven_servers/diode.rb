# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Data Diode protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Data Diode protocol types for proven-servers.
  module Diode
    # Direction matching the Idris2 ABI tags.
    module Direction
      HIGH_TO_LOW = 0
      LOW_TO_HIGH = 1
    end

    # DiodeProtocol matching the Idris2 ABI tags.
    module DiodeProtocol
      UDP = 0
      TCP = 1
      FILE_TRANSFER = 2
      SYSLOG = 3
      SNMP = 4
    end

    # TransferState matching the Idris2 ABI tags.
    module TransferState
      QUEUED = 0
      SENDING = 1
      CONFIRMING = 2
      COMPLETE = 3
      FAILED = 4
    end

    # ValidationResult matching the Idris2 ABI tags.
    module ValidationResult
      PASSED = 0
      FORMAT_ERROR = 1
      SIZE_EXCEEDED = 2
      POLICY_BLOCKED = 3
    end

    # IntegrityCheck matching the Idris2 ABI tags.
    module IntegrityCheck
      CRC32 = 0
      SHA256 = 1
      HMAC = 2
    end

    # GatewayState matching the Idris2 ABI tags.
    module GatewayState
      IDLE = 0
      CONFIGURED = 1
      TRANSFERRING = 2
      VALIDATING = 3
      SHUTDOWN = 4
    end

  end
end
