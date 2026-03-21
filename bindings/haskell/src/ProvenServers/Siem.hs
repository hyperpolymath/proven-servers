-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SIEM protocol types for proven-servers.
--
-- SIEM (Security Information and Event Management) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Siem
  ( -- * ADT types matching Idris2 ABI
      EventSeverity(..)
    , EventCategory(..)
    , CorrelationRule(..)
    , AlertState(..)
    , eventSeverityToTag
    , eventSeverityFromTag
    , eventCategoryToTag
    , eventCategoryFromTag
    , correlationRuleToTag
    , correlationRuleFromTag
    , alertStateToTag
    , alertStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- EventSeverity
-- ---------------------------------------------------------------------------

-- | EventSeverity type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data EventSeverity
  = Info  -- ^ Tag 0.
  | Low  -- ^ Tag 1.
  | Medium  -- ^ Tag 2.
  | High  -- ^ Tag 3.
  | Critical  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EventSeverity' to its ABI tag value.
eventSeverityToTag :: EventSeverity -> Word8
eventSeverityToTag = fromIntegral . fromEnum

-- | Decode a 'EventSeverity' from its ABI tag value.
eventSeverityFromTag :: Word8 -> Maybe EventSeverity
eventSeverityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EventSeverity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EventCategory
-- ---------------------------------------------------------------------------

-- | EventCategory type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data EventCategory
  = Authentication  -- ^ Tag 0.
  | NetworkTraffic  -- ^ Tag 1.
  | FileActivity  -- ^ Tag 2.
  | ProcessExecution  -- ^ Tag 3.
  | PolicyViolation  -- ^ Tag 4.
  | Malware  -- ^ Tag 5.
  | DataExfiltration  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EventCategory' to its ABI tag value.
eventCategoryToTag :: EventCategory -> Word8
eventCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'EventCategory' from its ABI tag value.
eventCategoryFromTag :: Word8 -> Maybe EventCategory
eventCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EventCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CorrelationRule
-- ---------------------------------------------------------------------------

-- | CorrelationRule type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data CorrelationRule
  = Threshold  -- ^ Tag 0.
  | Sequence  -- ^ Tag 1.
  | Aggregation  -- ^ Tag 2.
  | Absence  -- ^ Tag 3.
  | Statistical  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CorrelationRule' to its ABI tag value.
correlationRuleToTag :: CorrelationRule -> Word8
correlationRuleToTag = fromIntegral . fromEnum

-- | Decode a 'CorrelationRule' from its ABI tag value.
correlationRuleFromTag :: Word8 -> Maybe CorrelationRule
correlationRuleFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CorrelationRule)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AlertState
-- ---------------------------------------------------------------------------

-- | AlertState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data AlertState
  = New  -- ^ Tag 0.
  | Acknowledged  -- ^ Tag 1.
  | InProgress  -- ^ Tag 2.
  | Resolved  -- ^ Tag 3.
  | FalsePositive  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlertState' to its ABI tag value.
alertStateToTag :: AlertState -> Word8
alertStateToTag = fromIntegral . fromEnum

-- | Decode a 'AlertState' from its ABI tag value.
alertStateFromTag :: Word8 -> Maybe AlertState
alertStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlertState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
