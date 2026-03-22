// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// App Server protocol types for proven-servers.

/// RequestType matching the Idris2 ABI tags.
public enum RequestType: UInt8, CaseIterable, Sendable {
    case http = 0
    case webSocket = 1
    case grpc = 2
    case graphQl = 3
}

/// LifecycleState matching the Idris2 ABI tags.
public enum LifecycleState: UInt8, CaseIterable, Sendable {
    case initializing = 0
    case starting = 1
    case running = 2
    case draining = 3
    case stopping = 4
    case stopped = 5
}

/// HealthCheck matching the Idris2 ABI tags.
public enum HealthCheck: UInt8, CaseIterable, Sendable {
    case liveness = 0
    case readiness = 1
    case startup = 2
}

/// DeployStrategy matching the Idris2 ABI tags.
public enum DeployStrategy: UInt8, CaseIterable, Sendable {
    case rollingUpdate = 0
    case blueGreen = 1
    case canary = 2
    case recreate = 3
}

/// ErrorCategory matching the Idris2 ABI tags.
public enum ErrorCategory: UInt8, CaseIterable, Sendable {
    case clientError = 0
    case serverError = 1
    case timeout = 2
    case circuitOpen = 3
    case rateLimited = 4
}
