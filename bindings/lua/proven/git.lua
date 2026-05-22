-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Git protocol types for proven-servers.

local M = {}

--- Command matching the Idris2 ABI tags.
M.Command = {
    UPLOAD_PACK = 0,
    RECEIVE_PACK = 1,
    UPLOAD_ARCHIVE = 2,
}

--- PacketType matching the Idris2 ABI tags.
M.PacketType = {
    FLUSH = 0,
    DELIMITER = 1,
    RESPONSE_END = 2,
    DATA = 3,
    PKT_ERROR = 4,
    SIDEBAND_DATA = 5,
    SIDEBAND_PROGRESS = 6,
    SIDEBAND_ERROR = 7,
}

--- RefType matching the Idris2 ABI tags.
M.RefType = {
    BRANCH = 0,
    TAG = 1,
    HEAD = 2,
    REMOTE = 3,
    GIT_NOTE = 4,
}

--- Capability matching the Idris2 ABI tags.
M.Capability = {
    MULTI_ACK = 0,
    THIN_PACK = 1,
    SIDE_BAND64K = 2,
    OFS_DELTA = 3,
    SHALLOW = 4,
    DEEPEN_SINCE = 5,
    DEEPEN_NOT = 6,
    FILTER_SPEC = 7,
    OBJECT_FORMAT = 8,
}

--- HookResult matching the Idris2 ABI tags.
M.HookResult = {
    ACCEPT = 0,
    REJECT = 1,
}

--- ServerState matching the Idris2 ABI tags.
M.ServerState = {
    IDLE = 0,
    DISCOVERY = 1,
    NEGOTIATING = 2,
    TRANSFER = 3,
    SHUTDOWN = 4,
}

return M
