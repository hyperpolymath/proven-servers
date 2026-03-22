// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * LDP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenLdp {
    private ProvenLdp() {}

    /** ContainerType (tags 0-2). */
    public enum ContainerType {
        BASIC(0),
        DIRECT(1),
        INDIRECT(2);

        private final int tag;
        ContainerType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContainerType fromTag(int tag) {
            for (ContainerType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LdpResourceType (tags 0-2). */
    public enum LdpResourceType {
        RDF_SOURCE(0),
        NON_RDF_SOURCE(1),
        CONTAINER(2);

        private final int tag;
        LdpResourceType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LdpResourceType fromTag(int tag) {
            for (LdpResourceType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Preference (tags 0-4). */
    public enum Preference {
        MINIMAL_CONTAINER(0),
        INCLUDE_CONTAINMENT(1),
        INCLUDE_MEMBERSHIP(2),
        OMIT_CONTAINMENT(3),
        OMIT_MEMBERSHIP(4);

        private final int tag;
        Preference(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Preference fromTag(int tag) {
            for (Preference v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** InteractionModel (tags 0-4). */
    public enum InteractionModel {
        LDPR(0),
        LDPC(1),
        LDP_BASIC_CONTAINER(2),
        LDP_DIRECT_CONTAINER(3),
        LDP_INDIRECT_CONTAINER(4);

        private final int tag;
        InteractionModel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static InteractionModel fromTag(int tag) {
            for (InteractionModel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ConstraintViolation (tags 0-3). */
    public enum ConstraintViolation {
        MEMBERSHIP_CONSTANT(0),
        CONTAINS_TRIPLES_MODIFIED(1),
        SERVER_MANAGED(2),
        TYPE_CONFLICT(3);

        private final int tag;
        ConstraintViolation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ConstraintViolation fromTag(int tag) {
            for (ConstraintViolation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
