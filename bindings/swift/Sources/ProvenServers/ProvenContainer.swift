// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container protocol types for proven-servers.

/// ContainerState matching the Idris2 ABI tags.
public enum ContainerState: UInt8, CaseIterable, Sendable {
    case creating = 0
    case running = 1
    case paused = 2
    case restarting = 3
    case stopped = 4
    case removing = 5
    case dead = 6
}

/// ContainerOperation matching the Idris2 ABI tags.
public enum ContainerOperation: UInt8, CaseIterable, Sendable {
    case create = 0
    case start = 1
    case stop = 2
    case restart = 3
    case pause = 4
    case unpause = 5
    case kill = 6
    case remove = 7
    case exec = 8
    case logs = 9
    case inspect = 10
}

/// NetworkMode matching the Idris2 ABI tags.
public enum NetworkMode: UInt8, CaseIterable, Sendable {
    case bridge = 0
    case host = 1
    case none = 2
    case overlay = 3
    case macvlan = 4
}

/// VolumeType matching the Idris2 ABI tags.
public enum VolumeType: UInt8, CaseIterable, Sendable {
    case bind = 0
    case named = 1
    case tmpfs = 2
}

/// RestartPolicy matching the Idris2 ABI tags.
public enum RestartPolicy: UInt8, CaseIterable, Sendable {
    case no = 0
    case always = 1
    case onFailure = 2
    case unlessStopped = 3
}

/// HealthStatus matching the Idris2 ABI tags.
public enum HealthStatus: UInt8, CaseIterable, Sendable {
    case starting = 0
    case healthy = 1
    case unhealthy = 2
    case noCheck = 3
}
