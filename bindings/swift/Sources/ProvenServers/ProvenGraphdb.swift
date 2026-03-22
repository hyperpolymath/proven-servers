// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph DB protocol types for proven-servers.

/// ElementType matching the Idris2 ABI tags.
public enum ElementType: UInt8, CaseIterable, Sendable {
    case node = 0
    case edge = 1
    case property = 2
    case label = 3
    case index = 4
}

/// QueryLanguage matching the Idris2 ABI tags.
public enum QueryLanguage: UInt8, CaseIterable, Sendable {
    case cypher = 0
    case gremlin = 1
    case sparql = 2
    case graphQl = 3
}

/// TraversalStrategy matching the Idris2 ABI tags.
public enum TraversalStrategy: UInt8, CaseIterable, Sendable {
    case bfs = 0
    case dfs = 1
    case dijkstra = 2
    case aStar = 3
    case random = 4
}

/// Consistency matching the Idris2 ABI tags.
public enum Consistency: UInt8, CaseIterable, Sendable {
    case strong = 0
    case eventual = 1
    case session = 2
    case causal = 3
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case syntaxError = 0
    case nodeNotFound = 1
    case edgeNotFound = 2
    case constraintViolation = 3
    case indexExists = 4
    case transactionConflict = 5
    case outOfMemory = 6
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connected = 1
    case querying = 2
    case traversing = 3
    case disconnecting = 4
}
