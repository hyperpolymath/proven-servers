// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Proxy protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenProxy {
    private ProvenProxy() {}

    /** ProxyMode (tags 0-1). */
    public enum ProxyMode {
        FORWARD(0),
        REVERSE(1);

        private final int tag;
        ProxyMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ProxyMode fromTag(int tag) {
            for (ProxyMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HopByHopHeader (tags 0-7). */
    public enum HopByHopHeader {
        CONNECTION(0),
        KEEP_ALIVE(1),
        PROXY_AUTH(2),
        PROXY_AUTHZ(3),
        TE(4),
        TRAILERS(5),
        TRANSFER_ENCODING(6),
        UPGRADE(7);

        private final int tag;
        HopByHopHeader(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HopByHopHeader fromTag(int tag) {
            for (HopByHopHeader v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CacheDirective (tags 0-5). */
    public enum CacheDirective {
        NO_CACHE(0),
        NO_STORE(1),
        MAX_AGE(2),
        PUBLIC(3),
        PRIVATE(4),
        MUST_REVALIDATE(5);

        private final int tag;
        CacheDirective(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CacheDirective fromTag(int tag) {
            for (CacheDirective v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ProxyError (tags 0-3). */
    public enum ProxyError {
        BAD_GATEWAY(0),
        GATEWAY_TIMEOUT(1),
        UPSTREAM_REFUSED(2),
        UPSTREAM_TLS(3);

        private final int tag;
        ProxyError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ProxyError fromTag(int tag) {
            for (ProxyError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
