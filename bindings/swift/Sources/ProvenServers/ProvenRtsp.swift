// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
public enum Method: UInt8, CaseIterable, Sendable {
    case describe = 0
    case setup = 1
    case play = 2
    case pause = 3
    case teardown = 4
    case getParameter = 5
    case setParameter = 6
    case options = 7
    case announce = 8
    case record = 9
    case redirect = 10
}

/// TransportProtocol matching the Idris2 ABI tags.
public enum TransportProtocol: UInt8, CaseIterable, Sendable {
    case rtpAvpUdp = 0
    case rtpAvpTcp = 1
    case rtpAvpUdpMulticast = 2
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case `init` = 0
    case ready = 1
    case playing = 2
    case recording = 3
}

/// StatusCode matching the Idris2 ABI tags.
public enum StatusCode: UInt8, CaseIterable, Sendable {
    case statusCode_Ok = 0
    case movedPermanently = 1
    case movedTemporarily = 2
    case badRequest = 3
    case unauthorized = 4
    case notFound = 5
    case statusCode_MethodNotAllowed = 6
    case notAcceptable = 7
    case sessionNotFound = 8
    case internalServerError = 9
    case notImplemented = 10
    case serviceUnavailable = 11
}

/// RtspError matching the Idris2 ABI tags.
public enum RtspError: UInt8, CaseIterable, Sendable {
    case rtspError_Ok = 0
    case invalidSlot = 1
    case notActive = 2
    case invalidTransition = 3
    case rtspError_MethodNotAllowed = 4
    case transportError = 5
    case sessionExpired = 6
}
