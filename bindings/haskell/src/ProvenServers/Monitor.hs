-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Monitor protocol types for proven-servers.
--
-- Monitoring/uptime types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Monitor
  ( -- * ADT types matching Idris2 ABI
      CheckType(..)
    , Status(..)
    , AlertChannel(..)
    , Severity(..)
    , CheckState(..)
    , MonitorState(..)
    , checkTypeToTag
    , checkTypeFromTag
    , statusToTag
    , statusFromTag
    , alertChannelToTag
    , alertChannelFromTag
    , severityToTag
    , severityFromTag
    , checkStateToTag
    , checkStateFromTag
    , monitorStateToTag
    , monitorStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- CheckType
-- ---------------------------------------------------------------------------

-- | CheckType type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data CheckType
  = Http  -- ^ Tag 0.
  | Tcp  -- ^ Tag 1.
  | Udp  -- ^ Tag 2.
  | Icmp  -- ^ Tag 3.
  | Dns  -- ^ Tag 4.
  | Certificate  -- ^ Tag 5.
  | Disk  -- ^ Tag 6.
  | Cpu  -- ^ Tag 7.
  | Memory  -- ^ Tag 8.
  | Process  -- ^ Tag 9.
  | Custom  -- ^ Tag 10.
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

-- | Status type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Status
  = Up  -- ^ Tag 0.
  | Down  -- ^ Tag 1.
  | Degraded  -- ^ Tag 2.
  | Unknown  -- ^ Tag 3.
  | Maintenance  -- ^ Tag 4.
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

-- | AlertChannel type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data AlertChannel
  = Email  -- ^ Tag 0.
  | Sms  -- ^ Tag 1.
  | Webhook  -- ^ Tag 2.
  | Slack  -- ^ Tag 3.
  | PagerDuty  -- ^ Tag 4.
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

-- | Severity type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data Severity
  = Info  -- ^ Tag 0.
  | Warning  -- ^ Tag 1.
  | Error  -- ^ Tag 2.
  | Critical  -- ^ Tag 3.
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

-- | CheckState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data CheckState
  = Pending  -- ^ Tag 0.
  | CheckState_Running  -- ^ Tag 1.
  | Passed  -- ^ Tag 2.
  | Failed  -- ^ Tag 3.
  | Timeout  -- ^ Tag 4.
  | CsError  -- ^ Tag 5.
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

-- | MonitorState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data MonitorState
  = Idle  -- ^ Tag 0.
  | Configured  -- ^ Tag 1.
  | MonitorState_Running  -- ^ Tag 2.
  | MonPaused  -- ^ Tag 3.
  | Alerting  -- ^ Tag 4.
  | Shutdown  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MonitorState' to its ABI tag value.
monitorStateToTag :: MonitorState -> Word8
monitorStateToTag = fromIntegral . fromEnum

-- | Decode a 'MonitorState' from its ABI tag value.
monitorStateFromTag :: Word8 -> Maybe MonitorState
monitorStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MonitorState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
