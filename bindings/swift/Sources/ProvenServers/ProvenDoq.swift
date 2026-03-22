// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoQ protocol types for proven-servers.

/// StreamType matching the Idris2 ABI tags.
public enum StreamType: UInt8, CaseIterable, Sendable {
    case unidirectional = 0
    case bidirectional = 1
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case noError = 0
    case internalError = 1
    case excessiveLoad = 2
    case protocolError = 3
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case initial = 0
    case handshaking = 1
    case ready = 2
    case draining = 3
    case closed = 4
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case bound = 1
    case listening = 2
    case processing = 3
    case shutdown = 4
}
