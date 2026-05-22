<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** QueryType matching the Idris2 ABI tags. */
enum QueryType: int
{
    case Select = 0;
    case Insert = 1;
    case Update = 2;
    case Delete = 3;
    case CreateTable = 4;
    case DropTable = 5;
    case AlterTable = 6;
    case CreateIndex = 7;
    case DropIndex = 8;
    case Begin = 9;
    case Commit = 10;
    case Rollback = 11;
}

/** DataType matching the Idris2 ABI tags. */
enum DataType: int
{
    case Integer = 0;
    case Float = 1;
    case Text = 2;
    case Blob = 3;
    case Boolean = 4;
    case Timestamp = 5;
    case Uuid = 6;
    case Json = 7;
    case Null = 8;
}

/** IsolationLevel matching the Idris2 ABI tags. */
enum IsolationLevel: int
{
    case ReadUncommitted = 0;
    case ReadCommitted = 1;
    case RepeatableRead = 2;
    case Serializable = 3;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case SyntaxError = 0;
    case TableNotFound = 1;
    case ColumnNotFound = 2;
    case DuplicateKey = 3;
    case ConstraintViolation = 4;
    case TypeMismatch = 5;
    case DeadlockDetected = 6;
    case TransactionAborted = 7;
    case DiskFull = 8;
    case ConnectionLost = 9;
}

/** JoinType matching the Idris2 ABI tags. */
enum JoinType: int
{
    case Inner = 0;
    case LeftOuter = 1;
    case RightOuter = 2;
    case FullOuter = 3;
    case Cross = 4;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Connected = 1;
    case Transaction = 2;
    case Executing = 3;
    case Finalising = 4;
    case Disconnecting = 5;
}
