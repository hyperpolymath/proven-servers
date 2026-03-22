# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-http protocol types.

"""HTTP protocol types for proven-servers."""

from enum import IntEnum


class Method(IntEnum):
    """Method matching the Idris2 ABI tags."""
    GET = 0
    POST = 1
    PUT = 2
    DELETE = 3
    PATCH = 4
    HEAD = 5
    OPTIONS = 6
    TRACE = 7
    CONNECT = 8


class Version(IntEnum):
    """Version matching the Idris2 ABI tags."""
    HTTP10 = 0
    HTTP11 = 1
    HTTP20 = 2
    HTTP30 = 3


class StatusCategory(IntEnum):
    """StatusCategory matching the Idris2 ABI tags."""
    INFORMATIONAL = 0
    SUCCESS = 1
    REDIRECT = 2
    CLIENT_ERROR = 3
    SERVER_ERROR = 4


class StatusCode(IntEnum):
    """StatusCode matching the Idris2 ABI tags."""
    CONTINUE = 0
    SWITCHING_PROTOCOLS = 1
    OK = 2
    CREATED = 3
    ACCEPTED = 4
    NO_CONTENT = 5
    MOVED_PERMANENTLY = 6
    FOUND = 7
    NOT_MODIFIED = 8
    TEMPORARY_REDIRECT = 9
    PERMANENT_REDIRECT = 10
    BAD_REQUEST = 11
    UNAUTHORIZED = 12
    FORBIDDEN = 13
    NOT_FOUND = 14
    METHOD_NOT_ALLOWED = 15
    REQUEST_TIMEOUT = 16
    CONFLICT = 17
    GONE = 18
    LENGTH_REQUIRED = 19
    PAYLOAD_TOO_LARGE = 20
    URI_TOO_LONG = 21
    UNSUPPORTED_MEDIA = 22
    TOO_MANY_REQUESTS = 23
    INTERNAL_ERROR = 24
    NOT_IMPLEMENTED = 25
    BAD_GATEWAY = 26
    SERVICE_UNAVAILABLE = 27
    GATEWAY_TIMEOUT = 28


class ContentType(IntEnum):
    """ContentType matching the Idris2 ABI tags."""
    TEXT_PLAIN = 0
    TEXT_HTML = 1
    APPLICATION_JSON = 2
    APPLICATION_XML = 3
    APPLICATION_FORM = 4
    MULTIPART_FORM = 5
    OCTET_STREAM = 6
    TEXT_CSS = 7


class HeaderType(IntEnum):
    """HeaderType matching the Idris2 ABI tags."""
    CONTENT_TYPE = 0
    CONTENT_LENGTH = 1
    HOST = 2
    CONNECTION = 3
    ACCEPT = 4
    USER_AGENT = 5
    SERVER = 6
    LOCATION = 7
    CACHE_CONTROL = 8
    CUSTOM = 9


class RequestPhase(IntEnum):
    """RequestPhase matching the Idris2 ABI tags."""
    IDLE = 0
    RECEIVING = 1
    HEADERS_PARSED = 2
    BODY_RECEIVING = 3
    COMPLETE = 4
    RESPONDING = 5
    SENT = 6
