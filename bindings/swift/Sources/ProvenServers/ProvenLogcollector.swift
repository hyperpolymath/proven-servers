// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector protocol types for proven-servers.

/// LogLevel matching the Idris2 ABI tags.
public enum LogLevel: UInt8, CaseIterable, Sendable {
    case trace = 0
    case debug = 1
    case info = 2
    case warn = 3
    case err = 4
    case fatal = 5
}

/// InputFormat matching the Idris2 ABI tags.
public enum InputFormat: UInt8, CaseIterable, Sendable {
    case json = 0
    case logfmt = 1
    case syslog = 2
    case cef = 3
    case gelf = 4
    case raw = 5
}

/// OutputTarget matching the Idris2 ABI tags.
public enum OutputTarget: UInt8, CaseIterable, Sendable {
    case file = 0
    case elasticsearch = 1
    case s3 = 2
    case kafka = 3
    case stdout = 4
}

/// FilterOp matching the Idris2 ABI tags.
public enum FilterOp: UInt8, CaseIterable, Sendable {
    case include = 0
    case exclude = 1
    case transform = 2
    case redact = 3
    case sample = 4
}

/// PipelineStage matching the Idris2 ABI tags.
public enum PipelineStage: UInt8, CaseIterable, Sendable {
    case input = 0
    case parse = 1
    case filter = 2
    case pipelineTransform = 3
    case output = 4
}
