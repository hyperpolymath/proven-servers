# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-tls Zig FFI.
#
# Note: The TLS protocol FFI follows the same slot-based context pool
# pattern as all other proven-servers protocols. The Zig FFI library
# (libproven_tls.so) must be built separately.

"""Python bindings for the proven-tls protocol FFI."""

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

class TlsState(IntEnum):
    """TLS handshake lifecycle states matching the Idris2 ABI tags."""
    IDLE = 0
    CLIENT_HELLO = 1
    SERVER_HELLO = 2
    NEGOTIATED = 3
    HANDSHAKE_COMPLETE = 4
    APPLICATION_DATA = 5
    SHUTDOWN = 6
    CLOSED = 7


class TlsVersion(IntEnum):
    """TLS protocol version tags matching the Idris2 ABI."""
    TLS_1_2 = 0
    TLS_1_3 = 1


class CipherSuite(IntEnum):
    """TLS cipher suite tags matching the Idris2 ABI."""
    AES_128_GCM_SHA256 = 0
    AES_256_GCM_SHA384 = 1
    CHACHA20_POLY1305_SHA256 = 2
    AES_128_CCM_SHA256 = 3


class CertStatus(IntEnum):
    """Certificate validation status tags."""
    UNCHECKED = 0
    VALID = 1
    EXPIRED = 2
    REVOKED = 3
    SELF_SIGNED = 4
    UNKNOWN_CA = 5
    HOSTNAME_MISMATCH = 6


class AlertLevel(IntEnum):
    """TLS alert level tags."""
    WARNING = 0
    FATAL = 1


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-tls shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("tls")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.tls_abi_version.restype = ctypes.c_uint32
    lib.tls_create.restype = ctypes.c_int
    lib.tls_create.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.tls_destroy.restype = None
    lib.tls_destroy.argtypes = [ctypes.c_int]
    lib.tls_state.restype = ctypes.c_uint8
    lib.tls_state.argtypes = [ctypes.c_int]
    lib.tls_version.restype = ctypes.c_uint8
    lib.tls_version.argtypes = [ctypes.c_int]
    lib.tls_cipher_suite.restype = ctypes.c_uint8
    lib.tls_cipher_suite.argtypes = [ctypes.c_int]
    lib.tls_cert_status.restype = ctypes.c_uint8
    lib.tls_cert_status.argtypes = [ctypes.c_int]
    lib.tls_is_resumed.restype = ctypes.c_uint8
    lib.tls_is_resumed.argtypes = [ctypes.c_int]
    lib.tls_bytes_sent.restype = ctypes.c_uint64
    lib.tls_bytes_sent.argtypes = [ctypes.c_int]
    lib.tls_bytes_received.restype = ctypes.c_uint64
    lib.tls_bytes_received.argtypes = [ctypes.c_int]
    lib.tls_client_hello.restype = ctypes.c_uint8
    lib.tls_client_hello.argtypes = [ctypes.c_int]
    lib.tls_server_hello.restype = ctypes.c_uint8
    lib.tls_server_hello.argtypes = [ctypes.c_int]
    lib.tls_negotiate.restype = ctypes.c_uint8
    lib.tls_negotiate.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.tls_complete_handshake.restype = ctypes.c_uint8
    lib.tls_complete_handshake.argtypes = [ctypes.c_int]
    lib.tls_validate_cert.restype = ctypes.c_uint8
    lib.tls_validate_cert.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.tls_send_data.restype = ctypes.c_uint8
    lib.tls_send_data.argtypes = [ctypes.c_int, ctypes.c_uint32]
    lib.tls_receive_data.restype = ctypes.c_uint8
    lib.tls_receive_data.argtypes = [ctypes.c_int, ctypes.c_uint32]
    lib.tls_rekey.restype = ctypes.c_uint8
    lib.tls_rekey.argtypes = [ctypes.c_int]
    lib.tls_shutdown.restype = ctypes.c_uint8
    lib.tls_shutdown.argtypes = [ctypes.c_int]
    lib.tls_send_alert.restype = ctypes.c_uint8
    lib.tls_send_alert.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.tls_can_transition.restype = ctypes.c_uint8
    lib.tls_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class TlsContext:
    """Context manager for a TLS session lifecycle.

    Usage::

        with TlsContext(TlsVersion.TLS_1_3, CipherSuite.AES_256_GCM_SHA384) as ctx:
            ctx.client_hello()
            ctx.server_hello()
            ctx.negotiate(CipherSuite.AES_256_GCM_SHA384)
            ctx.validate_cert(CertStatus.VALID)
            ctx.complete_handshake()
            ctx.send_data(1024)
            ctx.shutdown()
    """

    def __init__(self, version: TlsVersion = TlsVersion.TLS_1_3,
                 cipher_suite: CipherSuite = CipherSuite.AES_256_GCM_SHA384) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.tls_create(version.value, cipher_suite.value))
        self._lib = lib
        self._closed = False

    def __enter__(self) -> TlsContext:
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
            self._lib.tls_destroy(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def state(self) -> Optional[TlsState]:
        """Get the current TLS handshake state."""
        tag = self._lib.tls_state(self._slot)
        try:
            return TlsState(tag)
        except ValueError:
            return None

    def version(self) -> Optional[TlsVersion]:
        """Get the negotiated TLS version."""
        tag = self._lib.tls_version(self._slot)
        try:
            return TlsVersion(tag)
        except ValueError:
            return None

    def cipher_suite(self) -> Optional[CipherSuite]:
        """Get the negotiated cipher suite."""
        tag = self._lib.tls_cipher_suite(self._slot)
        try:
            return CipherSuite(tag)
        except ValueError:
            return None

    def cert_status(self) -> Optional[CertStatus]:
        """Get the certificate validation status."""
        tag = self._lib.tls_cert_status(self._slot)
        try:
            return CertStatus(tag)
        except ValueError:
            return None

    def is_resumed(self) -> bool:
        """Check if this is a resumed session."""
        return self._lib.tls_is_resumed(self._slot) == 1

    def bytes_sent(self) -> int:
        """Get the total bytes sent over the TLS connection."""
        return self._lib.tls_bytes_sent(self._slot)

    def bytes_received(self) -> int:
        """Get the total bytes received over the TLS connection."""
        return self._lib.tls_bytes_received(self._slot)

    # -- Handshake ---------------------------------------------------------

    def client_hello(self) -> None:
        """Send ClientHello. Transitions Idle -> ClientHello."""
        check_status(self._lib.tls_client_hello(self._slot))

    def server_hello(self) -> None:
        """Receive ServerHello. Transitions ClientHello -> ServerHello."""
        check_status(self._lib.tls_server_hello(self._slot))

    def negotiate(self, cipher_suite: CipherSuite) -> None:
        """Negotiate cipher suite. Transitions ServerHello -> Negotiated."""
        check_status(self._lib.tls_negotiate(self._slot, cipher_suite.value))

    def validate_cert(self, status: CertStatus) -> None:
        """Validate the server certificate."""
        check_status(self._lib.tls_validate_cert(self._slot, status.value))

    def complete_handshake(self) -> None:
        """Complete the handshake. Transitions Negotiated -> HandshakeComplete."""
        check_status(self._lib.tls_complete_handshake(self._slot))

    # -- Data transfer -----------------------------------------------------

    def send_data(self, length: int) -> None:
        """Record sending data over the TLS connection."""
        check_status(self._lib.tls_send_data(self._slot, length))

    def receive_data(self, length: int) -> None:
        """Record receiving data over the TLS connection."""
        check_status(self._lib.tls_receive_data(self._slot, length))

    def rekey(self) -> None:
        """Re-key the session. Only valid in ApplicationData state."""
        check_status(self._lib.tls_rekey(self._slot))

    # -- Shutdown ----------------------------------------------------------

    def shutdown(self) -> None:
        """Initiate TLS shutdown. Transitions ApplicationData -> Shutdown."""
        check_status(self._lib.tls_shutdown(self._slot))

    def send_alert(self, level: AlertLevel) -> None:
        """Send a TLS alert."""
        check_status(self._lib.tls_send_alert(self._slot, level.value))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().tls_abi_version()


def can_transition(from_state: TlsState, to_state: TlsState) -> bool:
    """Stateless query: check whether a TLS state transition is valid."""
    return _get_lib().tls_can_transition(from_state.value, to_state.value) == 1
