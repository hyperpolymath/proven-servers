# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# OCSP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # OCSP protocol types for proven-servers.
  module Ocsp
    # CertStatus matching the Idris2 ABI tags.
    module CertStatus
      GOOD = 0
      REVOKED = 1
      UNKNOWN = 2
    end

    # ResponseStatus matching the Idris2 ABI tags.
    module ResponseStatus
      SUCCESSFUL = 0
      MALFORMED_REQUEST = 1
      INTERNAL_ERROR = 2
      TRY_LATER = 3
      SIG_REQUIRED = 4
      UNAUTHORIZED = 5
    end

    # HashAlgorithm matching the Idris2 ABI tags.
    module HashAlgorithm
      SHA1 = 0
      SHA256 = 1
      SHA384 = 2
      SHA512 = 3
    end

    # ResponderState matching the Idris2 ABI tags.
    module ResponderState
      IDLE = 0
      READY = 1
      PROCESSING = 2
      SIGNING = 3
      CLOSING = 4
    end

  end
end
