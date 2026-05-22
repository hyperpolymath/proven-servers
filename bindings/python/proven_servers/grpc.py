# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-grpc Zig FFI.

"""Python bindings for the proven-grpc protocol FFI."""

from __future__ import annotations

import ctypes
from enum import IntEnum
from types import TracebackType
from typing import Optional

from proven_servers.error import check_slot, check_status
from proven_servers.ffi import load_library


# ---------------------------------------------------------------------------
# Enums matching Idris2 ABI tags
# ---------------------------------------------------------------------------

class StreamState(IntEnum):
    """HTTP/2 stream states matching the Idris2 ABI tags."""
    IDLE = 0
    RESERVED = 1
    OPEN = 2
    HALF_CLOSED_LOCAL = 3
    HALF_CLOSED_REMOTE = 4
    CLOSED = 5


class Compression(IntEnum):
    """gRPC compression algorithms matching the Idris2 ABI tags."""
    NONE = 0
    GZIP = 1
    DEFLATE = 2
    SNAPPY = 3
    ZSTD = 4


class StatusCode(IntEnum):
    """gRPC status codes matching the Idris2 ABI tags."""
    OK = 0
    CANCELLED = 1
    UNKNOWN = 2
    INVALID_ARGUMENT = 3
    DEADLINE_EXCEEDED = 4
    NOT_FOUND = 5
    ALREADY_EXISTS = 6
    PERMISSION_DENIED = 7
    RESOURCE_EXHAUSTED = 8
    FAILED_PRECONDITION = 9
    ABORTED = 10
    OUT_OF_RANGE = 11
    UNIMPLEMENTED = 12
    INTERNAL = 13
    UNAVAILABLE = 14
    DATA_LOSS = 15
    UNAUTHENTICATED = 16


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-grpc shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("grpc")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.grpc_abi_version.restype = ctypes.c_uint32
    lib.grpc_create.restype = ctypes.c_int
    lib.grpc_create.argtypes = [ctypes.c_uint8]
    lib.grpc_destroy.restype = None
    lib.grpc_destroy.argtypes = [ctypes.c_int]
    lib.grpc_stream_state.restype = ctypes.c_uint8
    lib.grpc_stream_state.argtypes = [ctypes.c_int]
    lib.grpc_compression.restype = ctypes.c_uint8
    lib.grpc_compression.argtypes = [ctypes.c_int]
    lib.grpc_status_code.restype = ctypes.c_uint8
    lib.grpc_status_code.argtypes = [ctypes.c_int]
    lib.grpc_set_status.restype = ctypes.c_uint8
    lib.grpc_set_status.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.grpc_stream_id.restype = ctypes.c_uint32
    lib.grpc_stream_id.argtypes = [ctypes.c_int]
    lib.grpc_send_headers.restype = ctypes.c_uint8
    lib.grpc_send_headers.argtypes = [ctypes.c_int]
    lib.grpc_local_end_stream.restype = ctypes.c_uint8
    lib.grpc_local_end_stream.argtypes = [ctypes.c_int]
    lib.grpc_remote_end_stream.restype = ctypes.c_uint8
    lib.grpc_remote_end_stream.argtypes = [ctypes.c_int]
    lib.grpc_reset_stream.restype = ctypes.c_uint8
    lib.grpc_reset_stream.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.grpc_close_half_local.restype = ctypes.c_uint8
    lib.grpc_close_half_local.argtypes = [ctypes.c_int]
    lib.grpc_close_half_remote.restype = ctypes.c_uint8
    lib.grpc_close_half_remote.argtypes = [ctypes.c_int]
    lib.grpc_push_promise.restype = ctypes.c_uint8
    lib.grpc_push_promise.argtypes = [ctypes.c_int]
    lib.grpc_reserved_to_half.restype = ctypes.c_uint8
    lib.grpc_reserved_to_half.argtypes = [ctypes.c_int]
    lib.grpc_can_send.restype = ctypes.c_uint8
    lib.grpc_can_send.argtypes = [ctypes.c_int]
    lib.grpc_can_receive.restype = ctypes.c_uint8
    lib.grpc_can_receive.argtypes = [ctypes.c_int]
    lib.grpc_send_window.restype = ctypes.c_int32
    lib.grpc_send_window.argtypes = [ctypes.c_int]
    lib.grpc_recv_window.restype = ctypes.c_int32
    lib.grpc_recv_window.argtypes = [ctypes.c_int]
    lib.grpc_update_send_window.restype = ctypes.c_uint8
    lib.grpc_update_send_window.argtypes = [ctypes.c_int, ctypes.c_int32]
    lib.grpc_update_recv_window.restype = ctypes.c_uint8
    lib.grpc_update_recv_window.argtypes = [ctypes.c_int, ctypes.c_int32]
    lib.grpc_can_transition.restype = ctypes.c_uint8
    lib.grpc_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class GrpcContext:
    """Context manager for a gRPC stream lifecycle.

    Usage::

        with GrpcContext(Compression.NONE) as ctx:
            ctx.send_headers()
            ctx.set_status(StatusCode.OK)
            ctx.local_end_stream()
    """

    def __init__(self, compression: Compression = Compression.NONE) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.grpc_create(compression.value))
        self._lib = lib
        self._closed = False

    def __enter__(self) -> GrpcContext:
        return self

    def __exit__(self, exc_type: Optional[type[BaseException]],
                 exc_val: Optional[BaseException],
                 exc_tb: Optional[TracebackType]) -> None:
        self.close()

    def __del__(self) -> None:
        self.close()

    def close(self) -> None:
        """Release the context slot back to the pool."""
        if not self._closed:
            self._lib.grpc_destroy(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def stream_state(self) -> Optional[StreamState]:
        """Get the current HTTP/2 stream state."""
        tag = self._lib.grpc_stream_state(self._slot)
        try:
            return StreamState(tag)
        except ValueError:
            return None

    def compression(self) -> int:
        """Get the compression algorithm tag."""
        return self._lib.grpc_compression(self._slot)

    def status_code(self) -> Optional[StatusCode]:
        """Get the gRPC status code."""
        tag = self._lib.grpc_status_code(self._slot)
        try:
            return StatusCode(tag)
        except ValueError:
            return None

    def stream_id(self) -> int:
        """Get the HTTP/2 stream ID."""
        return self._lib.grpc_stream_id(self._slot)

    def can_send(self) -> bool:
        """Check if DATA frames can be sent from this state."""
        return self._lib.grpc_can_send(self._slot) == 1

    def can_receive(self) -> bool:
        """Check if DATA frames can be received in this state."""
        return self._lib.grpc_can_receive(self._slot) == 1

    def send_window(self) -> int:
        """Get the send-side flow control window."""
        return self._lib.grpc_send_window(self._slot)

    def recv_window(self) -> int:
        """Get the receive-side flow control window."""
        return self._lib.grpc_recv_window(self._slot)

    # -- Stream commands ---------------------------------------------------

    def set_status(self, status: StatusCode) -> None:
        """Set the gRPC status code."""
        check_status(self._lib.grpc_set_status(self._slot, status.value))

    def send_headers(self) -> None:
        """Send HEADERS frame. Transitions Idle -> Open."""
        check_status(self._lib.grpc_send_headers(self._slot))

    def local_end_stream(self) -> None:
        """Local END_STREAM. Transitions Open -> HalfClosedLocal."""
        check_status(self._lib.grpc_local_end_stream(self._slot))

    def remote_end_stream(self) -> None:
        """Remote END_STREAM. Transitions Open -> HalfClosedRemote."""
        check_status(self._lib.grpc_remote_end_stream(self._slot))

    def reset_stream(self, status: StatusCode) -> None:
        """RST_STREAM. Transitions Open -> Closed."""
        check_status(self._lib.grpc_reset_stream(self._slot, status.value))

    def close_half_local(self) -> None:
        """Close from HalfClosedLocal -> Closed."""
        check_status(self._lib.grpc_close_half_local(self._slot))

    def close_half_remote(self) -> None:
        """Close from HalfClosedRemote -> Closed."""
        check_status(self._lib.grpc_close_half_remote(self._slot))

    def push_promise(self) -> None:
        """PUSH_PROMISE. Transitions Idle -> Reserved."""
        check_status(self._lib.grpc_push_promise(self._slot))

    def reserved_to_half(self) -> None:
        """Reserved -> HalfClosedRemote."""
        check_status(self._lib.grpc_reserved_to_half(self._slot))

    def update_send_window(self, delta: int) -> None:
        """Update the send-side flow control window by delta."""
        check_status(self._lib.grpc_update_send_window(self._slot, delta))

    def update_recv_window(self, delta: int) -> None:
        """Update the receive-side flow control window by delta."""
        check_status(self._lib.grpc_update_recv_window(self._slot, delta))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().grpc_abi_version()


def can_transition(from_state: StreamState, to_state: StreamState) -> bool:
    """Stateless query: check whether a stream state transition is valid."""
    return _get_lib().grpc_can_transition(from_state.value, to_state.value) == 1
