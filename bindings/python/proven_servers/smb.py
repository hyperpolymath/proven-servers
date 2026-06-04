# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-smb protocol types.

"""SMB protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    NEGOTIATE = 0
    SESSION_SETUP = 1
    LOGOFF = 2
    TREE_CONNECT = 3
    TREE_DISCONNECT = 4
    CREATE = 5
    CLOSE = 6
    READ = 7
    WRITE = 8
    LOCK = 9
    IOCTL = 10
    CANCEL = 11
    QUERY_DIRECTORY = 12
    CHANGE_NOTIFY = 13
    QUERY_INFO = 14
    SET_INFO = 15


class Dialect(IntEnum):
    """Dialect matching the Idris2 ABI tags."""
    SMB2_0_2 = 0
    SMB2_1 = 1
    SMB3_0 = 2
    SMB3_0_2 = 3
    SMB3_1_1 = 4


class ShareType(IntEnum):
    """ShareType matching the Idris2 ABI tags."""
    DISK = 0
    PIPE = 1
    PRINT = 2


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    NEGOTIATED = 1
    AUTHENTICATED = 2
    TREE_CONNECTED = 3
    FILE_OPEN = 4
    DISCONNECTING = 5
