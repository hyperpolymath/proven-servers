# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# PTP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # PTP protocol types for proven-servers.
  module Ptp
    # PtpMessageType matching the Idris2 ABI tags.
    module PtpMessageType
      SYNC = 0
      DELAY_REQ = 1
      PDELAY_REQ = 2
      PDELAY_RESP = 3
      FOLLOW_UP = 4
      DELAY_RESP = 5
      PDELAY_RESP_FOLLOW_UP = 6
      ANNOUNCE = 7
      SIGNALING = 8
      MANAGEMENT = 9
    end

    # ClockClass matching the Idris2 ABI tags.
    module ClockClass
      PRIMARY_CLOCK = 0
      APPLICATION_SPECIFIC = 1
      SLAVE_ONLY = 2
      DEFAULT_CLASS = 3
    end

    # PtpPortState matching the Idris2 ABI tags.
    module PtpPortState
      INITIALIZING = 0
      FAULTY = 1
      DISABLED = 2
      LISTENING = 3
      PRE_MASTER = 4
      MASTER = 5
      PASSIVE = 6
      UNCALIBRATED = 7
      SLAVE = 8
    end

    # DelayMechanism matching the Idris2 ABI tags.
    module DelayMechanism
      E2_E = 0
      P2_P = 1
      DM_DISABLED = 2
    end

  end
end
