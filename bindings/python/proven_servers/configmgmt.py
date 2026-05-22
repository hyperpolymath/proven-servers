# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-configmgmt protocol types.

"""Config Mgmt protocol types for proven-servers."""

from enum import IntEnum


class ResourceType(IntEnum):
    """ResourceType matching the Idris2 ABI tags."""
    FILE = 0
    PACKAGE = 1
    SERVICE = 2
    USER = 3
    GROUP = 4
    CRON = 5
    MOUNT = 6
    FIREWALL = 7
    REGISTRY = 8


class ResourceState(IntEnum):
    """ResourceState matching the Idris2 ABI tags."""
    PRESENT = 0
    ABSENT = 1
    RUNNING = 2
    STOPPED = 3
    ENABLED = 4
    DISABLED = 5


class ChangeAction(IntEnum):
    """ChangeAction matching the Idris2 ABI tags."""
    CREATE = 0
    MODIFY = 1
    DELETE = 2
    RESTART = 3
    RELOAD = 4
    SKIP = 5


class DriftStatus(IntEnum):
    """DriftStatus matching the Idris2 ABI tags."""
    IN_SYNC = 0
    DRIFTED = 1
    D_UNKNOWN = 2
    UNMANAGED = 3


class ApplyMode(IntEnum):
    """ApplyMode matching the Idris2 ABI tags."""
    ENFORCE = 0
    DRY_RUN = 1
    AUDIT = 2
