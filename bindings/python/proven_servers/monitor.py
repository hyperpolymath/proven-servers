# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-monitor protocol types.

"""Monitor protocol types for proven-servers."""

from enum import IntEnum


class CheckType(IntEnum):
    """CheckType matching the Idris2 ABI tags."""
    HTTP = 0
    TCP = 1
    UDP = 2
    ICMP = 3
    DNS = 4
    CERTIFICATE = 5
    DISK = 6
    CPU = 7
    MEMORY = 8
    PROCESS = 9
    CUSTOM = 10


class Status(IntEnum):
    """Status matching the Idris2 ABI tags."""
    UP = 0
    DOWN = 1
    DEGRADED = 2
    UNKNOWN = 3
    MAINTENANCE = 4


class AlertChannel(IntEnum):
    """AlertChannel matching the Idris2 ABI tags."""
    EMAIL = 0
    SMS = 1
    WEBHOOK = 2
    SLACK = 3
    PAGER_DUTY = 4


class Severity(IntEnum):
    """Severity matching the Idris2 ABI tags."""
    INFO = 0
    WARNING = 1
    ERROR = 2
    CRITICAL = 3


class CheckState(IntEnum):
    """CheckState matching the Idris2 ABI tags."""
    PENDING = 0
    CHECK_STATE_RUNNING = 1
    PASSED = 2
    FAILED = 3
    TIMEOUT = 4
    CS_ERROR = 5


class MonitorState(IntEnum):
    """MonitorState matching the Idris2 ABI tags."""
    IDLE = 0
    CONFIGURED = 1
    MONITOR_STATE_RUNNING = 2
    MON_PAUSED = 3
    ALERTING = 4
    SHUTDOWN = 5
