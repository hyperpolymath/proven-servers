-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SSH Bastion protocol types for proven-servers.

local M = {}

--- BastionState matching the Idris2 ABI tags.
M.BastionState = {
    CONNECTED = 0,
    KEY_EXCHANGED = 1,
    AUTHENTICATED = 2,
    CHANNEL_OPEN = 3,
    ACTIVE = 4,
    CLOSED = 5,
}

--- KexMethod matching the Idris2 ABI tags.
M.KexMethod = {
    CURVE25519 = 0,
    DH_GROUP14 = 1,
    DH_GROUP16 = 2,
    ECDH_P256 = 3,
    ECDH_P384 = 4,
}

--- BastionAuthMethod matching the Idris2 ABI tags.
M.BastionAuthMethod = {
    PUBLIC_KEY = 0,
    PASSWORD = 1,
    KEYBOARD = 2,
    CERTIFICATE = 3,
}

--- BastionChannelType matching the Idris2 ABI tags.
M.BastionChannelType = {
    SESSION = 0,
    DIRECT_TCP_IP = 1,
    FORWARDED_TCP_IP = 2,
    SUBSYSTEM = 3,
}

--- BastionChannelState matching the Idris2 ABI tags.
M.BastionChannelState = {
    OPENING = 0,
    OPEN = 1,
    CLOSING = 2,
    CHANNEL_CLOSED = 3,
}

--- DisconnectReason matching the Idris2 ABI tags.
M.DisconnectReason = {
    HOST_NOT_ALLOWED = 0,
    PROTOCOL_ERROR = 1,
    KEY_EXCHANGE_FAILED = 2,
    AUTH_FAILED = 3,
    SERVICE_NOT_AVAILABLE = 4,
    BY_APPLICATION = 5,
    TOO_MANY_CONNECTIONS = 6,
}

return M
