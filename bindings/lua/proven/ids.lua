-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IDS protocol types for proven-servers.

local M = {}

--- AlertSeverity matching the Idris2 ABI tags.
M.AlertSeverity = {
    ALERT_SEVERITY__LOW = 0,
    ALERT_SEVERITY__MEDIUM = 1,
    ALERT_SEVERITY__HIGH = 2,
    ALERT_SEVERITY__CRITICAL = 3,
}

--- DetectionMethod matching the Idris2 ABI tags.
M.DetectionMethod = {
    SIGNATURE = 0,
    ANOMALY = 1,
    STATEFUL = 2,
    HEURISTIC = 3,
}

--- IdsProtocol matching the Idris2 ABI tags.
M.IdsProtocol = {
    TCP = 0,
    UDP = 1,
    ICMP = 2,
    DNS = 3,
    HTTP = 4,
    TLS = 5,
    SSH = 6,
}

--- IdsAction matching the Idris2 ABI tags.
M.IdsAction = {
    ALERT = 0,
    DROP = 1,
    LOG = 2,
    BLOCK = 3,
    PASS = 4,
}

--- Direction matching the Idris2 ABI tags.
M.Direction = {
    INBOUND = 0,
    OUTBOUND = 1,
    BOTH = 2,
}

--- ThreatLevel matching the Idris2 ABI tags.
M.ThreatLevel = {
    INFO = 0,
    THREAT_LEVEL__LOW = 1,
    THREAT_LEVEL__MEDIUM = 2,
    THREAT_LEVEL__HIGH = 3,
    THREAT_LEVEL__CRITICAL = 4,
}

return M
