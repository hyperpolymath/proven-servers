// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * SOCKS5 protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSocks {
    private ProvenSocks() {}

    /** AuthMethod (tags 0-3). */
    public enum AuthMethod {
        NO_AUTH(0),
        GSSAPI(1),
        USERNAME_PASSWORD(2),
        NO_ACCEPTABLE(3);

        private final int tag;
        AuthMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthMethod fromTag(int tag) {
            for (AuthMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Command (tags 0-2). */
    public enum Command {
        CONNECT(0),
        BIND(1),
        UDP_ASSOCIATE(2);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AddressType (tags 0-2). */
    public enum AddressType {
        I_PV4(0),
        DOMAIN_NAME(1),
        I_PV6(2);

        private final int tag;
        AddressType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AddressType fromTag(int tag) {
            for (AddressType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Reply (tags 0-8). */
    public enum Reply {
        SUCCEEDED(0),
        GENERAL_FAILURE(1),
        NOT_ALLOWED(2),
        NETWORK_UNREACHABLE(3),
        HOST_UNREACHABLE(4),
        CONNECTION_REFUSED(5),
        TTL_EXPIRED(6),
        COMMAND_NOT_SUPPORTED(7),
        ADDRESS_TYPE_NOT_SUPPORTED(8);

        private final int tag;
        Reply(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Reply fromTag(int tag) {
            for (Reply v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** State (tags 0-5). */
    public enum State {
        INITIAL(0),
        AUTHENTICATING(1),
        AUTHENTICATED(2),
        CONNECTING(3),
        ESTABLISHED(4),
        CLOSED(5);

        private final int tag;
        State(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static State fromTag(int tag) {
            for (State v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
