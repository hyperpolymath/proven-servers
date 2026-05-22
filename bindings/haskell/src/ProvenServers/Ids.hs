-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Intrusion Detection System types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ids
  (
    AlertSeverity(..)
  , alertSeverityToTag
  , alertSeverityFromTag
  , DetectionMethod(..)
  , detectionMethodToTag
  , detectionMethodFromTag
  , IdsProtocol(..)
  , idsProtocolToTag
  , idsProtocolFromTag
  , IdsAction(..)
  , idsActionToTag
  , idsActionFromTag
  , Direction(..)
  , directionToTag
  , directionFromTag
  , ThreatLevel(..)
  , threatLevelToTag
  , threatLevelFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AlertSeverity
-- ---------------------------------------------------------------------------

-- | Alert severity levels.
--
-- Tags 0-3 (4 constructors).
data AlertSeverity
  = Low  -- ^ Low (tag 0).
  | Medium  -- ^ Medium (tag 1).
  | High  -- ^ High (tag 2).
  | Critical  -- ^ Critical (tag 3).
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

-- | Intrusion detection methods.
--
-- Tags 0-3 (4 constructors).
data DetectionMethod
  = Signature  -- ^ Signature (tag 0).
  | Anomaly  -- ^ Anomaly (tag 1).
  | Stateful  -- ^ Stateful (tag 2).
  | Heuristic  -- ^ Heuristic (tag 3).
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

-- | Monitored network protocols.
--
-- Tags 0-6 (7 constructors).
data IdsProtocol
  = Tcp  -- ^ TCP (tag 0).
  | Udp  -- ^ UDP (tag 1).
  | Icmp  -- ^ ICMP (tag 2).
  | Dns  -- ^ DNS (tag 3).
  | Http  -- ^ HTTP (tag 4).
  | Tls  -- ^ TLS (tag 5).
  | Ssh  -- ^ SSH (tag 6).
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

-- | IDS response actions.
--
-- Tags 0-4 (5 constructors).
data IdsAction
  = Alert  -- ^ Alert (tag 0).
  | Drop  -- ^ Drop (tag 1).
  | Log  -- ^ Log (tag 2).
  | Block  -- ^ Block (tag 3).
  | Pass  -- ^ Pass (tag 4).
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

-- | Traffic direction.
--
-- Tags 0-2 (3 constructors).
data Direction
  = Inbound  -- ^ Inbound (tag 0).
  | Outbound  -- ^ Outbound (tag 1).
  | Both  -- ^ Both (tag 2).
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

-- | Threat assessment levels.
--
-- Tags 0-4 (5 constructors).
data ThreatLevel
  = Info  -- ^ Info (tag 0).
  | Low  -- ^ Low (tag 1).
  | Medium  -- ^ Medium (tag 2).
  | High  -- ^ High (tag 3).
  | Critical  -- ^ Critical (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ThreatLevel' to its ABI tag value.
threatLevelToTag :: ThreatLevel -> Word8
threatLevelToTag = fromIntegral . fromEnum

-- | Decode a 'ThreatLevel' from its ABI tag value.
threatLevelFromTag :: Word8 -> Maybe ThreatLevel
threatLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ThreatLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
