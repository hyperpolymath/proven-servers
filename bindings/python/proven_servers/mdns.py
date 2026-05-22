# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-mdns protocol types.

"""mDNS protocol types for proven-servers."""

from enum import IntEnum


class MdnsRecordType(IntEnum):
    """MdnsRecordType matching the Idris2 ABI tags."""
    A = 0
    AAAA = 1
    PTR = 2
    SRV = 3
    TXT = 4


class QueryType(IntEnum):
    """QueryType matching the Idris2 ABI tags."""
    STANDARD = 0
    ONE_SHOT = 1
    CONTINUOUS = 2


class ConflictAction(IntEnum):
    """ConflictAction matching the Idris2 ABI tags."""
    PROBE = 0
    DEFEND = 1
    WITHDRAW = 2


class ServiceFlag(IntEnum):
    """ServiceFlag matching the Idris2 ABI tags."""
    UNIQUE = 0
    SHARED = 1


class ResponderState(IntEnum):
    """ResponderState matching the Idris2 ABI tags."""
    IDLE = 0
    PROBING = 1
    ANNOUNCING = 2
    RUNNING = 3
    SHUTTING_DOWN = 4
