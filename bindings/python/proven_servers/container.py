# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-container protocol types.

"""Container protocol types for proven-servers."""

from enum import IntEnum


class ContainerState(IntEnum):
    """ContainerState matching the Idris2 ABI tags."""
    CREATING = 0
    RUNNING = 1
    PAUSED = 2
    RESTARTING = 3
    STOPPED = 4
    REMOVING = 5
    DEAD = 6


class ContainerOperation(IntEnum):
    """ContainerOperation matching the Idris2 ABI tags."""
    CREATE = 0
    START = 1
    STOP = 2
    RESTART = 3
    PAUSE = 4
    UNPAUSE = 5
    KILL = 6
    REMOVE = 7
    EXEC = 8
    LOGS = 9
    INSPECT = 10


class NetworkMode(IntEnum):
    """NetworkMode matching the Idris2 ABI tags."""
    BRIDGE = 0
    HOST = 1
    NONE = 2
    OVERLAY = 3
    MACVLAN = 4


class VolumeType(IntEnum):
    """VolumeType matching the Idris2 ABI tags."""
    BIND = 0
    NAMED = 1
    TMPFS = 2


class RestartPolicy(IntEnum):
    """RestartPolicy matching the Idris2 ABI tags."""
    NO = 0
    ALWAYS = 1
    ON_FAILURE = 2
    UNLESS_STOPPED = 3


class HealthStatus(IntEnum):
    """HealthStatus matching the Idris2 ABI tags."""
    STARTING = 0
    HEALTHY = 1
    UNHEALTHY = 2
    NO_CHECK = 3
