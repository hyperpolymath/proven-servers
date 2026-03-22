// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case login = 0
    case command_Logout = 1
    case select = 2
    case examine = 3
    case create = 4
    case delete = 5
    case rename = 6
    case list = 7
    case fetch = 8
    case store = 9
    case search = 10
    case copy = 11
    case noop = 12
    case capability = 13
}

/// State matching the Idris2 ABI tags.
public enum State: UInt8, CaseIterable, Sendable {
    case notAuthenticated = 0
    case authenticated = 1
    case selected = 2
    case state_Logout = 3
}

/// Flag matching the Idris2 ABI tags.
public enum Flag: UInt8, CaseIterable, Sendable {
    case seen = 0
    case answered = 1
    case flagged = 2
    case deleted = 3
    case draft = 4
    case recent = 5
}
