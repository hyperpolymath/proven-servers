# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-graphql Zig FFI.

"""Python bindings for the proven-graphql protocol FFI."""

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

class GraphqlPhase(IntEnum):
    """GraphQL request lifecycle phases matching the Idris2 ABI tags."""
    RECEIVED = 0
    PARSED = 1
    EXECUTING = 2
    COMPLETE = 3
    ERROR = 4


class OperationType(IntEnum):
    """GraphQL operation types matching the Idris2 ABI tags."""
    QUERY = 0
    MUTATION = 1
    SUBSCRIPTION = 2


class ErrorCategory(IntEnum):
    """GraphQL error categories matching the Idris2 ABI tags."""
    SYNTAX = 0
    VALIDATION = 1
    AUTHORIZATION = 2
    EXECUTION = 3
    RATE_LIMIT = 4
    INTERNAL = 5


class SubscriptionPhase(IntEnum):
    """GraphQL subscription lifecycle phases."""
    CREATED = 0
    ACTIVE = 1
    EMITTING = 2
    COMPLETED = 3
    ABORTED = 4


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-graphql shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("graphql")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.graphql_abi_version.restype = ctypes.c_uint32
    lib.graphql_create.restype = ctypes.c_int
    lib.graphql_create.argtypes = [ctypes.c_uint8]
    lib.graphql_destroy.restype = None
    lib.graphql_destroy.argtypes = [ctypes.c_int]
    lib.graphql_phase.restype = ctypes.c_uint8
    lib.graphql_phase.argtypes = [ctypes.c_int]
    lib.graphql_operation_type.restype = ctypes.c_uint8
    lib.graphql_operation_type.argtypes = [ctypes.c_int]
    lib.graphql_error_category.restype = ctypes.c_uint8
    lib.graphql_error_category.argtypes = [ctypes.c_int]
    lib.graphql_advance.restype = ctypes.c_uint8
    lib.graphql_advance.argtypes = [ctypes.c_int]
    lib.graphql_abort.restype = ctypes.c_uint8
    lib.graphql_abort.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.graphql_set_query_depth.restype = ctypes.c_uint8
    lib.graphql_set_query_depth.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.graphql_query_depth.restype = ctypes.c_uint16
    lib.graphql_query_depth.argtypes = [ctypes.c_int]
    lib.graphql_set_complexity.restype = ctypes.c_uint8
    lib.graphql_set_complexity.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.graphql_complexity.restype = ctypes.c_uint16
    lib.graphql_complexity.argtypes = [ctypes.c_int]
    lib.graphql_resolve_field.restype = ctypes.c_uint8
    lib.graphql_resolve_field.argtypes = [ctypes.c_int, ctypes.c_uint8, ctypes.c_uint8]
    lib.graphql_fields_resolved.restype = ctypes.c_uint16
    lib.graphql_fields_resolved.argtypes = [ctypes.c_int]
    lib.graphql_can_transition.restype = ctypes.c_uint8
    lib.graphql_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.graphql_sub_create.restype = ctypes.c_int
    lib.graphql_sub_create.argtypes = [ctypes.c_int]
    lib.graphql_sub_phase.restype = ctypes.c_uint8
    lib.graphql_sub_phase.argtypes = [ctypes.c_int]
    lib.graphql_sub_advance.restype = ctypes.c_uint8
    lib.graphql_sub_advance.argtypes = [ctypes.c_int]
    lib.graphql_sub_emit_event.restype = ctypes.c_uint8
    lib.graphql_sub_emit_event.argtypes = [ctypes.c_int]
    lib.graphql_sub_abort.restype = ctypes.c_uint8
    lib.graphql_sub_abort.argtypes = [ctypes.c_int]
    lib.graphql_sub_event_count.restype = ctypes.c_uint32
    lib.graphql_sub_event_count.argtypes = [ctypes.c_int]
    lib.graphql_sub_can_transition.restype = ctypes.c_uint8
    lib.graphql_sub_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.graphql_introspection_query.restype = ctypes.c_uint8
    lib.graphql_introspection_query.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.graphql_check_depth.restype = ctypes.c_uint8
    lib.graphql_check_depth.argtypes = [ctypes.c_uint16, ctypes.c_uint16]
    lib.graphql_check_complexity.restype = ctypes.c_uint8
    lib.graphql_check_complexity.argtypes = [ctypes.c_uint16, ctypes.c_uint16]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class GraphqlContext:
    """Context manager for a GraphQL request lifecycle.

    Usage::

        with GraphqlContext(OperationType.QUERY) as ctx:
            ctx.advance()  # Received -> Parsed
            ctx.set_query_depth(3)
            ctx.set_complexity(50)
            ctx.advance()  # Parsed -> Executing
            ctx.resolve_field(type_kind=0, scalar_kind=0)
            ctx.advance()  # Executing -> Complete
    """

    def __init__(self, op_type: OperationType = OperationType.QUERY) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.graphql_create(op_type.value))
        self._lib = lib
        self._closed = False

    def __enter__(self) -> GraphqlContext:
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
            self._lib.graphql_destroy(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def phase(self) -> Optional[GraphqlPhase]:
        """Get the current request phase."""
        tag = self._lib.graphql_phase(self._slot)
        try:
            return GraphqlPhase(tag)
        except ValueError:
            return None

    def operation_type(self) -> int:
        """Get the operation type tag."""
        return self._lib.graphql_operation_type(self._slot)

    def error_category(self) -> int:
        """Get the error category tag (255 = no error)."""
        return self._lib.graphql_error_category(self._slot)

    def query_depth(self) -> int:
        """Get the current query depth."""
        return self._lib.graphql_query_depth(self._slot)

    def complexity(self) -> int:
        """Get the current complexity score."""
        return self._lib.graphql_complexity(self._slot)

    def fields_resolved(self) -> int:
        """Get the number of fields resolved so far."""
        return self._lib.graphql_fields_resolved(self._slot)

    # -- Lifecycle ---------------------------------------------------------

    def advance(self) -> None:
        """Advance to the next lifecycle phase."""
        check_status(self._lib.graphql_advance(self._slot))

    def abort(self, err_category: ErrorCategory) -> None:
        """Abort the request with an error category."""
        check_status(self._lib.graphql_abort(self._slot, err_category.value))

    def set_query_depth(self, depth: int) -> None:
        """Set the query nesting depth."""
        check_status(self._lib.graphql_set_query_depth(self._slot, depth))

    def set_complexity(self, score: int) -> None:
        """Set the query complexity score."""
        check_status(self._lib.graphql_set_complexity(self._slot, score))

    def resolve_field(self, type_kind: int, scalar_kind: int) -> None:
        """Record a field resolution with type and scalar kind."""
        check_status(self._lib.graphql_resolve_field(self._slot, type_kind, scalar_kind))

    def introspection_query(self, intro_field: int) -> None:
        """Run an introspection query on a specific field."""
        check_status(self._lib.graphql_introspection_query(self._slot, intro_field))

    # -- Subscriptions -----------------------------------------------------

    def sub_create(self) -> int:
        """Create a subscription. Returns the subscription slot ID."""
        return check_slot(self._lib.graphql_sub_create(self._slot))

    def sub_phase(self) -> int:
        """Get the subscription phase tag."""
        return self._lib.graphql_sub_phase(self._slot)

    def sub_advance(self) -> None:
        """Advance the subscription lifecycle."""
        check_status(self._lib.graphql_sub_advance(self._slot))

    def sub_emit_event(self) -> None:
        """Emit a subscription event."""
        check_status(self._lib.graphql_sub_emit_event(self._slot))

    def sub_abort(self) -> None:
        """Abort a subscription."""
        check_status(self._lib.graphql_sub_abort(self._slot))

    def sub_event_count(self) -> int:
        """Get the subscription event count."""
        return self._lib.graphql_sub_event_count(self._slot)


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().graphql_abi_version()


def can_transition(from_phase: GraphqlPhase, to_phase: GraphqlPhase) -> bool:
    """Stateless query: check whether a request phase transition is valid."""
    return _get_lib().graphql_can_transition(from_phase.value, to_phase.value) == 1


def sub_can_transition(from_phase: int, to_phase: int) -> bool:
    """Stateless query: check whether a subscription phase transition is valid."""
    return _get_lib().graphql_sub_can_transition(from_phase, to_phase) == 1


def check_depth(depth: int, max_depth: int) -> bool:
    """Stateless: check if a query depth is within limits."""
    return _get_lib().graphql_check_depth(depth, max_depth) == 1


def check_complexity(score: int, max_complexity: int) -> bool:
    """Stateless: check if a complexity score is within limits."""
    return _get_lib().graphql_check_complexity(score, max_complexity) == 1
