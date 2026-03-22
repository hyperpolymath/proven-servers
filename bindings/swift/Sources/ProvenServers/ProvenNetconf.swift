// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

/// NetconfOperation matching the Idris2 ABI tags.
public enum NetconfOperation: UInt8, CaseIterable, Sendable {
    case get = 0
    case getConfig = 1
    case editConfig = 2
    case copyConfig = 3
    case deleteConfig = 4
    case lock = 5
    case unlock = 6
    case closeSession = 7
    case killSession = 8
    case commit = 9
    case validate = 10
    case discardChanges = 11
}

/// Datastore matching the Idris2 ABI tags.
public enum Datastore: UInt8, CaseIterable, Sendable {
    case running = 0
    case startup = 1
    case candidate = 2
}

/// EditOperation matching the Idris2 ABI tags.
public enum EditOperation: UInt8, CaseIterable, Sendable {
    case merge = 0
    case replace = 1
    case create = 2
    case delete = 3
    case remove = 4
}

/// NetconfErrorType matching the Idris2 ABI tags.
public enum NetconfErrorType: UInt8, CaseIterable, Sendable {
    case transport = 0
    case rpc = 1
    case `protocol` = 2
    case application = 3
}

/// ErrorSeverity matching the Idris2 ABI tags.
public enum ErrorSeverity: UInt8, CaseIterable, Sendable {
    case error = 0
    case warning = 1
}

/// NetconfState matching the Idris2 ABI tags.
public enum NetconfState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connected = 1
    case locked = 2
    case editing = 3
    case closing = 4
    case terminated = 5
}
