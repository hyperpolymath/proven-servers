-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Monitor types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Monitor
  (
    CheckType(..)
  , checkTypeToTag
  , checkTypeFromTag
  , Status(..)
  , statusToTag
  , statusFromTag
  , AlertChannel(..)
  , alertChannelToTag
  , alertChannelFromTag
  , Severity(..)
  , severityToTag
  , severityFromTag
  , CheckState(..)
  , checkStateToTag
  , checkStateFromTag
  , MonitorState(..)
  , monitorStateToTag
  , monitorStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- CheckType
-- ---------------------------------------------------------------------------

-- | Monitor check types.
--
-- Tags 0-10 (11 constructors).
data CheckType
  = Http  -- ^ HTTP (tag 0).
  | Tcp  -- ^ TCP (tag 1).
  | Udp  -- ^ UDP (tag 2).
  | Icmp  -- ^ ICMP (tag 3).
  | Dns  -- ^ DNS (tag 4).
  | Certificate  -- ^ Certificate (tag 5).
  | Disk  -- ^ Disk (tag 6).
  | Cpu  -- ^ CPU (tag 7).
  | Memory  -- ^ Memory (tag 8).
  | Process  -- ^ Process (tag 9).
  | Custom  -- ^ Custom (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CheckType' to its ABI tag value.
checkTypeToTag :: CheckType -> Word8
checkTypeToTag = fromIntegral . fromEnum

-- | Decode a 'CheckType' from its ABI tag value.
checkTypeFromTag :: Word8 -> Maybe CheckType
checkTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CheckType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Status
-- ---------------------------------------------------------------------------

-- | Monitor status values.
--
-- Tags 0-4 (5 constructors).
data Status
  = Up  -- ^ Up (tag 0).
  | Down  -- ^ Down (tag 1).
  | Degraded  -- ^ Degraded (tag 2).
  | Unknown  -- ^ Unknown (tag 3).
  | Maintenance  -- ^ Maintenance (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Status' to its ABI tag value.
statusToTag :: Status -> Word8
statusToTag = fromIntegral . fromEnum

-- | Decode a 'Status' from its ABI tag value.
statusFromTag :: Word8 -> Maybe Status
statusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Status)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AlertChannel
-- ---------------------------------------------------------------------------

-- | Alert notification channels.
--
-- Tags 0-4 (5 constructors).
data AlertChannel
  = Email  -- ^ Email (tag 0).
  | Sms  -- ^ SMS (tag 1).
  | Webhook  -- ^ Webhook (tag 2).
  | Slack  -- ^ Slack (tag 3).
  | PagerDuty  -- ^ PagerDuty (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlertChannel' to its ABI tag value.
alertChannelToTag :: AlertChannel -> Word8
alertChannelToTag = fromIntegral . fromEnum

-- | Decode a 'AlertChannel' from its ABI tag value.
alertChannelFromTag :: Word8 -> Maybe AlertChannel
alertChannelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlertChannel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Severity
-- ---------------------------------------------------------------------------

-- | Monitor severity levels.
--
-- Tags 0-3 (4 constructors).
data Severity
  = Info  -- ^ Info (tag 0).
  | Warning  -- ^ Warning (tag 1).
  | Error  -- ^ Error (tag 2).
  | Critical  -- ^ Critical (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Severity' to its ABI tag value.
severityToTag :: Severity -> Word8
severityToTag = fromIntegral . fromEnum

-- | Decode a 'Severity' from its ABI tag value.
severityFromTag :: Word8 -> Maybe Severity
severityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Severity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CheckState
-- ---------------------------------------------------------------------------

-- | Monitor check execution states.
--
-- Tags 0-5 (6 constructors).
data CheckState
  = Pending  -- ^ Pending (tag 0).
  | Running  -- ^ Running (tag 1).
  | Passed  -- ^ Passed (tag 2).
  | Failed  -- ^ Failed (tag 3).
  | Timeout  -- ^ Timeout (tag 4).
  | CsError  -- ^ Error (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CheckState' to its ABI tag value.
checkStateToTag :: CheckState -> Word8
checkStateToTag = fromIntegral . fromEnum

-- | Decode a 'CheckState' from its ABI tag value.
checkStateFromTag :: Word8 -> Maybe CheckState
checkStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CheckState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MonitorState
-- ---------------------------------------------------------------------------

-- | Monitor service states.
--
-- Tags 0-5 (6 constructors).
data MonitorState
  = Idle  -- ^ Idle (tag 0).
  | Configured  -- ^ Configured (tag 1).
  | Running  -- ^ Running (tag 2).
  | MonPaused  -- ^ Paused (tag 3).
  | Alerting  -- ^ Alerting (tag 4).
  | Shutdown  -- ^ Shutdown (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MonitorState' to its ABI tag value.
monitorStateToTag :: MonitorState -> Word8
monitorStateToTag = fromIntegral . fromEnum

-- | Decode a 'MonitorState' from its ABI tag value.
monitorStateFromTag :: Word8 -> Maybe MonitorState
monitorStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MonitorState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
