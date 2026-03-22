// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

/// RecordType matching the Idris2 ABI tags.
public enum RecordType: UInt8, CaseIterable, Sendable {
    case endOfMessage = 0
    case nextProtocol = 1
    case error = 2
    case warning = 3
    case aeadAlgorithm = 4
    case cookie = 5
    case cookiePlaceholder = 6
    case ntskeServer = 7
    case ntskePort = 8
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case unrecognizedCritical = 0
    case badRequest = 1
    case internalError = 2
}

/// AeadAlgorithm matching the Idris2 ABI tags.
public enum AeadAlgorithm: UInt8, CaseIterable, Sendable {
    case aeadAes128Gcm = 0
    case aeadAes256Gcm = 1
    case aeadAesSivCmac256 = 2
}

/// HandshakeState matching the Idris2 ABI tags.
public enum HandshakeState: UInt8, CaseIterable, Sendable {
    case initial = 0
    case handshakeState_Negotiating = 1
    case handshakeState_Established = 2
    case failed = 3
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case handshaking = 1
    case sessionState_Negotiating = 2
    case sessionState_Established = 3
    case closing = 4
}
