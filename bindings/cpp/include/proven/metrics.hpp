// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file metrics.hpp
/// @brief Metrics protocol types for proven-servers.

#ifndef PROVEN_METRICS_HPP
#define PROVEN_METRICS_HPP

#include <cstdint>

namespace proven {

/// @brief MetricType matching the Idris2 ABI tags.
enum class MetricType : uint8_t {
    Counter = 0,
    Gauge = 1,
    Histogram = 2,
    Summary = 3,
    Info = 4,
    StateSet = 5
};

/// @brief ScrapeResult matching the Idris2 ABI tags.
enum class ScrapeResult : uint8_t {
    Success = 0,
    ScrapeTimeout = 1,
    ConnectionRefused = 2,
    InvalidResponse = 3
};

/// @brief AlertState matching the Idris2 ABI tags.
enum class AlertState : uint8_t {
    Inactive = 0,
    Pending = 1,
    Firing = 2,
    Resolved = 3
};

/// @brief AggregationOp matching the Idris2 ABI tags.
enum class AggregationOp : uint8_t {
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
};

/// @brief QueryError matching the Idris2 ABI tags.
enum class QueryError : uint8_t {
    ParseError = 0,
    ExecutionError = 1,
    QueryTimeout = 2,
    TooManySeries = 3
};

/// @brief CollectorState matching the Idris2 ABI tags.
enum class CollectorState : uint8_t {
    Idle = 0,
    Configured = 1,
    Scraping = 2,
    Alerting = 3,
    Stopping = 4
};

} // namespace proven

#endif // PROVEN_METRICS_HPP
