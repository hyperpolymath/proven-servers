// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

/** MetricType matching the Idris2 ABI tags. */
export const MetricType = Object.freeze({
  COUNTER: 0,
  GAUGE: 1,
  HISTOGRAM: 2,
  SUMMARY: 3,
  INFO: 4,
  STATE_SET: 5,
});

/** ScrapeResult matching the Idris2 ABI tags. */
export const ScrapeResult = Object.freeze({
  SUCCESS: 0,
  SCRAPE_TIMEOUT: 1,
  CONNECTION_REFUSED: 2,
  INVALID_RESPONSE: 3,
});

/** AlertState matching the Idris2 ABI tags. */
export const AlertState = Object.freeze({
  INACTIVE: 0,
  PENDING: 1,
  FIRING: 2,
  RESOLVED: 3,
});

/** AggregationOp matching the Idris2 ABI tags. */
export const AggregationOp = Object.freeze({
  SUM: 0,
  AVG: 1,
  MIN: 2,
  MAX: 3,
  COUNT: 4,
  RATE: 5,
  INCREASE: 6,
  P50: 7,
  P90: 8,
  P95: 9,
  P99: 10,
});

/** QueryError matching the Idris2 ABI tags. */
export const QueryError = Object.freeze({
  PARSE_ERROR: 0,
  EXECUTION_ERROR: 1,
  QUERY_TIMEOUT: 2,
  TOO_MANY_SERIES: 3,
});

/** CollectorState matching the Idris2 ABI tags. */
export const CollectorState = Object.freeze({
  IDLE: 0,
  CONFIGURED: 1,
  SCRAPING: 2,
  ALERTING: 3,
  STOPPING: 4,
});
