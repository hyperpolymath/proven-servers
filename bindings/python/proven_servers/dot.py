# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-dot protocol types.

"""DoT protocol types for proven-servers."""

from enum import IntEnum


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    CONNECTING = 0
    HANDSHAKING = 1
    ESTABLISHED = 2
    CLOSING = 3
    CLOSED = 4


class PaddingStrategy(IntEnum):
    """PaddingStrategy matching the Idris2 ABI tags."""
    NO_PADDING = 0
    BLOCK_PADDING = 1
    RANDOM_PADDING = 2


class ErrorReason(IntEnum):
    """ErrorReason matching the Idris2 ABI tags."""
    HANDSHAKE_FAILED = 0
    CERTIFICATE_INVALID = 1
    TIMEOUT = 2
    UPSTREAM_ERROR = 3


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    BOUND = 1
    LISTENING = 2
    PROCESSING = 3
    SHUTDOWN = 4
