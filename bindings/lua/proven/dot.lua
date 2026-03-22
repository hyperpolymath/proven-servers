-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DoT protocol types for proven-servers.

local M = {}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    CONNECTING = 0,
    HANDSHAKING = 1,
    ESTABLISHED = 2,
    CLOSING = 3,
    CLOSED = 4,
}

--- PaddingStrategy matching the Idris2 ABI tags.
M.PaddingStrategy = {
    NO_PADDING = 0,
    BLOCK_PADDING = 1,
    RANDOM_PADDING = 2,
}

--- ErrorReason matching the Idris2 ABI tags.
M.ErrorReason = {
    HANDSHAKE_FAILED = 0,
    CERTIFICATE_INVALID = 1,
    TIMEOUT = 2,
    UPSTREAM_ERROR = 3,
}

--- ServerState matching the Idris2 ABI tags.
M.ServerState = {
    IDLE = 0,
    BOUND = 1,
    LISTENING = 2,
    PROCESSING = 3,
    SHUTDOWN = 4,
}

return M
