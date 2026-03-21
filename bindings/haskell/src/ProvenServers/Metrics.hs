-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Metrics protocol types for proven-servers.
--
-- Metrics/Prometheus server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Metrics
  ( -- * ADT types matching Idris2 ABI
      MetricType(..)
    , ScrapeResult(..)
    , AlertState(..)
    , AggregationOp(..)
    , QueryError(..)
    , CollectorState(..)
    , metricTypeToTag
    , metricTypeFromTag
    , scrapeResultToTag
    , scrapeResultFromTag
    , alertStateToTag
    , alertStateFromTag
    , aggregationOpToTag
    , aggregationOpFromTag
    , queryErrorToTag
    , queryErrorFromTag
    , collectorStateToTag
    , collectorStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MetricType
-- ---------------------------------------------------------------------------

-- | MetricType type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data MetricType
  = Counter  -- ^ Tag 0.
  | Gauge  -- ^ Tag 1.
  | Histogram  -- ^ Tag 2.
  | Summary  -- ^ Tag 3.
  | Info  -- ^ Tag 4.
  | StateSet  -- ^ Tag 5.
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

-- | ScrapeResult type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ScrapeResult
  = Success  -- ^ Tag 0.
  | ScrapeTimeout  -- ^ Tag 1.
  | ConnectionRefused  -- ^ Tag 2.
  | InvalidResponse  -- ^ Tag 3.
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

-- | AlertState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AlertState
  = Inactive  -- ^ Tag 0.
  | Pending  -- ^ Tag 1.
  | Firing  -- ^ Tag 2.
  | Resolved  -- ^ Tag 3.
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

-- | AggregationOp type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data AggregationOp
  = Sum  -- ^ Tag 0.
  | Avg  -- ^ Tag 1.
  | Min  -- ^ Tag 2.
  | Max  -- ^ Tag 3.
  | Count  -- ^ Tag 4.
  | Rate  -- ^ Tag 5.
  | Increase  -- ^ Tag 6.
  | P50  -- ^ Tag 7.
  | P90  -- ^ Tag 8.
  | P95  -- ^ Tag 9.
  | P99  -- ^ Tag 10.
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

-- | QueryError type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data QueryError
  = ParseError  -- ^ Tag 0.
  | ExecutionError  -- ^ Tag 1.
  | QueryTimeout  -- ^ Tag 2.
  | TooManySeries  -- ^ Tag 3.
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

-- | CollectorState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data CollectorState
  = Idle  -- ^ Tag 0.
  | Configured  -- ^ Tag 1.
  | Scraping  -- ^ Tag 2.
  | Alerting  -- ^ Tag 3.
  | Stopping  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CollectorState' to its ABI tag value.
collectorStateToTag :: CollectorState -> Word8
collectorStateToTag = fromIntegral . fromEnum

-- | Decode a 'CollectorState' from its ABI tag value.
collectorStateFromTag :: Word8 -> Maybe CollectorState
collectorStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CollectorState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
