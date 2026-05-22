// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

/// MetricType matching the Idris2 ABI tags.
enum MetricType {
  counter(0),
  gauge(1),
  histogram(2),
  summary(3),
  info(4),
  stateSet(5);

  const MetricType(this.tag);
  final int tag;

  static MetricType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ScrapeResult matching the Idris2 ABI tags.
enum ScrapeResult {
  success(0),
  scrapeTimeout(1),
  connectionRefused(2),
  invalidResponse(3);

  const ScrapeResult(this.tag);
  final int tag;

  static ScrapeResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AlertState matching the Idris2 ABI tags.
enum AlertState {
  inactive(0),
  pending(1),
  firing(2),
  resolved(3);

  const AlertState(this.tag);
  final int tag;

  static AlertState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AggregationOp matching the Idris2 ABI tags.
enum AggregationOp {
  sum(0),
  avg(1),
  min(2),
  max(3),
  count(4),
  rate(5),
  increase(6),
  p50(7),
  p90(8),
  p95(9),
  p99(10);

  const AggregationOp(this.tag);
  final int tag;

  static AggregationOp? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// QueryError matching the Idris2 ABI tags.
enum QueryError {
  parseError(0),
  executionError(1),
  queryTimeout(2),
  tooManySeries(3);

  const QueryError(this.tag);
  final int tag;

  static QueryError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CollectorState matching the Idris2 ABI tags.
enum CollectorState {
  idle(0),
  configured(1),
  scraping(2),
  alerting(3),
  stopping(4);

  const CollectorState(this.tag);
  final int tag;

  static CollectorState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
