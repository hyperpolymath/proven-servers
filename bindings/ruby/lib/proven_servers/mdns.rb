# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# mDNS protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # mDNS protocol types for proven-servers.
  module Mdns
    # MdnsRecordType matching the Idris2 ABI tags.
    module MdnsRecordType
      A = 0
      AAAA = 1
      PTR = 2
      SRV = 3
      TXT = 4
    end

    # QueryType matching the Idris2 ABI tags.
    module QueryType
      STANDARD = 0
      ONE_SHOT = 1
      CONTINUOUS = 2
    end

    # ConflictAction matching the Idris2 ABI tags.
    module ConflictAction
      PROBE = 0
      DEFEND = 1
      WITHDRAW = 2
    end

    # ServiceFlag matching the Idris2 ABI tags.
    module ServiceFlag
      UNIQUE = 0
      SHARED = 1
    end

    # ResponderState matching the Idris2 ABI tags.
    module ResponderState
      IDLE = 0
      PROBING = 1
      ANNOUNCING = 2
      RUNNING = 3
      SHUTTING_DOWN = 4
    end

  end
end
