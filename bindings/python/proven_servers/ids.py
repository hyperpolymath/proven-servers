# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ids protocol types.

"""IDS protocol types for proven-servers."""

from enum import IntEnum


class AlertSeverity(IntEnum):
    """AlertSeverity matching the Idris2 ABI tags."""
    ALERT_SEVERITY_LOW = 0
    ALERT_SEVERITY_MEDIUM = 1
    ALERT_SEVERITY_HIGH = 2
    ALERT_SEVERITY_CRITICAL = 3


class DetectionMethod(IntEnum):
    """DetectionMethod matching the Idris2 ABI tags."""
    SIGNATURE = 0
    ANOMALY = 1
    STATEFUL = 2
    HEURISTIC = 3


class IdsProtocol(IntEnum):
    """IdsProtocol matching the Idris2 ABI tags."""
    TCP = 0
    UDP = 1
    ICMP = 2
    DNS = 3
    HTTP = 4
    TLS = 5
    SSH = 6


class IdsAction(IntEnum):
    """IdsAction matching the Idris2 ABI tags."""
    ALERT = 0
    DROP = 1
    LOG = 2
    BLOCK = 3
    PASS = 4


class Direction(IntEnum):
    """Direction matching the Idris2 ABI tags."""
    INBOUND = 0
    OUTBOUND = 1
    BOTH = 2


class ThreatLevel(IntEnum):
    """ThreatLevel matching the Idris2 ABI tags."""
    INFO = 0
    THREAT_LEVEL_LOW = 1
    THREAT_LEVEL_MEDIUM = 2
    THREAT_LEVEL_HIGH = 3
    THREAT_LEVEL_CRITICAL = 4
