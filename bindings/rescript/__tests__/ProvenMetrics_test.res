// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenMetrics protocol bindings.

open ProvenMetrics

let test_metricType_roundtrip = () => {
  assert(metricTypeFromTag(0) == Some(Counter))
  assert(metricTypeFromTag(1) == Some(Gauge))
  assert(metricTypeFromTag(2) == Some(Histogram))
  assert(metricTypeFromTag(3) == Some(Summary))
  assert(metricTypeFromTag(4) == Some(Info))
  assert(metricTypeFromTag(5) == Some(StateSet))
  assert(metricTypeFromTag(6) == None)
}

let test_metricType_toTag = () => {
  assert(metricTypeToTag(Counter) == 0)
  assert(metricTypeToTag(Gauge) == 1)
  assert(metricTypeToTag(Histogram) == 2)
  assert(metricTypeToTag(Summary) == 3)
  assert(metricTypeToTag(Info) == 4)
  assert(metricTypeToTag(StateSet) == 5)
}

let test_scrapeResult_roundtrip = () => {
  assert(scrapeResultFromTag(0) == Some(Success))
  assert(scrapeResultFromTag(1) == Some(ScrapeTimeout))
  assert(scrapeResultFromTag(2) == Some(ConnectionRefused))
  assert(scrapeResultFromTag(3) == Some(InvalidResponse))
  assert(scrapeResultFromTag(4) == None)
}

let test_scrapeResult_toTag = () => {
  assert(scrapeResultToTag(Success) == 0)
  assert(scrapeResultToTag(ScrapeTimeout) == 1)
  assert(scrapeResultToTag(ConnectionRefused) == 2)
  assert(scrapeResultToTag(InvalidResponse) == 3)
}

let test_alertState_roundtrip = () => {
  assert(alertStateFromTag(0) == Some(Inactive))
  assert(alertStateFromTag(1) == Some(Pending))
  assert(alertStateFromTag(2) == Some(Firing))
  assert(alertStateFromTag(3) == Some(Resolved))
  assert(alertStateFromTag(4) == None)
}

let test_alertState_toTag = () => {
  assert(alertStateToTag(Inactive) == 0)
  assert(alertStateToTag(Pending) == 1)
  assert(alertStateToTag(Firing) == 2)
  assert(alertStateToTag(Resolved) == 3)
}

let test_aggregationOp_roundtrip = () => {
  assert(aggregationOpFromTag(0) == Some(Sum))
  assert(aggregationOpFromTag(1) == Some(Avg))
  assert(aggregationOpFromTag(2) == Some(Min))
  assert(aggregationOpFromTag(3) == Some(Max))
  assert(aggregationOpFromTag(4) == Some(Count))
  assert(aggregationOpFromTag(5) == Some(Rate))
  assert(aggregationOpFromTag(6) == Some(Increase))
  assert(aggregationOpFromTag(7) == Some(P50))
  assert(aggregationOpFromTag(8) == Some(P90))
  assert(aggregationOpFromTag(9) == Some(P95))
  assert(aggregationOpFromTag(10) == Some(P99))
  assert(aggregationOpFromTag(11) == None)
}

let test_aggregationOp_toTag = () => {
  assert(aggregationOpToTag(Sum) == 0)
  assert(aggregationOpToTag(Avg) == 1)
  assert(aggregationOpToTag(Min) == 2)
  assert(aggregationOpToTag(Max) == 3)
  assert(aggregationOpToTag(Count) == 4)
  assert(aggregationOpToTag(Rate) == 5)
  assert(aggregationOpToTag(Increase) == 6)
  assert(aggregationOpToTag(P50) == 7)
  assert(aggregationOpToTag(P90) == 8)
  assert(aggregationOpToTag(P95) == 9)
  assert(aggregationOpToTag(P99) == 10)
}

let test_queryError_roundtrip = () => {
  assert(queryErrorFromTag(0) == Some(ParseError))
  assert(queryErrorFromTag(1) == Some(ExecutionError))
  assert(queryErrorFromTag(2) == Some(QueryTimeout))
  assert(queryErrorFromTag(3) == Some(TooManySeries))
  assert(queryErrorFromTag(4) == None)
}

let test_queryError_toTag = () => {
  assert(queryErrorToTag(ParseError) == 0)
  assert(queryErrorToTag(ExecutionError) == 1)
  assert(queryErrorToTag(QueryTimeout) == 2)
  assert(queryErrorToTag(TooManySeries) == 3)
}

let test_collectorState_roundtrip = () => {
  assert(collectorStateFromTag(0) == Some(Idle))
  assert(collectorStateFromTag(1) == Some(Configured))
  assert(collectorStateFromTag(2) == Some(Scraping))
  assert(collectorStateFromTag(3) == Some(Alerting))
  assert(collectorStateFromTag(4) == Some(Stopping))
  assert(collectorStateFromTag(5) == None)
}

let test_collectorState_toTag = () => {
  assert(collectorStateToTag(Idle) == 0)
  assert(collectorStateToTag(Configured) == 1)
  assert(collectorStateToTag(Scraping) == 2)
  assert(collectorStateToTag(Alerting) == 3)
  assert(collectorStateToTag(Stopping) == 4)
}

// Run all tests
test_metricType_roundtrip()
test_metricType_toTag()
test_scrapeResult_roundtrip()
test_scrapeResult_toTag()
test_alertState_roundtrip()
test_alertState_toTag()
test_aggregationOp_roundtrip()
test_aggregationOp_toTag()
test_queryError_roundtrip()
test_queryError_toTag()
test_collectorState_roundtrip()
test_collectorState_toTag()
