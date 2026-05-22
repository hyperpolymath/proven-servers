# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-media protocol types.

"""Media protocol types for proven-servers."""

from enum import IntEnum


class MediaContentType(IntEnum):
    """MediaContentType matching the Idris2 ABI tags."""
    AUDIO = 0
    VIDEO = 1
    LIVE_STREAM = 2
    PLAYLIST = 3
    SUBTITLE = 4


class Codec(IntEnum):
    """Codec matching the Idris2 ABI tags."""
    H264 = 0
    H265 = 1
    AV1 = 2
    VP9 = 3
    AAC = 4
    OPUS = 5
    FLAC = 6
    MP3 = 7


class StreamProtocol(IntEnum):
    """StreamProtocol matching the Idris2 ABI tags."""
    HLS = 0
    DASH = 1
    RTMP = 2
    RTSP = 3
    WEB_RTC = 4
    SRT = 5


class TranscodeProfile(IntEnum):
    """TranscodeProfile matching the Idris2 ABI tags."""
    PASSTHROUGH = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    ULTRA = 4


class PlayerEvent(IntEnum):
    """PlayerEvent matching the Idris2 ABI tags."""
    PLAY = 0
    PAUSE = 1
    SEEK = 2
    STOP = 3
    BUFFER_START = 4
    BUFFER_END = 5
    ERROR = 6
    QUALITY_CHANGE = 7


class PlayerState(IntEnum):
    """PlayerState matching the Idris2 ABI tags."""
    IDLE = 0
    READY = 1
    PLAYING = 2
    PAUSED = 3
    STOPPING = 4
