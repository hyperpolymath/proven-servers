-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQP protocol types for proven-servers.

local M = {}

--- FrameType matching the Idris2 ABI tags.
M.FrameType = {
    METHOD = 0,
    HEADER = 1,
    BODY = 2,
    HEARTBEAT = 3,
}

--- MethodClass matching the Idris2 ABI tags.
M.MethodClass = {
    CONNECTION = 0,
    CHANNEL = 1,
    EXCHANGE = 2,
    QUEUE = 3,
    BASIC = 4,
    TX = 5,
    CONFIRM = 6,
}

--- ExchangeType matching the Idris2 ABI tags.
M.ExchangeType = {
    DIRECT = 0,
    FANOUT = 1,
    TOPIC = 2,
    HEADERS = 3,
}

--- DeliveryMode matching the Idris2 ABI tags.
M.DeliveryMode = {
    NON_PERSISTENT = 0,
    PERSISTENT = 1,
}

--- ErrorSeverity matching the Idris2 ABI tags.
M.ErrorSeverity = {
    CHANNEL_LEVEL = 0,
    CONNECTION_LEVEL = 1,
}

--- ConnectionState matching the Idris2 ABI tags.
M.ConnectionState = {
    CONNECTION_STATE__IDLE = 0,
    NEGOTIATING = 1,
    TUNING_OK = 2,
    OPEN = 3,
    CLOSING = 4,
}

--- ChannelState matching the Idris2 ABI tags.
M.ChannelState = {
    CLOSED = 0,
    OPENING = 1,
    CH_OPEN = 2,
    CH_CLOSING = 3,
}

--- BrokerState matching the Idris2 ABI tags.
M.BrokerState = {
    BROKER_STATE__IDLE = 0,
    CONNECTED = 1,
    CHANNEL_OPEN = 2,
    CONSUMING = 3,
    PUBLISHING = 4,
    DISCONNECTING = 5,
}

return M
