# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ocsp protocol types.

"""OCSP protocol types for proven-servers."""

from enum import IntEnum


class CertStatus(IntEnum):
    """CertStatus matching the Idris2 ABI tags."""
    GOOD = 0
    REVOKED = 1
    UNKNOWN = 2


class ResponseStatus(IntEnum):
    """ResponseStatus matching the Idris2 ABI tags."""
    SUCCESSFUL = 0
    MALFORMED_REQUEST = 1
    INTERNAL_ERROR = 2
    TRY_LATER = 3
    SIG_REQUIRED = 4
    UNAUTHORIZED = 5


class HashAlgorithm(IntEnum):
    """HashAlgorithm matching the Idris2 ABI tags."""
    SHA1 = 0
    SHA256 = 1
    SHA384 = 2
    SHA512 = 3


class ResponderState(IntEnum):
    """ResponderState matching the Idris2 ABI tags."""
    IDLE = 0
    READY = 1
    PROCESSING = 2
    SIGNING = 3
    CLOSING = 4
