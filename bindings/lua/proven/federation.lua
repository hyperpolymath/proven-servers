-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Federation protocol types for proven-servers.

local M = {}

--- ActivityType matching the Idris2 ABI tags.
M.ActivityType = {
    CREATE = 0,
    UPDATE = 1,
    DELETE = 2,
    FOLLOW = 3,
    ACCEPT = 4,
    REJECT = 5,
    ANNOUNCE = 6,
    LIKE = 7,
    UNDO = 8,
    BLOCK = 9,
    FLAG = 10,
}

--- ActorType matching the Idris2 ABI tags.
M.ActorType = {
    PERSON = 0,
    SERVICE = 1,
    APPLICATION = 2,
    GROUP = 3,
    ORGANIZATION = 4,
}

--- DeliveryStatus matching the Idris2 ABI tags.
M.DeliveryStatus = {
    PENDING = 0,
    DELIVERED = 1,
    FAILED = 2,
    REJECTED = 3,
    DEFERRED = 4,
}

--- TrustLevel matching the Idris2 ABI tags.
M.TrustLevel = {
    SELF_SIGNED = 0,
    PEER_VERIFIED = 1,
    FEDERATION_TRUSTED = 2,
    REVOKED = 3,
    UNKNOWN = 4,
}

--- ObjectType matching the Idris2 ABI tags.
M.ObjectType = {
    NOTE = 0,
    ARTICLE = 1,
    IMAGE = 2,
    VIDEO = 3,
    AUDIO = 4,
    DOCUMENT = 5,
    EVENT = 6,
    COLLECTION = 7,
    ORDERED_COLLECTION = 8,
}

--- ServerState matching the Idris2 ABI tags.
M.ServerState = {
    IDLE = 0,
    ACTIVE = 1,
    PROCESSING = 2,
    DELIVERING = 3,
    SHUTDOWN = 4,
}

return M
