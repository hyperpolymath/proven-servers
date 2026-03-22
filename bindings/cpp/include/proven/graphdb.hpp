// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file graphdb.hpp
/// @brief Graph DB protocol types for proven-servers.

#ifndef PROVEN_GRAPHDB_HPP
#define PROVEN_GRAPHDB_HPP

#include <cstdint>

namespace proven {

/// @brief ElementType matching the Idris2 ABI tags.
enum class ElementType : uint8_t {
    Node = 0,
    Edge = 1,
    Property = 2,
    Label = 3,
    Index = 4
};

/// @brief QueryLanguage matching the Idris2 ABI tags.
enum class QueryLanguage : uint8_t {
    Cypher = 0,
    Gremlin = 1,
    Sparql = 2,
    GraphQl = 3
};

/// @brief TraversalStrategy matching the Idris2 ABI tags.
enum class TraversalStrategy : uint8_t {
    Bfs = 0,
    Dfs = 1,
    Dijkstra = 2,
    AStar = 3,
    Random = 4
};

/// @brief Consistency matching the Idris2 ABI tags.
enum class Consistency : uint8_t {
    Strong = 0,
    Eventual = 1,
    Session = 2,
    Causal = 3
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    SyntaxError = 0,
    NodeNotFound = 1,
    EdgeNotFound = 2,
    ConstraintViolation = 3,
    IndexExists = 4,
    TransactionConflict = 5,
    OutOfMemory = 6
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Connected = 1,
    Querying = 2,
    Traversing = 3,
    Disconnecting = 4
};

} // namespace proven

#endif // PROVEN_GRAPHDB_HPP
