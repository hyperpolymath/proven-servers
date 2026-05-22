// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

/// Algorithm matching the Idris2 ABI tags.
public enum Algorithm: UInt8, CaseIterable, Sendable {
    case roundRobin = 0
    case leastConnections = 1
    case ipHash = 2
    case random = 3
    case weightedRoundRobin = 4
    case leastResponseTime = 5
}

/// HealthCheckType matching the Idris2 ABI tags.
public enum HealthCheckType: UInt8, CaseIterable, Sendable {
    case healthCheckType_Http = 0
    case healthCheckType_Tcp = 1
    case healthCheckType_Grpc = 2
    case script = 3
}

/// BackendState matching the Idris2 ABI tags.
public enum BackendState: UInt8, CaseIterable, Sendable {
    case healthy = 0
    case unhealthy = 1
    case draining = 2
    case disabled = 3
}

/// SessionPersistence matching the Idris2 ABI tags.
public enum SessionPersistence: UInt8, CaseIterable, Sendable {
    case none = 0
    case cookie = 1
    case sourceIp = 2
    case header = 3
}

/// LbProtocol matching the Idris2 ABI tags.
public enum LbProtocol: UInt8, CaseIterable, Sendable {
    case lbProtocol_Http = 0
    case https = 1
    case lbProtocol_Tcp = 2
    case udp = 3
    case lbProtocol_Grpc = 4
}
