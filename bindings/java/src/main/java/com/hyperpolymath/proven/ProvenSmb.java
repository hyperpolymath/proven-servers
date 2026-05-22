// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMB protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * SMB protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSmb {
    private ProvenSmb() {}

    /** Command (tags 0-15). */
    public enum Command {
        NEGOTIATE(0),
        SESSION_SETUP(1),
        LOGOFF(2),
        TREE_CONNECT(3),
        TREE_DISCONNECT(4),
        CREATE(5),
        CLOSE(6),
        READ(7),
        WRITE(8),
        LOCK(9),
        IOCTL(10),
        CANCEL(11),
        QUERY_DIRECTORY(12),
        CHANGE_NOTIFY(13),
        QUERY_INFO(14),
        SET_INFO(15);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Dialect (tags 0-4). */
    public enum Dialect {
        SMB2_0_2(0),
        SMB2_1(1),
        SMB3_0(2),
        SMB3_0_2(3),
        SMB3_1_1(4);

        private final int tag;
        Dialect(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Dialect fromTag(int tag) {
            for (Dialect v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ShareType (tags 0-2). */
    public enum ShareType {
        DISK(0),
        PIPE(1),
        PRINT(2);

        private final int tag;
        ShareType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ShareType fromTag(int tag) {
            for (ShareType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-5). */
    public enum SessionState {
        IDLE(0),
        NEGOTIATED(1),
        AUTHENTICATED(2),
        TREE_CONNECTED(3),
        FILE_OPEN(4),
        DISCONNECTING(5);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
