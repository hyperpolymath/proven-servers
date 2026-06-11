# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-honeypot protocol types.

"""Honeypot protocol types for proven-servers."""

from enum import IntEnum


class ServiceEmulation(IntEnum):
    """ServiceEmulation matching the Idris2 ABI tags."""
    SSH = 0
    HTTP = 1
    FTP = 2
    SMTP = 3
    TELNET = 4
    MYSQL = 5
    RDP = 6


class InteractionLevel(IntEnum):
    """InteractionLevel matching the Idris2 ABI tags."""
    LOW = 0
    MEDIUM = 1
    HIGH = 2


class HoneypotAlertSeverity(IntEnum):
    """HoneypotAlertSeverity matching the Idris2 ABI tags."""
    INFO = 0
    AS_LOW = 1
    AS_MEDIUM = 2
    AS_HIGH = 3
    CRITICAL = 4


class AttackerAction(IntEnum):
    """AttackerAction matching the Idris2 ABI tags."""
    SCAN = 0
    BRUTE_FORCE = 1
    EXPLOIT = 2
    PAYLOAD = 3
    LATERAL = 4
    EXFILTRATION = 5


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    DEPLOYED = 1
    ENGAGED = 2
    SHUTDOWN = 3
