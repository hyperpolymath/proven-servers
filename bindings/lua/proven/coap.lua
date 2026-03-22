-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CoAP protocol types for proven-servers.

local M = {}

--- Method matching the Idris2 ABI tags.
M.Method = {
    GET = 0,
    POST = 1,
    PUT = 2,
    DELETE = 3,
}

--- MessageType matching the Idris2 ABI tags.
M.MessageType = {
    CONFIRMABLE = 0,
    NON_CONFIRMABLE = 1,
    ACKNOWLEDGEMENT = 2,
    RESET = 3,
}

--- ContentFormat matching the Idris2 ABI tags.
M.ContentFormat = {
    TEXT_PLAIN = 0,
    LINK_FORMAT = 1,
    XML = 2,
    OCTET_STREAM = 3,
    EXI = 4,
    JSON = 5,
    CBOR = 6,
}

--- ResponseClass matching the Idris2 ABI tags.
M.ResponseClass = {
    SUCCESS = 0,
    CLIENT_ERROR = 1,
    SERVER_ERROR = 2,
    SIGNALING = 3,
    EMPTY = 4,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    BOUND = 1,
    SERVING = 2,
    OBSERVING = 3,
    SHUTDOWN = 4,
}

return M
