# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-gameserver protocol types.

"""Game Server protocol types for proven-servers."""

from enum import IntEnum


class SessionType(IntEnum):
    """SessionType matching the Idris2 ABI tags."""
    LOBBY = 0
    MATCH = 1
    PRACTICE = 2
    SPECTATOR = 3
    TOURNAMENT = 4


class PlayerState(IntEnum):
    """PlayerState matching the Idris2 ABI tags."""
    IDLE = 0
    QUEUING = 1
    LOADING = 2
    PLAYING = 3
    SPECTATING = 4
    DISCONNECTED = 5


class MatchState(IntEnum):
    """MatchState matching the Idris2 ABI tags."""
    WAITING = 0
    STARTING = 1
    IN_PROGRESS = 2
    PAUSED = 3
    ENDING = 4
    COMPLETE = 5
