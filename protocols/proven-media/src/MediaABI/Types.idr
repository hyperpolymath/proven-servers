-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- MediaABI.Types: C-ABI-compatible numeric representations of Media types.
--
-- Maps every constructor of the core Media sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/media.zig)
-- exactly.
--
-- Types covered:
--   MediaType        (5 constructors, tags 0-4)
--   Codec            (8 constructors, tags 0-7)
--   StreamProtocol   (6 constructors, tags 0-5)
--   TranscodeProfile (5 constructors, tags 0-4)
--   PlayerEvent      (8 constructors, tags 0-7)
--   PlayerState      (5 constructors, tags 0-4)

module MediaABI.Types

import Media.Types

%default total

---------------------------------------------------------------------------
-- MediaType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
mediaTypeToTag : MediaType -> Bits8
mediaTypeToTag Audio      = 0
mediaTypeToTag Video      = 1
mediaTypeToTag LiveStream = 2
mediaTypeToTag Playlist   = 3
mediaTypeToTag Subtitle   = 4

public export
tagToMediaType : Bits8 -> Maybe MediaType
tagToMediaType 0 = Just Audio
tagToMediaType 1 = Just Video
tagToMediaType 2 = Just LiveStream
tagToMediaType 3 = Just Playlist
tagToMediaType 4 = Just Subtitle
tagToMediaType _ = Nothing

public export
mediaTypeRoundtrip : (m : MediaType) -> tagToMediaType (mediaTypeToTag m) = Just m
mediaTypeRoundtrip Audio      = Refl
mediaTypeRoundtrip Video      = Refl
mediaTypeRoundtrip LiveStream = Refl
mediaTypeRoundtrip Playlist   = Refl
mediaTypeRoundtrip Subtitle   = Refl

---------------------------------------------------------------------------
-- Codec (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
codecToTag : Codec -> Bits8
codecToTag H264 = 0
codecToTag H265 = 1
codecToTag AV1  = 2
codecToTag VP9  = 3
codecToTag AAC  = 4
codecToTag Opus = 5
codecToTag FLAC = 6
codecToTag MP3  = 7

public export
tagToCodec : Bits8 -> Maybe Codec
tagToCodec 0 = Just H264
tagToCodec 1 = Just H265
tagToCodec 2 = Just AV1
tagToCodec 3 = Just VP9
tagToCodec 4 = Just AAC
tagToCodec 5 = Just Opus
tagToCodec 6 = Just FLAC
tagToCodec 7 = Just MP3
tagToCodec _ = Nothing

public export
codecRoundtrip : (c : Codec) -> tagToCodec (codecToTag c) = Just c
codecRoundtrip H264 = Refl
codecRoundtrip H265 = Refl
codecRoundtrip AV1  = Refl
codecRoundtrip VP9  = Refl
codecRoundtrip AAC  = Refl
codecRoundtrip Opus = Refl
codecRoundtrip FLAC = Refl
codecRoundtrip MP3  = Refl

---------------------------------------------------------------------------
-- StreamProtocol (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
streamProtocolToTag : StreamProtocol -> Bits8
streamProtocolToTag HLS    = 0
streamProtocolToTag DASH   = 1
streamProtocolToTag RTMP   = 2
streamProtocolToTag RTSP   = 3
streamProtocolToTag WebRTC = 4
streamProtocolToTag SRT    = 5

public export
tagToStreamProtocol : Bits8 -> Maybe StreamProtocol
tagToStreamProtocol 0 = Just HLS
tagToStreamProtocol 1 = Just DASH
tagToStreamProtocol 2 = Just RTMP
tagToStreamProtocol 3 = Just RTSP
tagToStreamProtocol 4 = Just WebRTC
tagToStreamProtocol 5 = Just SRT
tagToStreamProtocol _ = Nothing

public export
streamProtocolRoundtrip : (s : StreamProtocol) -> tagToStreamProtocol (streamProtocolToTag s) = Just s
streamProtocolRoundtrip HLS    = Refl
streamProtocolRoundtrip DASH   = Refl
streamProtocolRoundtrip RTMP   = Refl
streamProtocolRoundtrip RTSP   = Refl
streamProtocolRoundtrip WebRTC = Refl
streamProtocolRoundtrip SRT    = Refl

---------------------------------------------------------------------------
-- TranscodeProfile (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
transcodeProfileToTag : TranscodeProfile -> Bits8
transcodeProfileToTag Passthrough = 0
transcodeProfileToTag Low         = 1
transcodeProfileToTag Medium      = 2
transcodeProfileToTag High        = 3
transcodeProfileToTag Ultra       = 4

public export
tagToTranscodeProfile : Bits8 -> Maybe TranscodeProfile
tagToTranscodeProfile 0 = Just Passthrough
tagToTranscodeProfile 1 = Just Low
tagToTranscodeProfile 2 = Just Medium
tagToTranscodeProfile 3 = Just High
tagToTranscodeProfile 4 = Just Ultra
tagToTranscodeProfile _ = Nothing

public export
transcodeProfileRoundtrip : (t : TranscodeProfile) -> tagToTranscodeProfile (transcodeProfileToTag t) = Just t
transcodeProfileRoundtrip Passthrough = Refl
transcodeProfileRoundtrip Low         = Refl
transcodeProfileRoundtrip Medium      = Refl
transcodeProfileRoundtrip High        = Refl
transcodeProfileRoundtrip Ultra       = Refl

---------------------------------------------------------------------------
-- PlayerEvent (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
playerEventToTag : PlayerEvent -> Bits8
playerEventToTag Play          = 0
playerEventToTag Pause         = 1
playerEventToTag Seek          = 2
playerEventToTag Stop          = 3
playerEventToTag BufferStart   = 4
playerEventToTag BufferEnd     = 5
playerEventToTag Error         = 6
playerEventToTag QualityChange = 7

public export
tagToPlayerEvent : Bits8 -> Maybe PlayerEvent
tagToPlayerEvent 0 = Just Play
tagToPlayerEvent 1 = Just Pause
tagToPlayerEvent 2 = Just Seek
tagToPlayerEvent 3 = Just Stop
tagToPlayerEvent 4 = Just BufferStart
tagToPlayerEvent 5 = Just BufferEnd
tagToPlayerEvent 6 = Just Error
tagToPlayerEvent 7 = Just QualityChange
tagToPlayerEvent _ = Nothing

public export
playerEventRoundtrip : (e : PlayerEvent) -> tagToPlayerEvent (playerEventToTag e) = Just e
playerEventRoundtrip Play          = Refl
playerEventRoundtrip Pause         = Refl
playerEventRoundtrip Seek          = Refl
playerEventRoundtrip Stop          = Refl
playerEventRoundtrip BufferStart   = Refl
playerEventRoundtrip BufferEnd     = Refl
playerEventRoundtrip Error         = Refl
playerEventRoundtrip QualityChange = Refl

---------------------------------------------------------------------------
-- PlayerState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| Media player session lifecycle states.
||| Used by the FFI layer for the C ABI.
public export
data PlayerState : Type where
  ||| No stream loaded. Initial and terminal state.
  PSIdle       : PlayerState
  ||| Stream loaded, ready to play.
  PSReady      : PlayerState
  ||| Actively playing media.
  PSPlaying    : PlayerState
  ||| Playback paused.
  PSPaused     : PlayerState
  ||| Session shutting down, releasing resources.
  PSStopping   : PlayerState

public export
Eq PlayerState where
  PSIdle     == PSIdle     = True
  PSReady    == PSReady    = True
  PSPlaying  == PSPlaying  = True
  PSPaused   == PSPaused   = True
  PSStopping == PSStopping = True
  _          == _          = False

public export
Show PlayerState where
  show PSIdle     = "Idle"
  show PSReady    = "Ready"
  show PSPlaying  = "Playing"
  show PSPaused   = "Paused"
  show PSStopping = "Stopping"

public export
playerStateToTag : PlayerState -> Bits8
playerStateToTag PSIdle     = 0
playerStateToTag PSReady    = 1
playerStateToTag PSPlaying  = 2
playerStateToTag PSPaused   = 3
playerStateToTag PSStopping = 4

public export
tagToPlayerState : Bits8 -> Maybe PlayerState
tagToPlayerState 0 = Just PSIdle
tagToPlayerState 1 = Just PSReady
tagToPlayerState 2 = Just PSPlaying
tagToPlayerState 3 = Just PSPaused
tagToPlayerState 4 = Just PSStopping
tagToPlayerState _ = Nothing

public export
playerStateRoundtrip : (s : PlayerState) -> tagToPlayerState (playerStateToTag s) = Just s
playerStateRoundtrip PSIdle     = Refl
playerStateRoundtrip PSReady    = Refl
playerStateRoundtrip PSPlaying  = Refl
playerStateRoundtrip PSPaused   = Refl
playerStateRoundtrip PSStopping = Refl
