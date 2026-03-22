-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Load Balancer protocol types for proven-servers.

local M = {}

--- Algorithm matching the Idris2 ABI tags.
M.Algorithm = {
    ROUND_ROBIN = 0,
    LEAST_CONNECTIONS = 1,
    IP_HASH = 2,
    RANDOM = 3,
    WEIGHTED_ROUND_ROBIN = 4,
    LEAST_RESPONSE_TIME = 5,
}

--- HealthCheckType matching the Idris2 ABI tags.
M.HealthCheckType = {
    HEALTH_CHECK_TYPE__HTTP = 0,
    HEALTH_CHECK_TYPE__TCP = 1,
    HEALTH_CHECK_TYPE__GRPC = 2,
    SCRIPT = 3,
}

--- BackendState matching the Idris2 ABI tags.
M.BackendState = {
    HEALTHY = 0,
    UNHEALTHY = 1,
    DRAINING = 2,
    DISABLED = 3,
}

--- SessionPersistence matching the Idris2 ABI tags.
M.SessionPersistence = {
    NONE = 0,
    COOKIE = 1,
    SOURCE_IP = 2,
    HEADER = 3,
}

--- LbProtocol matching the Idris2 ABI tags.
M.LbProtocol = {
    LB_PROTOCOL__HTTP = 0,
    HTTPS = 1,
    LB_PROTOCOL__TCP = 2,
    UDP = 3,
    LB_PROTOCOL__GRPC = 4,
}

return M
