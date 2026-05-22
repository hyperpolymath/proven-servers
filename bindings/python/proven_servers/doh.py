# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-doh protocol types.

"""DoH protocol types for proven-servers."""

from enum import IntEnum


class ContentType(IntEnum):
    """ContentType matching the Idris2 ABI tags."""
    DNS_MESSAGE = 0
    DNS_JSON = 1


class RequestMethod(IntEnum):
    """RequestMethod matching the Idris2 ABI tags."""
    GET = 0
    POST = 1


class WireFormat(IntEnum):
    """WireFormat matching the Idris2 ABI tags."""
    BINARY = 0
    JSON = 1


class ErrorReason(IntEnum):
    """ErrorReason matching the Idris2 ABI tags."""
    BAD_CONTENT_TYPE = 0
    BAD_METHOD = 1
    PAYLOAD_TOO_LARGE = 2
    UPSTREAM_TIMEOUT = 3
    UPSTREAM_ERROR = 4


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    BOUND = 1
    SERVING = 2
    RESOLVING = 3
    SHUTDOWN = 4
