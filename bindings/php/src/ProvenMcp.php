<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** McpMessageType matching the Idris2 ABI tags. */
enum McpMessageType: int
{
    case Initialize = 0;
    case Initialized = 1;
    case Ping = 2;
    case CallTool = 3;
    case ToolResult = 4;
    case ListTools = 5;
    case ListResources = 6;
    case ReadResource = 7;
    case ListPrompts = 8;
    case GetPrompt = 9;
    case Subscribe = 10;
    case Unsubscribe = 11;
    case Notification = 12;
    case Cancel = 13;
}

/** Transport matching the Idris2 ABI tags. */
enum Transport: int
{
    case Stdio = 0;
    case Sse = 1;
    case WebSocket = 2;
    case StreamableHttp = 3;
}

/** McpContentType matching the Idris2 ABI tags. */
enum McpContentType: int
{
    case Text = 0;
    case Image = 1;
    case Resource = 2;
    case Embedding = 3;
}

/** McpErrorCode matching the Idris2 ABI tags. */
enum McpErrorCode: int
{
    case ParseError = 0;
    case InvalidRequest = 1;
    case MethodNotFound = 2;
    case InvalidParams = 3;
    case InternalError = 4;
    case Timeout = 5;
}

/** McpCapability matching the Idris2 ABI tags. */
enum McpCapability: int
{
    case Tools = 0;
    case Resources = 1;
    case Prompts = 2;
    case Logging = 3;
    case Sampling = 4;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Connecting = 1;
    case Ready = 2;
    case Processing = 3;
    case Disconnecting = 4;
}
