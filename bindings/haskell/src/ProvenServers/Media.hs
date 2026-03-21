-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Media protocol types for proven-servers.
--
-- Media streaming server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Media
  ( -- * ADT types matching Idris2 ABI
      MediaContentType(..)
    , Codec(..)
    , StreamProtocol(..)
    , TranscodeProfile(..)
    , PlayerEvent(..)
    , PlayerState(..)
    , mediaContentTypeToTag
    , mediaContentTypeFromTag
    , codecToTag
    , codecFromTag
    , streamProtocolToTag
    , streamProtocolFromTag
    , transcodeProfileToTag
    , transcodeProfileFromTag
    , playerEventToTag
    , playerEventFromTag
    , playerStateToTag
    , playerStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MediaContentType
-- ---------------------------------------------------------------------------

-- | MediaContentType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data MediaContentType
  = Audio  -- ^ Tag 0.
  | Video  -- ^ Tag 1.
  | LiveStream  -- ^ Tag 2.
  | Playlist  -- ^ Tag 3.
  | Subtitle  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MediaContentType' to its ABI tag value.
mediaContentTypeToTag :: MediaContentType -> Word8
mediaContentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MediaContentType' from its ABI tag value.
mediaContentTypeFromTag :: Word8 -> Maybe MediaContentType
mediaContentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MediaContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Codec
-- ---------------------------------------------------------------------------

-- | Codec type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data Codec
  = H264  -- ^ Tag 0.
  | H265  -- ^ Tag 1.
  | Av1  -- ^ Tag 2.
  | Vp9  -- ^ Tag 3.
  | Aac  -- ^ Tag 4.
  | Opus  -- ^ Tag 5.
  | Flac  -- ^ Tag 6.
  | Mp3  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Codec' to its ABI tag value.
codecToTag :: Codec -> Word8
codecToTag = fromIntegral . fromEnum

-- | Decode a 'Codec' from its ABI tag value.
codecFromTag :: Word8 -> Maybe Codec
codecFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Codec)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StreamProtocol
-- ---------------------------------------------------------------------------

-- | StreamProtocol type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data StreamProtocol
  = Hls  -- ^ Tag 0.
  | Dash  -- ^ Tag 1.
  | Rtmp  -- ^ Tag 2.
  | Rtsp  -- ^ Tag 3.
  | WebRtc  -- ^ Tag 4.
  | Srt  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamProtocol' to its ABI tag value.
streamProtocolToTag :: StreamProtocol -> Word8
streamProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'StreamProtocol' from its ABI tag value.
streamProtocolFromTag :: Word8 -> Maybe StreamProtocol
streamProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TranscodeProfile
-- ---------------------------------------------------------------------------

-- | TranscodeProfile type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data TranscodeProfile
  = Passthrough  -- ^ Tag 0.
  | Low  -- ^ Tag 1.
  | Medium  -- ^ Tag 2.
  | High  -- ^ Tag 3.
  | Ultra  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TranscodeProfile' to its ABI tag value.
transcodeProfileToTag :: TranscodeProfile -> Word8
transcodeProfileToTag = fromIntegral . fromEnum

-- | Decode a 'TranscodeProfile' from its ABI tag value.
transcodeProfileFromTag :: Word8 -> Maybe TranscodeProfile
transcodeProfileFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TranscodeProfile)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PlayerEvent
-- ---------------------------------------------------------------------------

-- | PlayerEvent type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data PlayerEvent
  = Play  -- ^ Tag 0.
  | Pause  -- ^ Tag 1.
  | Seek  -- ^ Tag 2.
  | Stop  -- ^ Tag 3.
  | BufferStart  -- ^ Tag 4.
  | BufferEnd  -- ^ Tag 5.
  | Error  -- ^ Tag 6.
  | QualityChange  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PlayerEvent' to its ABI tag value.
playerEventToTag :: PlayerEvent -> Word8
playerEventToTag = fromIntegral . fromEnum

-- | Decode a 'PlayerEvent' from its ABI tag value.
playerEventFromTag :: Word8 -> Maybe PlayerEvent
playerEventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PlayerEvent)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PlayerState
-- ---------------------------------------------------------------------------

-- | PlayerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data PlayerState
  = Idle  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | Playing  -- ^ Tag 2.
  | Paused  -- ^ Tag 3.
  | Stopping  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PlayerState' to its ABI tag value.
playerStateToTag :: PlayerState -> Word8
playerStateToTag = fromIntegral . fromEnum

-- | Decode a 'PlayerState' from its ABI tag value.
playerStateFromTag :: Word8 -> Maybe PlayerState
playerStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PlayerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
