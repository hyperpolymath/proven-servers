-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- abi.Types: C-ABI-compatible numeric representations of Metrics types.
--
-- Maps every constructor of the core Metrics sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/metrics.zig)
-- exactly.
--
-- Types covered:
--   MetricType     (6 constructors, tags 0-5)
--   ScrapeResult   (4 constructors, tags 0-3)
--   AlertState     (4 constructors, tags 0-3)
--   AggregationOp  (11 constructors, tags 0-10)
--   QueryError     (4 constructors, tags 0-3)
--   CollectorState (5 constructors, tags 0-4)

module abi.Types

import Metrics.Types

%default total

---------------------------------------------------------------------------
-- MetricType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
metricTypeToTag : MetricType -> Bits8
metricTypeToTag Counter   = 0
metricTypeToTag Gauge     = 1
metricTypeToTag Histogram = 2
metricTypeToTag Summary   = 3
metricTypeToTag Info      = 4
metricTypeToTag StateSet  = 5

public export
tagToMetricType : Bits8 -> Maybe MetricType
tagToMetricType 0 = Just Counter
tagToMetricType 1 = Just Gauge
tagToMetricType 2 = Just Histogram
tagToMetricType 3 = Just Summary
tagToMetricType 4 = Just Info
tagToMetricType 5 = Just StateSet
tagToMetricType _ = Nothing

public export
metricTypeRoundtrip : (m : MetricType) -> tagToMetricType (metricTypeToTag m) = Just m
metricTypeRoundtrip Counter   = Refl
metricTypeRoundtrip Gauge     = Refl
metricTypeRoundtrip Histogram = Refl
metricTypeRoundtrip Summary   = Refl
metricTypeRoundtrip Info      = Refl
metricTypeRoundtrip StateSet  = Refl

---------------------------------------------------------------------------
-- ScrapeResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
scrapeResultToTag : ScrapeResult -> Bits8
scrapeResultToTag Success          = 0
scrapeResultToTag ScrapeTimeout    = 1
scrapeResultToTag ConnectionRefused = 2
scrapeResultToTag InvalidResponse  = 3

public export
tagToScrapeResult : Bits8 -> Maybe ScrapeResult
tagToScrapeResult 0 = Just Success
tagToScrapeResult 1 = Just ScrapeTimeout
tagToScrapeResult 2 = Just ConnectionRefused
tagToScrapeResult 3 = Just InvalidResponse
tagToScrapeResult _ = Nothing

public export
scrapeResultRoundtrip : (s : ScrapeResult) -> tagToScrapeResult (scrapeResultToTag s) = Just s
scrapeResultRoundtrip Success          = Refl
scrapeResultRoundtrip ScrapeTimeout    = Refl
scrapeResultRoundtrip ConnectionRefused = Refl
scrapeResultRoundtrip InvalidResponse  = Refl

---------------------------------------------------------------------------
-- AlertState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
alertStateToTag : AlertState -> Bits8
alertStateToTag Inactive = 0
alertStateToTag Pending  = 1
alertStateToTag Firing   = 2
alertStateToTag Resolved = 3

public export
tagToAlertState : Bits8 -> Maybe AlertState
tagToAlertState 0 = Just Inactive
tagToAlertState 1 = Just Pending
tagToAlertState 2 = Just Firing
tagToAlertState 3 = Just Resolved
tagToAlertState _ = Nothing

public export
alertStateRoundtrip : (a : AlertState) -> tagToAlertState (alertStateToTag a) = Just a
alertStateRoundtrip Inactive = Refl
alertStateRoundtrip Pending  = Refl
alertStateRoundtrip Firing   = Refl
alertStateRoundtrip Resolved = Refl

---------------------------------------------------------------------------
-- AggregationOp (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
aggregationOpToTag : AggregationOp -> Bits8
aggregationOpToTag Sum      = 0
aggregationOpToTag Avg      = 1
aggregationOpToTag Min      = 2
aggregationOpToTag Max      = 3
aggregationOpToTag Count    = 4
aggregationOpToTag Rate     = 5
aggregationOpToTag Increase = 6
aggregationOpToTag P50      = 7
aggregationOpToTag P90      = 8
aggregationOpToTag P95      = 9
aggregationOpToTag P99      = 10

public export
tagToAggregationOp : Bits8 -> Maybe AggregationOp
tagToAggregationOp 0  = Just Sum
tagToAggregationOp 1  = Just Avg
tagToAggregationOp 2  = Just Min
tagToAggregationOp 3  = Just Max
tagToAggregationOp 4  = Just Count
tagToAggregationOp 5  = Just Rate
tagToAggregationOp 6  = Just Increase
tagToAggregationOp 7  = Just P50
tagToAggregationOp 8  = Just P90
tagToAggregationOp 9  = Just P95
tagToAggregationOp 10 = Just P99
tagToAggregationOp _  = Nothing

public export
aggregationOpRoundtrip : (a : AggregationOp) -> tagToAggregationOp (aggregationOpToTag a) = Just a
aggregationOpRoundtrip Sum      = Refl
aggregationOpRoundtrip Avg      = Refl
aggregationOpRoundtrip Min      = Refl
aggregationOpRoundtrip Max      = Refl
aggregationOpRoundtrip Count    = Refl
aggregationOpRoundtrip Rate     = Refl
aggregationOpRoundtrip Increase = Refl
aggregationOpRoundtrip P50      = Refl
aggregationOpRoundtrip P90      = Refl
aggregationOpRoundtrip P95      = Refl
aggregationOpRoundtrip P99      = Refl

---------------------------------------------------------------------------
-- QueryError (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
queryErrorToTag : QueryError -> Bits8
queryErrorToTag ParseError     = 0
queryErrorToTag ExecutionError = 1
queryErrorToTag QueryTimeout   = 2
queryErrorToTag TooManySeries  = 3

public export
tagToQueryError : Bits8 -> Maybe QueryError
tagToQueryError 0 = Just ParseError
tagToQueryError 1 = Just ExecutionError
tagToQueryError 2 = Just QueryTimeout
tagToQueryError 3 = Just TooManySeries
tagToQueryError _ = Nothing

public export
queryErrorRoundtrip : (e : QueryError) -> tagToQueryError (queryErrorToTag e) = Just e
queryErrorRoundtrip ParseError     = Refl
queryErrorRoundtrip ExecutionError = Refl
queryErrorRoundtrip QueryTimeout   = Refl
queryErrorRoundtrip TooManySeries  = Refl

---------------------------------------------------------------------------
-- CollectorState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| Metrics collector session lifecycle states.
||| Used by the FFI layer for the C ABI.
public export
data CollectorState : Type where
  ||| No collector active. Initial and terminal state.
  CSIdle       : CollectorState
  ||| Collector configured, targets added.
  CSConfigured : CollectorState
  ||| Actively scraping targets.
  CSScraping   : CollectorState
  ||| Evaluating alert rules.
  CSAlerting   : CollectorState
  ||| Collector shutting down.
  CSStopping   : CollectorState

public export
Eq CollectorState where
  CSIdle       == CSIdle       = True
  CSConfigured == CSConfigured = True
  CSScraping   == CSScraping   = True
  CSAlerting   == CSAlerting   = True
  CSStopping   == CSStopping   = True
  _            == _            = False

public export
Show CollectorState where
  show CSIdle       = "Idle"
  show CSConfigured = "Configured"
  show CSScraping   = "Scraping"
  show CSAlerting   = "Alerting"
  show CSStopping   = "Stopping"

public export
collectorStateToTag : CollectorState -> Bits8
collectorStateToTag CSIdle       = 0
collectorStateToTag CSConfigured = 1
collectorStateToTag CSScraping   = 2
collectorStateToTag CSAlerting   = 3
collectorStateToTag CSStopping   = 4

public export
tagToCollectorState : Bits8 -> Maybe CollectorState
tagToCollectorState 0 = Just CSIdle
tagToCollectorState 1 = Just CSConfigured
tagToCollectorState 2 = Just CSScraping
tagToCollectorState 3 = Just CSAlerting
tagToCollectorState 4 = Just CSStopping
tagToCollectorState _ = Nothing

public export
collectorStateRoundtrip : (s : CollectorState) -> tagToCollectorState (collectorStateToTag s) = Just s
collectorStateRoundtrip CSIdle       = Refl
collectorStateRoundtrip CSConfigured = Refl
collectorStateRoundtrip CSScraping   = Refl
collectorStateRoundtrip CSAlerting   = Refl
collectorStateRoundtrip CSStopping   = Refl
