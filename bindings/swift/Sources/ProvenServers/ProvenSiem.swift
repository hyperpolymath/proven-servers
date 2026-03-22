// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM protocol types for proven-servers.

/// EventSeverity matching the Idris2 ABI tags.
public enum EventSeverity: UInt8, CaseIterable, Sendable {
    case info = 0
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
}

/// EventCategory matching the Idris2 ABI tags.
public enum EventCategory: UInt8, CaseIterable, Sendable {
    case authentication = 0
    case networkTraffic = 1
    case fileActivity = 2
    case processExecution = 3
    case policyViolation = 4
    case malware = 5
    case dataExfiltration = 6
}

/// CorrelationRule matching the Idris2 ABI tags.
public enum CorrelationRule: UInt8, CaseIterable, Sendable {
    case threshold = 0
    case sequence = 1
    case aggregation = 2
    case absence = 3
    case statistical = 4
}

/// AlertState matching the Idris2 ABI tags.
public enum AlertState: UInt8, CaseIterable, Sendable {
    case new = 0
    case acknowledged = 1
    case inProgress = 2
    case resolved = 3
    case falsePositive = 4
}
