//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Metrics protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `MetricsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Metrics Constants
// ===========================================================================

/// Metrics Port constant.
pub const metrics_port = 9090

// ===========================================================================
// MetricType
// ===========================================================================

/// Metric data types (OpenMetrics).
/// 
/// Matches `MetricType` in `MetricsABI.Types`.
pub type MetricType {
  /// Counter (tag 0).
  Counter
  /// Gauge (tag 1).
  Gauge
  /// Histogram (tag 2).
  Histogram
  /// Summary (tag 3).
  Summary
  /// Info (tag 4).
  Info
  /// StateSet (tag 5).
  StateSet
}

/// Convert a `MetricType` to its C-ABI tag value.
pub fn metric_type_to_int(value: MetricType) -> Int {
  case value {
    Counter -> 0
    Gauge -> 1
    Histogram -> 2
    Summary -> 3
    Info -> 4
    StateSet -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn metric_type_from_int(tag: Int) -> Result(MetricType, Nil) {
  case tag {
    0 -> Ok(Counter)
    1 -> Ok(Gauge)
    2 -> Ok(Histogram)
    3 -> Ok(Summary)
    4 -> Ok(Info)
    5 -> Ok(StateSet)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ScrapeResult
// ===========================================================================

/// Metrics scrape results.
/// 
/// Matches `ScrapeResult` in `MetricsABI.Types`.
pub type ScrapeResult {
  /// Success (tag 0).
  Success
  /// ScrapeTimeout (tag 1).
  ScrapeTimeout
  /// ConnectionRefused (tag 2).
  ConnectionRefused
  /// InvalidResponse (tag 3).
  InvalidResponse
}

/// Convert a `ScrapeResult` to its C-ABI tag value.
pub fn scrape_result_to_int(value: ScrapeResult) -> Int {
  case value {
    Success -> 0
    ScrapeTimeout -> 1
    ConnectionRefused -> 2
    InvalidResponse -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn scrape_result_from_int(tag: Int) -> Result(ScrapeResult, Nil) {
  case tag {
    0 -> Ok(Success)
    1 -> Ok(ScrapeTimeout)
    2 -> Ok(ConnectionRefused)
    3 -> Ok(InvalidResponse)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AlertState
// ===========================================================================

/// Alert rule states.
/// 
/// Matches `AlertState` in `MetricsABI.Types`.
pub type AlertState {
  /// Inactive (tag 0).
  Inactive
  /// Pending (tag 1).
  Pending
  /// Firing (tag 2).
  Firing
  /// Resolved (tag 3).
  Resolved
}

/// Convert a `AlertState` to its C-ABI tag value.
pub fn alert_state_to_int(value: AlertState) -> Int {
  case value {
    Inactive -> 0
    Pending -> 1
    Firing -> 2
    Resolved -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_state_from_int(tag: Int) -> Result(AlertState, Nil) {
  case tag {
    0 -> Ok(Inactive)
    1 -> Ok(Pending)
    2 -> Ok(Firing)
    3 -> Ok(Resolved)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AggregationOp
// ===========================================================================

/// Metrics aggregation operations.
/// 
/// Matches `AggregationOp` in `MetricsABI.Types`.
pub type AggregationOp {
  /// Sum (tag 0).
  Sum
  /// Avg (tag 1).
  Avg
  /// Min (tag 2).
  Min
  /// Max (tag 3).
  Max
  /// Count (tag 4).
  Count
  /// Rate (tag 5).
  Rate
  /// Increase (tag 6).
  Increase
  /// P50 (tag 7).
  P50
  /// P90 (tag 8).
  P90
  /// P95 (tag 9).
  P95
  /// P99 (tag 10).
  P99
}

/// Convert a `AggregationOp` to its C-ABI tag value.
pub fn aggregation_op_to_int(value: AggregationOp) -> Int {
  case value {
    Sum -> 0
    Avg -> 1
    Min -> 2
    Max -> 3
    Count -> 4
    Rate -> 5
    Increase -> 6
    P50 -> 7
    P90 -> 8
    P95 -> 9
    P99 -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn aggregation_op_from_int(tag: Int) -> Result(AggregationOp, Nil) {
  case tag {
    0 -> Ok(Sum)
    1 -> Ok(Avg)
    2 -> Ok(Min)
    3 -> Ok(Max)
    4 -> Ok(Count)
    5 -> Ok(Rate)
    6 -> Ok(Increase)
    7 -> Ok(P50)
    8 -> Ok(P90)
    9 -> Ok(P95)
    10 -> Ok(P99)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// QueryError
// ===========================================================================

/// Metrics query error codes.
/// 
/// Matches `QueryError` in `MetricsABI.Types`.
pub type QueryError {
  /// ParseError (tag 0).
  ParseError
  /// ExecutionError (tag 1).
  ExecutionError
  /// QueryTimeout (tag 2).
  QueryTimeout
  /// TooManySeries (tag 3).
  TooManySeries
}

/// Convert a `QueryError` to its C-ABI tag value.
pub fn query_error_to_int(value: QueryError) -> Int {
  case value {
    ParseError -> 0
    ExecutionError -> 1
    QueryTimeout -> 2
    TooManySeries -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn query_error_from_int(tag: Int) -> Result(QueryError, Nil) {
  case tag {
    0 -> Ok(ParseError)
    1 -> Ok(ExecutionError)
    2 -> Ok(QueryTimeout)
    3 -> Ok(TooManySeries)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CollectorState
// ===========================================================================

/// Metrics collector states.
/// 
/// Matches `CollectorState` in `MetricsABI.Types`.
pub type CollectorState {
  /// Idle (tag 0).
  Idle
  /// Configured (tag 1).
  Configured
  /// Scraping (tag 2).
  Scraping
  /// Alerting (tag 3).
  Alerting
  /// Stopping (tag 4).
  Stopping
}

/// Convert a `CollectorState` to its C-ABI tag value.
pub fn collector_state_to_int(value: CollectorState) -> Int {
  case value {
    Idle -> 0
    Configured -> 1
    Scraping -> 2
    Alerting -> 3
    Stopping -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn collector_state_from_int(tag: Int) -> Result(CollectorState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Configured)
    2 -> Ok(Scraping)
    3 -> Ok(Alerting)
    4 -> Ok(Stopping)
    _ -> Error(Nil)
  }
}

