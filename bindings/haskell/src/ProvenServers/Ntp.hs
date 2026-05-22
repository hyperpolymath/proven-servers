-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NTP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ntp
  (
    ntpPort
  , LeapIndicator(..)
  , leapIndicatorToTag
  , leapIndicatorFromTag
  , isSynchronised
  , hasLeapSecond
  , NtpMode(..)
  , ntpModeToTag
  , ntpModeFromTag
  , isTimeSync
  , ExchangeState(..)
  , exchangeStateToTag
  , exchangeStateFromTag
  , exchangeStateCanTransitionTo
  , ClockDisciplineState(..)
  , clockDisciplineStateToTag
  , clockDisciplineStateFromTag
  , isHealthy
  , needsIntervention
  , KissCode(..)
  , kissCodeToTag
  , kissCodeFromTag
  , shouldStop
  , codeStr
  , NtpError(..)
  , ntpErrorToTag
  , ntpErrorFromTag
  , isOk
  , isRemoteError
  ) where

import Data.Word (Word16, Word8)

-- | Standard NTP port (RFC 5905).
ntpPort :: Word16
ntpPort = 123

-- ---------------------------------------------------------------------------
-- LeapIndicator
-- ---------------------------------------------------------------------------

-- | NTP leap second indicator (RFC 5905 Section 7.3).
--
-- Tags 0-3 (4 constructors).
data LeapIndicator
  = NoWarning  -- ^ No warning (tag 0).
  | LastMinute61  -- ^ Last minute of the day has 61 seconds (positive leap second) (tag 1).
  | LastMinute59  -- ^ Last minute of the day has 59 seconds (negative leap second) (tag 2).
  | Unsynchronised  -- ^ Clock not synchronised (alarm condition) (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LeapIndicator' to its ABI tag value.
leapIndicatorToTag :: LeapIndicator -> Word8
leapIndicatorToTag = fromIntegral . fromEnum

-- | Decode a 'LeapIndicator' from its ABI tag value.
leapIndicatorFromTag :: Word8 -> Maybe LeapIndicator
leapIndicatorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LeapIndicator)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the clock is considered synchronised.
isSynchronised :: LeapIndicator -> Bool
isSynchronised Unsynchronised = False
isSynchronised _ = True

-- | Whether a leap second adjustment is pending.
hasLeapSecond :: LeapIndicator -> Bool
hasLeapSecond LastMinute61 = True
hasLeapSecond LastMinute59 = True
hasLeapSecond _ = False

-- ---------------------------------------------------------------------------
-- NtpMode
-- ---------------------------------------------------------------------------

-- | NTP association mode (RFC 5905 Section 7.3, Mode field).
--
-- Tags 0-7 (8 constructors).
data NtpMode
  = Reserved  -- ^ Reserved (tag 0).
  | SymmetricActive  -- ^ Symmetric active (tag 1).
  | SymmetricPassive  -- ^ Symmetric passive (tag 2).
  | Client  -- ^ Client (tag 3).
  | Server  -- ^ Server (tag 4).
  | Broadcast  -- ^ Broadcast (tag 5).
  | ControlMessage  -- ^ NTP control message (tag 6).
  | Private  -- ^ Reserved for private use (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NtpMode' to its ABI tag value.
ntpModeToTag :: NtpMode -> Word8
ntpModeToTag = fromIntegral . fromEnum

-- | Decode a 'NtpMode' from its ABI tag value.
ntpModeFromTag :: Word8 -> Maybe NtpMode
ntpModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NtpMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | (as opposed to control or reserved).
isTimeSync :: NtpMode -> Bool
isTimeSync SymmetricActive = True
isTimeSync SymmetricPassive = True
isTimeSync Client = True
isTimeSync Server = True
isTimeSync Broadcast = True
isTimeSync _ = False

-- ---------------------------------------------------------------------------
-- ExchangeState
-- ---------------------------------------------------------------------------

-- | NTP request/response exchange state machine.
--
-- Tags 0-3 (4 constructors).
data ExchangeState
  = Idle  -- ^ Idle, awaiting next request (tag 0).
  | RequestReceived  -- ^ Client request received (tag 1).
  | TimestampCalculated  -- ^ Timestamps calculated for response (tag 2).
  | ResponseSent  -- ^ Response sent to client (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExchangeState' to its ABI tag value.
exchangeStateToTag :: ExchangeState -> Word8
exchangeStateToTag = fromIntegral . fromEnum

-- | Decode a 'ExchangeState' from its ABI tag value.
exchangeStateFromTag :: Word8 -> Maybe ExchangeState
exchangeStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExchangeState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
exchangeStateCanTransitionTo :: ExchangeState -> ExchangeState -> Bool
exchangeStateCanTransitionTo Idle RequestReceived = True
exchangeStateCanTransitionTo RequestReceived TimestampCalculated = True
exchangeStateCanTransitionTo TimestampCalculated ResponseSent = True
exchangeStateCanTransitionTo ResponseSent Idle = True
exchangeStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- ClockDisciplineState
-- ---------------------------------------------------------------------------

-- | Clock discipline algorithm states (RFC 5905 Section 12).
--
-- Tags 0-4 (5 constructors).
data ClockDisciplineState
  = Unset  -- ^ Clock has not been set (tag 0).
  | Spike  -- ^ Detected a clock spike (large offset) (tag 1).
  | Freq  -- ^ Frequency-only discipline mode (tag 2).
  | Sync  -- ^ Fully synchronised (phase + frequency locked) (tag 3).
  | Panic  -- ^ Panic condition — offset too large to correct (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ClockDisciplineState' to its ABI tag value.
clockDisciplineStateToTag :: ClockDisciplineState -> Word8
clockDisciplineStateToTag = fromIntegral . fromEnum

-- | Decode a 'ClockDisciplineState' from its ABI tag value.
clockDisciplineStateFromTag :: Word8 -> Maybe ClockDisciplineState
clockDisciplineStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ClockDisciplineState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the clock is in a healthy state.
isHealthy :: ClockDisciplineState -> Bool
isHealthy Freq = True
isHealthy Sync = True
isHealthy _ = False

-- | Whether the clock requires operator intervention.
needsIntervention :: ClockDisciplineState -> Bool
needsIntervention Panic = True
needsIntervention _ = False

-- ---------------------------------------------------------------------------
-- KissCode
-- ---------------------------------------------------------------------------

-- | NTP Kiss-o'-Death codes (RFC 5905 Section 7.4).
--
-- Tags 0-3 (4 constructors).
data KissCode
  = Deny  -- ^ Access denied (DENY) (tag 0).
  | Rstr  -- ^ Access restricted (RSTR) (tag 1).
  | Rate  -- ^ Rate exceeded (RATE) (tag 2).
  | Other  -- ^ Other/unknown kiss code (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KissCode' to its ABI tag value.
kissCodeToTag :: KissCode -> Word8
kissCodeToTag = fromIntegral . fromEnum

-- | Decode a 'KissCode' from its ABI tag value.
kissCodeFromTag :: Word8 -> Maybe KissCode
kissCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KissCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the client should stop querying this server.
shouldStop :: KissCode -> Bool
shouldStop Deny = True
shouldStop Rstr = True
shouldStop _ = False

-- | The 4-character ASCII kiss code string.
codeStr :: KissCode -> String
codeStr Deny = "DENY"
codeStr Rstr = "RSTR"
codeStr Rate = "RATE"
codeStr Other = "????"

-- ---------------------------------------------------------------------------
-- NtpError
-- ---------------------------------------------------------------------------

-- | NTP error codes.
--
-- Tags 0-5 (6 constructors).
data NtpError
  = Ok  -- ^ No error (tag 0).
  | InvalidSlot  -- ^ Invalid peer slot reference (tag 1).
  | NotActive  -- ^ Peer association not active (tag 2).
  | InvalidPacket  -- ^ Malformed NTP packet (tag 3).
  | KissOfDeath  -- ^ Received Kiss-o'-Death from server (tag 4).
  | StratumTooHigh  -- ^ Server stratum exceeds maximum (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NtpError' to its ABI tag value.
ntpErrorToTag :: NtpError -> Word8
ntpErrorToTag = fromIntegral . fromEnum

-- | Decode a 'NtpError' from its ABI tag value.
ntpErrorFromTag :: Word8 -> Maybe NtpError
ntpErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NtpError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this represents a successful outcome.
isOk :: NtpError -> Bool
isOk Ok = True
isOk _ = False

-- | Whether this error indicates a problem with the remote server.
isRemoteError :: NtpError -> Bool
isRemoteError KissOfDeath = True
isRemoteError StratumTooHigh = True
isRemoteError _ = False
