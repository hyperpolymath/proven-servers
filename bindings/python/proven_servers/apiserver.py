# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-apiserver protocol types.

"""API Server protocol types for proven-servers."""

from enum import IntEnum


class AuthScheme(IntEnum):
    """AuthScheme matching the Idris2 ABI tags."""
    API_KEY = 0
    BEARER = 1
    BASIC = 2
    O_AUTH2 = 3
    HMAC = 4
    MTLS = 5


class RateLimitStrategy(IntEnum):
    """RateLimitStrategy matching the Idris2 ABI tags."""
    FIXED_WINDOW = 0
    SLIDING_WINDOW = 1
    TOKEN_BUCKET = 2
    LEAKY_BUCKET = 3


class ApiVersion(IntEnum):
    """ApiVersion matching the Idris2 ABI tags."""
    V1 = 0
    V2 = 1
    V3 = 2
    LATEST = 3
    DEPRECATED = 4


class ResponseFormat(IntEnum):
    """ResponseFormat matching the Idris2 ABI tags."""
    JSON = 0
    XML = 1
    PROTOBUF = 2
    MESSAGE_PACK = 3


class GatewayError(IntEnum):
    """GatewayError matching the Idris2 ABI tags."""
    UNAUTHORIZED = 0
    RATE_LIMITED = 1
    NOT_FOUND = 2
    BAD_REQUEST = 3
    SERVICE_UNAVAILABLE = 4
    CIRCUIT_OPEN = 5
