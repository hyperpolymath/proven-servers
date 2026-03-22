-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Config Mgmt protocol types for proven-servers.

local M = {}

--- ResourceType matching the Idris2 ABI tags.
M.ResourceType = {
    FILE = 0,
    PACKAGE = 1,
    SERVICE = 2,
    USER = 3,
    GROUP = 4,
    CRON = 5,
    MOUNT = 6,
    FIREWALL = 7,
    REGISTRY = 8,
}

--- ResourceState matching the Idris2 ABI tags.
M.ResourceState = {
    PRESENT = 0,
    ABSENT = 1,
    RUNNING = 2,
    STOPPED = 3,
    ENABLED = 4,
    DISABLED = 5,
}

--- ChangeAction matching the Idris2 ABI tags.
M.ChangeAction = {
    CREATE = 0,
    MODIFY = 1,
    DELETE = 2,
    RESTART = 3,
    RELOAD = 4,
    SKIP = 5,
}

--- DriftStatus matching the Idris2 ABI tags.
M.DriftStatus = {
    IN_SYNC = 0,
    DRIFTED = 1,
    D_UNKNOWN = 2,
    UNMANAGED = 3,
}

--- ApplyMode matching the Idris2 ABI tags.
M.ApplyMode = {
    ENFORCE = 0,
    DRY_RUN = 1,
    AUDIT = 2,
}

return M
