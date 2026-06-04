# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-wasm protocol types.

"""WASM protocol types for proven-servers."""

from enum import IntEnum


class ValType(IntEnum):
    """ValType matching the Idris2 ABI tags."""
    I32 = 0
    I64 = 1
    F32 = 2
    F64 = 3
    V128 = 4
    FUNC_REF = 5
    EXTERN_REF = 6


class ExternKind(IntEnum):
    """ExternKind matching the Idris2 ABI tags."""
    FUNC_EXTERN = 0
    TABLE_EXTERN = 1
    MEM_EXTERN = 2
    GLOBAL_EXTERN = 3


class Mutability(IntEnum):
    """Mutability matching the Idris2 ABI tags."""
    IMMUTABLE = 0
    MUTABLE = 1
