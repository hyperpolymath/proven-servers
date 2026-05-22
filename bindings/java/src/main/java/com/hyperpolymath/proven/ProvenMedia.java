// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Media protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenMedia {
    private ProvenMedia() {}

    /** MediaContentType (tags 0-4). */
    public enum MediaContentType {
        AUDIO(0),
        VIDEO(1),
        LIVE_STREAM(2),
        PLAYLIST(3),
        SUBTITLE(4);

        private final int tag;
        MediaContentType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MediaContentType fromTag(int tag) {
            for (MediaContentType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Codec (tags 0-7). */
    public enum Codec {
        H264(0),
        H265(1),
        AV1(2),
        VP9(3),
        AAC(4),
        OPUS(5),
        FLAC(6),
        MP3(7);

        private final int tag;
        Codec(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Codec fromTag(int tag) {
            for (Codec v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StreamProtocol (tags 0-5). */
    public enum StreamProtocol {
        HLS(0),
        DASH(1),
        RTMP(2),
        RTSP(3),
        WEB_RTC(4),
        SRT(5);

        private final int tag;
        StreamProtocol(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StreamProtocol fromTag(int tag) {
            for (StreamProtocol v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TranscodeProfile (tags 0-4). */
    public enum TranscodeProfile {
        PASSTHROUGH(0),
        LOW(1),
        MEDIUM(2),
        HIGH(3),
        ULTRA(4);

        private final int tag;
        TranscodeProfile(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TranscodeProfile fromTag(int tag) {
            for (TranscodeProfile v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PlayerEvent (tags 0-7). */
    public enum PlayerEvent {
        PLAY(0),
        PAUSE(1),
        SEEK(2),
        STOP(3),
        BUFFER_START(4),
        BUFFER_END(5),
        ERROR(6),
        QUALITY_CHANGE(7);

        private final int tag;
        PlayerEvent(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PlayerEvent fromTag(int tag) {
            for (PlayerEvent v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PlayerState (tags 0-4). */
    public enum PlayerState {
        IDLE(0),
        READY(1),
        PLAYING(2),
        PAUSED(3),
        STOPPING(4);

        private final int tag;
        PlayerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PlayerState fromTag(int tag) {
            for (PlayerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
