# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-netconf protocol types.

"""NETCONF protocol types for proven-servers."""

from enum import IntEnum


class NetconfOperation(IntEnum):
    """NetconfOperation matching the Idris2 ABI tags."""
    GET = 0
    GET_CONFIG = 1
    EDIT_CONFIG = 2
    COPY_CONFIG = 3
    DELETE_CONFIG = 4
    LOCK = 5
    UNLOCK = 6
    CLOSE_SESSION = 7
    KILL_SESSION = 8
    COMMIT = 9
    VALIDATE = 10
    DISCARD_CHANGES = 11


class Datastore(IntEnum):
    """Datastore matching the Idris2 ABI tags."""
    RUNNING = 0
    STARTUP = 1
    CANDIDATE = 2


class EditOperation(IntEnum):
    """EditOperation matching the Idris2 ABI tags."""
    MERGE = 0
    REPLACE = 1
    CREATE = 2
    DELETE = 3
    REMOVE = 4


class NetconfErrorType(IntEnum):
    """NetconfErrorType matching the Idris2 ABI tags."""
    TRANSPORT = 0
    RPC = 1
    PROTOCOL = 2
    APPLICATION = 3


class ErrorSeverity(IntEnum):
    """ErrorSeverity matching the Idris2 ABI tags."""
    ERROR = 0
    WARNING = 1


class NetconfState(IntEnum):
    """NetconfState matching the Idris2 ABI tags."""
    IDLE = 0
    CONNECTED = 1
    LOCKED = 2
    EDITING = 3
    CLOSING = 4
    TERMINATED = 5
