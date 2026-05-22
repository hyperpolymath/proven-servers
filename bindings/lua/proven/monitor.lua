-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Monitor protocol types for proven-servers.

local M = {}

--- CheckType matching the Idris2 ABI tags.
M.CheckType = {
    HTTP = 0,
    TCP = 1,
    UDP = 2,
    ICMP = 3,
    DNS = 4,
    CERTIFICATE = 5,
    DISK = 6,
    CPU = 7,
    MEMORY = 8,
    PROCESS = 9,
    CUSTOM = 10,
}

--- Status matching the Idris2 ABI tags.
M.Status = {
    UP = 0,
    DOWN = 1,
    DEGRADED = 2,
    UNKNOWN = 3,
    MAINTENANCE = 4,
}

--- AlertChannel matching the Idris2 ABI tags.
M.AlertChannel = {
    EMAIL = 0,
    SMS = 1,
    WEBHOOK = 2,
    SLACK = 3,
    PAGER_DUTY = 4,
}

--- Severity matching the Idris2 ABI tags.
M.Severity = {
    INFO = 0,
    WARNING = 1,
    ERROR = 2,
    CRITICAL = 3,
}

--- CheckState matching the Idris2 ABI tags.
M.CheckState = {
    PENDING = 0,
    CHECK_STATE__RUNNING = 1,
    PASSED = 2,
    FAILED = 3,
    TIMEOUT = 4,
    CS_ERROR = 5,
}

--- MonitorState matching the Idris2 ABI tags.
M.MonitorState = {
    IDLE = 0,
    CONFIGURED = 1,
    MONITOR_STATE__RUNNING = 2,
    MON_PAUSED = 3,
    ALERTING = 4,
    SHUTDOWN = 5,
}

return M
