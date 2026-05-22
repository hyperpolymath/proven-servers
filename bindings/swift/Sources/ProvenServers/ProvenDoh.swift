// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

/// ContentType matching the Idris2 ABI tags.
public enum ContentType: UInt8, CaseIterable, Sendable {
    case dnsMessage = 0
    case dnsJson = 1
}

/// RequestMethod matching the Idris2 ABI tags.
public enum RequestMethod: UInt8, CaseIterable, Sendable {
    case get = 0
    case post = 1
}

/// WireFormat matching the Idris2 ABI tags.
public enum WireFormat: UInt8, CaseIterable, Sendable {
    case binary = 0
    case json = 1
}

/// ErrorReason matching the Idris2 ABI tags.
public enum ErrorReason: UInt8, CaseIterable, Sendable {
    case badContentType = 0
    case badMethod = 1
    case payloadTooLarge = 2
    case upstreamTimeout = 3
    case upstreamError = 4
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case bound = 1
    case serving = 2
    case resolving = 3
    case shutdown = 4
}
