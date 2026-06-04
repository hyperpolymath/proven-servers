# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-rtsp protocol types.

"""RTSP protocol types for proven-servers."""

from enum import IntEnum


class Method(IntEnum):
    """Method matching the Idris2 ABI tags."""
    DESCRIBE = 0
    SETUP = 1
    PLAY = 2
    PAUSE = 3
    TEARDOWN = 4
    GET_PARAMETER = 5
    SET_PARAMETER = 6
    OPTIONS = 7
    ANNOUNCE = 8
    RECORD = 9
    REDIRECT = 10


class TransportProtocol(IntEnum):
    """TransportProtocol matching the Idris2 ABI tags."""
    RTP_AVP_UDP = 0
    RTP_AVP_TCP = 1
    RTP_AVP_UDP_MULTICAST = 2


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    INIT = 0
    READY = 1
    PLAYING = 2
    RECORDING = 3


class StatusCode(IntEnum):
    """StatusCode matching the Idris2 ABI tags."""
    STATUS_CODE_OK = 0
    MOVED_PERMANENTLY = 1
    MOVED_TEMPORARILY = 2
    BAD_REQUEST = 3
    UNAUTHORIZED = 4
    NOT_FOUND = 5
    STATUS_CODE_METHOD_NOT_ALLOWED = 6
    NOT_ACCEPTABLE = 7
    SESSION_NOT_FOUND = 8
    INTERNAL_SERVER_ERROR = 9
    NOT_IMPLEMENTED = 10
    SERVICE_UNAVAILABLE = 11


class RtspError(IntEnum):
    """RtspError matching the Idris2 ABI tags."""
    RTSP_ERROR_OK = 0
    INVALID_SLOT = 1
    NOT_ACTIVE = 2
    INVALID_TRANSITION = 3
    RTSP_ERROR_METHOD_NOT_ALLOWED = 4
    TRANSPORT_ERROR = 5
    SESSION_EXPIRED = 6
