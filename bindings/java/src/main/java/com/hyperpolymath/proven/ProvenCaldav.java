// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * CalDAV protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenCaldav {
    private ProvenCaldav() {}

    /** ComponentType (tags 0-3). */
    public enum ComponentType {
        VEVENT(0),
        VTODO(1),
        VJOURNAL(2),
        VFREEBUSY(3);

        private final int tag;
        ComponentType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ComponentType fromTag(int tag) {
            for (ComponentType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CalMethod (tags 0-6). */
    public enum CalMethod {
        GET(0),
        PUT(1),
        DELETE(2),
        PROPFIND(3),
        PROPPATCH(4),
        REPORT(5),
        MKCALENDAR(6);

        private final int tag;
        CalMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CalMethod fromTag(int tag) {
            for (CalMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ScheduleStatus (tags 0-4). */
    public enum ScheduleStatus {
        NEEDS_ACTION(0),
        ACCEPTED(1),
        DECLINED(2),
        TENTATIVE(3),
        DELEGATED(4);

        private final int tag;
        ScheduleStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ScheduleStatus fromTag(int tag) {
            for (ScheduleStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CalError (tags 0-5). */
    public enum CalError {
        VALID_CALENDAR_DATA(0),
        NO_RESOURCE_TYPE_CHANGE(1),
        SUPPORTED_COMPONENT_MISMATCH(2),
        MAX_RESOURCE_SIZE(3),
        UID_CONFLICT(4),
        PRECONDITION_FAILED(5);

        private final int tag;
        CalError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CalError fromTag(int tag) {
            for (CalError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        BOUND(1),
        SERVING(2),
        SCHEDULING(3),
        SHUTDOWN(4);

        private final int tag;
        ServerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServerState fromTag(int tag) {
            for (ServerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
