-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SPARQL protocol types for proven-servers.

local M = {}

--- SparqlQueryType matching the Idris2 ABI tags.
M.SparqlQueryType = {
    SELECT = 0,
    CONSTRUCT = 1,
    ASK = 2,
    DESCRIBE = 3,
}

--- UpdateType matching the Idris2 ABI tags.
M.UpdateType = {
    INSERT = 0,
    DELETE = 1,
    LOAD = 2,
    CLEAR = 3,
    CREATE = 4,
    DROP = 5,
}

--- ResultFormat matching the Idris2 ABI tags.
M.ResultFormat = {
    XML = 0,
    JSON = 1,
    CSV = 2,
    TSV = 3,
}

--- SparqlErrorType matching the Idris2 ABI tags.
M.SparqlErrorType = {
    PARSE_ERROR = 0,
    QUERY_TIMEOUT = 1,
    RESULTS_TOO_LARGE = 2,
    UNKNOWN_GRAPH = 3,
    ACCESS_DENIED = 4,
}

return M
