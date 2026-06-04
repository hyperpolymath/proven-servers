# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-nfs protocol types.

"""NFS protocol types for proven-servers."""

from enum import IntEnum


class Operation(IntEnum):
    """Operation matching the Idris2 ABI tags."""
    OPERATION_ACCESS = 0
    CLOSE = 1
    COMMIT = 2
    CREATE = 3
    GET_ATTR = 4
    OPERATION_LINK = 5
    LOCK = 6
    LOOKUP = 7
    OPEN = 8
    READ = 9
    READ_DIR = 10
    REMOVE = 11
    RENAME = 12
    SET_ATTR = 13
    WRITE = 14


class FileType(IntEnum):
    """FileType matching the Idris2 ABI tags."""
    REGULAR = 0
    DIRECTORY = 1
    BLOCK_DEVICE = 2
    CHAR_DEVICE = 3
    FILE_TYPE_LINK = 4
    SOCKET = 5
    FIFO = 6


class Status(IntEnum):
    """Status matching the Idris2 ABI tags."""
    OK = 0
    PERM = 1
    NO_ENT = 2
    IO = 3
    NX_IO = 4
    STATUS_ACCESS = 5
    EXIST = 6
    NOT_DIR = 7
    IS_DIR = 8
    F_BIG = 9
    NO_SPC = 10
    R_OFS = 11
    NOT_EMPTY = 12
    STALE = 13


class NfsState(IntEnum):
    """NfsState matching the Idris2 ABI tags."""
    IDLE = 0
    MOUNTED = 1
    FILE_OPEN = 2
    LOCKED = 3
    BUSY = 4
    UNMOUNTING = 5
