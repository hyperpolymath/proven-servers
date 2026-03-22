// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * RTSP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenRtsp {
    private ProvenRtsp() {}

    /** Method (tags 0-10). */
    public enum Method {
        DESCRIBE(0),
        SETUP(1),
        PLAY(2),
        PAUSE(3),
        TEARDOWN(4),
        GET_PARAMETER(5),
        SET_PARAMETER(6),
        OPTIONS(7),
        ANNOUNCE(8),
        RECORD(9),
        REDIRECT(10);

        private final int tag;
        Method(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Method fromTag(int tag) {
            for (Method v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransportProtocol (tags 0-2). */
    public enum TransportProtocol {
        RTP_AVP_UDP(0),
        RTP_AVP_TCP(1),
        RTP_AVP_UDP_MULTICAST(2);

        private final int tag;
        TransportProtocol(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransportProtocol fromTag(int tag) {
            for (TransportProtocol v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-3). */
    public enum SessionState {
        INIT(0),
        READY(1),
        PLAYING(2),
        RECORDING(3);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StatusCode (tags 0-11). */
    public enum StatusCode {
        OK(0),
        MOVED_PERMANENTLY(1),
        MOVED_TEMPORARILY(2),
        BAD_REQUEST(3),
        UNAUTHORIZED(4),
        NOT_FOUND(5),
        METHOD_NOT_ALLOWED(6),
        NOT_ACCEPTABLE(7),
        SESSION_NOT_FOUND(8),
        INTERNAL_SERVER_ERROR(9),
        NOT_IMPLEMENTED(10),
        SERVICE_UNAVAILABLE(11);

        private final int tag;
        StatusCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StatusCode fromTag(int tag) {
            for (StatusCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RtspError (tags 0-6). */
    public enum RtspError {
        OK(0),
        INVALID_SLOT(1),
        NOT_ACTIVE(2),
        INVALID_TRANSITION(3),
        METHOD_NOT_ALLOWED(4),
        TRANSPORT_ERROR(5),
        SESSION_EXPIRED(6);

        private final int tag;
        RtspError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RtspError fromTag(int tag) {
            for (RtspError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
