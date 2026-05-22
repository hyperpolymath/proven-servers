// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RADIUS protocol types for proven-servers.

/// PacketType matching the Idris2 ABI tags.
public enum PacketType: UInt8, CaseIterable, Sendable {
    case accessRequest = 1
    case accessAccept = 2
    case accessReject = 3
    case accountingRequest = 4
    case accountingResponse = 5
    case accessChallenge = 11
}

/// AttributeType matching the Idris2 ABI tags.
public enum AttributeType: UInt8, CaseIterable, Sendable {
    case userName = 1
    case userPassword = 2
    case nasIpAddress = 4
    case nasPort = 5
    case serviceType = 6
    case framedProtocol = 7
    case framedIpAddress = 8
    case replyMessage = 18
    case sessionTimeout = 27
}

/// ServiceType matching the Idris2 ABI tags.
public enum ServiceType: UInt8, CaseIterable, Sendable {
    case login = 1
    case framed = 2
    case callbackLogin = 3
    case callbackFramed = 4
    case outbound = 5
    case administrative = 6
}

/// AuthMethod matching the Idris2 ABI tags.
public enum AuthMethod: UInt8, CaseIterable, Sendable {
    case pap = 0
    case chap = 1
    case mschap = 2
    case mschapv2 = 3
    case eap = 4
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case authenticating = 1
    case authorized = 2
    case rejected = 3
    case challenged = 4
    case accounting = 5
    case complete = 6
}

/// RadiusResult matching the Idris2 ABI tags.
public enum RadiusResult: UInt8, CaseIterable, Sendable {
    case ok = 0
    case err = 1
    case invalidParam = 2
    case poolExhausted = 3
    case badSecret = 4
}
