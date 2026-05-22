-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTS protocol types for proven-servers.

local M = {}

--- RecordType matching the Idris2 ABI tags.
M.RecordType = {
    END_OF_MESSAGE = 0,
    NEXT_PROTOCOL = 1,
    ERROR = 2,
    WARNING = 3,
    AEAD_ALGORITHM = 4,
    COOKIE = 5,
    COOKIE_PLACEHOLDER = 6,
    NTSKE_SERVER = 7,
    NTSKE_PORT = 8,
}

--- ErrorCode matching the Idris2 ABI tags.
M.ErrorCode = {
    UNRECOGNIZED_CRITICAL = 0,
    BAD_REQUEST = 1,
    INTERNAL_ERROR = 2,
}

--- AeadAlgorithm matching the Idris2 ABI tags.
M.AeadAlgorithm = {
    AEAD_AES128_GCM = 0,
    AEAD_AES256_GCM = 1,
    AEAD_AES_SIV_CMAC256 = 2,
}

--- HandshakeState matching the Idris2 ABI tags.
M.HandshakeState = {
    INITIAL = 0,
    HANDSHAKE_STATE__NEGOTIATING = 1,
    HANDSHAKE_STATE__ESTABLISHED = 2,
    FAILED = 3,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    HANDSHAKING = 1,
    SESSION_STATE__NEGOTIATING = 2,
    SESSION_STATE__ESTABLISHED = 3,
    CLOSING = 4,
}

return M
