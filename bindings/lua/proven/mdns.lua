-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- mDNS protocol types for proven-servers.

local M = {}

--- MdnsRecordType matching the Idris2 ABI tags.
M.MdnsRecordType = {
    A = 0,
    AAAA = 1,
    PTR = 2,
    SRV = 3,
    TXT = 4,
}

--- QueryType matching the Idris2 ABI tags.
M.QueryType = {
    STANDARD = 0,
    ONE_SHOT = 1,
    CONTINUOUS = 2,
}

--- ConflictAction matching the Idris2 ABI tags.
M.ConflictAction = {
    PROBE = 0,
    DEFEND = 1,
    WITHDRAW = 2,
}

--- ServiceFlag matching the Idris2 ABI tags.
M.ServiceFlag = {
    UNIQUE = 0,
    SHARED = 1,
}

--- ResponderState matching the Idris2 ABI tags.
M.ResponderState = {
    IDLE = 0,
    PROBING = 1,
    ANNOUNCING = 2,
    RUNNING = 3,
    SHUTTING_DOWN = 4,
}

return M
