# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-diode protocol types.

"""Data Diode protocol types for proven-servers."""

from enum import IntEnum


class Direction(IntEnum):
    """Direction matching the Idris2 ABI tags."""
    HIGH_TO_LOW = 0
    LOW_TO_HIGH = 1


class DiodeProtocol(IntEnum):
    """DiodeProtocol matching the Idris2 ABI tags."""
    UDP = 0
    TCP = 1
    FILE_TRANSFER = 2
    SYSLOG = 3
    SNMP = 4


class TransferState(IntEnum):
    """TransferState matching the Idris2 ABI tags."""
    QUEUED = 0
    SENDING = 1
    CONFIRMING = 2
    COMPLETE = 3
    FAILED = 4


class ValidationResult(IntEnum):
    """ValidationResult matching the Idris2 ABI tags."""
    PASSED = 0
    FORMAT_ERROR = 1
    SIZE_EXCEEDED = 2
    POLICY_BLOCKED = 3


class IntegrityCheck(IntEnum):
    """IntegrityCheck matching the Idris2 ABI tags."""
    CRC32 = 0
    SHA256 = 1
    HMAC = 2


class GatewayState(IntEnum):
    """GatewayState matching the Idris2 ABI tags."""
    IDLE = 0
    CONFIGURED = 1
    TRANSFERRING = 2
    VALIDATING = 3
    SHUTDOWN = 4
