# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-nts protocol types.

"""NTS protocol types for proven-servers."""

from enum import IntEnum


class RecordType(IntEnum):
    """RecordType matching the Idris2 ABI tags."""
    END_OF_MESSAGE = 0
    NEXT_PROTOCOL = 1
    ERROR = 2
    WARNING = 3
    AEAD_ALGORITHM = 4
    COOKIE = 5
    COOKIE_PLACEHOLDER = 6
    NTSKE_SERVER = 7
    NTSKE_PORT = 8


class ErrorCode(IntEnum):
    """ErrorCode matching the Idris2 ABI tags."""
    UNRECOGNIZED_CRITICAL = 0
    BAD_REQUEST = 1
    INTERNAL_ERROR = 2


class AeadAlgorithm(IntEnum):
    """AeadAlgorithm matching the Idris2 ABI tags."""
    AEAD_AES128_GCM = 0
    AEAD_AES256_GCM = 1
    AEAD_AES_SIV_CMAC256 = 2


class HandshakeState(IntEnum):
    """HandshakeState matching the Idris2 ABI tags."""
    INITIAL = 0
    HANDSHAKE_STATE_NEGOTIATING = 1
    HANDSHAKE_STATE_ESTABLISHED = 2
    FAILED = 3


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    HANDSHAKING = 1
    SESSION_STATE_NEGOTIATING = 2
    SESSION_STATE_ESTABLISHED = 3
    CLOSING = 4
