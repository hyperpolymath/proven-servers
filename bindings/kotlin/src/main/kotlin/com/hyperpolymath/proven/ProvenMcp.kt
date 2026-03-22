// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP protocol types for proven-servers.

package com.hyperpolymath.proven

/** McpMessageType matching the Idris2 ABI tags. */
enum class McpMessageType(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): McpMessageType? = entries.find { it.tag == tag }
    }
}

/** Transport matching the Idris2 ABI tags. */
enum class Transport(val tag: Int) {
    STDIO(0),
    SSE(1),
    WEB_SOCKET(2),
    STREAMABLE_HTTP(3);

    companion object {
        fun fromTag(tag: Int): Transport? = entries.find { it.tag == tag }
    }
}

/** McpContentType matching the Idris2 ABI tags. */
enum class McpContentType(val tag: Int) {
    TEXT(0),
    IMAGE(1),
    RESOURCE(2),
    EMBEDDING(3);

    companion object {
        fun fromTag(tag: Int): McpContentType? = entries.find { it.tag == tag }
    }
}

/** McpErrorCode matching the Idris2 ABI tags. */
enum class McpErrorCode(val tag: Int) {
    PARSE_ERROR(0),
    INVALID_REQUEST(1),
    METHOD_NOT_FOUND(2),
    INVALID_PARAMS(3),
    INTERNAL_ERROR(4),
    TIMEOUT(5);

    companion object {
        fun fromTag(tag: Int): McpErrorCode? = entries.find { it.tag == tag }
    }
}

/** McpCapability matching the Idris2 ABI tags. */
enum class McpCapability(val tag: Int) {
    TOOLS(0),
    RESOURCES(1),
    PROMPTS(2),
    LOGGING(3),
    SAMPLING(4);

    companion object {
        fun fromTag(tag: Int): McpCapability? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    CONNECTING(1),
    READY(2),
    PROCESSING(3),
    DISCONNECTING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
