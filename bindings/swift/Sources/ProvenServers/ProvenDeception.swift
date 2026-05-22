// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

/// DecoyType matching the Idris2 ABI tags.
public enum DecoyType: UInt8, CaseIterable, Sendable {
    case service = 0
    case credential = 1
    case file = 2
    case network = 3
    case token = 4
    case breadcrumb = 5
}

/// TriggerEvent matching the Idris2 ABI tags.
public enum TriggerEvent: UInt8, CaseIterable, Sendable {
    case access = 0
    case login = 1
    case read = 2
    case write = 3
    case execute = 4
    case scan = 5
}

/// AlertPriority matching the Idris2 ABI tags.
public enum AlertPriority: UInt8, CaseIterable, Sendable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
}

/// DecoyState matching the Idris2 ABI tags.
public enum DecoyState: UInt8, CaseIterable, Sendable {
    case active = 0
    case triggered = 1
    case disabled = 2
    case expired = 3
}

/// ResponseAction matching the Idris2 ABI tags.
public enum ResponseAction: UInt8, CaseIterable, Sendable {
    case alert = 0
    case redirect = 1
    case delay = 2
    case fingerprint = 3
    case isolate = 4
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case configured = 1
    case monitoring = 2
    case responding = 3
    case shutdown = 4
}
