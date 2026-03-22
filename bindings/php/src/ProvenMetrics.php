<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MetricType matching the Idris2 ABI tags. */
enum MetricType: int
{
    case Counter = 0;
    case Gauge = 1;
    case Histogram = 2;
    case Summary = 3;
    case Info = 4;
    case StateSet = 5;
}

/** ScrapeResult matching the Idris2 ABI tags. */
enum ScrapeResult: int
{
    case Success = 0;
    case ScrapeTimeout = 1;
    case ConnectionRefused = 2;
    case InvalidResponse = 3;
}

/** AlertState matching the Idris2 ABI tags. */
enum AlertState: int
{
    case Inactive = 0;
    case Pending = 1;
    case Firing = 2;
    case Resolved = 3;
}

/** AggregationOp matching the Idris2 ABI tags. */
enum AggregationOp: int
{
    case Sum = 0;
    case Avg = 1;
    case Min = 2;
    case Max = 3;
    case Count = 4;
    case Rate = 5;
    case Increase = 6;
    case P50 = 7;
    case P90 = 8;
    case P95 = 9;
    case P99 = 10;
}

/** QueryError matching the Idris2 ABI tags. */
enum QueryError: int
{
    case ParseError = 0;
    case ExecutionError = 1;
    case QueryTimeout = 2;
    case TooManySeries = 3;
}

/** CollectorState matching the Idris2 ABI tags. */
enum CollectorState: int
{
    case Idle = 0;
    case Configured = 1;
    case Scraping = 2;
    case Alerting = 3;
    case Stopping = 4;
}
