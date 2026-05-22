// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

/// ReliabilityKind matching the Idris2 ABI tags.
public enum ReliabilityKind: UInt8, CaseIterable, Sendable {
    case bestEffort = 0
    case reliable = 1
}

/// DurabilityKind matching the Idris2 ABI tags.
public enum DurabilityKind: UInt8, CaseIterable, Sendable {
    case transientLocal = 1
    case transient = 2
    case persistent = 3
}

/// HistoryKind matching the Idris2 ABI tags.
public enum HistoryKind: UInt8, CaseIterable, Sendable {
    case keepLast = 0
    case keepAll = 1
}

/// OwnershipKind matching the Idris2 ABI tags.
public enum OwnershipKind: UInt8, CaseIterable, Sendable {
    case shared = 0
    case exclusive = 1
}

/// EntityType matching the Idris2 ABI tags.
public enum EntityType: UInt8, CaseIterable, Sendable {
    case participant = 0
    case publisher = 1
    case subscriber = 2
    case topic = 3
    case dataWriter = 4
    case dataReader = 5
}

/// ParticipantState matching the Idris2 ABI tags.
public enum ParticipantState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case joined = 1
    case publishing = 2
    case subscribing = 3
    case leaving = 4
}
