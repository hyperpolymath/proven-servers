-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NTP protocol types for proven-servers.
--
-- NTP (Network Time Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ntp
  ( -- * ADT types matching Idris2 ABI
      LeapIndicator(..)
    , NtpMode(..)
    , ExchangeState(..)
    , ClockDisciplineState(..)
    , KissCode(..)
    , NtpError(..)
    , leapIndicatorToTag
    , leapIndicatorFromTag
    , ntpModeToTag
    , ntpModeFromTag
    , exchangeStateToTag
    , exchangeStateFromTag
    , clockDisciplineStateToTag
    , clockDisciplineStateFromTag
    , kissCodeToTag
    , kissCodeFromTag
    , ntpErrorToTag
    , ntpErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- LeapIndicator
-- ---------------------------------------------------------------------------

-- | LeapIndicator type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data LeapIndicator
  = NoWarning  -- ^ Tag 0.
  | LastMinute61  -- ^ Tag 1.
  | LastMinute59  -- ^ Tag 2.
  | Unsynchronised  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LeapIndicator' to its ABI tag value.
leapIndicatorToTag :: LeapIndicator -> Word8
leapIndicatorToTag = fromIntegral . fromEnum

-- | Decode a 'LeapIndicator' from its ABI tag value.
leapIndicatorFromTag :: Word8 -> Maybe LeapIndicator
leapIndicatorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LeapIndicator)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NtpMode
-- ---------------------------------------------------------------------------

-- | NtpMode type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data NtpMode
  = Reserved  -- ^ Tag 0.
  | SymmetricActive  -- ^ Tag 1.
  | SymmetricPassive  -- ^ Tag 2.
  | Client  -- ^ Tag 3.
  | Server  -- ^ Tag 4.
  | Broadcast  -- ^ Tag 5.
  | ControlMessage  -- ^ Tag 6.
  | Private  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NtpMode' to its ABI tag value.
ntpModeToTag :: NtpMode -> Word8
ntpModeToTag = fromIntegral . fromEnum

-- | Decode a 'NtpMode' from its ABI tag value.
ntpModeFromTag :: Word8 -> Maybe NtpMode
ntpModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NtpMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ExchangeState
-- ---------------------------------------------------------------------------

-- | ExchangeState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ExchangeState
  = Idle  -- ^ Tag 0.
  | RequestReceived  -- ^ Tag 1.
  | TimestampCalculated  -- ^ Tag 2.
  | ResponseSent  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExchangeState' to its ABI tag value.
exchangeStateToTag :: ExchangeState -> Word8
exchangeStateToTag = fromIntegral . fromEnum

-- | Decode a 'ExchangeState' from its ABI tag value.
exchangeStateFromTag :: Word8 -> Maybe ExchangeState
exchangeStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExchangeState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ClockDisciplineState
-- ---------------------------------------------------------------------------

-- | ClockDisciplineState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ClockDisciplineState
  = Unset  -- ^ Tag 0.
  | Spike  -- ^ Tag 1.
  | Freq  -- ^ Tag 2.
  | Sync  -- ^ Tag 3.
  | Panic  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ClockDisciplineState' to its ABI tag value.
clockDisciplineStateToTag :: ClockDisciplineState -> Word8
clockDisciplineStateToTag = fromIntegral . fromEnum

-- | Decode a 'ClockDisciplineState' from its ABI tag value.
clockDisciplineStateFromTag :: Word8 -> Maybe ClockDisciplineState
clockDisciplineStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ClockDisciplineState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KissCode
-- ---------------------------------------------------------------------------

-- | KissCode type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data KissCode
  = Deny  -- ^ Tag 0.
  | Rstr  -- ^ Tag 1.
  | Rate  -- ^ Tag 2.
  | Other  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KissCode' to its ABI tag value.
kissCodeToTag :: KissCode -> Word8
kissCodeToTag = fromIntegral . fromEnum

-- | Decode a 'KissCode' from its ABI tag value.
kissCodeFromTag :: Word8 -> Maybe KissCode
kissCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KissCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NtpError
-- ---------------------------------------------------------------------------

-- | NtpError type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NtpError
  = Ok  -- ^ Tag 0.
  | InvalidSlot  -- ^ Tag 1.
  | NotActive  -- ^ Tag 2.
  | InvalidPacket  -- ^ Tag 3.
  | KissOfDeath  -- ^ Tag 4.
  | StratumTooHigh  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NtpError' to its ABI tag value.
ntpErrorToTag :: NtpError -> Word8
ntpErrorToTag = fromIntegral . fromEnum

-- | Decode a 'NtpError' from its ABI tag value.
ntpErrorFromTag :: Word8 -> Maybe NtpError
ntpErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NtpError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
