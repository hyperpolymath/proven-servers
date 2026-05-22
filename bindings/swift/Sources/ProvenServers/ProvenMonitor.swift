// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor protocol types for proven-servers.

/// CheckType matching the Idris2 ABI tags.
public enum CheckType: UInt8, CaseIterable, Sendable {
    case http = 0
    case tcp = 1
    case udp = 2
    case icmp = 3
    case dns = 4
    case certificate = 5
    case disk = 6
    case cpu = 7
    case memory = 8
    case process = 9
    case custom = 10
}

/// Status matching the Idris2 ABI tags.
public enum Status: UInt8, CaseIterable, Sendable {
    case up = 0
    case down = 1
    case degraded = 2
    case unknown = 3
    case maintenance = 4
}

/// AlertChannel matching the Idris2 ABI tags.
public enum AlertChannel: UInt8, CaseIterable, Sendable {
    case email = 0
    case sms = 1
    case webhook = 2
    case slack = 3
    case pagerDuty = 4
}

/// Severity matching the Idris2 ABI tags.
public enum Severity: UInt8, CaseIterable, Sendable {
    case info = 0
    case warning = 1
    case error = 2
    case critical = 3
}

/// CheckState matching the Idris2 ABI tags.
public enum CheckState: UInt8, CaseIterable, Sendable {
    case pending = 0
    case checkState_Running = 1
    case passed = 2
    case failed = 3
    case timeout = 4
    case csError = 5
}

/// MonitorState matching the Idris2 ABI tags.
public enum MonitorState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case configured = 1
    case monitorState_Running = 2
    case monPaused = 3
    case alerting = 4
    case shutdown = 5
}
