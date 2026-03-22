// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP protocol types for proven-servers.

/// Opcode matching the Idris2 ABI tags.
public enum Opcode: UInt8, CaseIterable, Sendable {
    case rrq = 0
    case wrq = 1
    case data = 2
    case ack = 3
    case error = 4
}

/// TransferMode matching the Idris2 ABI tags.
public enum TransferMode: UInt8, CaseIterable, Sendable {
    case netAscii = 0
    case octet = 1
    case mail = 2
}

/// TftpError matching the Idris2 ABI tags.
public enum TftpError: UInt8, CaseIterable, Sendable {
    case notDefined = 0
    case fileNotFound = 1
    case accessViolation = 2
    case diskFull = 3
    case illegalOperation = 4
    case unknownTid = 5
    case fileExists = 6
    case noSuchUser = 7
}

/// TransferState matching the Idris2 ABI tags.
public enum TransferState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case reading = 1
    case writing = 2
    case inError = 3
    case complete = 4
}
