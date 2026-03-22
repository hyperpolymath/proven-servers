-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ODNS protocol types for proven-servers.

local M = {}

--- Role matching the Idris2 ABI tags.
M.Role = {
    CLIENT = 0,
    PROXY = 1,
    TARGET = 2,
}

--- OdnsMessageType matching the Idris2 ABI tags.
M.OdnsMessageType = {
    QUERY = 0,
    RESPONSE = 1,
}

--- OdnsErrorReason matching the Idris2 ABI tags.
M.OdnsErrorReason = {
    PROXY_ERROR = 0,
    TARGET_ERROR = 1,
    DECRYPTION_FAILED = 2,
    INVALID_CONFIG = 3,
    PAYLOAD_TOO_LARGE = 4,
}

--- EncapsulationFormat matching the Idris2 ABI tags.
M.EncapsulationFormat = {
    HPKE = 0,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    KEY_EXCHANGE = 1,
    READY = 2,
    PROCESSING = 3,
    CLOSING = 4,
}

return M
