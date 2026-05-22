// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph DB protocol types for proven-servers.

package com.hyperpolymath.proven

/** ElementType matching the Idris2 ABI tags. */
enum class ElementType(val tag: Int) {
    NODE(0),
    EDGE(1),
    PROPERTY(2),
    LABEL(3),
    INDEX(4);

    companion object {
        fun fromTag(tag: Int): ElementType? = entries.find { it.tag == tag }
    }
}

/** QueryLanguage matching the Idris2 ABI tags. */
enum class QueryLanguage(val tag: Int) {
    CYPHER(0),
    GREMLIN(1),
    SPARQL(2),
    GRAPH_QL(3);

    companion object {
        fun fromTag(tag: Int): QueryLanguage? = entries.find { it.tag == tag }
    }
}

/** TraversalStrategy matching the Idris2 ABI tags. */
enum class TraversalStrategy(val tag: Int) {
    BFS(0),
    DFS(1),
    DIJKSTRA(2),
    A_STAR(3),
    RANDOM(4);

    companion object {
        fun fromTag(tag: Int): TraversalStrategy? = entries.find { it.tag == tag }
    }
}

/** Consistency matching the Idris2 ABI tags. */
enum class Consistency(val tag: Int) {
    STRONG(0),
    EVENTUAL(1),
    SESSION(2),
    CAUSAL(3);

    companion object {
        fun fromTag(tag: Int): Consistency? = entries.find { it.tag == tag }
    }
}

/** ErrorCode matching the Idris2 ABI tags. */
enum class ErrorCode(val tag: Int) {
    SYNTAX_ERROR(0),
    NODE_NOT_FOUND(1),
    EDGE_NOT_FOUND(2),
    CONSTRAINT_VIOLATION(3),
    INDEX_EXISTS(4),
    TRANSACTION_CONFLICT(5),
    OUT_OF_MEMORY(6);

    companion object {
        fun fromTag(tag: Int): ErrorCode? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    CONNECTED(1),
    QUERYING(2),
    TRAVERSING(3),
    DISCONNECTING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
