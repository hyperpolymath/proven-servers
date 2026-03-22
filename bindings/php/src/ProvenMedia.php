<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MediaContentType matching the Idris2 ABI tags. */
enum MediaContentType: int
{
    case Audio = 0;
    case Video = 1;
    case LiveStream = 2;
    case Playlist = 3;
    case Subtitle = 4;
}

/** Codec matching the Idris2 ABI tags. */
enum Codec: int
{
    case H264 = 0;
    case H265 = 1;
    case Av1 = 2;
    case Vp9 = 3;
    case Aac = 4;
    case Opus = 5;
    case Flac = 6;
    case Mp3 = 7;
}

/** StreamProtocol matching the Idris2 ABI tags. */
enum StreamProtocol: int
{
    case Hls = 0;
    case Dash = 1;
    case Rtmp = 2;
    case Rtsp = 3;
    case WebRtc = 4;
    case Srt = 5;
}

/** TranscodeProfile matching the Idris2 ABI tags. */
enum TranscodeProfile: int
{
    case Passthrough = 0;
    case Low = 1;
    case Medium = 2;
    case High = 3;
    case Ultra = 4;
}

/** PlayerEvent matching the Idris2 ABI tags. */
enum PlayerEvent: int
{
    case Play = 0;
    case Pause = 1;
    case Seek = 2;
    case Stop = 3;
    case BufferStart = 4;
    case BufferEnd = 5;
    case Error = 6;
    case QualityChange = 7;
}

/** PlayerState matching the Idris2 ABI tags. */
enum PlayerState: int
{
    case Idle = 0;
    case Ready = 1;
    case Playing = 2;
    case Paused = 3;
    case Stopping = 4;
}
