-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- XMPP protocol types for proven-servers.

local M = {}

--- StanzaType matching the Idris2 ABI tags.
M.StanzaType = {
    MESSAGE = 0,
    PRESENCE = 1,
    IQ = 2,
}

--- MessageType matching the Idris2 ABI tags.
M.MessageType = {
    CHAT = 0,
    MESSAGE_TYPE__ERROR = 1,
    GROUPCHAT = 2,
    HEADLINE = 3,
    NORMAL = 4,
}

--- PresenceType matching the Idris2 ABI tags.
M.PresenceType = {
    AVAILABLE = 0,
    AWAY = 1,
    DND = 2,
    XA = 3,
    UNAVAILABLE = 4,
}

--- IqType matching the Idris2 ABI tags.
M.IqType = {
    GET = 0,
    SET = 1,
    RESULT = 2,
    IQ_TYPE__ERROR = 3,
}

--- StreamError matching the Idris2 ABI tags.
M.StreamError = {
    BAD_FORMAT = 0,
    CONFLICT = 1,
    CONNECTION_TIMEOUT = 2,
    HOST_GONE = 3,
    HOST_UNKNOWN = 4,
    NOT_AUTHORIZED = 5,
    POLICY_VIOLATION = 6,
    RESOURCE_CONSTRAINT = 7,
    SYSTEM_SHUTDOWN = 8,
}

return M
