-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Graph DB protocol types for proven-servers.

local M = {}

--- ElementType matching the Idris2 ABI tags.
M.ElementType = {
    NODE = 0,
    EDGE = 1,
    PROPERTY = 2,
    LABEL = 3,
    INDEX = 4,
}

--- QueryLanguage matching the Idris2 ABI tags.
M.QueryLanguage = {
    CYPHER = 0,
    GREMLIN = 1,
    SPARQL = 2,
    GRAPH_QL = 3,
}

--- TraversalStrategy matching the Idris2 ABI tags.
M.TraversalStrategy = {
    BFS = 0,
    DFS = 1,
    DIJKSTRA = 2,
    A_STAR = 3,
    RANDOM = 4,
}

--- Consistency matching the Idris2 ABI tags.
M.Consistency = {
    STRONG = 0,
    EVENTUAL = 1,
    SESSION = 2,
    CAUSAL = 3,
}

--- ErrorCode matching the Idris2 ABI tags.
M.ErrorCode = {
    SYNTAX_ERROR = 0,
    NODE_NOT_FOUND = 1,
    EDGE_NOT_FOUND = 2,
    CONSTRAINT_VIOLATION = 3,
    INDEX_EXISTS = 4,
    TRANSACTION_CONFLICT = 5,
    OUT_OF_MEMORY = 6,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    CONNECTED = 1,
    QUERYING = 2,
    TRAVERSING = 3,
    DISCONNECTING = 4,
}

return M
