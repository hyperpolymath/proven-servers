# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-webdav protocol types.

"""WebDAV protocol types for proven-servers."""

from enum import IntEnum


class Method(IntEnum):
    """Method matching the Idris2 ABI tags."""
    PROPFIND = 0
    PROPPATCH = 1
    MKCOL = 2
    COPY = 3
    MOVE = 4
    LOCK = 5
    UNLOCK = 6


class StatusCode(IntEnum):
    """StatusCode matching the Idris2 ABI tags."""
    MULTI_STATUS = 0
    UNPROCESSABLE_ENTITY = 1
    LOCKED = 2
    FAILED_DEPENDENCY = 3
    INSUFFICIENT_STORAGE = 4


class LockScope(IntEnum):
    """LockScope matching the Idris2 ABI tags."""
    EXCLUSIVE = 0
    SHARED = 1


class LockType(IntEnum):
    """LockType matching the Idris2 ABI tags."""
    WRITE = 0


class Depth(IntEnum):
    """Depth matching the Idris2 ABI tags."""
    ZERO = 0
    ONE = 1
    INFINITY = 2


class PropertyOp(IntEnum):
    """PropertyOp matching the Idris2 ABI tags."""
    SET = 0
    REMOVE = 1
