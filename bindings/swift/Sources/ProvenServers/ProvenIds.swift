// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

/// AlertSeverity matching the Idris2 ABI tags.
public enum AlertSeverity: UInt8, CaseIterable, Sendable {
    case alertSeverity_Low = 0
    case alertSeverity_Medium = 1
    case alertSeverity_High = 2
    case alertSeverity_Critical = 3
}

/// DetectionMethod matching the Idris2 ABI tags.
public enum DetectionMethod: UInt8, CaseIterable, Sendable {
    case signature = 0
    case anomaly = 1
    case stateful = 2
    case heuristic = 3
}

/// IdsProtocol matching the Idris2 ABI tags.
public enum IdsProtocol: UInt8, CaseIterable, Sendable {
    case tcp = 0
    case udp = 1
    case icmp = 2
    case dns = 3
    case http = 4
    case tls = 5
    case ssh = 6
}

/// IdsAction matching the Idris2 ABI tags.
public enum IdsAction: UInt8, CaseIterable, Sendable {
    case alert = 0
    case drop = 1
    case log = 2
    case block = 3
    case pass = 4
}

/// Direction matching the Idris2 ABI tags.
public enum Direction: UInt8, CaseIterable, Sendable {
    case inbound = 0
    case outbound = 1
    case both = 2
}

/// ThreatLevel matching the Idris2 ABI tags.
public enum ThreatLevel: UInt8, CaseIterable, Sendable {
    case info = 0
    case threatLevel_Low = 1
    case threatLevel_Medium = 2
    case threatLevel_High = 3
    case threatLevel_Critical = 4
}
