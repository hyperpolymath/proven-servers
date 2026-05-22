//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Media Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `MediaABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// MediaContentType
// ===========================================================================

/// Media content types.
/// 
/// Matches `MediaContentType` in `MediaABI.Types`.
pub type MediaContentType {
  /// Audio (tag 0).
  Audio
  /// Video (tag 1).
  Video
  /// LiveStream (tag 2).
  LiveStream
  /// Playlist (tag 3).
  Playlist
  /// Subtitle (tag 4).
  Subtitle
}

/// Convert a `MediaContentType` to its C-ABI tag value.
pub fn media_content_type_to_int(value: MediaContentType) -> Int {
  case value {
    Audio -> 0
    Video -> 1
    LiveStream -> 2
    Playlist -> 3
    Subtitle -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn media_content_type_from_int(tag: Int) -> Result(MediaContentType, Nil) {
  case tag {
    0 -> Ok(Audio)
    1 -> Ok(Video)
    2 -> Ok(LiveStream)
    3 -> Ok(Playlist)
    4 -> Ok(Subtitle)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Codec
// ===========================================================================

/// Media codecs.
/// 
/// Matches `Codec` in `MediaABI.Types`.
pub type Codec {
  /// H264 (tag 0).
  H264
  /// H265 (tag 1).
  H265
  /// AV1 (tag 2).
  Av1
  /// VP9 (tag 3).
  Vp9
  /// AAC (tag 4).
  Aac
  /// Opus (tag 5).
  Opus
  /// FLAC (tag 6).
  Flac
  /// MP3 (tag 7).
  Mp3
}

/// Convert a `Codec` to its C-ABI tag value.
pub fn codec_to_int(value: Codec) -> Int {
  case value {
    H264 -> 0
    H265 -> 1
    Av1 -> 2
    Vp9 -> 3
    Aac -> 4
    Opus -> 5
    Flac -> 6
    Mp3 -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn codec_from_int(tag: Int) -> Result(Codec, Nil) {
  case tag {
    0 -> Ok(H264)
    1 -> Ok(H265)
    2 -> Ok(Av1)
    3 -> Ok(Vp9)
    4 -> Ok(Aac)
    5 -> Ok(Opus)
    6 -> Ok(Flac)
    7 -> Ok(Mp3)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StreamProtocol
// ===========================================================================

/// Media streaming protocols.
/// 
/// Matches `StreamProtocol` in `MediaABI.Types`.
pub type StreamProtocol {
  /// HLS (tag 0).
  Hls
  /// DASH (tag 1).
  Dash
  /// RTMP (tag 2).
  Rtmp
  /// RTSP (tag 3).
  Rtsp
  /// WebRTC (tag 4).
  WebRtc
  /// SRT (tag 5).
  Srt
}

/// Convert a `StreamProtocol` to its C-ABI tag value.
pub fn stream_protocol_to_int(value: StreamProtocol) -> Int {
  case value {
    Hls -> 0
    Dash -> 1
    Rtmp -> 2
    Rtsp -> 3
    WebRtc -> 4
    Srt -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn stream_protocol_from_int(tag: Int) -> Result(StreamProtocol, Nil) {
  case tag {
    0 -> Ok(Hls)
    1 -> Ok(Dash)
    2 -> Ok(Rtmp)
    3 -> Ok(Rtsp)
    4 -> Ok(WebRtc)
    5 -> Ok(Srt)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TranscodeProfile
// ===========================================================================

/// Transcoding quality profiles.
/// 
/// Matches `TranscodeProfile` in `MediaABI.Types`.
pub type TranscodeProfile {
  /// Passthrough (tag 0).
  Passthrough
  /// Low (tag 1).
  Low
  /// Medium (tag 2).
  Medium
  /// High (tag 3).
  High
  /// Ultra (tag 4).
  Ultra
}

/// Convert a `TranscodeProfile` to its C-ABI tag value.
pub fn transcode_profile_to_int(value: TranscodeProfile) -> Int {
  case value {
    Passthrough -> 0
    Low -> 1
    Medium -> 2
    High -> 3
    Ultra -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn transcode_profile_from_int(tag: Int) -> Result(TranscodeProfile, Nil) {
  case tag {
    0 -> Ok(Passthrough)
    1 -> Ok(Low)
    2 -> Ok(Medium)
    3 -> Ok(High)
    4 -> Ok(Ultra)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PlayerEvent
// ===========================================================================

/// Media player events.
/// 
/// Matches `PlayerEvent` in `MediaABI.Types`.
pub type PlayerEvent {
  /// Play (tag 0).
  Play
  /// Pause (tag 1).
  Pause
  /// Seek (tag 2).
  Seek
  /// Stop (tag 3).
  Stop
  /// BufferStart (tag 4).
  BufferStart
  /// BufferEnd (tag 5).
  BufferEnd
  /// Error (tag 6).
  PlayerEventError
  /// QualityChange (tag 7).
  QualityChange
}

/// Convert a `PlayerEvent` to its C-ABI tag value.
pub fn player_event_to_int(value: PlayerEvent) -> Int {
  case value {
    Play -> 0
    Pause -> 1
    Seek -> 2
    Stop -> 3
    BufferStart -> 4
    BufferEnd -> 5
    PlayerEventError -> 6
    QualityChange -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn player_event_from_int(tag: Int) -> Result(PlayerEvent, Nil) {
  case tag {
    0 -> Ok(Play)
    1 -> Ok(Pause)
    2 -> Ok(Seek)
    3 -> Ok(Stop)
    4 -> Ok(BufferStart)
    5 -> Ok(BufferEnd)
    6 -> Ok(PlayerEventError)
    7 -> Ok(QualityChange)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PlayerState
// ===========================================================================

/// Media player states.
/// 
/// Matches `PlayerState` in `MediaABI.Types`.
pub type PlayerState {
  /// Idle (tag 0).
  Idle
  /// Ready (tag 1).
  Ready
  /// Playing (tag 2).
  Playing
  /// Paused (tag 3).
  Paused
  /// Stopping (tag 4).
  Stopping
}

/// Convert a `PlayerState` to its C-ABI tag value.
pub fn player_state_to_int(value: PlayerState) -> Int {
  case value {
    Idle -> 0
    Ready -> 1
    Playing -> 2
    Paused -> 3
    Stopping -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn player_state_from_int(tag: Int) -> Result(PlayerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Ready)
    2 -> Ok(Playing)
    3 -> Ok(Paused)
    4 -> Ok(Stopping)
    _ -> Error(Nil)
  }
}

