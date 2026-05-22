# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# POP3 protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # POP3 protocol types for proven-servers.
  module Pop3
    # Command matching the Idris2 ABI tags.
    module Command
      USER = 0
      PASS = 1
      STAT = 2
      LIST = 3
      RETR = 4
      DELE = 5
      NOOP = 6
      RSET = 7
      QUIT = 8
      TOP = 9
      UIDL = 10
    end

    # State matching the Idris2 ABI tags.
    module State
      AUTHORIZATION = 0
      TRANSACTION = 1
      UPDATE = 2
    end

    # Response matching the Idris2 ABI tags.
    module Response
      RESPONSE_OK = 0
      ERR = 1
    end

    # Pop3Error matching the Idris2 ABI tags.
    module Pop3Error
      POP3_ERROR_OK = 0
      INVALID_SLOT = 1
      NOT_ACTIVE = 2
      INVALID_TRANSITION = 3
      INVALID_COMMAND = 4
      AUTH_FAILED = 5
    end

  end
end
