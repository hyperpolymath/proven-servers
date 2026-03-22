# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-imap protocol types.

"""IMAP protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    LOGIN = 0
    COMMAND_LOGOUT = 1
    SELECT = 2
    EXAMINE = 3
    CREATE = 4
    DELETE = 5
    RENAME = 6
    LIST = 7
    FETCH = 8
    STORE = 9
    SEARCH = 10
    COPY = 11
    NOOP = 12
    CAPABILITY = 13


class State(IntEnum):
    """State matching the Idris2 ABI tags."""
    NOT_AUTHENTICATED = 0
    AUTHENTICATED = 1
    SELECTED = 2
    STATE_LOGOUT = 3


class Flag(IntEnum):
    """Flag matching the Idris2 ABI tags."""
    SEEN = 0
    ANSWERED = 1
    FLAGGED = 2
    DELETED = 3
    DRAFT = 4
    RECENT = 5
