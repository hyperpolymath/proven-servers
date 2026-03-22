-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Honeypot protocol types for proven-servers.

local M = {}

--- ServiceEmulation matching the Idris2 ABI tags.
M.ServiceEmulation = {
    SSH = 0,
    HTTP = 1,
    FTP = 2,
    SMTP = 3,
    TELNET = 4,
    MYSQL = 5,
    RDP = 6,
}

--- InteractionLevel matching the Idris2 ABI tags.
M.InteractionLevel = {
    LOW = 0,
    MEDIUM = 1,
    HIGH = 2,
}

--- HoneypotAlertSeverity matching the Idris2 ABI tags.
M.HoneypotAlertSeverity = {
    INFO = 0,
    AS_LOW = 1,
    AS_MEDIUM = 2,
    AS_HIGH = 3,
    CRITICAL = 4,
}

--- AttackerAction matching the Idris2 ABI tags.
M.AttackerAction = {
    SCAN = 0,
    BRUTE_FORCE = 1,
    EXPLOIT = 2,
    PAYLOAD = 3,
    LATERAL = 4,
    EXFILTRATION = 5,
}

--- ServerState matching the Idris2 ABI tags.
M.ServerState = {
    IDLE = 0,
    DEPLOYED = 1,
    ENGAGED = 2,
    SHUTDOWN = 3,
}

return M
