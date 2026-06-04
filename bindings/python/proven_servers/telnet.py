# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-telnet protocol types.

"""Telnet protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    SE = 0
    NOP = 1
    DATA_MARK = 2
    BREAK = 3
    INTERRUPT_PROCESS = 4
    ABORT_OUTPUT = 5
    ARE_YOU_THERE = 6
    ERASE_CHAR = 7
    ERASE_LINE = 8
    GO_AHEAD = 9
    SB = 10
    WILL = 11
    WONT = 12
    DO = 13
    DONT = 14
    IAC = 15


class TelnetOption(IntEnum):
    """TelnetOption matching the Idris2 ABI tags."""
    ECHO = 0
    SUPPRESS_GO_AHEAD = 1
    STATUS = 2
    TIMING_MARK = 3
    TERMINAL_TYPE = 4
    WINDOW_SIZE = 5
    TERMINAL_SPEED = 6
    REMOTE_FLOW_CONTROL = 7
    LINEMODE = 8
    ENVIRONMENT = 9


class NegotiationState(IntEnum):
    """NegotiationState matching the Idris2 ABI tags."""
    INACTIVE = 0
    WILL_SENT = 1
    DO_SENT = 2
    NEGOTIATION_STATE_ACTIVE = 3


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    NEGOTIATING = 1
    SESSION_STATE_ACTIVE = 2
    SUBNEG = 3
    CLOSING = 4
