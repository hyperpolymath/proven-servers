# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# CT Log protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # CT Log protocol types for proven-servers.
  module Ctlog
    # LogEntryType matching the Idris2 ABI tags.
    module LogEntryType
      X509_ENTRY = 0
      PRECERT_ENTRY = 1
    end

    # SignatureType matching the Idris2 ABI tags.
    module SignatureType
      CERTIFICATE_TIMESTAMP = 0
      TREE_HASH = 1
    end

    # MerkleLeafType matching the Idris2 ABI tags.
    module MerkleLeafType
      TIMESTAMPED_ENTRY = 0
    end

    # SubmissionStatus matching the Idris2 ABI tags.
    module SubmissionStatus
      ACCEPTED = 0
      DUPLICATE = 1
      RATE_LIMITED = 2
      REJECTED = 3
      INVALID_CHAIN = 4
      UNKNOWN_ANCHOR = 5
    end

    # VerificationResult matching the Idris2 ABI tags.
    module VerificationResult
      VALID_PROOF = 0
      INVALID_PROOF = 1
      INCONSISTENT_TREE = 2
      STALE_STH = 3
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      ACTIVE = 1
      MERGING = 2
      SIGNING = 3
      SHUTDOWN = 4
    end

  end
end
