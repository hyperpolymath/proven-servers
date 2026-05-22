// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case uploadPack = 0
    case receivePack = 1
    case uploadArchive = 2
}

/// PacketType matching the Idris2 ABI tags.
public enum PacketType: UInt8, CaseIterable, Sendable {
    case flush = 0
    case delimiter = 1
    case responseEnd = 2
    case data = 3
    case pktError = 4
    case sidebandData = 5
    case sidebandProgress = 6
    case sidebandError = 7
}

/// RefType matching the Idris2 ABI tags.
public enum RefType: UInt8, CaseIterable, Sendable {
    case branch = 0
    case tag = 1
    case head = 2
    case remote = 3
    case gitNote = 4
}

/// Capability matching the Idris2 ABI tags.
public enum Capability: UInt8, CaseIterable, Sendable {
    case multiAck = 0
    case thinPack = 1
    case sideBand64k = 2
    case ofsDelta = 3
    case shallow = 4
    case deepenSince = 5
    case deepenNot = 6
    case filterSpec = 7
    case objectFormat = 8
}

/// HookResult matching the Idris2 ABI tags.
public enum HookResult: UInt8, CaseIterable, Sendable {
    case accept = 0
    case reject = 1
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case discovery = 1
    case negotiating = 2
    case transfer = 3
    case shutdown = 4
}
