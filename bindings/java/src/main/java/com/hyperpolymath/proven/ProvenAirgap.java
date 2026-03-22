// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Air Gap protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenAirgap {
    private ProvenAirgap() {}

    /** TransferDirection (tags 0-1). */
    public enum TransferDirection {
        IMPORT(0),
        EXPORT(1);

        private final int tag;
        TransferDirection(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransferDirection fromTag(int tag) {
            for (TransferDirection v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MediaType (tags 0-3). */
    public enum MediaType {
        USB(0),
        OPTICAL_DISC(1),
        TAPE_CARTRIDGE(2),
        DIODE_LINK(3);

        private final int tag;
        MediaType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MediaType fromTag(int tag) {
            for (MediaType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ScanResult (tags 0-3). */
    public enum ScanResult {
        CLEAN(0),
        SUSPICIOUS(1),
        MALICIOUS(2),
        UNSCANNABLE(3);

        private final int tag;
        ScanResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ScanResult fromTag(int tag) {
            for (ScanResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransferState (tags 0-6). */
    public enum TransferState {
        PENDING(0),
        SCANNING(1),
        APPROVED(2),
        REJECTED(3),
        IN_PROGRESS(4),
        COMPLETE(5),
        FAILED(6);

        private final int tag;
        TransferState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransferState fromTag(int tag) {
            for (TransferState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ValidationCheck (tags 0-4). */
    public enum ValidationCheck {
        HASH_VERIFY(0),
        SIGNATURE_VERIFY(1),
        FORMAT_CHECK(2),
        CONTENT_INSPECTION(3),
        MALWARE_SCAN(4);

        private final int tag;
        ValidationCheck(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ValidationCheck fromTag(int tag) {
            for (ValidationCheck v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
