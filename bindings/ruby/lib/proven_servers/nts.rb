# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# NTS protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # NTS protocol types for proven-servers.
  module Nts
    # RecordType matching the Idris2 ABI tags.
    module RecordType
      END_OF_MESSAGE = 0
      NEXT_PROTOCOL = 1
      ERROR = 2
      WARNING = 3
      AEAD_ALGORITHM = 4
      COOKIE = 5
      COOKIE_PLACEHOLDER = 6
      NTSKE_SERVER = 7
      NTSKE_PORT = 8
    end

    # ErrorCode matching the Idris2 ABI tags.
    module ErrorCode
      UNRECOGNIZED_CRITICAL = 0
      BAD_REQUEST = 1
      INTERNAL_ERROR = 2
    end

    # AeadAlgorithm matching the Idris2 ABI tags.
    module AeadAlgorithm
      AEAD_AES128_GCM = 0
      AEAD_AES256_GCM = 1
      AEAD_AES_SIV_CMAC256 = 2
    end

    # HandshakeState matching the Idris2 ABI tags.
    module HandshakeState
      INITIAL = 0
      HANDSHAKE_STATE_NEGOTIATING = 1
      HANDSHAKE_STATE_ESTABLISHED = 2
      FAILED = 3
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      HANDSHAKING = 1
      SESSION_STATE_NEGOTIATING = 2
      SESSION_STATE_ESTABLISHED = 3
      CLOSING = 4
    end

  end
end
