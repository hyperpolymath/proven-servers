# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ldap protocol types.

"""LDAP protocol types for proven-servers."""

from enum import IntEnum


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    ANONYMOUS = 0
    BOUND = 1
    CLOSED = 2
    BINDING = 3


class Operation(IntEnum):
    """Operation matching the Idris2 ABI tags."""
    BIND = 0
    UNBIND = 1
    SEARCH = 2
    MODIFY = 3
    ADD = 4
    DELETE = 5
    MOD_DN = 6
    COMPARE = 7
    ABANDON = 8
    EXTENDED = 9


class SearchScope(IntEnum):
    """SearchScope matching the Idris2 ABI tags."""
    BASE_OBJECT = 0
    SINGLE_LEVEL = 1
    WHOLE_SUBTREE = 2


class ResultCode(IntEnum):
    """ResultCode matching the Idris2 ABI tags."""
    SUCCESS = 0
    OPERATIONS_ERROR = 1
    PROTOCOL_ERROR = 2
    TIME_LIMIT_EXCEEDED = 3
    SIZE_LIMIT_EXCEEDED = 4
    AUTH_METHOD_NOT_SUPPORTED = 5
    NO_SUCH_OBJECT = 6
    INVALID_CREDENTIALS = 7
    INSUFFICIENT_ACCESS_RIGHTS = 8
    BUSY = 9
    UNAVAILABLE = 10
