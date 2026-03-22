// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for proven-servers.

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case anonymous = 0
    case bound = 1
    case closed = 2
    case binding = 3
}

/// Operation matching the Idris2 ABI tags.
public enum Operation: UInt8, CaseIterable, Sendable {
    case bind = 0
    case unbind = 1
    case search = 2
    case modify = 3
    case add = 4
    case delete = 5
    case modDn = 6
    case compare = 7
    case abandon = 8
    case extended = 9
}

/// SearchScope matching the Idris2 ABI tags.
public enum SearchScope: UInt8, CaseIterable, Sendable {
    case baseObject = 0
    case singleLevel = 1
    case wholeSubtree = 2
}

/// ResultCode matching the Idris2 ABI tags.
public enum ResultCode: UInt8, CaseIterable, Sendable {
    case success = 0
    case operationsError = 1
    case protocolError = 2
    case timeLimitExceeded = 3
    case sizeLimitExceeded = 4
    case authMethodNotSupported = 5
    case noSuchObject = 6
    case invalidCredentials = 7
    case insufficientAccessRights = 8
    case busy = 9
    case unavailable = 10
}
