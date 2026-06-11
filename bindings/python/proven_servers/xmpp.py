# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-xmpp protocol types.

"""XMPP protocol types for proven-servers."""

from enum import IntEnum


class StanzaType(IntEnum):
    """StanzaType matching the Idris2 ABI tags."""
    MESSAGE = 0
    PRESENCE = 1
    IQ = 2


class MessageType(IntEnum):
    """MessageType matching the Idris2 ABI tags."""
    CHAT = 0
    MESSAGE_TYPE_ERROR = 1
    GROUPCHAT = 2
    HEADLINE = 3
    NORMAL = 4


class PresenceType(IntEnum):
    """PresenceType matching the Idris2 ABI tags."""
    AVAILABLE = 0
    AWAY = 1
    DND = 2
    XA = 3
    UNAVAILABLE = 4


class IqType(IntEnum):
    """IqType matching the Idris2 ABI tags."""
    GET = 0
    SET = 1
    RESULT = 2
    IQ_TYPE_ERROR = 3


class StreamError(IntEnum):
    """StreamError matching the Idris2 ABI tags."""
    BAD_FORMAT = 0
    CONFLICT = 1
    CONNECTION_TIMEOUT = 2
    HOST_GONE = 3
    HOST_UNKNOWN = 4
    NOT_AUTHORIZED = 5
    POLICY_VIOLATION = 6
    RESOURCE_CONSTRAINT = 7
    SYSTEM_SHUTDOWN = 8
