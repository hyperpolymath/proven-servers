// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

namespace Proven;

/// <summary>MetricType matching the Idris2 ABI tags (0-5).</summary>
public enum MetricType : byte
{
    Counter = 0,
    Gauge = 1,
    Histogram = 2,
    Summary = 3,
    Info = 4,
    StateSet = 5
}

/// <summary>ScrapeResult matching the Idris2 ABI tags (0-3).</summary>
public enum ScrapeResult : byte
{
    Success = 0,
    ScrapeTimeout = 1,
    ConnectionRefused = 2,
    InvalidResponse = 3
}

/// <summary>AlertState matching the Idris2 ABI tags (0-3).</summary>
public enum AlertState : byte
{
    Inactive = 0,
    Pending = 1,
    Firing = 2,
    Resolved = 3
}

/// <summary>AggregationOp matching the Idris2 ABI tags (0-10).</summary>
public enum AggregationOp : byte
{
    Sum = 0,
    Avg = 1,
    Min = 2,
    Max = 3,
    Count = 4,
    Rate = 5,
    Increase = 6,
    P50 = 7,
    P90 = 8,
    P95 = 9,
    P99 = 10
}

/// <summary>QueryError matching the Idris2 ABI tags (0-3).</summary>
public enum QueryError : byte
{
    ParseError = 0,
    ExecutionError = 1,
    QueryTimeout = 2,
    TooManySeries = 3
}

/// <summary>CollectorState matching the Idris2 ABI tags (0-4).</summary>
public enum CollectorState : byte
{
    Idle = 0,
    Configured = 1,
    Scraping = 2,
    Alerting = 3,
    Stopping = 4
}
