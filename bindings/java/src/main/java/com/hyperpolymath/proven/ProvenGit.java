// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Git protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenGit {
    private ProvenGit() {}

    /** Command (tags 0-2). */
    public enum Command {
        UPLOAD_PACK(0),
        RECEIVE_PACK(1),
        UPLOAD_ARCHIVE(2);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PacketType (tags 0-7). */
    public enum PacketType {
        FLUSH(0),
        DELIMITER(1),
        RESPONSE_END(2),
        DATA(3),
        PKT_ERROR(4),
        SIDEBAND_DATA(5),
        SIDEBAND_PROGRESS(6),
        SIDEBAND_ERROR(7);

        private final int tag;
        PacketType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PacketType fromTag(int tag) {
            for (PacketType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RefType (tags 0-4). */
    public enum RefType {
        BRANCH(0),
        TAG(1),
        HEAD(2),
        REMOTE(3),
        GIT_NOTE(4);

        private final int tag;
        RefType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RefType fromTag(int tag) {
            for (RefType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Capability (tags 0-8). */
    public enum Capability {
        MULTI_ACK(0),
        THIN_PACK(1),
        SIDE_BAND64K(2),
        OFS_DELTA(3),
        SHALLOW(4),
        DEEPEN_SINCE(5),
        DEEPEN_NOT(6),
        FILTER_SPEC(7),
        OBJECT_FORMAT(8);

        private final int tag;
        Capability(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Capability fromTag(int tag) {
            for (Capability v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HookResult (tags 0-1). */
    public enum HookResult {
        ACCEPT(0),
        REJECT(1);

        private final int tag;
        HookResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HookResult fromTag(int tag) {
            for (HookResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        DISCOVERY(1),
        NEGOTIATING(2),
        TRANSFER(3),
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
