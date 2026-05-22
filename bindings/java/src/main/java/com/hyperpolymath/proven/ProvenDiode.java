// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Data Diode protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDiode {
    private ProvenDiode() {}

    /** Direction (tags 0-1). */
    public enum Direction {
        HIGH_TO_LOW(0),
        LOW_TO_HIGH(1);

        private final int tag;
        Direction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Direction fromTag(int tag) {
            for (Direction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DiodeProtocol (tags 0-4). */
    public enum DiodeProtocol {
        UDP(0),
        TCP(1),
        FILE_TRANSFER(2),
        SYSLOG(3),
        SNMP(4);

        private final int tag;
        DiodeProtocol(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DiodeProtocol fromTag(int tag) {
            for (DiodeProtocol v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransferState (tags 0-4). */
    public enum TransferState {
        QUEUED(0),
        SENDING(1),
        CONFIRMING(2),
        COMPLETE(3),
        FAILED(4);

        private final int tag;
        TransferState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransferState fromTag(int tag) {
            for (TransferState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ValidationResult (tags 0-3). */
    public enum ValidationResult {
        PASSED(0),
        FORMAT_ERROR(1),
        SIZE_EXCEEDED(2),
        POLICY_BLOCKED(3);

        private final int tag;
        ValidationResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ValidationResult fromTag(int tag) {
            for (ValidationResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IntegrityCheck (tags 0-2). */
    public enum IntegrityCheck {
        CRC32(0),
        SHA256(1),
        HMAC(2);

        private final int tag;
        IntegrityCheck(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IntegrityCheck fromTag(int tag) {
            for (IntegrityCheck v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** GatewayState (tags 0-4). */
    public enum GatewayState {
        IDLE(0),
        CONFIGURED(1),
        TRANSFERRING(2),
        VALIDATING(3),
        SHUTDOWN(4);

        private final int tag;
        GatewayState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static GatewayState fromTag(int tag) {
            for (GatewayState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
