# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-tacacs protocol types.

"""TACACS+ protocol types for proven-servers."""

from enum import IntEnum


class PacketType(IntEnum):
    """PacketType matching the Idris2 ABI tags."""
    AUTHENTICATION = 0
    AUTHORIZATION = 1
    ACCOUNTING = 2


class AuthenType(IntEnum):
    """AuthenType matching the Idris2 ABI tags."""
    ASCII = 0
    PAP = 1
    CHAP = 2
    MS_CHAP_V1 = 3
    MS_CHAP_V2 = 4


class AuthenAction(IntEnum):
    """AuthenAction matching the Idris2 ABI tags."""
    LOGIN = 0
    CHANGE_PASS = 1
    SEND_AUTH = 2


class AuthenStatus(IntEnum):
    """AuthenStatus matching the Idris2 ABI tags."""
    PASS = 0
    AUTHEN_STATUS_FAIL = 1
    GET_DATA = 2
    GET_USER = 3
    GET_PASS = 4
    RESTART = 5
    AUTHEN_STATUS_ERROR = 6
    AUTHEN_STATUS_FOLLOW = 7


class AuthorStatus(IntEnum):
    """AuthorStatus matching the Idris2 ABI tags."""
    PASS_ADD = 0
    PASS_REPL = 1
    AUTHOR_STATUS_FAIL = 2
    AUTHOR_STATUS_ERROR = 3
    AUTHOR_STATUS_FOLLOW = 4


class AcctStatus(IntEnum):
    """AcctStatus matching the Idris2 ABI tags."""
    SUCCESS = 0
    ACCT_STATUS_ERROR = 1
    ACCT_STATUS_FOLLOW = 2


class AcctFlag(IntEnum):
    """AcctFlag matching the Idris2 ABI tags."""
    START = 0
    STOP = 1
    WATCHDOG = 2


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    AUTHENTICATING = 1
    AUTHORIZING = 2
    ACTIVE = 3
    CLOSING = 4
