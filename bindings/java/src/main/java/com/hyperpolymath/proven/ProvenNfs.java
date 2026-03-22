// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NFS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * NFS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenNfs {
    private ProvenNfs() {}

    /** Operation (tags 0-14). */
    public enum Operation {
        ACCESS(0),
        CLOSE(1),
        COMMIT(2),
        CREATE(3),
        GET_ATTR(4),
        LINK(5),
        LOCK(6),
        LOOKUP(7),
        OPEN(8),
        READ(9),
        READ_DIR(10),
        REMOVE(11),
        RENAME(12),
        SET_ATTR(13),
        WRITE(14);

        private final int tag;
        Operation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Operation fromTag(int tag) {
            for (Operation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FileType (tags 0-6). */
    public enum FileType {
        REGULAR(0),
        DIRECTORY(1),
        BLOCK_DEVICE(2),
        CHAR_DEVICE(3),
        LINK(4),
        SOCKET(5),
        FIFO(6);

        private final int tag;
        FileType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FileType fromTag(int tag) {
            for (FileType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Status (tags 0-13). */
    public enum Status {
        OK(0),
        PERM(1),
        NO_ENT(2),
        IO(3),
        NX_IO(4),
        ACCESS(5),
        EXIST(6),
        NOT_DIR(7),
        IS_DIR(8),
        F_BIG(9),
        NO_SPC(10),
        R_OFS(11),
        NOT_EMPTY(12),
        STALE(13);

        private final int tag;
        Status(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Status fromTag(int tag) {
            for (Status v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NfsState (tags 0-5). */
    public enum NfsState {
        IDLE(0),
        MOUNTED(1),
        FILE_OPEN(2),
        LOCKED(3),
        BUSY(4),
        UNMOUNTING(5);

        private final int tag;
        NfsState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NfsState fromTag(int tag) {
            for (NfsState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
