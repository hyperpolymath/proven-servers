-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Metrics Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Metrics
  (
    metricsPort
  , MetricType(..)
  , metricTypeToTag
  , metricTypeFromTag
  , ScrapeResult(..)
  , scrapeResultToTag
  , scrapeResultFromTag
  , AlertState(..)
  , alertStateToTag
  , alertStateFromTag
  , AggregationOp(..)
  , aggregationOpToTag
  , aggregationOpFromTag
  , QueryError(..)
  , queryErrorToTag
  , queryErrorFromTag
  , CollectorState(..)
  , collectorStateToTag
  , collectorStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard Prometheus port.
metricsPort :: Word16
metricsPort = 9090

-- ---------------------------------------------------------------------------
-- MetricType
-- ---------------------------------------------------------------------------

-- | Standard Prometheus port.
--
-- Tags 0-5 (6 constructors).
data MetricType
  = Counter  -- ^ Counter (tag 0).
  | Gauge  -- ^ Gauge (tag 1).
  | Histogram  -- ^ Histogram (tag 2).
  | Summary  -- ^ Summary (tag 3).
  | Info  -- ^ Info (tag 4).
  | StateSet  -- ^ StateSet (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MetricType' to its ABI tag value.
metricTypeToTag :: MetricType -> Word8
metricTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MetricType' from its ABI tag value.
metricTypeFromTag :: Word8 -> Maybe MetricType
metricTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MetricType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ScrapeResult
-- ---------------------------------------------------------------------------

-- | Metrics scrape results.
--
-- Tags 0-3 (4 constructors).
data ScrapeResult
  = Success  -- ^ Success (tag 0).
  | ScrapeTimeout  -- ^ ScrapeTimeout (tag 1).
  | ConnectionRefused  -- ^ ConnectionRefused (tag 2).
  | InvalidResponse  -- ^ InvalidResponse (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ScrapeResult' to its ABI tag value.
scrapeResultToTag :: ScrapeResult -> Word8
scrapeResultToTag = fromIntegral . fromEnum

-- | Decode a 'ScrapeResult' from its ABI tag value.
scrapeResultFromTag :: Word8 -> Maybe ScrapeResult
scrapeResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ScrapeResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AlertState
-- ---------------------------------------------------------------------------

-- | Alert rule states.
--
-- Tags 0-3 (4 constructors).
data AlertState
  = Inactive  -- ^ Inactive (tag 0).
  | Pending  -- ^ Pending (tag 1).
  | Firing  -- ^ Firing (tag 2).
  | Resolved  -- ^ Resolved (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlertState' to its ABI tag value.
alertStateToTag :: AlertState -> Word8
alertStateToTag = fromIntegral . fromEnum

-- | Decode a 'AlertState' from its ABI tag value.
alertStateFromTag :: Word8 -> Maybe AlertState
alertStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlertState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AggregationOp
-- ---------------------------------------------------------------------------

-- | Metrics aggregation operations.
--
-- Tags 0-10 (11 constructors).
data AggregationOp
  = Sum  -- ^ Sum (tag 0).
  | Avg  -- ^ Avg (tag 1).
  | Min  -- ^ Min (tag 2).
  | Max  -- ^ Max (tag 3).
  | Count  -- ^ Count (tag 4).
  | Rate  -- ^ Rate (tag 5).
  | Increase  -- ^ Increase (tag 6).
  | P50  -- ^ P50 (tag 7).
  | P90  -- ^ P90 (tag 8).
  | P95  -- ^ P95 (tag 9).
  | P99  -- ^ P99 (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AggregationOp' to its ABI tag value.
aggregationOpToTag :: AggregationOp -> Word8
aggregationOpToTag = fromIntegral . fromEnum

-- | Decode a 'AggregationOp' from its ABI tag value.
aggregationOpFromTag :: Word8 -> Maybe AggregationOp
aggregationOpFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AggregationOp)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- QueryError
-- ---------------------------------------------------------------------------

-- | Metrics query error codes.
--
-- Tags 0-3 (4 constructors).
data QueryError
  = ParseError  -- ^ ParseError (tag 0).
  | ExecutionError  -- ^ ExecutionError (tag 1).
  | QueryTimeout  -- ^ QueryTimeout (tag 2).
  | TooManySeries  -- ^ TooManySeries (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QueryError' to its ABI tag value.
queryErrorToTag :: QueryError -> Word8
queryErrorToTag = fromIntegral . fromEnum

-- | Decode a 'QueryError' from its ABI tag value.
queryErrorFromTag :: Word8 -> Maybe QueryError
queryErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QueryError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CollectorState
-- ---------------------------------------------------------------------------

-- | Metrics collector states.
--
-- Tags 0-4 (5 constructors).
data CollectorState
  = Idle  -- ^ Idle (tag 0).
  | Configured  -- ^ Configured (tag 1).
  | Scraping  -- ^ Scraping (tag 2).
  | Alerting  -- ^ Alerting (tag 3).
  | Stopping  -- ^ Stopping (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CollectorState' to its ABI tag value.
collectorStateToTag :: CollectorState -> Word8
collectorStateToTag = fromIntegral . fromEnum

-- | Decode a 'CollectorState' from its ABI tag value.
collectorStateFromTag :: Word8 -> Maybe CollectorState
collectorStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CollectorState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
