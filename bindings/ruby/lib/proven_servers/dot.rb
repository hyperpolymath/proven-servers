# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# DoT protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # DoT protocol types for proven-servers.
  module Dot
    # SessionState matching the Idris2 ABI tags.
    module SessionState
      CONNECTING = 0
      HANDSHAKING = 1
      ESTABLISHED = 2
      CLOSING = 3
      CLOSED = 4
    end

    # PaddingStrategy matching the Idris2 ABI tags.
    module PaddingStrategy
      NO_PADDING = 0
      BLOCK_PADDING = 1
      RANDOM_PADDING = 2
    end

    # ErrorReason matching the Idris2 ABI tags.
    module ErrorReason
      HANDSHAKE_FAILED = 0
      CERTIFICATE_INVALID = 1
      TIMEOUT = 2
      UPSTREAM_ERROR = 3
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
