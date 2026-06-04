# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-cache protocol types.

"""Cache protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    GET = 0
    SET = 1
    DELETE = 2
    EXISTS = 3
    EXPIRE = 4
    TTL = 5
    KEYS = 6
    FLUSH = 7
    INCR = 8
    DECR = 9
    APPEND = 10
    PREPEND = 11
    CAS = 12


class EvictionPolicy(IntEnum):
    """EvictionPolicy matching the Idris2 ABI tags."""
    LRU = 0
    LFU = 1
    RANDOM = 2
    EVICT_TTL = 3
    NO_EVICTION = 4


class DataType(IntEnum):
    """DataType matching the Idris2 ABI tags."""
    STRING_VAL = 0
    INT_VAL = 1
    LIST_VAL = 2
    SET_VAL = 3
    HASH_VAL = 4


class ErrorCode(IntEnum):
    """ErrorCode matching the Idris2 ABI tags."""
    NOT_FOUND = 0
    TYPE_MISMATCH = 1
    OUT_OF_MEMORY = 2
    KEY_TOO_LONG = 3
    VALUE_TOO_LARGE = 4
    CAS_CONFLICT = 5


class ReplicationMode(IntEnum):
    """ReplicationMode matching the Idris2 ABI tags."""
    NONE = 0
    PRIMARY = 1
    REPLICA = 2
    SENTINEL = 3
