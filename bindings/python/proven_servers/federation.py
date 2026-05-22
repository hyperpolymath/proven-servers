# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-federation protocol types.

"""Federation protocol types for proven-servers."""

from enum import IntEnum


class ActivityType(IntEnum):
    """ActivityType matching the Idris2 ABI tags."""
    CREATE = 0
    UPDATE = 1
    DELETE = 2
    FOLLOW = 3
    ACCEPT = 4
    REJECT = 5
    ANNOUNCE = 6
    LIKE = 7
    UNDO = 8
    BLOCK = 9
    FLAG = 10


class ActorType(IntEnum):
    """ActorType matching the Idris2 ABI tags."""
    PERSON = 0
    SERVICE = 1
    APPLICATION = 2
    GROUP = 3
    ORGANIZATION = 4


class DeliveryStatus(IntEnum):
    """DeliveryStatus matching the Idris2 ABI tags."""
    PENDING = 0
    DELIVERED = 1
    FAILED = 2
    REJECTED = 3
    DEFERRED = 4


class TrustLevel(IntEnum):
    """TrustLevel matching the Idris2 ABI tags."""
    SELF_SIGNED = 0
    PEER_VERIFIED = 1
    FEDERATION_TRUSTED = 2
    REVOKED = 3
    UNKNOWN = 4


class ObjectType(IntEnum):
    """ObjectType matching the Idris2 ABI tags."""
    NOTE = 0
    ARTICLE = 1
    IMAGE = 2
    VIDEO = 3
    AUDIO = 4
    DOCUMENT = 5
    EVENT = 6
    COLLECTION = 7
    ORDERED_COLLECTION = 8


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    ACTIVE = 1
    PROCESSING = 2
    DELIVERING = 3
    SHUTDOWN = 4
