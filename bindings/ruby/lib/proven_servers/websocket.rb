# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# WebSocket protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # WebSocket protocol types for proven-servers.
  module Websocket
    # Opcode matching the Idris2 ABI tags.
    module Opcode
      CONTINUATION = 0
      TEXT = 0
      BINARY = 0
      CLOSE = 0
      PING = 0
      PONG = 0
    end

    # CloseCode matching the Idris2 ABI tags.
    module CloseCode
      NORMAL = 1000
      GOING_AWAY = 1001
      PROTOCOL_ERROR = 1002
      UNSUPPORTED_DATA = 1003
      NO_STATUS = 1005
      ABNORMAL = 1006
      INVALID_PAYLOAD = 1007
      POLICY_VIOLATION = 1008
      MESSAGE_TOO_BIG = 1009
      MANDATORY_EXTENSION = 1010
      INTERNAL_ERROR = 1011
    end

  end
end
