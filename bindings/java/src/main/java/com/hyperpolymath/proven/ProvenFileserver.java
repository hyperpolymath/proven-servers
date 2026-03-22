// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * File Server protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenFileserver {
    private ProvenFileserver() {}

    /** FileOperation (tags 0-9). */
    public enum FileOperation {
        READ(0),
        WRITE(1),
        CREATE(2),
        DELETE(3),
        RENAME(4),
        LIST(5),
        STAT(6),
        LOCK(7),
        UNLOCK(8),
        WATCH(9);

        private final int tag;
        FileOperation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FileOperation fromTag(int tag) {
            for (FileOperation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FileType (tags 0-6). */
    public enum FileType {
        REGULAR(0),
        DIRECTORY(1),
        SYMLINK(2),
        BLOCK_DEVICE(3),
        CHAR_DEVICE(4),
        FIFO(5),
        SOCKET(6);

        private final int tag;
        FileType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FileType fromTag(int tag) {
            for (FileType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FilePermission (tags 0-8). */
    public enum FilePermission {
        OWNER_READ(0),
        OWNER_WRITE(1),
        OWNER_EXECUTE(2),
        GROUP_READ(3),
        GROUP_WRITE(4),
        GROUP_EXECUTE(5),
        OTHER_READ(6),
        OTHER_WRITE(7),
        OTHER_EXECUTE(8);

        private final int tag;
        FilePermission(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FilePermission fromTag(int tag) {
            for (FilePermission v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LockType (tags 0-3). */
    public enum LockType {
        SHARED(0),
        EXCLUSIVE(1),
        ADVISORY(2),
        MANDATORY(3);

        private final int tag;
        LockType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LockType fromTag(int tag) {
            for (LockType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FileErrorCode (tags 0-9). */
    public enum FileErrorCode {
        NOT_FOUND(0),
        PERMISSION_DENIED(1),
        ALREADY_EXISTS(2),
        NOT_EMPTY(3),
        IS_DIRECTORY(4),
        NOT_DIRECTORY(5),
        NO_SPACE(6),
        READ_ONLY(7),
        LOCKED(8),
        IO_ERROR(9);

        private final int tag;
        FileErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FileErrorCode fromTag(int tag) {
            for (FileErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        CONNECTED(1),
        OPERATING(2),
        FS_LOCKED(3),
        DISCONNECTING(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
