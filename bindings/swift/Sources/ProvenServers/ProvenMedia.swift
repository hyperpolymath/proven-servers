// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media protocol types for proven-servers.

/// MediaContentType matching the Idris2 ABI tags.
public enum MediaContentType: UInt8, CaseIterable, Sendable {
    case audio = 0
    case video = 1
    case liveStream = 2
    case playlist = 3
    case subtitle = 4
}

/// Codec matching the Idris2 ABI tags.
public enum Codec: UInt8, CaseIterable, Sendable {
    case h264 = 0
    case h265 = 1
    case av1 = 2
    case vp9 = 3
    case aac = 4
    case opus = 5
    case flac = 6
    case mp3 = 7
}

/// StreamProtocol matching the Idris2 ABI tags.
public enum StreamProtocol: UInt8, CaseIterable, Sendable {
    case hls = 0
    case dash = 1
    case rtmp = 2
    case rtsp = 3
    case webRtc = 4
    case srt = 5
}

/// TranscodeProfile matching the Idris2 ABI tags.
public enum TranscodeProfile: UInt8, CaseIterable, Sendable {
    case passthrough = 0
    case low = 1
    case medium = 2
    case high = 3
    case ultra = 4
}

/// PlayerEvent matching the Idris2 ABI tags.
public enum PlayerEvent: UInt8, CaseIterable, Sendable {
    case play = 0
    case pause = 1
    case seek = 2
    case stop = 3
    case bufferStart = 4
    case bufferEnd = 5
    case error = 6
    case qualityChange = 7
}

/// PlayerState matching the Idris2 ABI tags.
public enum PlayerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ready = 1
    case playing = 2
    case paused = 3
    case stopping = 4
}
