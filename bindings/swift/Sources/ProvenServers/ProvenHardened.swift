// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

/// HardeningLevel matching the Idris2 ABI tags.
public enum HardeningLevel: UInt8, CaseIterable, Sendable {
    case minimal = 0
    case standard = 1
    case high = 2
    case maximum = 3
}

/// SecurityControl matching the Idris2 ABI tags.
public enum SecurityControl: UInt8, CaseIterable, Sendable {
    case aslr = 0
    case dep = 1
    case stackCanary = 2
    case cfi = 3
    case sandboxing = 4
    case secureBoot = 5
    case auditLog = 6
}

/// ComplianceStandard matching the Idris2 ABI tags.
public enum ComplianceStandard: UInt8, CaseIterable, Sendable {
    case cis = 0
    case stig = 1
    case nist80053 = 2
    case pciDss = 3
    case fips140 = 4
}

/// AuditEvent matching the Idris2 ABI tags.
public enum AuditEvent: UInt8, CaseIterable, Sendable {
    case processStart = 0
    case fileAccess = 1
    case networkConn = 2
    case privilegeEscalation = 3
    case configChange = 4
    case authAttempt = 5
}

/// HardenedHealthStatus matching the Idris2 ABI tags.
public enum HardenedHealthStatus: UInt8, CaseIterable, Sendable {
    case healthy = 0
    case degraded = 1
    case compromised = 2
    case unresponsive = 3
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case hardening = 1
    case active = 2
    case auditing = 3
    case shutdown = 4
}
