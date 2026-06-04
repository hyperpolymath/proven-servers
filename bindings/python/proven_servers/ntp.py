# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ntp protocol types.

"""NTP protocol types for proven-servers."""

from enum import IntEnum


class LeapIndicator(IntEnum):
    """LeapIndicator matching the Idris2 ABI tags."""
    NO_WARNING = 0
    LAST_MINUTE61 = 1
    LAST_MINUTE59 = 2
    UNSYNCHRONISED = 3


class NtpMode(IntEnum):
    """NtpMode matching the Idris2 ABI tags."""
    RESERVED = 0
    SYMMETRIC_ACTIVE = 1
    SYMMETRIC_PASSIVE = 2
    CLIENT = 3
    SERVER = 4
    BROADCAST = 5
    CONTROL_MESSAGE = 6
    PRIVATE = 7


class ExchangeState(IntEnum):
    """ExchangeState matching the Idris2 ABI tags."""
    IDLE = 0
    REQUEST_RECEIVED = 1
    TIMESTAMP_CALCULATED = 2
    RESPONSE_SENT = 3


class ClockDisciplineState(IntEnum):
    """ClockDisciplineState matching the Idris2 ABI tags."""
    UNSET = 0
    SPIKE = 1
    FREQ = 2
    SYNC = 3
    PANIC = 4


class KissCode(IntEnum):
    """KissCode matching the Idris2 ABI tags."""
    DENY = 0
    RSTR = 1
    RATE = 2
    OTHER = 3


class NtpError(IntEnum):
    """NtpError matching the Idris2 ABI tags."""
    OK = 0
    INVALID_SLOT = 1
    NOT_ACTIVE = 2
    INVALID_PACKET = 3
    KISS_OF_DEATH = 4
    STRATUM_TOO_HIGH = 5
