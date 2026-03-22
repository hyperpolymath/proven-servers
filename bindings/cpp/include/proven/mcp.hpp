// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file mcp.hpp
/// @brief MCP protocol types for proven-servers.

#ifndef PROVEN_MCP_HPP
#define PROVEN_MCP_HPP

#include <cstdint>

namespace proven {

/// @brief McpMessageType matching the Idris2 ABI tags.
enum class McpMessageType : uint8_t {
    Initialize = 0,
    Initialized = 1,
    Ping = 2,
    CallTool = 3,
    ToolResult = 4,
    ListTools = 5,
    ListResources = 6,
    ReadResource = 7,
    ListPrompts = 8,
    GetPrompt = 9,
    Subscribe = 10,
    Unsubscribe = 11,
    Notification = 12,
    Cancel = 13
};

/// @brief Transport matching the Idris2 ABI tags.
enum class Transport : uint8_t {
    Stdio = 0,
    Sse = 1,
    WebSocket = 2,
    StreamableHttp = 3
};

/// @brief McpContentType matching the Idris2 ABI tags.
enum class McpContentType : uint8_t {
    Text = 0,
    Image = 1,
    Resource = 2,
    Embedding = 3
};

/// @brief McpErrorCode matching the Idris2 ABI tags.
enum class McpErrorCode : uint8_t {
    ParseError = 0,
    InvalidRequest = 1,
    MethodNotFound = 2,
    InvalidParams = 3,
    InternalError = 4,
    Timeout = 5
};

/// @brief McpCapability matching the Idris2 ABI tags.
enum class McpCapability : uint8_t {
    Tools = 0,
    Resources = 1,
    Prompts = 2,
    Logging = 3,
    Sampling = 4
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Connecting = 1,
    Ready = 2,
    Processing = 3,
    Disconnecting = 4
};

} // namespace proven

#endif // PROVEN_MCP_HPP
