# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# NFS protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # NFS protocol types for proven-servers.
  module Nfs
    # Operation matching the Idris2 ABI tags.
    module Operation
      OPERATION_ACCESS = 0
      CLOSE = 1
      COMMIT = 2
      CREATE = 3
      GET_ATTR = 4
      OPERATION_LINK = 5
      LOCK = 6
      LOOKUP = 7
      OPEN = 8
      READ = 9
      READ_DIR = 10
      REMOVE = 11
      RENAME = 12
      SET_ATTR = 13
      WRITE = 14
    end

    # FileType matching the Idris2 ABI tags.
    module FileType
      REGULAR = 0
      DIRECTORY = 1
      BLOCK_DEVICE = 2
      CHAR_DEVICE = 3
      FILE_TYPE_LINK = 4
      SOCKET = 5
      FIFO = 6
    end

    # Status matching the Idris2 ABI tags.
    module Status
      OK = 0
      PERM = 1
      NO_ENT = 2
      IO = 3
      NX_IO = 4
      STATUS_ACCESS = 5
      EXIST = 6
      NOT_DIR = 7
      IS_DIR = 8
      F_BIG = 9
      NO_SPC = 10
      R_OFS = 11
      NOT_EMPTY = 12
      STALE = 13
    end

    # NfsState matching the Idris2 ABI tags.
    module NfsState
      IDLE = 0
      MOUNTED = 1
      FILE_OPEN = 2
      LOCKED = 3
      BUSY = 4
      UNMOUNTING = 5
    end

  end
end
