# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-httpd Zig FFI.
#
# Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig:
#   - Context lifecycle: http_create_context, http_destroy_context
#   - Request parsing: http_parse_request
#   - Request queries: http_get_method, http_get_path, http_get_header, http_get_body
#   - Response construction: http_set_status, http_set_header, http_set_body,
#     http_send_response
#   - Phase & transition: http_get_phase, http_get_version, http_keep_alive_check,
#     http_reset_context, http_can_transition

"""Python bindings for the proven-httpd protocol FFI."""

from __future__ import annotations

import ctypes
from enum import IntEnum
from types import TracebackType
from typing import Optional

from proven_servers.error import ProvenError, check_slot, check_status
from proven_servers.ffi import load_library


# ---------------------------------------------------------------------------
# Enums matching Idris2 ABI tags
# ---------------------------------------------------------------------------

class Method(IntEnum):
    """HTTP request methods matching the Idris2 ABI tags."""
    GET = 0
    POST = 1
    PUT = 2
    DELETE = 3
    PATCH = 4
    HEAD = 5
    OPTIONS = 6
    TRACE = 7
    CONNECT = 8


class RequestPhase(IntEnum):
    """HTTP request lifecycle phases matching the Idris2 ABI tags."""
    IDLE = 0
    RECEIVING = 1
    HEADERS_PARSED = 2
    BODY_RECEIVING = 3
    COMPLETE = 4
    RESPONDING = 5
    SENT = 6


class StatusCode(IntEnum):
    """HTTP response status code tags matching the Idris2 ABI."""
    OK = 0
    CREATED = 1
    NO_CONTENT = 2
    MOVED_PERMANENTLY = 3
    FOUND = 4
    NOT_MODIFIED = 5
    BAD_REQUEST = 6
    UNAUTHORIZED = 7
    FORBIDDEN = 8
    NOT_FOUND = 9
    METHOD_NOT_ALLOWED = 10
    CONFLICT = 11
    GONE = 12
    UNPROCESSABLE_ENTITY = 13
    TOO_MANY_REQUESTS = 14
    INTERNAL_SERVER_ERROR = 15
    NOT_IMPLEMENTED = 16
    BAD_GATEWAY = 17
    SERVICE_UNAVAILABLE = 18
    GATEWAY_TIMEOUT = 19


class Version(IntEnum):
    """HTTP version tags matching the Idris2 ABI."""
    HTTP_1_0 = 0
    HTTP_1_1 = 1
    HTTP_2 = 2


class ParseResult(IntEnum):
    """Result of feeding raw HTTP data into a context."""
    COMPLETE = 0
    REJECTED = 1
    NEED_MORE = 2


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-httpd shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("httpd")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.http_abi_version.restype = ctypes.c_uint32
    lib.http_abi_version.argtypes = []

    lib.http_create_context.restype = ctypes.c_int
    lib.http_create_context.argtypes = []

    lib.http_destroy_context.restype = None
    lib.http_destroy_context.argtypes = [ctypes.c_int]

    lib.http_parse_request.restype = ctypes.c_uint8
    lib.http_parse_request.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]

    lib.http_get_method.restype = ctypes.c_uint8
    lib.http_get_method.argtypes = [ctypes.c_int]

    lib.http_get_path.restype = ctypes.c_uint32
    lib.http_get_path.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]

    lib.http_get_header.restype = ctypes.c_uint32
    lib.http_get_header.argtypes = [
        ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
        ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
    ]

    lib.http_get_body.restype = ctypes.c_uint32
    lib.http_get_body.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]

    lib.http_set_status.restype = ctypes.c_uint8
    lib.http_set_status.argtypes = [ctypes.c_int, ctypes.c_uint8]

    lib.http_set_header.restype = ctypes.c_uint8
    lib.http_set_header.argtypes = [
        ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
        ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
    ]

    lib.http_set_body.restype = ctypes.c_uint8
    lib.http_set_body.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]

    lib.http_send_response.restype = ctypes.c_uint8
    lib.http_send_response.argtypes = [ctypes.c_int]

    lib.http_keep_alive_check.restype = ctypes.c_uint8
    lib.http_keep_alive_check.argtypes = [ctypes.c_int]

    lib.http_get_phase.restype = ctypes.c_uint8
    lib.http_get_phase.argtypes = [ctypes.c_int]

    lib.http_get_version.restype = ctypes.c_uint8
    lib.http_get_version.argtypes = [ctypes.c_int]

    lib.http_reset_context.restype = ctypes.c_uint8
    lib.http_reset_context.argtypes = [ctypes.c_int]

    lib.http_can_transition.restype = ctypes.c_uint8
    lib.http_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class HttpContext:
    """Context manager for an HTTP request/response lifecycle.

    Wraps a slot in the Zig FFI context pool. The slot is automatically
    released when the context manager exits or the object is garbage
    collected.

    Usage::

        with HttpContext() as ctx:
            result = ctx.parse_request(raw_data)
            if result == ParseResult.COMPLETE:
                method = ctx.get_method()
                path = ctx.get_path()
                ctx.set_status(StatusCode.OK)
                ctx.set_body(b"Hello, world!")
                ctx.send_response()
    """

    def __init__(self) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.http_create_context())
        self._lib = lib
        self._closed = False

    def __enter__(self) -> HttpContext:
        return self

    def __exit__(
        self,
        exc_type: Optional[type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> None:
        self.close()

    def __del__(self) -> None:
        self.close()

    def close(self) -> None:
        """Release the context slot back to the pool."""
        if not self._closed:
            self._lib.http_destroy_context(self._slot)
            self._closed = True

    # -- Request parsing ---------------------------------------------------

    def parse_request(self, data: bytes) -> ParseResult:
        """Feed raw HTTP data into the context for parsing.

        Drives the Idle -> Receiving -> HeadersParsed -> Complete
        transition chain.

        Args:
            data: Raw HTTP request bytes.

        Returns:
            ParseResult indicating completion status.
        """
        buf = (ctypes.c_uint8 * len(data))(*data)
        result = self._lib.http_parse_request(self._slot, buf, len(data))
        return ParseResult(result)

    # -- Request queries ---------------------------------------------------

    def get_method(self) -> Optional[Method]:
        """Get the HTTP method of the parsed request.

        Returns None if the method has not been parsed yet (tag 255).
        """
        tag = self._lib.http_get_method(self._slot)
        if tag == 255:
            return None
        return Method(tag)

    def get_path(self, max_len: int = 4096) -> str:
        """Copy the request path from the context.

        Args:
            max_len: Maximum path length in bytes.

        Returns:
            The request path as a UTF-8 string.
        """
        buf = (ctypes.c_uint8 * max_len)()
        written = self._lib.http_get_path(self._slot, buf, max_len)
        return bytes(buf[:written]).decode("utf-8", errors="replace")

    def get_header(self, key: str, max_len: int = 4096) -> str:
        """Look up a request header by key (case-insensitive).

        Args:
            key: The header name to look up.
            max_len: Maximum value length in bytes.

        Returns:
            The header value, or empty string if not found.
        """
        key_bytes = key.encode("utf-8")
        key_buf = (ctypes.c_uint8 * len(key_bytes))(*key_bytes)
        val_buf = (ctypes.c_uint8 * max_len)()
        written = self._lib.http_get_header(
            self._slot, key_buf, len(key_bytes), val_buf, max_len,
        )
        return bytes(val_buf[:written]).decode("utf-8", errors="replace")

    def get_body(self, max_len: int = 65536) -> bytes:
        """Copy the request body from the context.

        Args:
            max_len: Maximum body length in bytes.

        Returns:
            The request body as raw bytes.
        """
        buf = (ctypes.c_uint8 * max_len)()
        written = self._lib.http_get_body(self._slot, buf, max_len)
        return bytes(buf[:written])

    # -- Response construction ---------------------------------------------

    def set_status(self, status: StatusCode) -> None:
        """Set the response status code.

        Requires the context to be in Complete or Responding phase.

        Args:
            status: The status code tag to set.

        Raises:
            ProvenError: If in the wrong phase.
        """
        check_status(self._lib.http_set_status(self._slot, status.value))

    def set_header(self, key: str, value: str) -> None:
        """Set a response header.

        Args:
            key: Header name.
            value: Header value.

        Raises:
            ProvenError: If in the wrong phase or capacity exceeded.
        """
        k = key.encode("utf-8")
        v = value.encode("utf-8")
        k_buf = (ctypes.c_uint8 * len(k))(*k)
        v_buf = (ctypes.c_uint8 * len(v))(*v)
        check_status(self._lib.http_set_header(
            self._slot, k_buf, len(k), v_buf, len(v),
        ))

    def set_body(self, data: bytes) -> None:
        """Set the response body.

        Args:
            data: Response body bytes.

        Raises:
            ProvenError: If in the wrong phase or capacity exceeded.
        """
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.http_set_body(self._slot, buf, len(data)))

    def send_response(self) -> None:
        """Send the response, transitioning Responding -> Sent.

        Raises:
            ProvenError: If not in Responding phase.
        """
        check_status(self._lib.http_send_response(self._slot))

    # -- Phase & transition ------------------------------------------------

    def keep_alive_check(self) -> bool:
        """Check if the connection uses keep-alive."""
        return self._lib.http_keep_alive_check(self._slot) == 1

    def get_phase(self) -> Optional[RequestPhase]:
        """Get the current request processing phase."""
        tag = self._lib.http_get_phase(self._slot)
        try:
            return RequestPhase(tag)
        except ValueError:
            return None

    def get_version(self) -> Optional[Version]:
        """Get the HTTP version of the parsed request."""
        tag = self._lib.http_get_version(self._slot)
        try:
            return Version(tag)
        except ValueError:
            return None

    def reset(self) -> None:
        """Reset the context for keep-alive reuse (Sent -> Idle).

        Raises:
            ProvenError: If not in Sent phase.
        """
        check_status(self._lib.http_reset_context(self._slot))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version of the linked libproven_httpd."""
    return _get_lib().http_abi_version()


def can_transition(from_phase: RequestPhase, to_phase: RequestPhase) -> bool:
    """Stateless query: check whether a lifecycle transition is valid.

    Args:
        from_phase: The source phase.
        to_phase: The target phase.

    Returns:
        True if the transition is allowed by the HTTP state machine.
    """
    return _get_lib().http_can_transition(from_phase.value, to_phase.value) == 1
