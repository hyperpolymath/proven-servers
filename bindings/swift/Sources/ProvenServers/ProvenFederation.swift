// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation protocol types for proven-servers.

/// ActivityType matching the Idris2 ABI tags.
public enum ActivityType: UInt8, CaseIterable, Sendable {
    case create = 0
    case update = 1
    case delete = 2
    case follow = 3
    case accept = 4
    case reject = 5
    case announce = 6
    case like = 7
    case undo = 8
    case block = 9
    case flag = 10
}

/// ActorType matching the Idris2 ABI tags.
public enum ActorType: UInt8, CaseIterable, Sendable {
    case person = 0
    case service = 1
    case application = 2
    case group = 3
    case organization = 4
}

/// DeliveryStatus matching the Idris2 ABI tags.
public enum DeliveryStatus: UInt8, CaseIterable, Sendable {
    case pending = 0
    case delivered = 1
    case failed = 2
    case rejected = 3
    case deferred = 4
}

/// TrustLevel matching the Idris2 ABI tags.
public enum TrustLevel: UInt8, CaseIterable, Sendable {
    case selfSigned = 0
    case peerVerified = 1
    case federationTrusted = 2
    case revoked = 3
    case unknown = 4
}

/// ObjectType matching the Idris2 ABI tags.
public enum ObjectType: UInt8, CaseIterable, Sendable {
    case note = 0
    case article = 1
    case image = 2
    case video = 3
    case audio = 4
    case document = 5
    case event = 6
    case collection = 7
    case orderedCollection = 8
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case active = 1
    case processing = 2
    case delivering = 3
    case shutdown = 4
}
