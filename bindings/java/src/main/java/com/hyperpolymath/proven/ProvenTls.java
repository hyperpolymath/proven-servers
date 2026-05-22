// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TLS protocol bindings for proven-servers.

package com.hyperpolymath.proven;

/**
 * TLS protocol bindings for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenTls {
    private ProvenTls() {}

    /** TlsState (tags 0-6). */
    public enum TlsState {
        TLS_IDLE(0),
        TLS_CLIENT_HELLO(1),
        TLS_SERVER_HELLO(2),
        TLS_NEGOTIATING(3),
        TLS_ESTABLISHED(4),
        TLS_RENEGOTIATING(5),
        TLS_SHUTDOWN(6);

        private final int tag;
        TlsState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TlsState fromTag(int tag) {
            for (TlsState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TlsVersion (tags 0-1). */
    public enum TlsVersion {
        TLS12(0),
        TLS13(1);

        private final int tag;
        TlsVersion(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TlsVersion fromTag(int tag) {
            for (TlsVersion v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CipherSuite (tags 0-3). */
    public enum CipherSuite {
        AES_GCM128_SHA256(0),
        AES_GCM256_SHA384(1),
        CHA_CHA20_POLY1305_SHA256(2),
        AES_CCM128_SHA256(3);

        private final int tag;
        CipherSuite(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CipherSuite fromTag(int tag) {
            for (CipherSuite v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
