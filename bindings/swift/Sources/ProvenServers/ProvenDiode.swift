// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

/// Direction matching the Idris2 ABI tags.
public enum Direction: UInt8, CaseIterable, Sendable {
    case highToLow = 0
    case lowToHigh = 1
}

/// DiodeProtocol matching the Idris2 ABI tags.
public enum DiodeProtocol: UInt8, CaseIterable, Sendable {
    case udp = 0
    case tcp = 1
    case fileTransfer = 2
    case syslog = 3
    case snmp = 4
}

/// TransferState matching the Idris2 ABI tags.
public enum TransferState: UInt8, CaseIterable, Sendable {
    case queued = 0
    case sending = 1
    case confirming = 2
    case complete = 3
    case failed = 4
}

/// ValidationResult matching the Idris2 ABI tags.
public enum ValidationResult: UInt8, CaseIterable, Sendable {
    case passed = 0
    case formatError = 1
    case sizeExceeded = 2
    case policyBlocked = 3
}

/// IntegrityCheck matching the Idris2 ABI tags.
public enum IntegrityCheck: UInt8, CaseIterable, Sendable {
    case crc32 = 0
    case sha256 = 1
    case hmac = 2
}

/// GatewayState matching the Idris2 ABI tags.
public enum GatewayState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case configured = 1
    case transferring = 2
    case validating = 3
    case shutdown = 4
}
