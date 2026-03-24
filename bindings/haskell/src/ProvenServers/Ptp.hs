-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | PTP types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ptp
  (
    ptpEventPort
  , ptpGeneralPort
  , PtpMessageType(..)
  , ptpMessageTypeToTag
  , ptpMessageTypeFromTag
  , ClockClass(..)
  , clockClassToTag
  , clockClassFromTag
  , PtpPortState(..)
  , ptpPortStateToTag
  , ptpPortStateFromTag
  , DelayMechanism(..)
  , delayMechanismToTag
  , delayMechanismFromTag
  ) where

import Data.Word (Word16, Word8)

-- | PTP event port.
ptpEventPort :: Word16
ptpEventPort = 319

-- | PTP general port.
ptpGeneralPort :: Word16
ptpGeneralPort = 320

-- ---------------------------------------------------------------------------
-- PtpMessageType
-- ---------------------------------------------------------------------------

-- | PTP event port.
--
-- Tags 0-9 (10 constructors).
data PtpMessageType
  = Sync  -- ^ Sync (tag 0).
  | DelayReq  -- ^ DelayReq (tag 1).
  | PdelayReq  -- ^ PdelayReq (tag 2).
  | PdelayResp  -- ^ PdelayResp (tag 3).
  | FollowUp  -- ^ FollowUp (tag 4).
  | DelayResp  -- ^ DelayResp (tag 5).
  | PdelayRespFollowUp  -- ^ PdelayRespFollowUp (tag 6).
  | Announce  -- ^ Announce (tag 7).
  | Signaling  -- ^ Signaling (tag 8).
  | Management  -- ^ Management (tag 9).
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

-- | PTP clock classes.
--
-- Tags 0-3 (4 constructors).
data ClockClass
  = PrimaryClock  -- ^ PrimaryClock (tag 0).
  | ApplicationSpecific  -- ^ ApplicationSpecific (tag 1).
  | SlaveOnly  -- ^ SlaveOnly (tag 2).
  | DefaultClass  -- ^ DefaultClass (tag 3).
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

-- | PTP port states (IEEE 1588).
--
-- Tags 0-8 (9 constructors).
data PtpPortState
  = Initializing  -- ^ Initializing (tag 0).
  | Faulty  -- ^ Faulty (tag 1).
  | Disabled  -- ^ Disabled (tag 2).
  | Listening  -- ^ Listening (tag 3).
  | PreMaster  -- ^ PreMaster (tag 4).
  | Master  -- ^ Master (tag 5).
  | Passive  -- ^ Passive (tag 6).
  | Uncalibrated  -- ^ Uncalibrated (tag 7).
  | Slave  -- ^ Slave (tag 8).
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

-- | PTP delay measurement mechanisms.
--
-- Tags 0-2 (3 constructors).
data DelayMechanism
  = E2E  -- ^ End-to-end (tag 0).
  | P2P  -- ^ Peer-to-peer (tag 1).
  | DmDisabled  -- ^ Disabled (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DelayMechanism' to its ABI tag value.
delayMechanismToTag :: DelayMechanism -> Word8
delayMechanismToTag = fromIntegral . fromEnum

-- | Decode a 'DelayMechanism' from its ABI tag value.
delayMechanismFromTag :: Word8 -> Maybe DelayMechanism
delayMechanismFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DelayMechanism)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
