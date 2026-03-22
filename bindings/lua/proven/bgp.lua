-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BGP protocol types for proven-servers.

local M = {}

--- BgpState matching the Idris2 ABI tags.
M.BgpState = {
    IDLE = 0,
    CONNECT = 1,
    ACTIVE = 2,
    OPEN_SENT = 3,
    OPEN_CONFIRM = 4,
    ESTABLISHED = 5,
}

--- BgpEvent matching the Idris2 ABI tags.
M.BgpEvent = {
    MANUAL_START = 0,
    MANUAL_STOP = 1,
    AUTOMATIC_START = 2,
    CONNECT_RETRY_TIMER_EXPIRES = 3,
    HOLD_TIMER_EXPIRES = 4,
    KEEPALIVE_TIMER_EXPIRES = 5,
    DELAY_OPEN_TIMER_EXPIRES = 6,
    TCP_CONNECTION_VALID = 7,
    TCP_CR_ACKED = 8,
    TCP_CONNECTION_CONFIRMED = 9,
    TCP_CONNECTION_FAILS = 10,
    BGP_OPEN_RECEIVED = 11,
    BGP_HEADER_ERR = 12,
    BGP_OPEN_MSG_ERR = 13,
    NOTIF_MSG_VER_ERR = 14,
    NOTIF_MSG = 15,
    KEEPALIVE_MSG = 16,
    UPDATE_MSG = 17,
    UPDATE_MSG_ERR = 18,
}

--- MessageType matching the Idris2 ABI tags.
M.MessageType = {
    OPEN = 0,
    UPDATE = 1,
    NOTIFICATION = 2,
    KEEPALIVE = 3,
}

--- ErrorCode matching the Idris2 ABI tags.
M.ErrorCode = {
    MESSAGE_HEADER_ERROR = 0,
    OPEN_MESSAGE_ERROR = 1,
    UPDATE_MESSAGE_ERROR = 2,
    HOLD_TIMER_EXPIRED = 3,
    FSM_ERROR = 4,
    CEASE = 5,
}

--- Origin matching the Idris2 ABI tags.
M.Origin = {
    IGP = 0,
    EGP = 1,
    INCOMPLETE = 2,
}

--- AsPathSegmentType matching the Idris2 ABI tags.
M.AsPathSegmentType = {
    AS_SET = 0,
    AS_SEQUENCE = 1,
}

--- PathAttrType matching the Idris2 ABI tags.
M.PathAttrType = {
    ORIGIN = 0,
    AS_PATH = 1,
    NEXT_HOP = 2,
    MED = 3,
    LOCAL_PREF = 4,
    ATOMIC_AGGR = 5,
    AGGREGATOR = 6,
    UNKNOWN = 7,
}

return M
