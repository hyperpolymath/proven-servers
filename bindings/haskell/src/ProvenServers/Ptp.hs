-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | PTP protocol types for proven-servers.
--
-- PTP (Precision Time Protocol, IEEE 1588) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ptp
  ( -- * ADT types matching Idris2 ABI
      PtpMessageType(..)
    , ClockClass(..)
    , PtpPortState(..)
    , DelayMechanism(..)
    , ptpMessageTypeToTag
    , ptpMessageTypeFromTag
    , clockClassToTag
    , clockClassFromTag
    , ptpPortStateToTag
    , ptpPortStateFromTag
    , delayMechanismToTag
    , delayMechanismFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PtpMessageType
-- ---------------------------------------------------------------------------

-- | PtpMessageType type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data PtpMessageType
  = Sync  -- ^ Tag 0.
  | DelayReq  -- ^ Tag 1.
  | PdelayReq  -- ^ Tag 2.
  | PdelayResp  -- ^ Tag 3.
  | FollowUp  -- ^ Tag 4.
  | DelayResp  -- ^ Tag 5.
  | PdelayRespFollowUp  -- ^ Tag 6.
  | Announce  -- ^ Tag 7.
  | Signaling  -- ^ Tag 8.
  | Management  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PtpMessageType' to its ABI tag value.
ptpMessageTypeToTag :: PtpMessageType -> Word8
ptpMessageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PtpMessageType' from its ABI tag value.
ptpMessageTypeFromTag :: Word8 -> Maybe PtpMessageType
ptpMessageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PtpMessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ClockClass
-- ---------------------------------------------------------------------------

-- | ClockClass type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ClockClass
  = PrimaryClock  -- ^ Tag 0.
  | ApplicationSpecific  -- ^ Tag 1.
  | SlaveOnly  -- ^ Tag 2.
  | DefaultClass  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ClockClass' to its ABI tag value.
clockClassToTag :: ClockClass -> Word8
clockClassToTag = fromIntegral . fromEnum

-- | Decode a 'ClockClass' from its ABI tag value.
clockClassFromTag :: Word8 -> Maybe ClockClass
clockClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ClockClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PtpPortState
-- ---------------------------------------------------------------------------

-- | PtpPortState type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data PtpPortState
  = Initializing  -- ^ Tag 0.
  | Faulty  -- ^ Tag 1.
  | Disabled  -- ^ Tag 2.
  | Listening  -- ^ Tag 3.
  | PreMaster  -- ^ Tag 4.
  | Master  -- ^ Tag 5.
  | Passive  -- ^ Tag 6.
  | Uncalibrated  -- ^ Tag 7.
  | Slave  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PtpPortState' to its ABI tag value.
ptpPortStateToTag :: PtpPortState -> Word8
ptpPortStateToTag = fromIntegral . fromEnum

-- | Decode a 'PtpPortState' from its ABI tag value.
ptpPortStateFromTag :: Word8 -> Maybe PtpPortState
ptpPortStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PtpPortState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DelayMechanism
-- ---------------------------------------------------------------------------

-- | DelayMechanism type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data DelayMechanism
  = E2E  -- ^ Tag 0.
  | P2P  -- ^ Tag 1.
  | DmDisabled  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DelayMechanism' to its ABI tag value.
delayMechanismToTag :: DelayMechanism -> Word8
delayMechanismToTag = fromIntegral . fromEnum

-- | Decode a 'DelayMechanism' from its ABI tag value.
delayMechanismFromTag :: Word8 -> Maybe DelayMechanism
delayMechanismFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DelayMechanism)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
