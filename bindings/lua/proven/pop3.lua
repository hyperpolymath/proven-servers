-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- POP3 protocol types for proven-servers.

local M = {}

--- Command matching the Idris2 ABI tags.
M.Command = {
    USER = 0,
    PASS = 1,
    STAT = 2,
    LIST = 3,
    RETR = 4,
    DELE = 5,
    NOOP = 6,
    RSET = 7,
    QUIT = 8,
    TOP = 9,
    UIDL = 10,
}

--- State matching the Idris2 ABI tags.
M.State = {
    AUTHORIZATION = 0,
    TRANSACTION = 1,
    UPDATE = 2,
}

--- Response matching the Idris2 ABI tags.
M.Response = {
    RESPONSE__OK = 0,
    ERR = 1,
}

--- Pop3Error matching the Idris2 ABI tags.
M.Pop3Error = {
    POP3_ERROR__OK = 0,
    INVALID_SLOT = 1,
    NOT_ACTIVE = 2,
    INVALID_TRANSITION = 3,
    INVALID_COMMAND = 4,
    AUTH_FAILED = 5,
}

return M
