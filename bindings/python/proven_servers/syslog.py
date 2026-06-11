# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-syslog protocol types.

"""Syslog protocol types for proven-servers."""

from enum import IntEnum


class Severity(IntEnum):
    """Severity matching the Idris2 ABI tags."""
    EMERGENCY = 0
    SEVERITY_ALERT = 1
    CRITICAL = 2
    ERROR = 3
    WARNING = 4
    NOTICE = 5
    INFORMATIONAL = 6
    DEBUG = 7


class Facility(IntEnum):
    """Facility matching the Idris2 ABI tags."""
    KERN = 0
    USER = 1
    MAIL = 2
    DAEMON = 3
    AUTH = 4
    SYSLOG = 5
    LPR = 6
    NEWS = 7
    UUCP = 8
    CRON = 9
    AUTH_PRIV = 10
    FTP = 11
    NTP = 12
    AUDIT = 13
    FACILITY_ALERT = 14
    CLOCK = 15
    LOCAL0 = 16
    LOCAL1 = 17
    LOCAL2 = 18
    LOCAL3 = 19
    LOCAL4 = 20
    LOCAL5 = 21
    LOCAL6 = 22
    LOCAL7 = 23


class Transport(IntEnum):
    """Transport matching the Idris2 ABI tags."""
    UDP514 = 0
    TCP514 = 1
    TLS6514 = 2
