// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file dbserver.hpp
/// @brief Database protocol types for proven-servers.

#ifndef PROVEN_DBSERVER_HPP
#define PROVEN_DBSERVER_HPP

#include <cstdint>

namespace proven {

/// @brief QueryType matching the Idris2 ABI tags.
enum class QueryType : uint8_t {
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
};

/// @brief DataType matching the Idris2 ABI tags.
enum class DataType : uint8_t {
    Integer = 0,
    Float = 1,
    Text = 2,
    Blob = 3,
    Boolean = 4,
    Timestamp = 5,
    Uuid = 6,
    Json = 7,
    Null = 8
};

/// @brief IsolationLevel matching the Idris2 ABI tags.
enum class IsolationLevel : uint8_t {
    ReadUncommitted = 0,
    ReadCommitted = 1,
    RepeatableRead = 2,
    Serializable = 3
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
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
};

/// @brief JoinType matching the Idris2 ABI tags.
enum class JoinType : uint8_t {
    Inner = 0,
    LeftOuter = 1,
    RightOuter = 2,
    FullOuter = 3,
    Cross = 4
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Connected = 1,
    Transaction = 2,
    Executing = 3,
    Finalising = 4,
    Disconnecting = 5
};

} // namespace proven

#endif // PROVEN_DBSERVER_HPP
