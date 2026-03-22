# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# ODNS protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # ODNS protocol types for proven-servers.
  module Odns
    # Role matching the Idris2 ABI tags.
    module Role
      CLIENT = 0
      PROXY = 1
      TARGET = 2
    end

    # OdnsMessageType matching the Idris2 ABI tags.
    module OdnsMessageType
      QUERY = 0
      RESPONSE = 1
    end

    # OdnsErrorReason matching the Idris2 ABI tags.
    module OdnsErrorReason
      PROXY_ERROR = 0
      TARGET_ERROR = 1
      DECRYPTION_FAILED = 2
      INVALID_CONFIG = 3
      PAYLOAD_TOO_LARGE = 4
    end

    # EncapsulationFormat matching the Idris2 ABI tags.
    module EncapsulationFormat
      HPKE = 0
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      KEY_EXCHANGE = 1
      READY = 2
      PROCESSING = 3
      CLOSING = 4
    end

  end
end
