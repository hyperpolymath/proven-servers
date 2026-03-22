// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database protocol types for proven-servers.

namespace Proven;

/// <summary>QueryType matching the Idris2 ABI tags (0-11).</summary>
public enum QueryType : byte
{
    Select = 0,
    Insert = 1,
    Update = 2,
    Delete = 3,
    CreateTable = 4,
    DropTable = 5,
    AlterTable = 6,
    CreateIndex = 7,
    DropIndex = 8,
    Begin = 9,
    Commit = 10,
    Rollback = 11
}

/// <summary>DataType matching the Idris2 ABI tags (0-8).</summary>
public enum DataType : byte
{
    Integer = 0,
    Float = 1,
    Text = 2,
    Blob = 3,
    Boolean = 4,
    Timestamp = 5,
    Uuid = 6,
    Json = 7,
    Null = 8
}

/// <summary>IsolationLevel matching the Idris2 ABI tags (0-3).</summary>
public enum IsolationLevel : byte
{
    ReadUncommitted = 0,
    ReadCommitted = 1,
    RepeatableRead = 2,
    Serializable = 3
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-9).</summary>
public enum ErrorCode : byte
{
    SyntaxError = 0,
    TableNotFound = 1,
    ColumnNotFound = 2,
    DuplicateKey = 3,
    ConstraintViolation = 4,
    TypeMismatch = 5,
    DeadlockDetected = 6,
    TransactionAborted = 7,
    DiskFull = 8,
    ConnectionLost = 9
}

/// <summary>JoinType matching the Idris2 ABI tags (0-4).</summary>
public enum JoinType : byte
{
    Inner = 0,
    LeftOuter = 1,
    RightOuter = 2,
    FullOuter = 3,
    Cross = 4
}

/// <summary>SessionState matching the Idris2 ABI tags (0-5).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Connected = 1,
    Transaction = 2,
    Executing = 3,
    Finalising = 4,
    Disconnecting = 5
}
