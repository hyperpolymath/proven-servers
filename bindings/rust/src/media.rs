// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Media Server types for the proven-servers ABI.
//!
//! Formally verified media streaming types.
//! Mirrors the Idris2 module `MediaABI.Types`.
//!
//! - `MediaContentType` -- Media content types.
//! - `Codec` -- Media codecs.
//! - `StreamProtocol` -- Media streaming protocols.
//! - `TranscodeProfile` -- Transcoding quality profiles.
//! - `PlayerEvent` -- Media player events.
//! - `PlayerState` -- Media player states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// MediaContentType (tags 0-4)
// ===========================================================================

/// Media content types.
///
/// Matches `MediaContentType` in `MediaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MediaContentType {
    /// Audio (tag 0).
    Audio = 0,
    /// Video (tag 1).
    Video = 1,
    /// LiveStream (tag 2).
    LiveStream = 2,
    /// Playlist (tag 3).
    Playlist = 3,
    /// Subtitle (tag 4).
    Subtitle = 4,
}

impl MediaContentType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Audio),
            1 => Some(Self::Video),
            2 => Some(Self::LiveStream),
            3 => Some(Self::Playlist),
            4 => Some(Self::Subtitle),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MediaContentType; 5] = [
        Self::Audio, Self::Video, Self::LiveStream, Self::Playlist, Self::Subtitle,
    ];
}

impl fmt::Display for MediaContentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Codec (tags 0-7)
// ===========================================================================

/// Media codecs.
///
/// Matches `Codec` in `MediaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Codec {
    /// H264 (tag 0).
    H264 = 0,
    /// H265 (tag 1).
    H265 = 1,
    /// AV1 (tag 2).
    Av1 = 2,
    /// VP9 (tag 3).
    Vp9 = 3,
    /// AAC (tag 4).
    Aac = 4,
    /// Opus (tag 5).
    Opus = 5,
    /// FLAC (tag 6).
    Flac = 6,
    /// MP3 (tag 7).
    Mp3 = 7,
}

impl Codec {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::H264),
            1 => Some(Self::H265),
            2 => Some(Self::Av1),
            3 => Some(Self::Vp9),
            4 => Some(Self::Aac),
            5 => Some(Self::Opus),
            6 => Some(Self::Flac),
            7 => Some(Self::Mp3),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a video codec.
    pub fn is_video(self) -> bool {
        matches!(self, Self::H264 | Self::H265 | Self::Av1 | Self::Vp9)
    }

    /// Whether this is an audio codec.
    pub fn is_audio(self) -> bool {
        matches!(self, Self::Aac | Self::Opus | Self::Flac | Self::Mp3)
    }

    /// All variants of this type.
    pub const ALL: [Codec; 8] = [
        Self::H264, Self::H265, Self::Av1, Self::Vp9, Self::Aac, Self::Opus, Self::Flac, Self::Mp3,
    ];
}

impl fmt::Display for Codec {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StreamProtocol (tags 0-5)
// ===========================================================================

/// Media streaming protocols.
///
/// Matches `StreamProtocol` in `MediaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StreamProtocol {
    /// HLS (tag 0).
    Hls = 0,
    /// DASH (tag 1).
    Dash = 1,
    /// RTMP (tag 2).
    Rtmp = 2,
    /// RTSP (tag 3).
    Rtsp = 3,
    /// WebRTC (tag 4).
    WebRtc = 4,
    /// SRT (tag 5).
    Srt = 5,
}

impl StreamProtocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Hls),
            1 => Some(Self::Dash),
            2 => Some(Self::Rtmp),
            3 => Some(Self::Rtsp),
            4 => Some(Self::WebRtc),
            5 => Some(Self::Srt),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [StreamProtocol; 6] = [
        Self::Hls, Self::Dash, Self::Rtmp, Self::Rtsp, Self::WebRtc, Self::Srt,
    ];
}

impl fmt::Display for StreamProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TranscodeProfile (tags 0-4)
// ===========================================================================

/// Transcoding quality profiles.
///
/// Matches `TranscodeProfile` in `MediaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TranscodeProfile {
    /// Passthrough (tag 0).
    Passthrough = 0,
    /// Low (tag 1).
    Low = 1,
    /// Medium (tag 2).
    Medium = 2,
    /// High (tag 3).
    High = 3,
    /// Ultra (tag 4).
    Ultra = 4,
}

impl TranscodeProfile {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Passthrough),
            1 => Some(Self::Low),
            2 => Some(Self::Medium),
            3 => Some(Self::High),
            4 => Some(Self::Ultra),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TranscodeProfile; 5] = [
        Self::Passthrough, Self::Low, Self::Medium, Self::High, Self::Ultra,
    ];
}

impl fmt::Display for TranscodeProfile {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PlayerEvent (tags 0-7)
// ===========================================================================

/// Media player events.
///
/// Matches `PlayerEvent` in `MediaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PlayerEvent {
    /// Play (tag 0).
    Play = 0,
    /// Pause (tag 1).
    Pause = 1,
    /// Seek (tag 2).
    Seek = 2,
    /// Stop (tag 3).
    Stop = 3,
    /// BufferStart (tag 4).
    BufferStart = 4,
    /// BufferEnd (tag 5).
    BufferEnd = 5,
    /// Error (tag 6).
    Error = 6,
    /// QualityChange (tag 7).
    QualityChange = 7,
}

impl PlayerEvent {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Play),
            1 => Some(Self::Pause),
            2 => Some(Self::Seek),
            3 => Some(Self::Stop),
            4 => Some(Self::BufferStart),
            5 => Some(Self::BufferEnd),
            6 => Some(Self::Error),
            7 => Some(Self::QualityChange),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PlayerEvent; 8] = [
        Self::Play, Self::Pause, Self::Seek, Self::Stop, Self::BufferStart, Self::BufferEnd, Self::Error, Self::QualityChange,
    ];
}

impl fmt::Display for PlayerEvent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PlayerState (tags 0-4)
// ===========================================================================

/// Media player states.
///
/// Matches `PlayerState` in `MediaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PlayerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// Playing (tag 2).
    Playing = 2,
    /// Paused (tag 3).
    Paused = 3,
    /// Stopping (tag 4).
    Stopping = 4,
}

impl PlayerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Ready),
            2 => Some(Self::Playing),
            3 => Some(Self::Paused),
            4 => Some(Self::Stopping),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PlayerState; 5] = [
        Self::Idle, Self::Ready, Self::Playing, Self::Paused, Self::Stopping,
    ];
}

impl fmt::Display for PlayerState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn media_content_type_roundtrip() {
        for v in MediaContentType::ALL {
            let tag = v.to_tag();
            let decoded = MediaContentType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MediaContentType::from_tag(5).is_none());
    }

    #[test]
    fn codec_roundtrip() {
        for v in Codec::ALL {
            let tag = v.to_tag();
            let decoded = Codec::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Codec::from_tag(8).is_none());
    }

    #[test]
    fn stream_protocol_roundtrip() {
        for v in StreamProtocol::ALL {
            let tag = v.to_tag();
            let decoded = StreamProtocol::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(StreamProtocol::from_tag(6).is_none());
    }

    #[test]
    fn transcode_profile_roundtrip() {
        for v in TranscodeProfile::ALL {
            let tag = v.to_tag();
            let decoded = TranscodeProfile::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TranscodeProfile::from_tag(5).is_none());
    }

    #[test]
    fn player_event_roundtrip() {
        for v in PlayerEvent::ALL {
            let tag = v.to_tag();
            let decoded = PlayerEvent::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PlayerEvent::from_tag(8).is_none());
    }

    #[test]
    fn player_state_roundtrip() {
        for v in PlayerState::ALL {
            let tag = v.to_tag();
            let decoded = PlayerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PlayerState::from_tag(5).is_none());
    }

}
