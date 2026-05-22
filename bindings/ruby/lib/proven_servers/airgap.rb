# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Air Gap protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Air Gap protocol types for proven-servers.
  module Airgap
    # TransferDirection matching the Idris2 ABI tags.
    module TransferDirection
      IMPORT = 0
      EXPORT = 1
    end

    # MediaType matching the Idris2 ABI tags.
    module MediaType
      USB = 0
      OPTICAL_DISC = 1
      TAPE_CARTRIDGE = 2
      DIODE_LINK = 3
    end

    # ScanResult matching the Idris2 ABI tags.
    module ScanResult
      CLEAN = 0
      SUSPICIOUS = 1
      MALICIOUS = 2
      UNSCANNABLE = 3
    end

    # TransferState matching the Idris2 ABI tags.
    module TransferState
      PENDING = 0
      SCANNING = 1
      APPROVED = 2
      REJECTED = 3
      IN_PROGRESS = 4
      COMPLETE = 5
      FAILED = 6
    end

    # ValidationCheck matching the Idris2 ABI tags.
    module ValidationCheck
      HASH_VERIFY = 0
      SIGNATURE_VERIFY = 1
      FORMAT_CHECK = 2
      CONTENT_INSPECTION = 3
      MALWARE_SCAN = 4
    end

  end
end
