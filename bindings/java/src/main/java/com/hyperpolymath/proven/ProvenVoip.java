// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * VoIP/SIP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenVoip {
    private ProvenVoip() {}

    /** Method (tags 0-12). */
    public enum Method {
        INVITE(0),
        ACK(1),
        BYE(2),
        CANCEL(3),
        REGISTER(4),
        OPTIONS(5),
        INFO(6),
        UPDATE(7),
        SUBSCRIBE(8),
        NOTIFY(9),
        REFER(10),
        MESSAGE(11),
        PRACK(12);

        private final int tag;
        Method(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Method fromTag(int tag) {
            for (Method v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponseCode (tags 0-16). */
    public enum ResponseCode {
        TRYING(0),
        RINGING(1),
        SESSION_PROGRESS(2),
        OK(3),
        MULTIPLE_CHOICES(4),
        MOVED_PERMANENTLY(5),
        MOVED_TEMPORARILY(6),
        BAD_REQUEST(7),
        UNAUTHORIZED(8),
        FORBIDDEN(9),
        NOT_FOUND(10),
        METHOD_NOT_ALLOWED(11),
        REQUEST_TIMEOUT(12),
        BUSY_HERE(13),
        DECLINE(14),
        SERVER_INTERNAL_ERROR(15),
        SERVICE_UNAVAILABLE(16);

        private final int tag;
        ResponseCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponseCode fromTag(int tag) {
            for (ResponseCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DialogState (tags 0-2). */
    public enum DialogState {
        EARLY(0),
        CONFIRMED(1),
        TERMINATED(2);

        private final int tag;
        DialogState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DialogState fromTag(int tag) {
            for (DialogState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
