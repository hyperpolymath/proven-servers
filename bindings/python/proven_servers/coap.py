# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-coap protocol types.

"""CoAP protocol types for proven-servers."""

from enum import IntEnum


class Method(IntEnum):
    """Method matching the Idris2 ABI tags."""
    GET = 0
    POST = 1
    PUT = 2
    DELETE = 3


class MessageType(IntEnum):
    """MessageType matching the Idris2 ABI tags."""
    CONFIRMABLE = 0
    NON_CONFIRMABLE = 1
    ACKNOWLEDGEMENT = 2
    RESET = 3


class ContentFormat(IntEnum):
    """ContentFormat matching the Idris2 ABI tags."""
    TEXT_PLAIN = 0
    LINK_FORMAT = 1
    XML = 2
    OCTET_STREAM = 3
    EXI = 4
    JSON = 5
    CBOR = 6


class ResponseClass(IntEnum):
    """ResponseClass matching the Idris2 ABI tags."""
    SUCCESS = 0
    CLIENT_ERROR = 1
    SERVER_ERROR = 2
    SIGNALING = 3
    EMPTY = 4


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    BOUND = 1
    SERVING = 2
    OBSERVING = 3
    SHUTDOWN = 4
