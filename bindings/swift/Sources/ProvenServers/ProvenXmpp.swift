// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP protocol types for proven-servers.

/// StanzaType matching the Idris2 ABI tags.
public enum StanzaType: UInt8, CaseIterable, Sendable {
    case message = 0
    case presence = 1
    case iq = 2
}

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case chat = 0
    case messageType_Error = 1
    case groupchat = 2
    case headline = 3
    case normal = 4
}

/// PresenceType matching the Idris2 ABI tags.
public enum PresenceType: UInt8, CaseIterable, Sendable {
    case available = 0
    case away = 1
    case dnd = 2
    case xa = 3
    case unavailable = 4
}

/// IqType matching the Idris2 ABI tags.
public enum IqType: UInt8, CaseIterable, Sendable {
    case get = 0
    case set = 1
    case result = 2
    case iqType_Error = 3
}

/// StreamError matching the Idris2 ABI tags.
public enum StreamError: UInt8, CaseIterable, Sendable {
    case badFormat = 0
    case conflict = 1
    case connectionTimeout = 2
    case hostGone = 3
    case hostUnknown = 4
    case notAuthorized = 5
    case policyViolation = 6
    case resourceConstraint = 7
    case systemShutdown = 8
}
