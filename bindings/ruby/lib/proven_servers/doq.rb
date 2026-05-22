# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# DoQ protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # DoQ protocol types for proven-servers.
  module Doq
    # StreamType matching the Idris2 ABI tags.
    module StreamType
      UNIDIRECTIONAL = 0
      BIDIRECTIONAL = 1
    end

    # ErrorCode matching the Idris2 ABI tags.
    module ErrorCode
      NO_ERROR = 0
      INTERNAL_ERROR = 1
      EXCESSIVE_LOAD = 2
      PROTOCOL_ERROR = 3
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      INITIAL = 0
      HANDSHAKING = 1
      READY = 2
      DRAINING = 3
      CLOSED = 4
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      BOUND = 1
      LISTENING = 2
      PROCESSING = 3
      SHUTDOWN = 4
    end

  end
end
