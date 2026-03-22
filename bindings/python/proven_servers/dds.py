# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-dds protocol types.

"""DDS protocol types for proven-servers."""

from enum import IntEnum


class ReliabilityKind(IntEnum):
    """ReliabilityKind matching the Idris2 ABI tags."""
    BEST_EFFORT = 0
    RELIABLE = 1


class DurabilityKind(IntEnum):
    """DurabilityKind matching the Idris2 ABI tags."""
    TRANSIENT_LOCAL = 1
    TRANSIENT = 2
    PERSISTENT = 3


class HistoryKind(IntEnum):
    """HistoryKind matching the Idris2 ABI tags."""
    KEEP_LAST = 0
    KEEP_ALL = 1


class OwnershipKind(IntEnum):
    """OwnershipKind matching the Idris2 ABI tags."""
    SHARED = 0
    EXCLUSIVE = 1


class EntityType(IntEnum):
    """EntityType matching the Idris2 ABI tags."""
    PARTICIPANT = 0
    PUBLISHER = 1
    SUBSCRIBER = 2
    TOPIC = 3
    DATA_WRITER = 4
    DATA_READER = 5


class ParticipantState(IntEnum):
    """ParticipantState matching the Idris2 ABI tags."""
    IDLE = 0
    JOINED = 1
    PUBLISHING = 2
    SUBSCRIBING = 3
    LEAVING = 4
