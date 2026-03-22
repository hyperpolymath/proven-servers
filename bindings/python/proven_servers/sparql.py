# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-sparql protocol types.

"""SPARQL protocol types for proven-servers."""

from enum import IntEnum


class SparqlQueryType(IntEnum):
    """SparqlQueryType matching the Idris2 ABI tags."""
    SELECT = 0
    CONSTRUCT = 1
    ASK = 2
    DESCRIBE = 3


class UpdateType(IntEnum):
    """UpdateType matching the Idris2 ABI tags."""
    INSERT = 0
    DELETE = 1
    LOAD = 2
    CLEAR = 3
    CREATE = 4
    DROP = 5


class ResultFormat(IntEnum):
    """ResultFormat matching the Idris2 ABI tags."""
    XML = 0
    JSON = 1
    CSV = 2
    TSV = 3


class SparqlErrorType(IntEnum):
    """SparqlErrorType matching the Idris2 ABI tags."""
    PARSE_ERROR = 0
    QUERY_TIMEOUT = 1
    RESULTS_TOO_LARGE = 2
    UNKNOWN_GRAPH = 3
    ACCESS_DENIED = 4
