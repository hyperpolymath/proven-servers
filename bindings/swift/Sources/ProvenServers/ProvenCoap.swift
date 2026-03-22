// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
public enum Method: UInt8, CaseIterable, Sendable {
    case get = 0
    case post = 1
    case put = 2
    case delete = 3
}

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case confirmable = 0
    case nonConfirmable = 1
    case acknowledgement = 2
    case reset = 3
}

/// ContentFormat matching the Idris2 ABI tags.
public enum ContentFormat: UInt8, CaseIterable, Sendable {
    case textPlain = 0
    case linkFormat = 1
    case xml = 2
    case octetStream = 3
    case exi = 4
    case json = 5
    case cbor = 6
}

/// ResponseClass matching the Idris2 ABI tags.
public enum ResponseClass: UInt8, CaseIterable, Sendable {
    case success = 0
    case clientError = 1
    case serverError = 2
    case signaling = 3
    case empty = 4
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case bound = 1
    case serving = 2
    case observing = 3
    case shutdown = 4
}
