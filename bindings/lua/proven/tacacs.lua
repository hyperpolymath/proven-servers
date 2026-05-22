-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TACACS+ protocol types for proven-servers.

local M = {}

--- PacketType matching the Idris2 ABI tags.
M.PacketType = {
    AUTHENTICATION = 0,
    AUTHORIZATION = 1,
    ACCOUNTING = 2,
}

--- AuthenType matching the Idris2 ABI tags.
M.AuthenType = {
    ASCII = 0,
    PAP = 1,
    CHAP = 2,
    MS_CHAP_V1 = 3,
    MS_CHAP_V2 = 4,
}

--- AuthenAction matching the Idris2 ABI tags.
M.AuthenAction = {
    LOGIN = 0,
    CHANGE_PASS = 1,
    SEND_AUTH = 2,
}

--- AuthenStatus matching the Idris2 ABI tags.
M.AuthenStatus = {
    PASS = 0,
    AUTHEN_STATUS__FAIL = 1,
    GET_DATA = 2,
    GET_USER = 3,
    GET_PASS = 4,
    RESTART = 5,
    AUTHEN_STATUS__ERROR = 6,
    AUTHEN_STATUS__FOLLOW = 7,
}

--- AuthorStatus matching the Idris2 ABI tags.
M.AuthorStatus = {
    PASS_ADD = 0,
    PASS_REPL = 1,
    AUTHOR_STATUS__FAIL = 2,
    AUTHOR_STATUS__ERROR = 3,
    AUTHOR_STATUS__FOLLOW = 4,
}

--- AcctStatus matching the Idris2 ABI tags.
M.AcctStatus = {
    SUCCESS = 0,
    ACCT_STATUS__ERROR = 1,
    ACCT_STATUS__FOLLOW = 2,
}

--- AcctFlag matching the Idris2 ABI tags.
M.AcctFlag = {
    START = 0,
    STOP = 1,
    WATCHDOG = 2,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    AUTHENTICATING = 1,
    AUTHORIZING = 2,
    ACTIVE = 3,
    CLOSING = 4,
}

return M
