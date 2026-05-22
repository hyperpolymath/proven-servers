// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Object Store protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenObjectstore {
    private ProvenObjectstore() {}

    /** Operation (tags 0-11). */
    public enum Operation {
        PUT_OBJECT(0),
        GET_OBJECT(1),
        DELETE_OBJECT(2),
        LIST_OBJECTS(3),
        HEAD_OBJECT(4),
        COPY_OBJECT(5),
        CREATE_BUCKET(6),
        DELETE_BUCKET(7),
        LIST_BUCKETS(8),
        INIT_MULTIPART_UPLOAD(9),
        UPLOAD_PART(10),
        COMPLETE_MULTIPART_UPLOAD(11);

        private final int tag;
        Operation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Operation fromTag(int tag) {
            for (Operation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StorageClass (tags 0-4). */
    public enum StorageClass {
        STANDARD(0),
        INFREQUENT_ACCESS(1),
        GLACIER(2),
        DEEP_ARCHIVE(3),
        ONE_ZONE(4);

        private final int tag;
        StorageClass(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StorageClass fromTag(int tag) {
            for (StorageClass v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Acl (tags 0-3). */
    public enum Acl {
        PRIVATE(0),
        PUBLIC_READ(1),
        PUBLIC_READ_WRITE(2),
        AUTHENTICATED_READ(3);

        private final int tag;
        Acl(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Acl fromTag(int tag) {
            for (Acl v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-7). */
    public enum ErrorCode {
        NO_SUCH_BUCKET(0),
        NO_SUCH_KEY(1),
        BUCKET_ALREADY_EXISTS(2),
        BUCKET_NOT_EMPTY(3),
        ACCESS_DENIED(4),
        ENTITY_TOO_LARGE(5),
        INVALID_PART(6),
        INCOMPLETE_BODY(7);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        READY(1),
        BUCKET_ACTIVE(2),
        UPLOADING(3),
        CLOSING(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
