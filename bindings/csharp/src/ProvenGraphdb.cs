// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph DB protocol types for proven-servers.

namespace Proven;

/// <summary>ElementType matching the Idris2 ABI tags (0-4).</summary>
public enum ElementType : byte
{
    Node = 0,
    Edge = 1,
    Property = 2,
    Label = 3,
    Index = 4
}

/// <summary>QueryLanguage matching the Idris2 ABI tags (0-3).</summary>
public enum QueryLanguage : byte
{
    Cypher = 0,
    Gremlin = 1,
    Sparql = 2,
    GraphQl = 3
}

/// <summary>TraversalStrategy matching the Idris2 ABI tags (0-4).</summary>
public enum TraversalStrategy : byte
{
    Bfs = 0,
    Dfs = 1,
    Dijkstra = 2,
    AStar = 3,
    Random = 4
}

/// <summary>Consistency matching the Idris2 ABI tags (0-3).</summary>
public enum Consistency : byte
{
    Strong = 0,
    Eventual = 1,
    Session = 2,
    Causal = 3
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-6).</summary>
public enum ErrorCode : byte
{
    SyntaxError = 0,
    NodeNotFound = 1,
    EdgeNotFound = 2,
    ConstraintViolation = 3,
    IndexExists = 4,
    TransactionConflict = 5,
    OutOfMemory = 6
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Connected = 1,
    Querying = 2,
    Traversing = 3,
    Disconnecting = 4
}
