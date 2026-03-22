// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
public enum Method: UInt8, CaseIterable, Sendable {
    case propfind = 0
    case proppatch = 1
    case mkcol = 2
    case copy = 3
    case move = 4
    case lock = 5
    case unlock = 6
}

/// StatusCode matching the Idris2 ABI tags.
public enum StatusCode: UInt8, CaseIterable, Sendable {
    case multiStatus = 0
    case unprocessableEntity = 1
    case locked = 2
    case failedDependency = 3
    case insufficientStorage = 4
}

/// LockScope matching the Idris2 ABI tags.
public enum LockScope: UInt8, CaseIterable, Sendable {
    case exclusive = 0
    case shared = 1
}

/// LockType matching the Idris2 ABI tags.
public enum LockType: UInt8, CaseIterable, Sendable {
    case write = 0
}

/// Depth matching the Idris2 ABI tags.
public enum Depth: UInt8, CaseIterable, Sendable {
    case zero = 0
    case one = 1
    case infinity = 2
}

/// PropertyOp matching the Idris2 ABI tags.
public enum PropertyOp: UInt8, CaseIterable, Sendable {
    case set = 0
    case remove = 1
}
