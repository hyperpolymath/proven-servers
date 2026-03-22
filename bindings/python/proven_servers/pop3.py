# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-pop3 protocol types.

"""POP3 protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    USER = 0
    PASS = 1
    STAT = 2
    LIST = 3
    RETR = 4
    DELE = 5
    NOOP = 6
    RSET = 7
    QUIT = 8
    TOP = 9
    UIDL = 10


class State(IntEnum):
    """State matching the Idris2 ABI tags."""
    AUTHORIZATION = 0
    TRANSACTION = 1
    UPDATE = 2


class Response(IntEnum):
    """Response matching the Idris2 ABI tags."""
    RESPONSE_OK = 0
    ERR = 1


class Pop3Error(IntEnum):
    """Pop3Error matching the Idris2 ABI tags."""
    POP3_ERROR_OK = 0
    INVALID_SLOT = 1
    NOT_ACTIVE = 2
    INVALID_TRANSITION = 3
    INVALID_COMMAND = 4
    AUTH_FAILED = 5
