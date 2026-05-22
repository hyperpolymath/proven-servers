# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# CoAP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # CoAP protocol types for proven-servers.
  module Coap
    # Method matching the Idris2 ABI tags.
    module Method
      GET = 0
      POST = 1
      PUT = 2
      DELETE = 3
    end

    # MessageType matching the Idris2 ABI tags.
    module MessageType
      CONFIRMABLE = 0
      NON_CONFIRMABLE = 1
      ACKNOWLEDGEMENT = 2
      RESET = 3
    end

    # ContentFormat matching the Idris2 ABI tags.
    module ContentFormat
      TEXT_PLAIN = 0
      LINK_FORMAT = 1
      XML = 2
      OCTET_STREAM = 3
      EXI = 4
      JSON = 5
      CBOR = 6
    end

    # ResponseClass matching the Idris2 ABI tags.
    module ResponseClass
      SUCCESS = 0
      CLIENT_ERROR = 1
      SERVER_ERROR = 2
      SIGNALING = 3
      EMPTY = 4
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      BOUND = 1
      SERVING = 2
      OBSERVING = 3
      SHUTDOWN = 4
    end

  end
end
