# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-neurosym protocol types.

"""Neurosym protocol types for proven-servers."""

from enum import IntEnum


class InferenceMode(IntEnum):
    """InferenceMode matching the Idris2 ABI tags."""
    NEURAL = 0
    SYMBOLIC = 1
    HYBRID = 2
    CASCADE = 3


class SymbolicOp(IntEnum):
    """SymbolicOp matching the Idris2 ABI tags."""
    UNIFY = 0
    RESOLVE = 1
    REWRITE = 2
    PROVE = 3
    SEARCH = 4
    CONSTRAIN = 5


class NeuralOp(IntEnum):
    """NeuralOp matching the Idris2 ABI tags."""
    EMBED = 0
    CLASSIFY = 1
    GENERATE = 2
    ATTEND = 3
    RETRIEVE = 4
    FINETUNE = 5


class FusionStrategy(IntEnum):
    """FusionStrategy matching the Idris2 ABI tags."""
    NEURAL_THEN_SYMBOLIC = 0
    SYMBOLIC_THEN_NEURAL = 1
    PARALLEL = 2
    ITERATIVE = 3
    GATED = 4


class ConfidenceLevel(IntEnum):
    """ConfidenceLevel matching the Idris2 ABI tags."""
    PROVEN = 0
    HIGH_CONFIDENCE = 1
    MODERATE = 2
    LOW_CONFIDENCE = 3
    UNCERTAIN = 4
    CONTRADICTED = 5


class KnowledgeType(IntEnum):
    """KnowledgeType matching the Idris2 ABI tags."""
    AXIOM = 0
    LEARNED = 1
    INFERRED = 2
    GROUNDED = 3
    HYPOTHETICAL = 4
    RETRACTED = 5


class NeurosymState(IntEnum):
    """NeurosymState matching the Idris2 ABI tags."""
    IDLE = 0
    READY = 1
    INFERRING = 2
    REASONING = 3
    FUSING = 4
    SHUTDOWN = 5
