# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# TACACS+ protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # TACACS+ protocol types for proven-servers.
  module Tacacs
    # PacketType matching the Idris2 ABI tags.
    module PacketType
      AUTHENTICATION = 0
      AUTHORIZATION = 1
      ACCOUNTING = 2
    end

    # AuthenType matching the Idris2 ABI tags.
    module AuthenType
      ASCII = 0
      PAP = 1
      CHAP = 2
      MS_CHAP_V1 = 3
      MS_CHAP_V2 = 4
    end

    # AuthenAction matching the Idris2 ABI tags.
    module AuthenAction
      LOGIN = 0
      CHANGE_PASS = 1
      SEND_AUTH = 2
    end

    # AuthenStatus matching the Idris2 ABI tags.
    module AuthenStatus
      PASS = 0
      AUTHEN_STATUS_FAIL = 1
      GET_DATA = 2
      GET_USER = 3
      GET_PASS = 4
      RESTART = 5
      AUTHEN_STATUS_ERROR = 6
      AUTHEN_STATUS_FOLLOW = 7
    end

    # AuthorStatus matching the Idris2 ABI tags.
    module AuthorStatus
      PASS_ADD = 0
      PASS_REPL = 1
      AUTHOR_STATUS_FAIL = 2
      AUTHOR_STATUS_ERROR = 3
      AUTHOR_STATUS_FOLLOW = 4
    end

    # AcctStatus matching the Idris2 ABI tags.
    module AcctStatus
      SUCCESS = 0
      ACCT_STATUS_ERROR = 1
      ACCT_STATUS_FOLLOW = 2
    end

    # AcctFlag matching the Idris2 ABI tags.
    module AcctFlag
      START = 0
      STOP = 1
      WATCHDOG = 2
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      AUTHENTICATING = 1
      AUTHORIZING = 2
      ACTIVE = 3
      CLOSING = 4
    end

  end
end
