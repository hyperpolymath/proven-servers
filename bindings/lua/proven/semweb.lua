-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Semantic Web protocol types for proven-servers.

local M = {}

--- RdfFormat matching the Idris2 ABI tags.
M.RdfFormat = {
    RDF_XML = 0,
    TURTLE = 1,
    N_TRIPLES = 2,
    N_QUADS = 3,
    JSON_LD = 4,
    TRIG = 5,
}

--- SemwebResourceType matching the Idris2 ABI tags.
M.SemwebResourceType = {
    CLASS = 0,
    PROPERTY = 1,
    INDIVIDUAL = 2,
    ONTOLOGY = 3,
    NAMED_GRAPH = 4,
}

--- HttpMethod matching the Idris2 ABI tags.
M.HttpMethod = {
    GET = 0,
    POST = 1,
    PUT = 2,
    PATCH = 3,
    DELETE = 4,
}

--- ContentNegotiation matching the Idris2 ABI tags.
M.ContentNegotiation = {
    NEG_RDF_XML = 0,
    NEG_TURTLE = 1,
    NEG_JSON_LD = 2,
    NEG_HTML = 3,
}

--- SemwebErrorCode matching the Idris2 ABI tags.
M.SemwebErrorCode = {
    NOT_FOUND = 0,
    INVALID_URI = 1,
    MALFORMED_RDF = 2,
    UNSUPPORTED_FORMAT = 3,
    CONFLICTING_TRIPLES = 4,
}

return M
