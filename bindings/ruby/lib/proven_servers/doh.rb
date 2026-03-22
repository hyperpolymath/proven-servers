# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# DoH protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # DoH protocol types for proven-servers.
  module Doh
    # ContentType matching the Idris2 ABI tags.
    module ContentType
      DNS_MESSAGE = 0
      DNS_JSON = 1
    end

    # RequestMethod matching the Idris2 ABI tags.
    module RequestMethod
      GET = 0
      POST = 1
    end

    # WireFormat matching the Idris2 ABI tags.
    module WireFormat
      BINARY = 0
      JSON = 1
    end

    # ErrorReason matching the Idris2 ABI tags.
    module ErrorReason
      BAD_CONTENT_TYPE = 0
      BAD_METHOD = 1
      PAYLOAD_TOO_LARGE = 2
      UPSTREAM_TIMEOUT = 3
      UPSTREAM_ERROR = 4
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      BOUND = 1
      SERVING = 2
      RESOLVING = 3
      SHUTDOWN = 4
    end

  end
end
