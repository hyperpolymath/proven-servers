# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-deception protocol types.

"""Deception protocol types for proven-servers."""

from enum import IntEnum


class DecoyType(IntEnum):
    """DecoyType matching the Idris2 ABI tags."""
    SERVICE = 0
    CREDENTIAL = 1
    FILE = 2
    NETWORK = 3
    TOKEN = 4
    BREADCRUMB = 5


class TriggerEvent(IntEnum):
    """TriggerEvent matching the Idris2 ABI tags."""
    ACCESS = 0
    LOGIN = 1
    READ = 2
    WRITE = 3
    EXECUTE = 4
    SCAN = 5


class AlertPriority(IntEnum):
    """AlertPriority matching the Idris2 ABI tags."""
    LOW = 0
    MEDIUM = 1
    HIGH = 2
    CRITICAL = 3


class DecoyState(IntEnum):
    """DecoyState matching the Idris2 ABI tags."""
    ACTIVE = 0
    TRIGGERED = 1
    DISABLED = 2
    EXPIRED = 3


class ResponseAction(IntEnum):
    """ResponseAction matching the Idris2 ABI tags."""
    ALERT = 0
    REDIRECT = 1
    DELAY = 2
    FINGERPRINT = 3
    ISOLATE = 4


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    CONFIGURED = 1
    MONITORING = 2
    RESPONDING = 3
    SHUTDOWN = 4
