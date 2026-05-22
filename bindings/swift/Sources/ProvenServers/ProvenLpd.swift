// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

/// CommandCode matching the Idris2 ABI tags.
public enum CommandCode: UInt8, CaseIterable, Sendable {
    case printJob = 1
    case receiveJob = 2
    case shortQueue = 3
    case longQueue = 4
    case removeJobs = 5
}

/// SubCommandCode matching the Idris2 ABI tags.
public enum SubCommandCode: UInt8, CaseIterable, Sendable {
    case abortJob = 1
    case controlFile = 2
    case dataFile = 3
}

/// JobStatus matching the Idris2 ABI tags.
public enum JobStatus: UInt8, CaseIterable, Sendable {
    case pending = 0
    case printing = 1
    case complete = 2
    case failed = 3
}
