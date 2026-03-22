// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

/// ExecutionPolicy matching the Idris2 ABI tags.
public enum ExecutionPolicy: UInt8, CaseIterable, Sendable {
    case unrestricted = 0
    case readOnly = 1
    case networkDenied = 2
    case isolated = 3
    case ephemeral = 4
}

/// ResourceLimit matching the Idris2 ABI tags.
public enum ResourceLimit: UInt8, CaseIterable, Sendable {
    case cpuTime = 0
    case memory = 1
    case diskIo = 2
    case networkIo = 3
    case fileDescriptors = 4
    case processes = 5
}

/// SandboxState matching the Idris2 ABI tags.
public enum SandboxState: UInt8, CaseIterable, Sendable {
    case creating = 0
    case ready = 1
    case running = 2
    case suspended = 3
    case terminated = 4
    case destroyed = 5
}

/// ExitReason matching the Idris2 ABI tags.
public enum ExitReason: UInt8, CaseIterable, Sendable {
    case normal = 0
    case timeout = 1
    case memoryExceeded = 2
    case policyViolation = 3
    case killed = 4
    case error = 5
}

/// SyscallPolicy matching the Idris2 ABI tags.
public enum SyscallPolicy: UInt8, CaseIterable, Sendable {
    case allow = 0
    case deny = 1
    case log = 2
    case trap = 3
}
