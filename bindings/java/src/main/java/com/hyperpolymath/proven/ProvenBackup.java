// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Backup protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenBackup {
    private ProvenBackup() {}

    /** BackupType (tags 0-4). */
    public enum BackupType {
        FULL(0),
        INCREMENTAL(1),
        DIFFERENTIAL(2),
        SNAPSHOT(3),
        MIRROR(4);

        private final int tag;
        BackupType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BackupType fromTag(int tag) {
            for (BackupType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ScheduleFreq (tags 0-4). */
    public enum ScheduleFreq {
        HOURLY(0),
        DAILY(1),
        WEEKLY(2),
        MONTHLY(3),
        ON_DEMAND(4);

        private final int tag;
        ScheduleFreq(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ScheduleFreq fromTag(int tag) {
            for (ScheduleFreq v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CompressionAlg (tags 0-4). */
    public enum CompressionAlg {
        NONE(0),
        GZIP(1),
        ZSTD(2),
        LZ4(3),
        XZ(4);

        private final int tag;
        CompressionAlg(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CompressionAlg fromTag(int tag) {
            for (CompressionAlg v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EncryptionAlg (tags 0-2). */
    public enum EncryptionAlg {
        NO_ENCRYPTION(0),
        AES256_GCM(1),
        CHA_CHA20_POLY1305(2);

        private final int tag;
        EncryptionAlg(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EncryptionAlg fromTag(int tag) {
            for (EncryptionAlg v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** BackupState (tags 0-5). */
    public enum BackupState {
        IDLE(0),
        RUNNING(1),
        VERIFYING(2),
        COMPLETE(3),
        FAILED(4),
        CANCELLED(5);

        private final int tag;
        BackupState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BackupState fromTag(int tag) {
            for (BackupState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RetentionPolicy (tags 0-4). */
    public enum RetentionPolicy {
        KEEP_ALL(0),
        KEEP_LAST(1),
        KEEP_DAILY(2),
        KEEP_WEEKLY(3),
        KEEP_MONTHLY(4);

        private final int tag;
        RetentionPolicy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RetentionPolicy fromTag(int tag) {
            for (RetentionPolicy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
