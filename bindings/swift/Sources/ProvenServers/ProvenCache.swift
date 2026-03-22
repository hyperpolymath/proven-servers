// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case get = 0
    case set = 1
    case delete = 2
    case exists = 3
    case expire = 4
    case ttl = 5
    case keys = 6
    case flush = 7
    case incr = 8
    case decr = 9
    case append = 10
    case prepend = 11
    case cas = 12
}

/// EvictionPolicy matching the Idris2 ABI tags.
public enum EvictionPolicy: UInt8, CaseIterable, Sendable {
    case lru = 0
    case lfu = 1
    case random = 2
    case evictTtl = 3
    case noEviction = 4
}

/// DataType matching the Idris2 ABI tags.
public enum DataType: UInt8, CaseIterable, Sendable {
    case stringVal = 0
    case intVal = 1
    case listVal = 2
    case setVal = 3
    case hashVal = 4
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case notFound = 0
    case typeMismatch = 1
    case outOfMemory = 2
    case keyTooLong = 3
    case valueTooLarge = 4
    case casConflict = 5
}

/// ReplicationMode matching the Idris2 ABI tags.
public enum ReplicationMode: UInt8, CaseIterable, Sendable {
    case none = 0
    case primary = 1
    case replica = 2
    case sentinel = 3
}
