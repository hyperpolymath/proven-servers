// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA protocol types for proven-servers.

/// ServiceType matching the Idris2 ABI tags.
public enum ServiceType: UInt8, CaseIterable, Sendable {
    case read = 0
    case write = 1
    case browse = 2
    case subscribe = 3
    case publish = 4
    case call = 5
    case createSession = 6
    case activateSession = 7
    case closeSession = 8
    case createSubscription = 9
    case deleteSubscription = 10
}

/// NodeClass matching the Idris2 ABI tags.
public enum NodeClass: UInt8, CaseIterable, Sendable {
    case object = 0
    case variable = 1
    case method = 2
    case objectType = 3
    case variableType = 4
    case referenceType = 5
    case dataType = 6
    case view = 7
}

/// StatusCode matching the Idris2 ABI tags.
public enum StatusCode: UInt8, CaseIterable, Sendable {
    case good = 0
    case uncertain = 1
    case bad = 2
    case badNodeIdUnknown = 3
    case badAttributeIdInvalid = 4
    case badNotReadable = 5
    case badNotWritable = 6
    case badOutOfRange = 7
    case badTypeMismatch = 8
    case badSessionIdInvalid = 9
    case badSubscriptionIdInvalid = 10
    case badTimeout = 11
}

/// SecurityMode matching the Idris2 ABI tags.
public enum SecurityMode: UInt8, CaseIterable, Sendable {
    case none = 0
    case sign = 1
    case signAndEncrypt = 2
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connected = 1
    case created = 2
    case activated = 3
    case monitoring = 4
    case closing = 5
}
