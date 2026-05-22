// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Config Mgmt protocol types for proven-servers.

/// ResourceType matching the Idris2 ABI tags.
public enum ResourceType: UInt8, CaseIterable, Sendable {
    case file = 0
    case package = 1
    case service = 2
    case user = 3
    case group = 4
    case cron = 5
    case mount = 6
    case firewall = 7
    case registry = 8
}

/// ResourceState matching the Idris2 ABI tags.
public enum ResourceState: UInt8, CaseIterable, Sendable {
    case present = 0
    case absent = 1
    case running = 2
    case stopped = 3
    case enabled = 4
    case disabled = 5
}

/// ChangeAction matching the Idris2 ABI tags.
public enum ChangeAction: UInt8, CaseIterable, Sendable {
    case create = 0
    case modify = 1
    case delete = 2
    case restart = 3
    case reload = 4
    case skip = 5
}

/// DriftStatus matching the Idris2 ABI tags.
public enum DriftStatus: UInt8, CaseIterable, Sendable {
    case inSync = 0
    case drifted = 1
    case dUnknown = 2
    case unmanaged = 3
}

/// ApplyMode matching the Idris2 ABI tags.
public enum ApplyMode: UInt8, CaseIterable, Sendable {
    case enforce = 0
    case dryRun = 1
    case audit = 2
}
