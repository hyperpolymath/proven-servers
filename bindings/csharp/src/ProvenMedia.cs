// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media protocol types for proven-servers.

namespace Proven;

/// <summary>MediaContentType matching the Idris2 ABI tags (0-4).</summary>
public enum MediaContentType : byte
{
    Audio = 0,
    Video = 1,
    LiveStream = 2,
    Playlist = 3,
    Subtitle = 4
}

/// <summary>Codec matching the Idris2 ABI tags (0-7).</summary>
public enum Codec : byte
{
    H264 = 0,
    H265 = 1,
    Av1 = 2,
    Vp9 = 3,
    Aac = 4,
    Opus = 5,
    Flac = 6,
    Mp3 = 7
}

/// <summary>StreamProtocol matching the Idris2 ABI tags (0-5).</summary>
public enum StreamProtocol : byte
{
    Hls = 0,
    Dash = 1,
    Rtmp = 2,
    Rtsp = 3,
    WebRtc = 4,
    Srt = 5
}

/// <summary>TranscodeProfile matching the Idris2 ABI tags (0-4).</summary>
public enum TranscodeProfile : byte
{
    Passthrough = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Ultra = 4
}

/// <summary>PlayerEvent matching the Idris2 ABI tags (0-7).</summary>
public enum PlayerEvent : byte
{
    Play = 0,
    Pause = 1,
    Seek = 2,
    Stop = 3,
    BufferStart = 4,
    BufferEnd = 5,
    Error = 6,
    QualityChange = 7
}

/// <summary>PlayerState matching the Idris2 ABI tags (0-4).</summary>
public enum PlayerState : byte
{
    Idle = 0,
    Ready = 1,
    Playing = 2,
    Paused = 3,
    Stopping = 4
}
