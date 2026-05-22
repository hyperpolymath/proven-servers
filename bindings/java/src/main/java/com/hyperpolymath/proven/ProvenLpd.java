// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * LPD protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenLpd {
    private ProvenLpd() {}

    /** CommandCode (tags 0-4). */
    public enum CommandCode {
        PRINT_JOB(0),
        RECEIVE_JOB(1),
        SHORT_QUEUE(2),
        LONG_QUEUE(3),
        REMOVE_JOBS(4);

        private final int tag;
        CommandCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CommandCode fromTag(int tag) {
            for (CommandCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SubCommandCode (tags 0-2). */
    public enum SubCommandCode {
        ABORT_JOB(0),
        CONTROL_FILE(1),
        DATA_FILE(2);

        private final int tag;
        SubCommandCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SubCommandCode fromTag(int tag) {
            for (SubCommandCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** JobStatus (tags 0-3). */
    public enum JobStatus {
        PENDING(0),
        PRINTING(1),
        COMPLETE(2),
        FAILED(3);

        private final int tag;
        JobStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static JobStatus fromTag(int tag) {
            for (JobStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
