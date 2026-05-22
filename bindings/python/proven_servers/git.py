# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-git protocol types.

"""Git protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    UPLOAD_PACK = 0
    RECEIVE_PACK = 1
    UPLOAD_ARCHIVE = 2


class PacketType(IntEnum):
    """PacketType matching the Idris2 ABI tags."""
    FLUSH = 0
    DELIMITER = 1
    RESPONSE_END = 2
    DATA = 3
    PKT_ERROR = 4
    SIDEBAND_DATA = 5
    SIDEBAND_PROGRESS = 6
    SIDEBAND_ERROR = 7


class RefType(IntEnum):
    """RefType matching the Idris2 ABI tags."""
    BRANCH = 0
    TAG = 1
    HEAD = 2
    REMOTE = 3
    GIT_NOTE = 4


class Capability(IntEnum):
    """Capability matching the Idris2 ABI tags."""
    MULTI_ACK = 0
    THIN_PACK = 1
    SIDE_BAND64K = 2
    OFS_DELTA = 3
    SHALLOW = 4
    DEEPEN_SINCE = 5
    DEEPEN_NOT = 6
    FILTER_SPEC = 7
    OBJECT_FORMAT = 8


class HookResult(IntEnum):
    """HookResult matching the Idris2 ABI tags."""
    ACCEPT = 0
    REJECT = 1


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    DISCOVERY = 1
    NEGOTIATING = 2
    TRANSFER = 3
    SHUTDOWN = 4
