# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# LPD protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # LPD protocol types for proven-servers.
  module Lpd
    # CommandCode matching the Idris2 ABI tags.
    module CommandCode
      PRINT_JOB = 1
      RECEIVE_JOB = 2
      SHORT_QUEUE = 3
      LONG_QUEUE = 4
      REMOVE_JOBS = 5
    end

    # SubCommandCode matching the Idris2 ABI tags.
    module SubCommandCode
      ABORT_JOB = 1
      CONTROL_FILE = 2
      DATA_FILE = 3
    end

    # JobStatus matching the Idris2 ABI tags.
    module JobStatus
      PENDING = 0
      PRINTING = 1
      COMPLETE = 2
      FAILED = 3
    end

  end
end
