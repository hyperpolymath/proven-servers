// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * MCP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenMcp {
    private ProvenMcp() {}

    /** McpMessageType (tags 0-13). */
    public enum McpMessageType {
        INITIALIZE(0),
        INITIALIZED(1),
        PING(2),
        CALL_TOOL(3),
        TOOL_RESULT(4),
        LIST_TOOLS(5),
        LIST_RESOURCES(6),
        READ_RESOURCE(7),
        LIST_PROMPTS(8),
        GET_PROMPT(9),
        SUBSCRIBE(10),
        UNSUBSCRIBE(11),
        NOTIFICATION(12),
        CANCEL(13);

        private final int tag;
        McpMessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static McpMessageType fromTag(int tag) {
            for (McpMessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Transport (tags 0-3). */
    public enum Transport {
        STDIO(0),
        SSE(1),
        WEB_SOCKET(2),
        STREAMABLE_HTTP(3);

        private final int tag;
        Transport(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Transport fromTag(int tag) {
            for (Transport v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** McpContentType (tags 0-3). */
    public enum McpContentType {
        TEXT(0),
        IMAGE(1),
        RESOURCE(2),
        EMBEDDING(3);

        private final int tag;
        McpContentType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static McpContentType fromTag(int tag) {
            for (McpContentType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** McpErrorCode (tags 0-5). */
    public enum McpErrorCode {
        PARSE_ERROR(0),
        INVALID_REQUEST(1),
        METHOD_NOT_FOUND(2),
        INVALID_PARAMS(3),
        INTERNAL_ERROR(4),
        TIMEOUT(5);

        private final int tag;
        McpErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static McpErrorCode fromTag(int tag) {
            for (McpErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** McpCapability (tags 0-4). */
    public enum McpCapability {
        TOOLS(0),
        RESOURCES(1),
        PROMPTS(2),
        LOGGING(3),
        SAMPLING(4);

        private final int tag;
        McpCapability(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static McpCapability fromTag(int tag) {
            for (McpCapability v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        CONNECTING(1),
        READY(2),
        PROCESSING(3),
        DISCONNECTING(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
