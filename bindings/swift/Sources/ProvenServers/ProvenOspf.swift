// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for proven-servers.

/// PacketType matching the Idris2 ABI tags.
public enum PacketType: UInt8, CaseIterable, Sendable {
    case hello = 0
    case databaseDescription = 1
    case linkStateRequest = 2
    case linkStateUpdate = 3
    case linkStateAck = 4
}

/// NeighborState matching the Idris2 ABI tags.
public enum NeighborState: UInt8, CaseIterable, Sendable {
    case down = 0
    case attempt = 1
    case `init` = 2
    case twoWay = 3
    case exStart = 4
    case exchange = 5
    case loading = 6
    case full = 7
}

/// LsaType matching the Idris2 ABI tags.
public enum LsaType: UInt8, CaseIterable, Sendable {
    case routerLsa = 0
    case networkLsa = 1
    case summaryLsa = 2
    case asbrSummaryLsa = 3
    case asExternalLsa = 4
}

/// AreaType matching the Idris2 ABI tags.
public enum AreaType: UInt8, CaseIterable, Sendable {
    case normal = 0
    case stub = 1
    case totallyStub = 2
    case nssa = 3
}

/// OspfError matching the Idris2 ABI tags.
public enum OspfError: UInt8, CaseIterable, Sendable {
    case ok = 0
    case invalidSlot = 1
    case notActive = 2
    case invalidTransition = 3
    case invalidPacket = 4
    case areaError = 5
    case floodLimit = 6
}
