<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph DB protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ElementType matching the Idris2 ABI tags. */
enum ElementType: int
{
    case Node = 0;
    case Edge = 1;
    case Property = 2;
    case Label = 3;
    case Index = 4;
}

/** QueryLanguage matching the Idris2 ABI tags. */
enum QueryLanguage: int
{
    case Cypher = 0;
    case Gremlin = 1;
    case Sparql = 2;
    case GraphQl = 3;
}

/** TraversalStrategy matching the Idris2 ABI tags. */
enum TraversalStrategy: int
{
    case Bfs = 0;
    case Dfs = 1;
    case Dijkstra = 2;
    case AStar = 3;
    case Random = 4;
}

/** Consistency matching the Idris2 ABI tags. */
enum Consistency: int
{
    case Strong = 0;
    case Eventual = 1;
    case Session = 2;
    case Causal = 3;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case SyntaxError = 0;
    case NodeNotFound = 1;
    case EdgeNotFound = 2;
    case ConstraintViolation = 3;
    case IndexExists = 4;
    case TransactionConflict = 5;
    case OutOfMemory = 6;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Connected = 1;
    case Querying = 2;
    case Traversing = 3;
    case Disconnecting = 4;
}
