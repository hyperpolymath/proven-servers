# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# NTP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # NTP protocol types for proven-servers.
  module Ntp
    # LeapIndicator matching the Idris2 ABI tags.
    module LeapIndicator
      NO_WARNING = 0
      LAST_MINUTE61 = 1
      LAST_MINUTE59 = 2
      UNSYNCHRONISED = 3
    end

    # NtpMode matching the Idris2 ABI tags.
    module NtpMode
      RESERVED = 0
      SYMMETRIC_ACTIVE = 1
      SYMMETRIC_PASSIVE = 2
      CLIENT = 3
      SERVER = 4
      BROADCAST = 5
      CONTROL_MESSAGE = 6
      PRIVATE = 7
    end

    # ExchangeState matching the Idris2 ABI tags.
    module ExchangeState
      IDLE = 0
      REQUEST_RECEIVED = 1
      TIMESTAMP_CALCULATED = 2
      RESPONSE_SENT = 3
    end

    # ClockDisciplineState matching the Idris2 ABI tags.
    module ClockDisciplineState
      UNSET = 0
      SPIKE = 1
      FREQ = 2
      SYNC = 3
      PANIC = 4
    end

    # KissCode matching the Idris2 ABI tags.
    module KissCode
      DENY = 0
      RSTR = 1
      RATE = 2
      OTHER = 3
    end

    # NtpError matching the Idris2 ABI tags.
    module NtpError
      OK = 0
      INVALID_SLOT = 1
      NOT_ACTIVE = 2
      INVALID_PACKET = 3
      KISS_OF_DEATH = 4
      STRATUM_TOO_HIGH = 5
    end

  end
end
