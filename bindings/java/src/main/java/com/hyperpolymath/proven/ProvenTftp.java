// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * TFTP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenTftp {
    private ProvenTftp() {}

    /** Opcode (tags 0-4). */
    public enum Opcode {
        RRQ(0),
        WRQ(1),
        DATA(2),
        ACK(3),
        ERROR(4);

        private final int tag;
        Opcode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Opcode fromTag(int tag) {
            for (Opcode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransferMode (tags 0-2). */
    public enum TransferMode {
        NET_ASCII(0),
        OCTET(1),
        MAIL(2);

        private final int tag;
        TransferMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransferMode fromTag(int tag) {
            for (TransferMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TftpError (tags 0-7). */
    public enum TftpError {
        NOT_DEFINED(0),
        FILE_NOT_FOUND(1),
        ACCESS_VIOLATION(2),
        DISK_FULL(3),
        ILLEGAL_OPERATION(4),
        UNKNOWN_TID(5),
        FILE_EXISTS(6),
        NO_SUCH_USER(7);

        private final int tag;
        TftpError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TftpError fromTag(int tag) {
            for (TftpError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransferState (tags 0-4). */
    public enum TransferState {
        IDLE(0),
        READING(1),
        WRITING(2),
        IN_ERROR(3),
        COMPLETE(4);

        private final int tag;
        TransferState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransferState fromTag(int tag) {
            for (TransferState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
