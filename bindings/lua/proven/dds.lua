-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DDS protocol types for proven-servers.

local M = {}

--- ReliabilityKind matching the Idris2 ABI tags.
M.ReliabilityKind = {
    BEST_EFFORT = 0,
    RELIABLE = 1,
}

--- DurabilityKind matching the Idris2 ABI tags.
M.DurabilityKind = {
    TRANSIENT_LOCAL = 1,
    TRANSIENT = 2,
    PERSISTENT = 3,
}

--- HistoryKind matching the Idris2 ABI tags.
M.HistoryKind = {
    KEEP_LAST = 0,
    KEEP_ALL = 1,
}

--- OwnershipKind matching the Idris2 ABI tags.
M.OwnershipKind = {
    SHARED = 0,
    EXCLUSIVE = 1,
}

--- EntityType matching the Idris2 ABI tags.
M.EntityType = {
    PARTICIPANT = 0,
    PUBLISHER = 1,
    SUBSCRIBER = 2,
    TOPIC = 3,
    DATA_WRITER = 4,
    DATA_READER = 5,
}

--- ParticipantState matching the Idris2 ABI tags.
M.ParticipantState = {
    IDLE = 0,
    JOINED = 1,
    PUBLISHING = 2,
    SUBSCRIBING = 3,
    LEAVING = 4,
}

return M
