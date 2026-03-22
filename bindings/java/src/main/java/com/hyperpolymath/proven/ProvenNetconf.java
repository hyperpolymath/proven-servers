// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * NETCONF protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenNetconf {
    private ProvenNetconf() {}

    /** NetconfOperation (tags 0-11). */
    public enum NetconfOperation {
        GET(0),
        GET_CONFIG(1),
        EDIT_CONFIG(2),
        COPY_CONFIG(3),
        DELETE_CONFIG(4),
        LOCK(5),
        UNLOCK(6),
        CLOSE_SESSION(7),
        KILL_SESSION(8),
        COMMIT(9),
        VALIDATE(10),
        DISCARD_CHANGES(11);

        private final int tag;
        NetconfOperation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NetconfOperation fromTag(int tag) {
            for (NetconfOperation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Datastore (tags 0-2). */
    public enum Datastore {
        RUNNING(0),
        STARTUP(1),
        CANDIDATE(2);

        private final int tag;
        Datastore(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Datastore fromTag(int tag) {
            for (Datastore v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EditOperation (tags 0-4). */
    public enum EditOperation {
        MERGE(0),
        REPLACE(1),
        CREATE(2),
        DELETE(3),
        REMOVE(4);

        private final int tag;
        EditOperation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EditOperation fromTag(int tag) {
            for (EditOperation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NetconfErrorType (tags 0-3). */
    public enum NetconfErrorType {
        TRANSPORT(0),
        RPC(1),
        PROTOCOL(2),
        APPLICATION(3);

        private final int tag;
        NetconfErrorType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NetconfErrorType fromTag(int tag) {
            for (NetconfErrorType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorSeverity (tags 0-1). */
    public enum ErrorSeverity {
        ERROR(0),
        WARNING(1);

        private final int tag;
        ErrorSeverity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorSeverity fromTag(int tag) {
            for (ErrorSeverity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NetconfState (tags 0-5). */
    public enum NetconfState {
        IDLE(0),
        CONNECTED(1),
        LOCKED(2),
        EDITING(3),
        CLOSING(4),
        TERMINATED(5);

        private final int tag;
        NetconfState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NetconfState fromTag(int tag) {
            for (NetconfState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
