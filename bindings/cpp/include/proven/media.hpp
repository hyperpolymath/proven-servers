// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file media.hpp
/// @brief Media protocol types for proven-servers.

#ifndef PROVEN_MEDIA_HPP
#define PROVEN_MEDIA_HPP

#include <cstdint>

namespace proven {

/// @brief MediaContentType matching the Idris2 ABI tags.
enum class MediaContentType : uint8_t {
    Audio = 0,
    Video = 1,
    LiveStream = 2,
    Playlist = 3,
    Subtitle = 4
};

/// @brief Codec matching the Idris2 ABI tags.
enum class Codec : uint8_t {
    H264 = 0,
    H265 = 1,
    Av1 = 2,
    Vp9 = 3,
    Aac = 4,
    Opus = 5,
    Flac = 6,
    Mp3 = 7
};

/// @brief StreamProtocol matching the Idris2 ABI tags.
enum class StreamProtocol : uint8_t {
    Hls = 0,
    Dash = 1,
    Rtmp = 2,
    Rtsp = 3,
    WebRtc = 4,
    Srt = 5
};

/// @brief TranscodeProfile matching the Idris2 ABI tags.
enum class TranscodeProfile : uint8_t {
    Passthrough = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Ultra = 4
};

/// @brief PlayerEvent matching the Idris2 ABI tags.
enum class PlayerEvent : uint8_t {
    Play = 0,
    Pause = 1,
    Seek = 2,
    Stop = 3,
    BufferStart = 4,
    BufferEnd = 5,
    Error = 6,
    QualityChange = 7
};

/// @brief PlayerState matching the Idris2 ABI tags.
enum class PlayerState : uint8_t {
    Idle = 0,
    Ready = 1,
    Playing = 2,
    Paused = 3,
    Stopping = 4
};

} // namespace proven

#endif // PROVEN_MEDIA_HPP
