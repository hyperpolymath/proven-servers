# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-bfd protocol types.

"""BFD protocol types for proven-servers."""

from enum import IntEnum


class BfdState(IntEnum):
    """BfdState matching the Idris2 ABI tags."""
    ADMIN_DOWN = 0
    DOWN = 1
    INIT = 2
    UP = 3


class Diagnostic(IntEnum):
    """Diagnostic matching the Idris2 ABI tags."""
    NO_DIAGNOSTIC = 0
    CONTROL_DETECTION_TIME_EXPIRED = 1
    ECHO_FUNCTION_FAILED = 2
    NEIGHBOR_SIGNALED_SESSION_DOWN = 3
    FORWARDING_PLANE_RESET = 4
    PATH_DOWN = 5
    CONCATENATED_PATH_DOWN = 6
    ADMINISTRATIVELY_DOWN = 7
    REVERSE_CONCATENATED_PATH_DOWN = 8


class SessionMode(IntEnum):
    """SessionMode matching the Idris2 ABI tags."""
    ASYNC_MODE = 0
    DEMAND_MODE = 1


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    SS_DOWN = 1
    NEGOTIATING = 2
    ESTABLISHED = 3
    TEARDOWN = 4
