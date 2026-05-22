// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * API Server protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenApiserver {
    private ProvenApiserver() {}

    /** AuthScheme (tags 0-5). */
    public enum AuthScheme {
        API_KEY(0),
        BEARER(1),
        BASIC(2),
        O_AUTH2(3),
        HMAC(4),
        MTLS(5);

        private final int tag;
        AuthScheme(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthScheme fromTag(int tag) {
            for (AuthScheme v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RateLimitStrategy (tags 0-3). */
    public enum RateLimitStrategy {
        FIXED_WINDOW(0),
        SLIDING_WINDOW(1),
        TOKEN_BUCKET(2),
        LEAKY_BUCKET(3);

        private final int tag;
        RateLimitStrategy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RateLimitStrategy fromTag(int tag) {
            for (RateLimitStrategy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ApiVersion (tags 0-4). */
    public enum ApiVersion {
        V1(0),
        V2(1),
        V3(2),
        LATEST(3),
        DEPRECATED(4);

        private final int tag;
        ApiVersion(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ApiVersion fromTag(int tag) {
            for (ApiVersion v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponseFormat (tags 0-3). */
    public enum ResponseFormat {
        JSON(0),
        XML(1),
        PROTOBUF(2),
        MESSAGE_PACK(3);

        private final int tag;
        ResponseFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponseFormat fromTag(int tag) {
            for (ResponseFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** GatewayError (tags 0-5). */
    public enum GatewayError {
        UNAUTHORIZED(0),
        RATE_LIMITED(1),
        NOT_FOUND(2),
        BAD_REQUEST(3),
        SERVICE_UNAVAILABLE(4),
        CIRCUIT_OPEN(5);

        private final int tag;
        GatewayError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static GatewayError fromTag(int tag) {
            for (GatewayError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
