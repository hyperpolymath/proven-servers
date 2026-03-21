-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | IDS protocol types for proven-servers.
--
-- Intrusion Detection System types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ids
  ( -- * ADT types matching Idris2 ABI
      AlertSeverity(..)
    , DetectionMethod(..)
    , IdsProtocol(..)
    , IdsAction(..)
    , Direction(..)
    , ThreatLevel(..)
    , alertSeverityToTag
    , alertSeverityFromTag
    , detectionMethodToTag
    , detectionMethodFromTag
    , idsProtocolToTag
    , idsProtocolFromTag
    , idsActionToTag
    , idsActionFromTag
    , directionToTag
    , directionFromTag
    , threatLevelToTag
    , threatLevelFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AlertSeverity
-- ---------------------------------------------------------------------------

-- | AlertSeverity type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AlertSeverity
  = AlertSeverity_Low  -- ^ Tag 0.
  | AlertSeverity_Medium  -- ^ Tag 1.
  | AlertSeverity_High  -- ^ Tag 2.
  | AlertSeverity_Critical  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlertSeverity' to its ABI tag value.
alertSeverityToTag :: AlertSeverity -> Word8
alertSeverityToTag = fromIntegral . fromEnum

-- | Decode a 'AlertSeverity' from its ABI tag value.
alertSeverityFromTag :: Word8 -> Maybe AlertSeverity
alertSeverityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlertSeverity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DetectionMethod
-- ---------------------------------------------------------------------------

-- | DetectionMethod type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data DetectionMethod
  = Signature  -- ^ Tag 0.
  | Anomaly  -- ^ Tag 1.
  | Stateful  -- ^ Tag 2.
  | Heuristic  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DetectionMethod' to its ABI tag value.
detectionMethodToTag :: DetectionMethod -> Word8
detectionMethodToTag = fromIntegral . fromEnum

-- | Decode a 'DetectionMethod' from its ABI tag value.
detectionMethodFromTag :: Word8 -> Maybe DetectionMethod
detectionMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DetectionMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IdsProtocol
-- ---------------------------------------------------------------------------

-- | IdsProtocol type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data IdsProtocol
  = Tcp  -- ^ Tag 0.
  | Udp  -- ^ Tag 1.
  | Icmp  -- ^ Tag 2.
  | Dns  -- ^ Tag 3.
  | Http  -- ^ Tag 4.
  | Tls  -- ^ Tag 5.
  | Ssh  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IdsProtocol' to its ABI tag value.
idsProtocolToTag :: IdsProtocol -> Word8
idsProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'IdsProtocol' from its ABI tag value.
idsProtocolFromTag :: Word8 -> Maybe IdsProtocol
idsProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IdsProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IdsAction
-- ---------------------------------------------------------------------------

-- | IdsAction type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data IdsAction
  = Alert  -- ^ Tag 0.
  | Drop  -- ^ Tag 1.
  | Log  -- ^ Tag 2.
  | Block  -- ^ Tag 3.
  | Pass  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IdsAction' to its ABI tag value.
idsActionToTag :: IdsAction -> Word8
idsActionToTag = fromIntegral . fromEnum

-- | Decode a 'IdsAction' from its ABI tag value.
idsActionFromTag :: Word8 -> Maybe IdsAction
idsActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IdsAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Direction
-- ---------------------------------------------------------------------------

-- | Direction type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Direction
  = Inbound  -- ^ Tag 0.
  | Outbound  -- ^ Tag 1.
  | Both  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Direction' to its ABI tag value.
directionToTag :: Direction -> Word8
directionToTag = fromIntegral . fromEnum

-- | Decode a 'Direction' from its ABI tag value.
directionFromTag :: Word8 -> Maybe Direction
directionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Direction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ThreatLevel
-- ---------------------------------------------------------------------------

-- | ThreatLevel type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ThreatLevel
  = Info  -- ^ Tag 0.
  | ThreatLevel_Low  -- ^ Tag 1.
  | ThreatLevel_Medium  -- ^ Tag 2.
  | ThreatLevel_High  -- ^ Tag 3.
  | ThreatLevel_Critical  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ThreatLevel' to its ABI tag value.
threatLevelToTag :: ThreatLevel -> Word8
threatLevelToTag = fromIntegral . fromEnum

-- | Decode a 'ThreatLevel' from its ABI tag value.
threatLevelFromTag :: Word8 -> Maybe ThreatLevel
threatLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ThreatLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
