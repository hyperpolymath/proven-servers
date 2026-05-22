# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-dns Zig FFI.
#
# Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig:
#   - Context lifecycle: dns_create_context, dns_destroy_context
#   - Query parsing: dns_parse_query
#   - Lifecycle: dns_begin_lookup, dns_begin_response
#   - Records: dns_add_answer, dns_add_authority, dns_add_additional
#   - Response: dns_set_rcode, dns_build_response
#   - DNSSEC: dns_enable_dnssec, dns_load_dnssec_key, dns_sign_response,
#     dns_validate_dnssec
#   - State queries and transition checks

"""Python bindings for the proven-dns protocol FFI."""

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

class DnsState(IntEnum):
    """DNS query lifecycle states matching the Idris2 ABI tags."""
    IDLE = 0
    QUERY_RECEIVED = 1
    LOOKUP = 2
    RESPONSE_BUILDING = 3
    SENT = 4


class DnssecState(IntEnum):
    """DNSSEC states matching the Idris2 ABI tags."""
    DISABLED = 0
    ENABLED = 1
    KEY_LOADED = 2
    VALIDATED = 3


class DnssecAlgorithm(IntEnum):
    """DNSSEC signing algorithms matching the Idris2 ABI tags."""
    RSA_SHA256 = 0
    RSA_SHA512 = 1
    ECDSA_P256_SHA256 = 2
    ECDSA_P384_SHA384 = 3
    ED25519 = 4


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-dns shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("dns")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.dns_abi_version.restype = ctypes.c_uint32
    lib.dns_create_context.restype = ctypes.c_int
    lib.dns_destroy_context.restype = None
    lib.dns_destroy_context.argtypes = [ctypes.c_int]
    lib.dns_state.restype = ctypes.c_uint8
    lib.dns_state.argtypes = [ctypes.c_int]
    lib.dns_dnssec_state.restype = ctypes.c_uint8
    lib.dns_dnssec_state.argtypes = [ctypes.c_int]
    lib.dns_rcode.restype = ctypes.c_uint8
    lib.dns_rcode.argtypes = [ctypes.c_int]
    lib.dns_answer_count.restype = ctypes.c_uint16
    lib.dns_answer_count.argtypes = [ctypes.c_int]
    lib.dns_authority_count.restype = ctypes.c_uint16
    lib.dns_authority_count.argtypes = [ctypes.c_int]
    lib.dns_additional_count.restype = ctypes.c_uint16
    lib.dns_additional_count.argtypes = [ctypes.c_int]
    lib.dns_query_rtype.restype = ctypes.c_uint8
    lib.dns_query_rtype.argtypes = [ctypes.c_int]
    lib.dns_query_class.restype = ctypes.c_uint8
    lib.dns_query_class.argtypes = [ctypes.c_int]
    lib.dns_parse_query.restype = ctypes.c_uint8
    lib.dns_parse_query.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint16]
    lib.dns_begin_lookup.restype = ctypes.c_uint8
    lib.dns_begin_lookup.argtypes = [ctypes.c_int]
    lib.dns_begin_response.restype = ctypes.c_uint8
    lib.dns_begin_response.argtypes = [ctypes.c_int]
    lib.dns_add_answer.restype = ctypes.c_uint8
    lib.dns_add_answer.argtypes = [ctypes.c_int, ctypes.c_uint8, ctypes.c_uint8, ctypes.c_uint32,
                                    ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint16]
    lib.dns_add_authority.restype = ctypes.c_uint8
    lib.dns_add_authority.argtypes = [ctypes.c_int, ctypes.c_uint8, ctypes.c_uint8, ctypes.c_uint32,
                                       ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint16]
    lib.dns_add_additional.restype = ctypes.c_uint8
    lib.dns_add_additional.argtypes = [ctypes.c_int, ctypes.c_uint8, ctypes.c_uint8, ctypes.c_uint32,
                                        ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint16]
    lib.dns_set_rcode.restype = ctypes.c_uint8
    lib.dns_set_rcode.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.dns_build_response.restype = ctypes.c_uint8
    lib.dns_build_response.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8),
                                        ctypes.POINTER(ctypes.c_uint16)]
    lib.dns_enable_dnssec.restype = ctypes.c_uint8
    lib.dns_enable_dnssec.argtypes = [ctypes.c_int]
    lib.dns_load_dnssec_key.restype = ctypes.c_uint8
    lib.dns_load_dnssec_key.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.dns_sign_response.restype = ctypes.c_uint8
    lib.dns_sign_response.argtypes = [ctypes.c_int]
    lib.dns_validate_dnssec.restype = ctypes.c_uint8
    lib.dns_validate_dnssec.argtypes = [ctypes.c_int]
    lib.dns_can_transition.restype = ctypes.c_uint8
    lib.dns_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.dns_can_dnssec_transition.restype = ctypes.c_uint8
    lib.dns_can_dnssec_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class DnsContext:
    """Context manager for a DNS query/response lifecycle.

    Wraps a slot in the Zig FFI context pool. The slot is automatically
    released when the context manager exits.

    Usage::

        with DnsContext() as ctx:
            ctx.parse_query(raw_query)
            ctx.begin_lookup()
            ctx.begin_response()
            ctx.add_answer(rtype=1, rclass=1, ttl=300, rdata=ip_bytes)
            ctx.set_rcode(0)
            response = ctx.build_response()
    """

    def __init__(self) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.dns_create_context())
        self._lib = lib
        self._closed = False

    def __enter__(self) -> DnsContext:
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
            self._lib.dns_destroy_context(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def state(self) -> Optional[DnsState]:
        """Get the current lifecycle state."""
        tag = self._lib.dns_state(self._slot)
        try:
            return DnsState(tag)
        except ValueError:
            return None

    def dnssec_state(self) -> Optional[DnssecState]:
        """Get the current DNSSEC state."""
        tag = self._lib.dns_dnssec_state(self._slot)
        try:
            return DnssecState(tag)
        except ValueError:
            return None

    def rcode(self) -> int:
        """Get the response code tag."""
        return self._lib.dns_rcode(self._slot)

    def answer_count(self) -> int:
        """Get the number of answer records."""
        return self._lib.dns_answer_count(self._slot)

    def authority_count(self) -> int:
        """Get the number of authority records."""
        return self._lib.dns_authority_count(self._slot)

    def additional_count(self) -> int:
        """Get the number of additional records."""
        return self._lib.dns_additional_count(self._slot)

    def query_rtype(self) -> int:
        """Get the query record type tag (255 = unset)."""
        return self._lib.dns_query_rtype(self._slot)

    def query_class(self) -> int:
        """Get the query class tag (255 = unset)."""
        return self._lib.dns_query_class(self._slot)

    # -- Lifecycle ---------------------------------------------------------

    def parse_query(self, data: bytes) -> None:
        """Parse a DNS query from raw bytes. Transitions Idle -> QueryReceived.

        Args:
            data: Raw DNS query bytes.

        Raises:
            ProvenError: On invalid state or malformed query.
        """
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.dns_parse_query(self._slot, buf, len(data)))

    def begin_lookup(self) -> None:
        """Begin DNS lookup. Transitions QueryReceived -> Lookup."""
        check_status(self._lib.dns_begin_lookup(self._slot))

    def begin_response(self) -> None:
        """Begin building the response. Transitions Lookup -> ResponseBuilding."""
        check_status(self._lib.dns_begin_response(self._slot))

    # -- Record management -------------------------------------------------

    def add_answer(self, rtype: int, rclass: int, ttl: int, rdata: bytes) -> None:
        """Add a resource record to the answer section.

        Args:
            rtype: Record type ABI tag.
            rclass: Record class ABI tag.
            ttl: Time-to-live in seconds.
            rdata: Raw record data bytes.
        """
        buf = (ctypes.c_uint8 * len(rdata))(*rdata)
        check_status(self._lib.dns_add_answer(self._slot, rtype, rclass, ttl, buf, len(rdata)))

    def add_authority(self, rtype: int, rclass: int, ttl: int, rdata: bytes) -> None:
        """Add a resource record to the authority section."""
        buf = (ctypes.c_uint8 * len(rdata))(*rdata)
        check_status(self._lib.dns_add_authority(self._slot, rtype, rclass, ttl, buf, len(rdata)))

    def add_additional(self, rtype: int, rclass: int, ttl: int, rdata: bytes) -> None:
        """Add a resource record to the additional section."""
        buf = (ctypes.c_uint8 * len(rdata))(*rdata)
        check_status(self._lib.dns_add_additional(self._slot, rtype, rclass, ttl, buf, len(rdata)))

    # -- Response ----------------------------------------------------------

    def set_rcode(self, rcode_tag: int) -> None:
        """Set the response code. Only valid in ResponseBuilding state."""
        check_status(self._lib.dns_set_rcode(self._slot, rcode_tag))

    def build_response(self, max_len: int = 512) -> bytes:
        """Build the DNS response message. Transitions ResponseBuilding -> Sent.

        Args:
            max_len: Maximum response buffer size (default 512).

        Returns:
            The serialized DNS response bytes.
        """
        buf = (ctypes.c_uint8 * max_len)()
        out_len = ctypes.c_uint16(0)
        check_status(self._lib.dns_build_response(self._slot, buf, ctypes.byref(out_len)))
        return bytes(buf[:out_len.value])

    # -- DNSSEC ------------------------------------------------------------

    def enable_dnssec(self) -> None:
        """Enable DNSSEC. Transitions Disabled -> Enabled."""
        check_status(self._lib.dns_enable_dnssec(self._slot))

    def load_dnssec_key(self, algo: DnssecAlgorithm) -> None:
        """Load a DNSSEC signing key. Transitions Enabled -> KeyLoaded."""
        check_status(self._lib.dns_load_dnssec_key(self._slot, algo.value))

    def sign_response(self) -> None:
        """Sign the response (DNSSEC). Transitions KeyLoaded -> Validated."""
        check_status(self._lib.dns_sign_response(self._slot))

    def validate_dnssec(self) -> bool:
        """Check DNSSEC validation result. Returns True if validated."""
        return self._lib.dns_validate_dnssec(self._slot) == 0


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version of the linked DNS library."""
    return _get_lib().dns_abi_version()


def can_transition(from_state: DnsState, to_state: DnsState) -> bool:
    """Stateless query: check whether a DNS lifecycle transition is valid."""
    return _get_lib().dns_can_transition(from_state.value, to_state.value) == 1


def can_dnssec_transition(from_state: DnssecState, to_state: DnssecState) -> bool:
    """Stateless query: check whether a DNSSEC state transition is valid."""
    return _get_lib().dns_can_dnssec_transition(from_state.value, to_state.value) == 1
