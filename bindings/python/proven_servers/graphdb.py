# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-graphdb protocol types.

"""Graph DB protocol types for proven-servers."""

from enum import IntEnum


class ElementType(IntEnum):
    """ElementType matching the Idris2 ABI tags."""
    NODE = 0
    EDGE = 1
    PROPERTY = 2
    LABEL = 3
    INDEX = 4


class QueryLanguage(IntEnum):
    """QueryLanguage matching the Idris2 ABI tags."""
    CYPHER = 0
    GREMLIN = 1
    SPARQL = 2
    GRAPH_QL = 3


class TraversalStrategy(IntEnum):
    """TraversalStrategy matching the Idris2 ABI tags."""
    BFS = 0
    DFS = 1
    DIJKSTRA = 2
    A_STAR = 3
    RANDOM = 4


class Consistency(IntEnum):
    """Consistency matching the Idris2 ABI tags."""
    STRONG = 0
    EVENTUAL = 1
    SESSION = 2
    CAUSAL = 3


class ErrorCode(IntEnum):
    """ErrorCode matching the Idris2 ABI tags."""
    SYNTAX_ERROR = 0
    NODE_NOT_FOUND = 1
    EDGE_NOT_FOUND = 2
    CONSTRAINT_VIOLATION = 3
    INDEX_EXISTS = 4
    TRANSACTION_CONFLICT = 5
    OUT_OF_MEMORY = 6


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    CONNECTED = 1
    QUERYING = 2
    TRAVERSING = 3
    DISCONNECTING = 4
