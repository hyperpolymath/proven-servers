// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP protocol types for proven-servers.

namespace Proven;

/// <summary>McpMessageType matching the Idris2 ABI tags (0-13).</summary>
public enum McpMessageType : byte
{
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
}

/// <summary>Transport matching the Idris2 ABI tags (0-3).</summary>
public enum Transport : byte
{
    Stdio = 0,
    Sse = 1,
    WebSocket = 2,
    StreamableHttp = 3
}

/// <summary>McpContentType matching the Idris2 ABI tags (0-3).</summary>
public enum McpContentType : byte
{
    Text = 0,
    Image = 1,
    Resource = 2,
    Embedding = 3
}

/// <summary>McpErrorCode matching the Idris2 ABI tags (0-5).</summary>
public enum McpErrorCode : byte
{
    ParseError = 0,
    InvalidRequest = 1,
    MethodNotFound = 2,
    InvalidParams = 3,
    InternalError = 4,
    Timeout = 5
}

/// <summary>McpCapability matching the Idris2 ABI tags (0-4).</summary>
public enum McpCapability : byte
{
    Tools = 0,
    Resources = 1,
    Prompts = 2,
    Logging = 3,
    Sampling = 4
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Connecting = 1,
    Ready = 2,
    Processing = 3,
    Disconnecting = 4
}
