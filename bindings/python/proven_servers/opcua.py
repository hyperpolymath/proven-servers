# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-opcua protocol types.

"""OPC UA protocol types for proven-servers."""

from enum import IntEnum


class ServiceType(IntEnum):
    """ServiceType matching the Idris2 ABI tags."""
    READ = 0
    WRITE = 1
    BROWSE = 2
    SUBSCRIBE = 3
    PUBLISH = 4
    CALL = 5
    CREATE_SESSION = 6
    ACTIVATE_SESSION = 7
    CLOSE_SESSION = 8
    CREATE_SUBSCRIPTION = 9
    DELETE_SUBSCRIPTION = 10


class NodeClass(IntEnum):
    """NodeClass matching the Idris2 ABI tags."""
    OBJECT = 0
    VARIABLE = 1
    METHOD = 2
    OBJECT_TYPE = 3
    VARIABLE_TYPE = 4
    REFERENCE_TYPE = 5
    DATA_TYPE = 6
    VIEW = 7


class StatusCode(IntEnum):
    """StatusCode matching the Idris2 ABI tags."""
    GOOD = 0
    UNCERTAIN = 1
    BAD = 2
    BAD_NODE_ID_UNKNOWN = 3
    BAD_ATTRIBUTE_ID_INVALID = 4
    BAD_NOT_READABLE = 5
    BAD_NOT_WRITABLE = 6
    BAD_OUT_OF_RANGE = 7
    BAD_TYPE_MISMATCH = 8
    BAD_SESSION_ID_INVALID = 9
    BAD_SUBSCRIPTION_ID_INVALID = 10
    BAD_TIMEOUT = 11


class SecurityMode(IntEnum):
    """SecurityMode matching the Idris2 ABI tags."""
    NONE = 0
    SIGN = 1
    SIGN_AND_ENCRYPT = 2


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    CONNECTED = 1
    CREATED = 2
    ACTIVATED = 3
    MONITORING = 4
    CLOSING = 5
