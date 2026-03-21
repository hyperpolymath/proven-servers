// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module MetricsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Prometheus port.
let metricsPort = 9090

// ===========================================================================
// MetricType (tags 0-5)
// ===========================================================================

/// Standard Prometheus port.
type metricType =
  | @as(0) Counter
  | @as(1) Gauge
  | @as(2) Histogram
  | @as(3) Summary
  | @as(4) Info
  | @as(5) StateSet

/// Decode from the C-ABI tag value.
let metricTypeFromTag = (tag: int): option<metricType> =>
  switch tag {
  | 0 => Some(Counter)
  | 1 => Some(Gauge)
  | 2 => Some(Histogram)
  | 3 => Some(Summary)
  | 4 => Some(Info)
  | 5 => Some(StateSet)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let metricTypeToTag = (v: metricType): int =>
  switch v {
  | Counter => 0
  | Gauge => 1
  | Histogram => 2
  | Summary => 3
  | Info => 4
  | StateSet => 5
  }

// ===========================================================================
// ScrapeResult (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type scrapeResult =
  | @as(0) Success
  | @as(1) ScrapeTimeout
  | @as(2) ConnectionRefused
  | @as(3) InvalidResponse

/// Decode from the C-ABI tag value.
let scrapeResultFromTag = (tag: int): option<scrapeResult> =>
  switch tag {
  | 0 => Some(Success)
  | 1 => Some(ScrapeTimeout)
  | 2 => Some(ConnectionRefused)
  | 3 => Some(InvalidResponse)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let scrapeResultToTag = (v: scrapeResult): int =>
  switch v {
  | Success => 0
  | ScrapeTimeout => 1
  | ConnectionRefused => 2
  | InvalidResponse => 3
  }

// ===========================================================================
// AlertState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type alertState =
  | @as(0) Inactive
  | @as(1) Pending
  | @as(2) Firing
  | @as(3) Resolved

/// Decode from the C-ABI tag value.
let alertStateFromTag = (tag: int): option<alertState> =>
  switch tag {
  | 0 => Some(Inactive)
  | 1 => Some(Pending)
  | 2 => Some(Firing)
  | 3 => Some(Resolved)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let alertStateToTag = (v: alertState): int =>
  switch v {
  | Inactive => 0
  | Pending => 1
  | Firing => 2
  | Resolved => 3
  }

// ===========================================================================
// AggregationOp (tags 0-10)
// ===========================================================================

/// Decode from an ABI tag value.
type aggregationOp =
  | @as(0) Sum
  | @as(1) Avg
  | @as(2) Min
  | @as(3) Max
  | @as(4) Count
  | @as(5) Rate
  | @as(6) Increase
  | @as(7) P50
  | @as(8) P90
  | @as(9) P95
  | @as(10) P99

/// Decode from the C-ABI tag value.
let aggregationOpFromTag = (tag: int): option<aggregationOp> =>
  switch tag {
  | 0 => Some(Sum)
  | 1 => Some(Avg)
  | 2 => Some(Min)
  | 3 => Some(Max)
  | 4 => Some(Count)
  | 5 => Some(Rate)
  | 6 => Some(Increase)
  | 7 => Some(P50)
  | 8 => Some(P90)
  | 9 => Some(P95)
  | 10 => Some(P99)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let aggregationOpToTag = (v: aggregationOp): int =>
  switch v {
  | Sum => 0
  | Avg => 1
  | Min => 2
  | Max => 3
  | Count => 4
  | Rate => 5
  | Increase => 6
  | P50 => 7
  | P90 => 8
  | P95 => 9
  | P99 => 10
  }

// ===========================================================================
// QueryError (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type queryError =
  | @as(0) ParseError
  | @as(1) ExecutionError
  | @as(2) QueryTimeout
  | @as(3) TooManySeries

/// Decode from the C-ABI tag value.
let queryErrorFromTag = (tag: int): option<queryError> =>
  switch tag {
  | 0 => Some(ParseError)
  | 1 => Some(ExecutionError)
  | 2 => Some(QueryTimeout)
  | 3 => Some(TooManySeries)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let queryErrorToTag = (v: queryError): int =>
  switch v {
  | ParseError => 0
  | ExecutionError => 1
  | QueryTimeout => 2
  | TooManySeries => 3
  }

// ===========================================================================
// CollectorState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type collectorState =
  | @as(0) Idle
  | @as(1) Configured
  | @as(2) Scraping
  | @as(3) Alerting
  | @as(4) Stopping

/// Decode from the C-ABI tag value.
let collectorStateFromTag = (tag: int): option<collectorState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Configured)
  | 2 => Some(Scraping)
  | 3 => Some(Alerting)
  | 4 => Some(Stopping)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let collectorStateToTag = (v: collectorState): int =>
  switch v {
  | Idle => 0
  | Configured => 1
  | Scraping => 2
  | Alerting => 3
  | Stopping => 4
  }

