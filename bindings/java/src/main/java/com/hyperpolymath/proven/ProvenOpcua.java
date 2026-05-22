// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * OPC UA protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenOpcua {
    private ProvenOpcua() {}

    /** ServiceType (tags 0-10). */
    public enum ServiceType {
        READ(0),
        WRITE(1),
        BROWSE(2),
        SUBSCRIBE(3),
        PUBLISH(4),
        CALL(5),
        CREATE_SESSION(6),
        ACTIVATE_SESSION(7),
        CLOSE_SESSION(8),
        CREATE_SUBSCRIPTION(9),
        DELETE_SUBSCRIPTION(10);

        private final int tag;
        ServiceType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServiceType fromTag(int tag) {
            for (ServiceType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NodeClass (tags 0-7). */
    public enum NodeClass {
        OBJECT(0),
        VARIABLE(1),
        METHOD(2),
        OBJECT_TYPE(3),
        VARIABLE_TYPE(4),
        REFERENCE_TYPE(5),
        DATA_TYPE(6),
        VIEW(7);

        private final int tag;
        NodeClass(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NodeClass fromTag(int tag) {
            for (NodeClass v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StatusCode (tags 0-11). */
    public enum StatusCode {
        GOOD(0),
        UNCERTAIN(1),
        BAD(2),
        BAD_NODE_ID_UNKNOWN(3),
        BAD_ATTRIBUTE_ID_INVALID(4),
        BAD_NOT_READABLE(5),
        BAD_NOT_WRITABLE(6),
        BAD_OUT_OF_RANGE(7),
        BAD_TYPE_MISMATCH(8),
        BAD_SESSION_ID_INVALID(9),
        BAD_SUBSCRIPTION_ID_INVALID(10),
        BAD_TIMEOUT(11);

        private final int tag;
        StatusCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StatusCode fromTag(int tag) {
            for (StatusCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SecurityMode (tags 0-2). */
    public enum SecurityMode {
        NONE(0),
        SIGN(1),
        SIGN_AND_ENCRYPT(2);

        private final int tag;
        SecurityMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SecurityMode fromTag(int tag) {
            for (SecurityMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-5). */
    public enum SessionState {
        IDLE(0),
        CONNECTED(1),
        CREATED(2),
        ACTIVATED(3),
        MONITORING(4),
        CLOSING(5);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
