# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-appserver protocol types.

"""App Server protocol types for proven-servers."""

from enum import IntEnum


class RequestType(IntEnum):
    """RequestType matching the Idris2 ABI tags."""
    HTTP = 0
    WEB_SOCKET = 1
    GRPC = 2
    GRAPH_QL = 3


class LifecycleState(IntEnum):
    """LifecycleState matching the Idris2 ABI tags."""
    INITIALIZING = 0
    STARTING = 1
    RUNNING = 2
    DRAINING = 3
    STOPPING = 4
    STOPPED = 5


class HealthCheck(IntEnum):
    """HealthCheck matching the Idris2 ABI tags."""
    LIVENESS = 0
    READINESS = 1
    STARTUP = 2


class DeployStrategy(IntEnum):
    """DeployStrategy matching the Idris2 ABI tags."""
    ROLLING_UPDATE = 0
    BLUE_GREEN = 1
    CANARY = 2
    RECREATE = 3


class ErrorCategory(IntEnum):
    """ErrorCategory matching the Idris2 ABI tags."""
    CLIENT_ERROR = 0
    SERVER_ERROR = 1
    TIMEOUT = 2
    CIRCUIT_OPEN = 3
    RATE_LIMITED = 4
