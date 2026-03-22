# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-fileserver protocol types.

"""File Server protocol types for proven-servers."""

from enum import IntEnum


class FileOperation(IntEnum):
    """FileOperation matching the Idris2 ABI tags."""
    READ = 0
    WRITE = 1
    CREATE = 2
    DELETE = 3
    RENAME = 4
    LIST = 5
    STAT = 6
    LOCK = 7
    UNLOCK = 8
    WATCH = 9


class FileType(IntEnum):
    """FileType matching the Idris2 ABI tags."""
    REGULAR = 0
    DIRECTORY = 1
    SYMLINK = 2
    BLOCK_DEVICE = 3
    CHAR_DEVICE = 4
    FIFO = 5
    SOCKET = 6


class FilePermission(IntEnum):
    """FilePermission matching the Idris2 ABI tags."""
    OWNER_READ = 0
    OWNER_WRITE = 1
    OWNER_EXECUTE = 2
    GROUP_READ = 3
    GROUP_WRITE = 4
    GROUP_EXECUTE = 5
    OTHER_READ = 6
    OTHER_WRITE = 7
    OTHER_EXECUTE = 8


class LockType(IntEnum):
    """LockType matching the Idris2 ABI tags."""
    SHARED = 0
    EXCLUSIVE = 1
    ADVISORY = 2
    MANDATORY = 3


class FileErrorCode(IntEnum):
    """FileErrorCode matching the Idris2 ABI tags."""
    NOT_FOUND = 0
    PERMISSION_DENIED = 1
    ALREADY_EXISTS = 2
    NOT_EMPTY = 3
    IS_DIRECTORY = 4
    NOT_DIRECTORY = 5
    NO_SPACE = 6
    READ_ONLY = 7
    LOCKED = 8
    IO_ERROR = 9


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    CONNECTED = 1
    OPERATING = 2
    FS_LOCKED = 3
    DISCONNECTING = 4
