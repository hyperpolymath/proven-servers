# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-snmp protocol types.

"""SNMP protocol types for proven-servers."""

from enum import IntEnum


class Version(IntEnum):
    """Version matching the Idris2 ABI tags."""
    V1 = 0
    V2C = 1
    V3 = 2


class PduType(IntEnum):
    """PduType matching the Idris2 ABI tags."""
    GET_REQUEST = 0
    GET_NEXT_REQUEST = 1
    GET_RESPONSE = 2
    SET_REQUEST = 3
    GET_BULK_REQUEST = 4
    INFORM_REQUEST = 5
    SNMP_V2_TRAP = 6


class ErrorStatus(IntEnum):
    """ErrorStatus matching the Idris2 ABI tags."""
    NO_ERROR = 0
    TOO_BIG = 1
    NO_SUCH_NAME = 2
    BAD_VALUE = 3
    READ_ONLY = 4
    GEN_ERR = 5
    NO_ACCESS = 6
    WRONG_TYPE = 7
    WRONG_LENGTH = 8
    WRONG_VALUE = 9
    NO_CREATION = 10
    INCONSISTENT_VALUE = 11
    RESOURCE_UNAVAILABLE = 12
    COMMIT_FAILED = 13
    UNDO_FAILED = 14
    AUTHORIZATION_ERROR = 15
