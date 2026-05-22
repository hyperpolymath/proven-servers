// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module MediaABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// MediaContentType (tags 0-4)
// ===========================================================================

/// Media content types.
type mediaContentType =
  | @as(0) Audio
  | @as(1) Video
  | @as(2) LiveStream
  | @as(3) Playlist
  | @as(4) Subtitle

/// Decode from the C-ABI tag value.
let mediaContentTypeFromTag = (tag: int): option<mediaContentType> =>
  switch tag {
  | 0 => Some(Audio)
  | 1 => Some(Video)
  | 2 => Some(LiveStream)
  | 3 => Some(Playlist)
  | 4 => Some(Subtitle)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mediaContentTypeToTag = (v: mediaContentType): int =>
  switch v {
  | Audio => 0
  | Video => 1
  | LiveStream => 2
  | Playlist => 3
  | Subtitle => 4
  }

// ===========================================================================
// Codec (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type codec =
  | @as(0) H264
  | @as(1) H265
  | @as(2) Av1
  | @as(3) Vp9
  | @as(4) Aac
  | @as(5) Opus
  | @as(6) Flac
  | @as(7) Mp3

/// Decode from the C-ABI tag value.
let codecFromTag = (tag: int): option<codec> =>
  switch tag {
  | 0 => Some(H264)
  | 1 => Some(H265)
  | 2 => Some(Av1)
  | 3 => Some(Vp9)
  | 4 => Some(Aac)
  | 5 => Some(Opus)
  | 6 => Some(Flac)
  | 7 => Some(Mp3)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let codecToTag = (v: codec): int =>
  switch v {
  | H264 => 0
  | H265 => 1
  | Av1 => 2
  | Vp9 => 3
  | Aac => 4
  | Opus => 5
  | Flac => 6
  | Mp3 => 7
  }

/// Whether this is a video codec.
let codecIsVideo = (v: codec): bool =>
  switch v {
  | H264 | H265 | Av1 | Vp9 => true
  | _ => false
  }

/// Whether this is an audio codec.
let codecIsAudio = (v: codec): bool =>
  switch v {
  | Aac | Opus | Flac | Mp3 => true
  | _ => false
  }

// ===========================================================================
// StreamProtocol (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type streamProtocol =
  | @as(0) Hls
  | @as(1) Dash
  | @as(2) Rtmp
  | @as(3) Rtsp
  | @as(4) WebRtc
  | @as(5) Srt

/// Decode from the C-ABI tag value.
let streamProtocolFromTag = (tag: int): option<streamProtocol> =>
  switch tag {
  | 0 => Some(Hls)
  | 1 => Some(Dash)
  | 2 => Some(Rtmp)
  | 3 => Some(Rtsp)
  | 4 => Some(WebRtc)
  | 5 => Some(Srt)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let streamProtocolToTag = (v: streamProtocol): int =>
  switch v {
  | Hls => 0
  | Dash => 1
  | Rtmp => 2
  | Rtsp => 3
  | WebRtc => 4
  | Srt => 5
  }

// ===========================================================================
// TranscodeProfile (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type transcodeProfile =
  | @as(0) Passthrough
  | @as(1) Low
  | @as(2) Medium
  | @as(3) High
  | @as(4) Ultra

/// Decode from the C-ABI tag value.
let transcodeProfileFromTag = (tag: int): option<transcodeProfile> =>
  switch tag {
  | 0 => Some(Passthrough)
  | 1 => Some(Low)
  | 2 => Some(Medium)
  | 3 => Some(High)
  | 4 => Some(Ultra)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transcodeProfileToTag = (v: transcodeProfile): int =>
  switch v {
  | Passthrough => 0
  | Low => 1
  | Medium => 2
  | High => 3
  | Ultra => 4
  }

// ===========================================================================
// PlayerEvent (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type playerEvent =
  | @as(0) Play
  | @as(1) Pause
  | @as(2) Seek
  | @as(3) Stop
  | @as(4) BufferStart
  | @as(5) BufferEnd
  | @as(6) Error
  | @as(7) QualityChange

/// Decode from the C-ABI tag value.
let playerEventFromTag = (tag: int): option<playerEvent> =>
  switch tag {
  | 0 => Some(Play)
  | 1 => Some(Pause)
  | 2 => Some(Seek)
  | 3 => Some(Stop)
  | 4 => Some(BufferStart)
  | 5 => Some(BufferEnd)
  | 6 => Some(Error)
  | 7 => Some(QualityChange)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let playerEventToTag = (v: playerEvent): int =>
  switch v {
  | Play => 0
  | Pause => 1
  | Seek => 2
  | Stop => 3
  | BufferStart => 4
  | BufferEnd => 5
  | Error => 6
  | QualityChange => 7
  }

// ===========================================================================
// PlayerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type playerState =
  | @as(0) Idle
  | @as(1) Ready
  | @as(2) Playing
  | @as(3) Paused
  | @as(4) Stopping

/// Decode from the C-ABI tag value.
let playerStateFromTag = (tag: int): option<playerState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Ready)
  | 2 => Some(Playing)
  | 3 => Some(Paused)
  | 4 => Some(Stopping)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let playerStateToTag = (v: playerState): int =>
  switch v {
  | Idle => 0
  | Ready => 1
  | Playing => 2
  | Paused => 3
  | Stopping => 4
  }

