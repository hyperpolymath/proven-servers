// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case user = 0
    case pass = 1
    case stat = 2
    case list = 3
    case retr = 4
    case dele = 5
    case noop = 6
    case rset = 7
    case quit = 8
    case top = 9
    case uidl = 10
}

/// State matching the Idris2 ABI tags.
public enum State: UInt8, CaseIterable, Sendable {
    case authorization = 0
    case transaction = 1
    case update = 2
}

/// Response matching the Idris2 ABI tags.
public enum Response: UInt8, CaseIterable, Sendable {
    case response_Ok = 0
    case err = 1
}

/// Pop3Error matching the Idris2 ABI tags.
public enum Pop3Error: UInt8, CaseIterable, Sendable {
    case pop3Error_Ok = 0
    case invalidSlot = 1
    case notActive = 2
    case invalidTransition = 3
    case invalidCommand = 4
    case authFailed = 5
}
