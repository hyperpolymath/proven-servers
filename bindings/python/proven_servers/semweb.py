# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-semweb protocol types.

"""Semantic Web protocol types for proven-servers."""

from enum import IntEnum


class RdfFormat(IntEnum):
    """RdfFormat matching the Idris2 ABI tags."""
    RDF_XML = 0
    TURTLE = 1
    N_TRIPLES = 2
    N_QUADS = 3
    JSON_LD = 4
    TRIG = 5


class SemwebResourceType(IntEnum):
    """SemwebResourceType matching the Idris2 ABI tags."""
    CLASS = 0
    PROPERTY = 1
    INDIVIDUAL = 2
    ONTOLOGY = 3
    NAMED_GRAPH = 4


class HttpMethod(IntEnum):
    """HttpMethod matching the Idris2 ABI tags."""
    GET = 0
    POST = 1
    PUT = 2
    PATCH = 3
    DELETE = 4


class ContentNegotiation(IntEnum):
    """ContentNegotiation matching the Idris2 ABI tags."""
    NEG_RDF_XML = 0
    NEG_TURTLE = 1
    NEG_JSON_LD = 2
    NEG_HTML = 3


class SemwebErrorCode(IntEnum):
    """SemwebErrorCode matching the Idris2 ABI tags."""
    NOT_FOUND = 0
    INVALID_URI = 1
    MALFORMED_RDF = 2
    UNSUPPORTED_FORMAT = 3
    CONFLICTING_TRIPLES = 4
