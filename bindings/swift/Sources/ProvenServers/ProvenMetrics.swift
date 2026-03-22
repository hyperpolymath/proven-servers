// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

/// MetricType matching the Idris2 ABI tags.
public enum MetricType: UInt8, CaseIterable, Sendable {
    case counter = 0
    case gauge = 1
    case histogram = 2
    case summary = 3
    case info = 4
    case stateSet = 5
}

/// ScrapeResult matching the Idris2 ABI tags.
public enum ScrapeResult: UInt8, CaseIterable, Sendable {
    case success = 0
    case scrapeTimeout = 1
    case connectionRefused = 2
    case invalidResponse = 3
}

/// AlertState matching the Idris2 ABI tags.
public enum AlertState: UInt8, CaseIterable, Sendable {
    case inactive = 0
    case pending = 1
    case firing = 2
    case resolved = 3
}

/// AggregationOp matching the Idris2 ABI tags.
public enum AggregationOp: UInt8, CaseIterable, Sendable {
    case sum = 0
    case avg = 1
    case min = 2
    case max = 3
    case count = 4
    case rate = 5
    case increase = 6
    case p50 = 7
    case p90 = 8
    case p95 = 9
    case p99 = 10
}

/// QueryError matching the Idris2 ABI tags.
public enum QueryError: UInt8, CaseIterable, Sendable {
    case parseError = 0
    case executionError = 1
    case queryTimeout = 2
    case tooManySeries = 3
}

/// CollectorState matching the Idris2 ABI tags.
public enum CollectorState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case configured = 1
    case scraping = 2
    case alerting = 3
    case stopping = 4
}
