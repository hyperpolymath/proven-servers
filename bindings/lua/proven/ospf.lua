-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- OSPF protocol types for proven-servers.

local M = {}

--- PacketType matching the Idris2 ABI tags.
M.PacketType = {
    HELLO = 0,
    DATABASE_DESCRIPTION = 1,
    LINK_STATE_REQUEST = 2,
    LINK_STATE_UPDATE = 3,
    LINK_STATE_ACK = 4,
}

--- NeighborState matching the Idris2 ABI tags.
M.NeighborState = {
    DOWN = 0,
    ATTEMPT = 1,
    INIT = 2,
    TWO_WAY = 3,
    EX_START = 4,
    EXCHANGE = 5,
    LOADING = 6,
    FULL = 7,
}

--- LsaType matching the Idris2 ABI tags.
M.LsaType = {
    ROUTER_LSA = 0,
    NETWORK_LSA = 1,
    SUMMARY_LSA = 2,
    ASBR_SUMMARY_LSA = 3,
    AS_EXTERNAL_LSA = 4,
}

--- AreaType matching the Idris2 ABI tags.
M.AreaType = {
    NORMAL = 0,
    STUB = 1,
    TOTALLY_STUB = 2,
    NSSA = 3,
}

--- OspfError matching the Idris2 ABI tags.
M.OspfError = {
    OK = 0,
    INVALID_SLOT = 1,
    NOT_ACTIVE = 2,
    INVALID_TRANSITION = 3,
    INVALID_PACKET = 4,
    AREA_ERROR = 5,
    FLOOD_LIMIT = 6,
}

return M
