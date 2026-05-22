# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# SMB protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # SMB protocol types for proven-servers.
  module Smb
    # Command matching the Idris2 ABI tags.
    module Command
      NEGOTIATE = 0
      SESSION_SETUP = 1
      LOGOFF = 2
      TREE_CONNECT = 3
      TREE_DISCONNECT = 4
      CREATE = 5
      CLOSE = 6
      READ = 7
      WRITE = 8
      LOCK = 9
      IOCTL = 10
      CANCEL = 11
      QUERY_DIRECTORY = 12
      CHANGE_NOTIFY = 13
      QUERY_INFO = 14
      SET_INFO = 15
    end

    # Dialect matching the Idris2 ABI tags.
    module Dialect
      SMB2_0_2 = 0
      SMB2_1 = 1
      SMB3_0 = 2
      SMB3_0_2 = 3
      SMB3_1_1 = 4
    end

    # ShareType matching the Idris2 ABI tags.
    module ShareType
      DISK = 0
      PIPE = 1
      PRINT = 2
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      NEGOTIATED = 1
      AUTHENTICATED = 2
      TREE_CONNECTED = 3
      FILE_OPEN = 4
      DISCONNECTING = 5
    end

  end
end
