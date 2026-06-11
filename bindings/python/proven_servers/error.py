# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Shared error classes for the proven-servers Python bindings.
#
# Maps the slot-based context pool error pattern used by every Zig FFI
# implementation to Python exceptions. All protocol modules raise
# ProvenError with an appropriate ProvenErrorCode.

"""Shared error types for proven-servers FFI bindings."""

from __future__ import annotations

from enum import IntEnum
from typing import NoReturn


class ProvenErrorCode(IntEnum):
    """Error codes matching the proven-servers Zig FFI status conventions.

    Every Zig FFI function returns a u8 status:
      0 = success
      1 = invalid state (wrong lifecycle phase)
      2 = validation failed (bad input)
    Slot-creating functions return c_int: -1 = pool exhausted.
    """

    POOL_EXHAUSTED = -1
    """No free context slots available in the pool (64-slot limit)."""

    INVALID_SLOT = -2
    """The slot index is invalid or the context is not active."""

    INVALID_STATE = 1
    """Operation rejected: wrong lifecycle state for the requested transition."""

    INVALID_PARAMETER = 3
    """A parameter value is outside the valid ABI tag range."""

    CAPACITY_EXCEEDED = 4
    """Fixed-size buffer or array capacity exceeded."""

    VALIDATION_FAILED = 2
    """Input validation failed (e.g. path traversal, malformed data)."""

    UNKNOWN = 255
    """The FFI returned an unexpected or undocumented error code."""


class ProvenError(Exception):
    """Exception raised by proven-servers FFI wrapper functions.

    Attributes:
        code: The ProvenErrorCode describing the failure category.
        raw_code: The raw integer returned by the FFI function.
        message: Human-readable description of the error.
    """

    def __init__(self, code: ProvenErrorCode, raw_code: int = 0,
                 message: str = "") -> None:
        self.code = code
        self.raw_code = raw_code
        self.message = message or _DEFAULT_MESSAGES.get(code, f"unknown FFI error (code {raw_code})")
        super().__init__(self.message)

    def __repr__(self) -> str:
        return f"ProvenError({self.code.name}, raw_code={self.raw_code})"


# -----------------------------------------------------------------------
# Helper functions used by all protocol modules
# -----------------------------------------------------------------------

def check_slot(raw: int) -> int:
    """Interpret a slot-returning FFI call (c_int).

    Returns the slot index for non-negative values.
    Raises ProvenError with POOL_EXHAUSTED for -1.

    Args:
        raw: The raw c_int returned by the FFI create function.

    Returns:
        The valid slot index.

    Raises:
        ProvenError: If no free slot is available.
    """
    if raw >= 0:
        return raw
    raise ProvenError(ProvenErrorCode.POOL_EXHAUSTED, raw)


def check_status(raw: int) -> None:
    """Interpret a status-returning FFI call (u8).

    0 = success, 1 = invalid state, 2 = validation failed.

    Args:
        raw: The raw u8 status returned by the FFI function.

    Raises:
        ProvenError: If the status indicates failure.
    """
    if raw == 0:
        return
    code = _STATUS_MAP.get(raw, ProvenErrorCode.UNKNOWN)
    raise ProvenError(code, raw)


# -----------------------------------------------------------------------
# Internal mappings
# -----------------------------------------------------------------------

_STATUS_MAP: dict[int, ProvenErrorCode] = {
    1: ProvenErrorCode.INVALID_STATE,
    2: ProvenErrorCode.VALIDATION_FAILED,
}

_DEFAULT_MESSAGES: dict[ProvenErrorCode, str] = {
    ProvenErrorCode.POOL_EXHAUSTED: "context pool exhausted (64-slot limit)",
    ProvenErrorCode.INVALID_SLOT: "invalid or inactive context slot",
    ProvenErrorCode.INVALID_STATE: "operation rejected: wrong lifecycle state",
    ProvenErrorCode.INVALID_PARAMETER: "parameter value outside valid ABI tag range",
    ProvenErrorCode.CAPACITY_EXCEEDED: "fixed-size buffer or array capacity exceeded",
    ProvenErrorCode.VALIDATION_FAILED: "input validation failed",
    ProvenErrorCode.UNKNOWN: "unknown FFI error",
}
