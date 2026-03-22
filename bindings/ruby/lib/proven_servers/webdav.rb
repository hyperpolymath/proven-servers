# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# WebDAV protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # WebDAV protocol types for proven-servers.
  module Webdav
    # Method matching the Idris2 ABI tags.
    module Method
      PROPFIND = 0
      PROPPATCH = 1
      MKCOL = 2
      COPY = 3
      MOVE = 4
      LOCK = 5
      UNLOCK = 6
    end

    # StatusCode matching the Idris2 ABI tags.
    module StatusCode
      MULTI_STATUS = 0
      UNPROCESSABLE_ENTITY = 1
      LOCKED = 2
      FAILED_DEPENDENCY = 3
      INSUFFICIENT_STORAGE = 4
    end

    # LockScope matching the Idris2 ABI tags.
    module LockScope
      EXCLUSIVE = 0
      SHARED = 1
    end

    # LockType matching the Idris2 ABI tags.
    module LockType
      WRITE = 0
    end

    # Depth matching the Idris2 ABI tags.
    module Depth
      ZERO = 0
      ONE = 1
      INFINITY = 2
    end

    # PropertyOp matching the Idris2 ABI tags.
    module PropertyOp
      SET = 0
      REMOVE = 1
    end

  end
end
