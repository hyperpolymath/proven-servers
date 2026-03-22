# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# VoIP/SIP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # VoIP/SIP protocol types for proven-servers.
  module Voip
    # Method matching the Idris2 ABI tags.
    module Method
      INVITE = 0
      ACK = 1
      BYE = 2
      CANCEL = 3
      REGISTER = 4
      OPTIONS = 5
      INFO = 6
      UPDATE = 7
      SUBSCRIBE = 8
      NOTIFY = 9
      REFER = 10
      MESSAGE = 11
      PRACK = 12
    end

    # ResponseCode matching the Idris2 ABI tags.
    module ResponseCode
      TRYING = 0
      RINGING = 1
      SESSION_PROGRESS = 2
      OK = 3
      MULTIPLE_CHOICES = 4
      MOVED_PERMANENTLY = 5
      MOVED_TEMPORARILY = 6
      BAD_REQUEST = 7
      UNAUTHORIZED = 8
      FORBIDDEN = 9
      NOT_FOUND = 10
      METHOD_NOT_ALLOWED = 11
      REQUEST_TIMEOUT = 12
      BUSY_HERE = 13
      DECLINE = 14
      SERVER_INTERNAL_ERROR = 15
      SERVICE_UNAVAILABLE = 16
    end

    # DialogState matching the Idris2 ABI tags.
    module DialogState
      EARLY = 0
      CONFIRMED = 1
      TERMINATED = 2
    end

  end
end
