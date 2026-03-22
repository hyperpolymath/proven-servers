// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media protocol types for proven-servers.

package com.hyperpolymath.proven

/** MediaContentType matching the Idris2 ABI tags. */
enum class MediaContentType(val tag: Int) {
    AUDIO(0),
    VIDEO(1),
    LIVE_STREAM(2),
    PLAYLIST(3),
    SUBTITLE(4);

    companion object {
        fun fromTag(tag: Int): MediaContentType? = entries.find { it.tag == tag }
    }
}

/** Codec matching the Idris2 ABI tags. */
enum class Codec(val tag: Int) {
    H264(0),
    H265(1),
    AV1(2),
    VP9(3),
    AAC(4),
    OPUS(5),
    FLAC(6),
    MP3(7);

    companion object {
        fun fromTag(tag: Int): Codec? = entries.find { it.tag == tag }
    }
}

/** StreamProtocol matching the Idris2 ABI tags. */
enum class StreamProtocol(val tag: Int) {
    HLS(0),
    DASH(1),
    RTMP(2),
    RTSP(3),
    WEB_RTC(4),
    SRT(5);

    companion object {
        fun fromTag(tag: Int): StreamProtocol? = entries.find { it.tag == tag }
    }
}

/** TranscodeProfile matching the Idris2 ABI tags. */
enum class TranscodeProfile(val tag: Int) {
    PASSTHROUGH(0),
    LOW(1),
    MEDIUM(2),
    HIGH(3),
    ULTRA(4);

    companion object {
        fun fromTag(tag: Int): TranscodeProfile? = entries.find { it.tag == tag }
    }
}

/** PlayerEvent matching the Idris2 ABI tags. */
enum class PlayerEvent(val tag: Int) {
    PLAY(0),
    PAUSE(1),
    SEEK(2),
    STOP(3),
    BUFFER_START(4),
    BUFFER_END(5),
    ERROR(6),
    QUALITY_CHANGE(7);

    companion object {
        fun fromTag(tag: Int): PlayerEvent? = entries.find { it.tag == tag }
    }
}

/** PlayerState matching the Idris2 ABI tags. */
enum class PlayerState(val tag: Int) {
    IDLE(0),
    READY(1),
    PLAYING(2),
    PAUSED(3),
    STOPPING(4);

    companion object {
        fun fromTag(tag: Int): PlayerState? = entries.find { it.tag == tag }
    }
}
