// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database protocol types for proven-servers.

/// QueryType matching the Idris2 ABI tags.
public enum QueryType: UInt8, CaseIterable, Sendable {
    case select = 0
    case insert = 1
    case update = 2
    case delete = 3
    case createTable = 4
    case dropTable = 5
    case alterTable = 6
    case createIndex = 7
    case dropIndex = 8
    case begin = 9
    case commit = 10
    case rollback = 11
}

/// DataType matching the Idris2 ABI tags.
public enum DataType: UInt8, CaseIterable, Sendable {
    case integer = 0
    case float = 1
    case text = 2
    case blob = 3
    case boolean = 4
    case timestamp = 5
    case uuid = 6
    case json = 7
    case null = 8
}

/// IsolationLevel matching the Idris2 ABI tags.
public enum IsolationLevel: UInt8, CaseIterable, Sendable {
    case readUncommitted = 0
    case readCommitted = 1
    case repeatableRead = 2
    case serializable = 3
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case syntaxError = 0
    case tableNotFound = 1
    case columnNotFound = 2
    case duplicateKey = 3
    case constraintViolation = 4
    case typeMismatch = 5
    case deadlockDetected = 6
    case transactionAborted = 7
    case diskFull = 8
    case connectionLost = 9
}

/// JoinType matching the Idris2 ABI tags.
public enum JoinType: UInt8, CaseIterable, Sendable {
    case inner = 0
    case leftOuter = 1
    case rightOuter = 2
    case fullOuter = 3
    case cross = 4
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connected = 1
    case transaction = 2
    case executing = 3
    case finalising = 4
    case disconnecting = 5
}
