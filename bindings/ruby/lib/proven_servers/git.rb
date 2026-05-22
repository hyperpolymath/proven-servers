# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Git protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Git protocol types for proven-servers.
  module Git
    # Command matching the Idris2 ABI tags.
    module Command
      UPLOAD_PACK = 0
      RECEIVE_PACK = 1
      UPLOAD_ARCHIVE = 2
    end

    # PacketType matching the Idris2 ABI tags.
    module PacketType
      FLUSH = 0
      DELIMITER = 1
      RESPONSE_END = 2
      DATA = 3
      PKT_ERROR = 4
      SIDEBAND_DATA = 5
      SIDEBAND_PROGRESS = 6
      SIDEBAND_ERROR = 7
    end

    # RefType matching the Idris2 ABI tags.
    module RefType
      BRANCH = 0
      TAG = 1
      HEAD = 2
      REMOTE = 3
      GIT_NOTE = 4
    end

    # Capability matching the Idris2 ABI tags.
    module Capability
      MULTI_ACK = 0
      THIN_PACK = 1
      SIDE_BAND64K = 2
      OFS_DELTA = 3
      SHALLOW = 4
      DEEPEN_SINCE = 5
      DEEPEN_NOT = 6
      FILTER_SPEC = 7
      OBJECT_FORMAT = 8
    end

    # HookResult matching the Idris2 ABI tags.
    module HookResult
      ACCEPT = 0
      REJECT = 1
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      DISCOVERY = 1
      NEGOTIATING = 2
      TRANSFER = 3
      SHUTDOWN = 4
    end

  end
end
