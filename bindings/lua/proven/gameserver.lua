-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Game Server protocol types for proven-servers.

local M = {}

--- SessionType matching the Idris2 ABI tags.
M.SessionType = {
    LOBBY = 0,
    MATCH = 1,
    PRACTICE = 2,
    SPECTATOR = 3,
    TOURNAMENT = 4,
}

--- PlayerState matching the Idris2 ABI tags.
M.PlayerState = {
    IDLE = 0,
    QUEUING = 1,
    LOADING = 2,
    PLAYING = 3,
    SPECTATING = 4,
    DISCONNECTED = 5,
}

--- MatchState matching the Idris2 ABI tags.
M.MatchState = {
    WAITING = 0,
    STARTING = 1,
    IN_PROGRESS = 2,
    PAUSED = 3,
    ENDING = 4,
    COMPLETE = 5,
}

return M
