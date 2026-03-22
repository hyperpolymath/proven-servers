// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case text = 0
    case image = 1
    case file = 2
    case system = 3
    case reaction = 4
    case edit = 5
    case delete = 6
    case reply = 7
    case thread = 8
}

/// PresenceStatus matching the Idris2 ABI tags.
public enum PresenceStatus: UInt8, CaseIterable, Sendable {
    case online = 0
    case away = 1
    case dnd = 2
    case invisible = 3
    case offline = 4
}

/// RoomType matching the Idris2 ABI tags.
public enum RoomType: UInt8, CaseIterable, Sendable {
    case direct = 0
    case group = 1
    case channel = 2
    case broadcast = 3
}

/// Permission matching the Idris2 ABI tags.
public enum Permission: UInt8, CaseIterable, Sendable {
    case read = 0
    case write = 1
    case admin = 2
    case invite = 3
    case kick = 4
    case ban = 5
    case pin = 6
    case deleteOthers = 7
}

/// Event matching the Idris2 ABI tags.
public enum Event: UInt8, CaseIterable, Sendable {
    case messageSent = 0
    case messageDelivered = 1
    case messageRead = 2
    case userJoined = 3
    case userLeft = 4
    case typing = 5
    case roomCreated = 6
}
