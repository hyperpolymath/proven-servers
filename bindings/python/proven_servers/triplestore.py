# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-triplestore protocol types.

"""Triplestore protocol types for proven-servers."""

from enum import IntEnum


class Statement(IntEnum):
    """Statement matching the Idris2 ABI tags."""
    TRIPLE = 0
    QUAD = 1


class IndexOrder(IntEnum):
    """IndexOrder matching the Idris2 ABI tags."""
    SPO = 0
    POS = 1
    OSP = 2
    GSPO = 3
    GPOS = 4
    GOSP = 5


class StorageBackend(IntEnum):
    """StorageBackend matching the Idris2 ABI tags."""
    IN_MEMORY = 0
    B_TREE = 1
    LSM = 2
    PERSISTENT = 3


class ImportFormat(IntEnum):
    """ImportFormat matching the Idris2 ABI tags."""
    N_TRIPLES = 0
    TURTLE = 1
    RDF_XML = 2
    JSON_LD = 3
    N_QUADS = 4
    TRIG = 5


class TransactionIsolation(IntEnum):
    """TransactionIsolation matching the Idris2 ABI tags."""
    READ_COMMITTED = 0
    SERIALIZABLE = 1
    SNAPSHOT = 2


class StoreState(IntEnum):
    """StoreState matching the Idris2 ABI tags."""
    IDLE = 0
    READY = 1
    IN_TRANSACTION = 2
    IMPORTING = 3
    CLOSING = 4
