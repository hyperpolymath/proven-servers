# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-tftp protocol types.

"""TFTP protocol types for proven-servers."""

from enum import IntEnum


class Opcode(IntEnum):
    """Opcode matching the Idris2 ABI tags."""
    RRQ = 0
    WRQ = 1
    DATA = 2
    ACK = 3
    ERROR = 4


class TransferMode(IntEnum):
    """TransferMode matching the Idris2 ABI tags."""
    NET_ASCII = 0
    OCTET = 1
    MAIL = 2


class TftpError(IntEnum):
    """TftpError matching the Idris2 ABI tags."""
    NOT_DEFINED = 0
    FILE_NOT_FOUND = 1
    ACCESS_VIOLATION = 2
    DISK_FULL = 3
    ILLEGAL_OPERATION = 4
    UNKNOWN_TID = 5
    FILE_EXISTS = 6
    NO_SUCH_USER = 7


class TransferState(IntEnum):
    """TransferState matching the Idris2 ABI tags."""
    IDLE = 0
    READING = 1
    WRITING = 2
    IN_ERROR = 3
    COMPLETE = 4
