-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SIEM types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Siem
  (
    EventSeverity(..)
  , eventSeverityToTag
  , eventSeverityFromTag
  , EventCategory(..)
  , eventCategoryToTag
  , eventCategoryFromTag
  , CorrelationRule(..)
  , correlationRuleToTag
  , correlationRuleFromTag
  , AlertState(..)
  , alertStateToTag
  , alertStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- EventSeverity
-- ---------------------------------------------------------------------------

-- | Security event severity.
--
-- Tags 0-4 (5 constructors).
data EventSeverity
  = Info  -- ^ Info (tag 0).
  | Low  -- ^ Low (tag 1).
  | Medium  -- ^ Medium (tag 2).
  | High  -- ^ High (tag 3).
  | Critical  -- ^ Critical (tag 4).
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

-- | Security event categories.
--
-- Tags 0-6 (7 constructors).
data EventCategory
  = Authentication  -- ^ Authentication (tag 0).
  | NetworkTraffic  -- ^ NetworkTraffic (tag 1).
  | FileActivity  -- ^ FileActivity (tag 2).
  | ProcessExecution  -- ^ ProcessExecution (tag 3).
  | PolicyViolation  -- ^ PolicyViolation (tag 4).
  | Malware  -- ^ Malware (tag 5).
  | DataExfiltration  -- ^ DataExfiltration (tag 6).
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

-- | Event correlation rule types.
--
-- Tags 0-4 (5 constructors).
data CorrelationRule
  = Threshold  -- ^ Threshold (tag 0).
  | Sequence  -- ^ Sequence (tag 1).
  | Aggregation  -- ^ Aggregation (tag 2).
  | Absence  -- ^ Absence (tag 3).
  | Statistical  -- ^ Statistical (tag 4).
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

-- | SIEM alert states.
--
-- Tags 0-4 (5 constructors).
data AlertState
  = New  -- ^ New (tag 0).
  | Acknowledged  -- ^ Acknowledged (tag 1).
  | InProgress  -- ^ InProgress (tag 2).
  | Resolved  -- ^ Resolved (tag 3).
  | FalsePositive  -- ^ FalsePositive (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlertState' to its ABI tag value.
alertStateToTag :: AlertState -> Word8
alertStateToTag = fromIntegral . fromEnum

-- | Decode a 'AlertState' from its ABI tag value.
alertStateFromTag :: Word8 -> Maybe AlertState
alertStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlertState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
