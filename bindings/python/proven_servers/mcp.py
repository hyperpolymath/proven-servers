# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-mcp protocol types.

"""MCP protocol types for proven-servers."""

from enum import IntEnum


class McpMessageType(IntEnum):
    """McpMessageType matching the Idris2 ABI tags."""
    INITIALIZE = 0
    INITIALIZED = 1
    PING = 2
    CALL_TOOL = 3
    TOOL_RESULT = 4
    LIST_TOOLS = 5
    LIST_RESOURCES = 6
    READ_RESOURCE = 7
    LIST_PROMPTS = 8
    GET_PROMPT = 9
    SUBSCRIBE = 10
    UNSUBSCRIBE = 11
    NOTIFICATION = 12
    CANCEL = 13


class Transport(IntEnum):
    """Transport matching the Idris2 ABI tags."""
    STDIO = 0
    SSE = 1
    WEB_SOCKET = 2
    STREAMABLE_HTTP = 3


class McpContentType(IntEnum):
    """McpContentType matching the Idris2 ABI tags."""
    TEXT = 0
    IMAGE = 1
    RESOURCE = 2
    EMBEDDING = 3


class McpErrorCode(IntEnum):
    """McpErrorCode matching the Idris2 ABI tags."""
    PARSE_ERROR = 0
    INVALID_REQUEST = 1
    METHOD_NOT_FOUND = 2
    INVALID_PARAMS = 3
    INTERNAL_ERROR = 4
    TIMEOUT = 5


class McpCapability(IntEnum):
    """McpCapability matching the Idris2 ABI tags."""
    TOOLS = 0
    RESOURCES = 1
    PROMPTS = 2
    LOGGING = 3
    SAMPLING = 4


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    CONNECTING = 1
    READY = 2
    PROCESSING = 3
    DISCONNECTING = 4
