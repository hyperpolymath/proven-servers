# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-siem protocol types.

"""SIEM protocol types for proven-servers."""

from enum import IntEnum


class EventSeverity(IntEnum):
    """EventSeverity matching the Idris2 ABI tags."""
    INFO = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4


class EventCategory(IntEnum):
    """EventCategory matching the Idris2 ABI tags."""
    AUTHENTICATION = 0
    NETWORK_TRAFFIC = 1
    FILE_ACTIVITY = 2
    PROCESS_EXECUTION = 3
    POLICY_VIOLATION = 4
    MALWARE = 5
    DATA_EXFILTRATION = 6


class CorrelationRule(IntEnum):
    """CorrelationRule matching the Idris2 ABI tags."""
    THRESHOLD = 0
    SEQUENCE = 1
    AGGREGATION = 2
    ABSENCE = 3
    STATISTICAL = 4


class AlertState(IntEnum):
    """AlertState matching the Idris2 ABI tags."""
    NEW = 0
    ACKNOWLEDGED = 1
    IN_PROGRESS = 2
    RESOLVED = 3
    FALSE_POSITIVE = 4
