# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-carddav protocol types.

"""CardDAV protocol types for proven-servers."""

from enum import IntEnum


class PropertyType(IntEnum):
    """PropertyType matching the Idris2 ABI tags."""
    FN_NAME = 0
    N = 1
    EMAIL = 2
    TEL = 3
    ADR = 4
    ORG = 5
    PHOTO = 6
    URL = 7
    NOTE = 8


class CardMethod(IntEnum):
    """CardMethod matching the Idris2 ABI tags."""
    GET = 0
    PUT = 1
    DELETE = 2
    PROPFIND = 3
    PROPPATCH = 4
    REPORT = 5
    MKCOL = 6


class VCardVersion(IntEnum):
    """VCardVersion matching the Idris2 ABI tags."""
    VCARD3 = 0
    VCARD4 = 1


class CardError(IntEnum):
    """CardError matching the Idris2 ABI tags."""
    VALID_ADDRESS_DATA = 0
    NO_RESOURCE_TYPE = 1
    MAX_RESOURCE_SIZE = 2
    UID_CONFLICT = 3
    SUPPORTED_ADDRESS_DATA = 4
    PRECONDITION_FAILED = 5


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    BOUND = 1
    SERVING = 2
    SHUTDOWN = 3
