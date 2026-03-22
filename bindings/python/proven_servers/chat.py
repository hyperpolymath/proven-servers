# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-chat protocol types.

"""Chat protocol types for proven-servers."""

from enum import IntEnum


class MessageType(IntEnum):
    """MessageType matching the Idris2 ABI tags."""
    TEXT = 0
    IMAGE = 1
    FILE = 2
    SYSTEM = 3
    REACTION = 4
    EDIT = 5
    DELETE = 6
    REPLY = 7
    THREAD = 8


class PresenceStatus(IntEnum):
    """PresenceStatus matching the Idris2 ABI tags."""
    ONLINE = 0
    AWAY = 1
    DND = 2
    INVISIBLE = 3
    OFFLINE = 4


class RoomType(IntEnum):
    """RoomType matching the Idris2 ABI tags."""
    DIRECT = 0
    GROUP = 1
    CHANNEL = 2
    BROADCAST = 3


class Permission(IntEnum):
    """Permission matching the Idris2 ABI tags."""
    READ = 0
    WRITE = 1
    ADMIN = 2
    INVITE = 3
    KICK = 4
    BAN = 5
    PIN = 6
    DELETE_OTHERS = 7


class Event(IntEnum):
    """Event matching the Idris2 ABI tags."""
    MESSAGE_SENT = 0
    MESSAGE_DELIVERED = 1
    MESSAGE_READ = 2
    USER_JOINED = 3
    USER_LEFT = 4
    TYPING = 5
    ROOM_CREATED = 6
