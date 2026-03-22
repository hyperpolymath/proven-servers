// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for proven-servers.

/// AuthMethod matching the Idris2 ABI tags.
public enum AuthMethod: UInt8, CaseIterable, Sendable {
    case noAuth = 0
    case gssapi = 1
    case usernamePassword = 2
    case noAcceptable = 3
}

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case connect = 0
    case bind = 1
    case udpAssociate = 2
}

/// AddressType matching the Idris2 ABI tags.
public enum AddressType: UInt8, CaseIterable, Sendable {
    case iPv4 = 0
    case domainName = 1
    case iPv6 = 2
}

/// Reply matching the Idris2 ABI tags.
public enum Reply: UInt8, CaseIterable, Sendable {
    case succeeded = 0
    case generalFailure = 1
    case notAllowed = 2
    case networkUnreachable = 3
    case hostUnreachable = 4
    case connectionRefused = 5
    case ttlExpired = 6
    case commandNotSupported = 7
    case addressTypeNotSupported = 8
}

/// State matching the Idris2 ABI tags.
public enum State: UInt8, CaseIterable, Sendable {
    case initial = 0
    case authenticating = 1
    case authenticated = 2
    case connecting = 3
    case established = 4
    case closed = 5
}
