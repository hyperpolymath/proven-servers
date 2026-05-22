# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-radius protocol types.

"""RADIUS protocol types for proven-servers."""

from enum import IntEnum


class PacketType(IntEnum):
    """PacketType matching the Idris2 ABI tags."""
    ACCESS_REQUEST = 1
    ACCESS_ACCEPT = 2
    ACCESS_REJECT = 3
    ACCOUNTING_REQUEST = 4
    ACCOUNTING_RESPONSE = 5
    ACCESS_CHALLENGE = 11


class AttributeType(IntEnum):
    """AttributeType matching the Idris2 ABI tags."""
    USER_NAME = 1
    USER_PASSWORD = 2
    NAS_IP_ADDRESS = 4
    NAS_PORT = 5
    SERVICE_TYPE = 6
    FRAMED_PROTOCOL = 7
    FRAMED_IP_ADDRESS = 8
    REPLY_MESSAGE = 18
    SESSION_TIMEOUT = 27


class ServiceType(IntEnum):
    """ServiceType matching the Idris2 ABI tags."""
    LOGIN = 1
    FRAMED = 2
    CALLBACK_LOGIN = 3
    CALLBACK_FRAMED = 4
    OUTBOUND = 5
    ADMINISTRATIVE = 6


class AuthMethod(IntEnum):
    """AuthMethod matching the Idris2 ABI tags."""
    PAP = 0
    CHAP = 1
    MSCHAP = 2
    MSCHAPV2 = 3
    EAP = 4


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    AUTHENTICATING = 1
    AUTHORIZED = 2
    REJECTED = 3
    CHALLENGED = 4
    ACCOUNTING = 5
    COMPLETE = 6


class RadiusResult(IntEnum):
    """RadiusResult matching the Idris2 ABI tags."""
    OK = 0
    ERR = 1
    INVALID_PARAM = 2
    POOL_EXHAUSTED = 3
    BAD_SECRET = 4
