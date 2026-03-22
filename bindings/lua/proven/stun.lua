-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- STUN/TURN protocol types for proven-servers.

local M = {}

--- MessageType matching the Idris2 ABI tags.
M.MessageType = {
    BINDING_REQUEST = 0,
    BINDING_RESPONSE = 1,
    BINDING_ERROR = 2,
    ALLOCATE_REQUEST = 3,
    ALLOCATE_RESPONSE = 4,
    ALLOCATE_ERROR = 5,
    REFRESH_REQUEST = 6,
    REFRESH_RESPONSE = 7,
    SEND_INDICATION = 8,
    DATA_INDICATION = 9,
    CREATE_PERMISSION = 10,
    CHANNEL_BIND = 11,
}

--- TransportProtocol matching the Idris2 ABI tags.
M.TransportProtocol = {
    UDP = 0,
    TCP = 1,
    TLS = 2,
    DTLS = 3,
}

--- ErrorCode matching the Idris2 ABI tags.
M.ErrorCode = {
    TRY_ALTERNATE = 0,
    BAD_REQUEST = 1,
    UNAUTHORIZED = 2,
    FORBIDDEN = 3,
    MOBILITY_FORBIDDEN = 4,
    STALE_NONCE = 5,
    SERVER_ERROR = 6,
    INSUFFICIENT_CAPACITY = 7,
}

return M
