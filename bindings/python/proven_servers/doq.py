# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-doq protocol types.

"""DoQ protocol types for proven-servers."""

from enum import IntEnum


class StreamType(IntEnum):
    """StreamType matching the Idris2 ABI tags."""
    UNIDIRECTIONAL = 0
    BIDIRECTIONAL = 1


class ErrorCode(IntEnum):
    """ErrorCode matching the Idris2 ABI tags."""
    NO_ERROR = 0
    INTERNAL_ERROR = 1
    EXCESSIVE_LOAD = 2
    PROTOCOL_ERROR = 3


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    INITIAL = 0
    HANDSHAKING = 1
    READY = 2
    DRAINING = 3
    CLOSED = 4


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    BOUND = 1
    LISTENING = 2
    PROCESSING = 3
    SHUTDOWN = 4
