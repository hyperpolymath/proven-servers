// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
public enum Method: UInt8, CaseIterable, Sendable {
    case invite = 0
    case ack = 1
    case bye = 2
    case cancel = 3
    case register = 4
    case options = 5
    case info = 6
    case update = 7
    case subscribe = 8
    case notify = 9
    case refer = 10
    case message = 11
    case prack = 12
}

/// ResponseCode matching the Idris2 ABI tags.
public enum ResponseCode: UInt8, CaseIterable, Sendable {
    case trying = 0
    case ringing = 1
    case sessionProgress = 2
    case ok = 3
    case multipleChoices = 4
    case movedPermanently = 5
    case movedTemporarily = 6
    case badRequest = 7
    case unauthorized = 8
    case forbidden = 9
    case notFound = 10
    case methodNotAllowed = 11
    case requestTimeout = 12
    case busyHere = 13
    case decline = 14
    case serverInternalError = 15
    case serviceUnavailable = 16
}

/// DialogState matching the Idris2 ABI tags.
public enum DialogState: UInt8, CaseIterable, Sendable {
    case early = 0
    case confirmed = 1
    case terminated = 2
}
