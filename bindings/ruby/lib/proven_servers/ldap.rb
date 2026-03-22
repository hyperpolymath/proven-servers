# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# LDAP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # LDAP protocol types for proven-servers.
  module Ldap
    # SessionState matching the Idris2 ABI tags.
    module SessionState
      ANONYMOUS = 0
      BOUND = 1
      CLOSED = 2
      BINDING = 3
    end

    # Operation matching the Idris2 ABI tags.
    module Operation
      BIND = 0
      UNBIND = 1
      SEARCH = 2
      MODIFY = 3
      ADD = 4
      DELETE = 5
      MOD_DN = 6
      COMPARE = 7
      ABANDON = 8
      EXTENDED = 9
    end

    # SearchScope matching the Idris2 ABI tags.
    module SearchScope
      BASE_OBJECT = 0
      SINGLE_LEVEL = 1
      WHOLE_SUBTREE = 2
    end

    # ResultCode matching the Idris2 ABI tags.
    module ResultCode
      SUCCESS = 0
      OPERATIONS_ERROR = 1
      PROTOCOL_ERROR = 2
      TIME_LIMIT_EXCEEDED = 3
      SIZE_LIMIT_EXCEEDED = 4
      AUTH_METHOD_NOT_SUPPORTED = 5
      NO_SUCH_OBJECT = 6
      INVALID_CREDENTIALS = 7
      INSUFFICIENT_ACCESS_RIGHTS = 8
      BUSY = 9
      UNAVAILABLE = 10
    end

  end
end
