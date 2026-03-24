-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Media Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Media
  (
    MediaContentType(..)
  , mediaContentTypeToTag
  , mediaContentTypeFromTag
  , Codec(..)
  , codecToTag
  , codecFromTag
  , isVideo
  , isAudio
  , StreamProtocol(..)
  , streamProtocolToTag
  , streamProtocolFromTag
  , TranscodeProfile(..)
  , transcodeProfileToTag
  , transcodeProfileFromTag
  , PlayerEvent(..)
  , playerEventToTag
  , playerEventFromTag
  , PlayerState(..)
  , playerStateToTag
  , playerStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MediaContentType
-- ---------------------------------------------------------------------------

-- | Media content types.
--
-- Tags 0-4 (5 constructors).
data MediaContentType
  = Audio  -- ^ Audio (tag 0).
  | Video  -- ^ Video (tag 1).
  | LiveStream  -- ^ LiveStream (tag 2).
  | Playlist  -- ^ Playlist (tag 3).
  | Subtitle  -- ^ Subtitle (tag 4).
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

-- | Media codecs.
--
-- Tags 0-7 (8 constructors).
data Codec
  = H264  -- ^ H264 (tag 0).
  | H265  -- ^ H265 (tag 1).
  | Av1  -- ^ AV1 (tag 2).
  | Vp9  -- ^ VP9 (tag 3).
  | Aac  -- ^ AAC (tag 4).
  | Opus  -- ^ Opus (tag 5).
  | Flac  -- ^ FLAC (tag 6).
  | Mp3  -- ^ MP3 (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Codec' to its ABI tag value.
codecToTag :: Codec -> Word8
codecToTag = fromIntegral . fromEnum

-- | Decode a 'Codec' from its ABI tag value.
codecFromTag :: Word8 -> Maybe Codec
codecFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Codec)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a video codec.
isVideo :: Codec -> Bool
isVideo H264 = True
isVideo H265 = True
isVideo Av1 = True
isVideo Vp9 = True
isVideo _ = False

-- | Whether this is an audio codec.
isAudio :: Codec -> Bool
isAudio Aac = True
isAudio Opus = True
isAudio Flac = True
isAudio Mp3 = True
isAudio _ = False

-- ---------------------------------------------------------------------------
-- StreamProtocol
-- ---------------------------------------------------------------------------

-- | Media streaming protocols.
--
-- Tags 0-5 (6 constructors).
data StreamProtocol
  = Hls  -- ^ HLS (tag 0).
  | Dash  -- ^ DASH (tag 1).
  | Rtmp  -- ^ RTMP (tag 2).
  | Rtsp  -- ^ RTSP (tag 3).
  | WebRtc  -- ^ WebRTC (tag 4).
  | Srt  -- ^ SRT (tag 5).
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

-- | Transcoding quality profiles.
--
-- Tags 0-4 (5 constructors).
data TranscodeProfile
  = Passthrough  -- ^ Passthrough (tag 0).
  | Low  -- ^ Low (tag 1).
  | Medium  -- ^ Medium (tag 2).
  | High  -- ^ High (tag 3).
  | Ultra  -- ^ Ultra (tag 4).
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

-- | Media player events.
--
-- Tags 0-7 (8 constructors).
data PlayerEvent
  = Play  -- ^ Play (tag 0).
  | Pause  -- ^ Pause (tag 1).
  | Seek  -- ^ Seek (tag 2).
  | Stop  -- ^ Stop (tag 3).
  | BufferStart  -- ^ BufferStart (tag 4).
  | BufferEnd  -- ^ BufferEnd (tag 5).
  | Error  -- ^ Error (tag 6).
  | QualityChange  -- ^ QualityChange (tag 7).
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

-- | Media player states.
--
-- Tags 0-4 (5 constructors).
data PlayerState
  = Idle  -- ^ Idle (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | Playing  -- ^ Playing (tag 2).
  | Paused  -- ^ Paused (tag 3).
  | Stopping  -- ^ Stopping (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PlayerState' to its ABI tag value.
playerStateToTag :: PlayerState -> Word8
playerStateToTag = fromIntegral . fromEnum

-- | Decode a 'PlayerState' from its ABI tag value.
playerStateFromTag :: Word8 -> Maybe PlayerState
playerStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PlayerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
