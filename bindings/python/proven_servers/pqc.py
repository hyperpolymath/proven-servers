# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-pqc protocol types.

"""PQC protocol types for proven-servers."""

from enum import IntEnum


class PqcAlgorithm(IntEnum):
    """PqcAlgorithm matching the Idris2 ABI tags."""
    CRYSTALS_KYBER = 0
    CRYSTALS_DILITHIUM = 1
    FALCON = 2
    SPHINCS_PLUS = 3
    CLASSIC_MCELIECE = 4
    BIKE = 5
    HQC = 6
    FRODOKEM = 7


class NistLevel(IntEnum):
    """NistLevel matching the Idris2 ABI tags."""
    NIST1 = 0
    NIST2 = 1
    NIST3 = 2
    NIST4 = 3
    NIST5 = 4


class Operation(IntEnum):
    """Operation matching the Idris2 ABI tags."""
    KEYGEN = 0
    ENCAPSULATE = 1
    DECAPSULATE = 2
    SIGN = 3
    VERIFY = 4


class HybridMode(IntEnum):
    """HybridMode matching the Idris2 ABI tags."""
    CLASSICAL_ONLY = 0
    PQC_ONLY = 1
    HYBRID = 2


class AlgorithmCategory(IntEnum):
    """AlgorithmCategory matching the Idris2 ABI tags."""
    KEM = 0
    SIGNATURE = 1


class KeyState(IntEnum):
    """KeyState matching the Idris2 ABI tags."""
    EMPTY = 0
    GENERATING = 1
    GENERATED = 2
    ACTIVE = 3
    EXPIRED = 4
    COMPROMISED = 5
