-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | RTSP protocol types for proven-servers.
--
-- RTSP (Real Time Streaming Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Rtsp
  ( -- * ADT types matching Idris2 ABI
      Method(..)
    , TransportProtocol(..)
    , SessionState(..)
    , StatusCode(..)
    , RtspError(..)
    , methodToTag
    , methodFromTag
    , transportProtocolToTag
    , transportProtocolFromTag
    , sessionStateToTag
    , sessionStateFromTag
    , statusCodeToTag
    , statusCodeFromTag
    , rtspErrorToTag
    , rtspErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Method type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data Method
  = Describe  -- ^ Tag 0.
  | Setup  -- ^ Tag 1.
  | Play  -- ^ Tag 2.
  | Pause  -- ^ Tag 3.
  | Teardown  -- ^ Tag 4.
  | GetParameter  -- ^ Tag 5.
  | SetParameter  -- ^ Tag 6.
  | Options  -- ^ Tag 7.
  | Announce  -- ^ Tag 8.
  | Record  -- ^ Tag 9.
  | Redirect  -- ^ Tag 10.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransportProtocol
-- ---------------------------------------------------------------------------

-- | TransportProtocol type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data TransportProtocol
  = RtpAvpUdp  -- ^ Tag 0.
  | RtpAvpTcp  -- ^ Tag 1.
  | RtpAvpUdpMulticast  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransportProtocol' to its ABI tag value.
transportProtocolToTag :: TransportProtocol -> Word8
transportProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'TransportProtocol' from its ABI tag value.
transportProtocolFromTag :: Word8 -> Maybe TransportProtocol
transportProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransportProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data SessionState
  = Init  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | Playing  -- ^ Tag 2.
  | Recording  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | StatusCode type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data StatusCode
  = StatusCode_Ok  -- ^ Tag 0.
  | MovedPermanently  -- ^ Tag 1.
  | MovedTemporarily  -- ^ Tag 2.
  | BadRequest  -- ^ Tag 3.
  | Unauthorized  -- ^ Tag 4.
  | NotFound  -- ^ Tag 5.
  | StatusCode_MethodNotAllowed  -- ^ Tag 6.
  | NotAcceptable  -- ^ Tag 7.
  | SessionNotFound  -- ^ Tag 8.
  | InternalServerError  -- ^ Tag 9.
  | NotImplemented  -- ^ Tag 10.
  | ServiceUnavailable  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RtspError
-- ---------------------------------------------------------------------------

-- | RtspError type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data RtspError
  = RtspError_Ok  -- ^ Tag 0.
  | InvalidSlot  -- ^ Tag 1.
  | NotActive  -- ^ Tag 2.
  | InvalidTransition  -- ^ Tag 3.
  | RtspError_MethodNotAllowed  -- ^ Tag 4.
  | TransportError  -- ^ Tag 5.
  | SessionExpired  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RtspError' to its ABI tag value.
rtspErrorToTag :: RtspError -> Word8
rtspErrorToTag = fromIntegral . fromEnum

-- | Decode a 'RtspError' from its ABI tag value.
rtspErrorFromTag :: Word8 -> Maybe RtspError
rtspErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RtspError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
