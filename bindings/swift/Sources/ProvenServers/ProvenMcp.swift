// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP protocol types for proven-servers.

/// McpMessageType matching the Idris2 ABI tags.
public enum McpMessageType: UInt8, CaseIterable, Sendable {
    case initialize = 0
    case initialized = 1
    case ping = 2
    case callTool = 3
    case toolResult = 4
    case listTools = 5
    case listResources = 6
    case readResource = 7
    case listPrompts = 8
    case getPrompt = 9
    case subscribe = 10
    case unsubscribe = 11
    case notification = 12
    case cancel = 13
}

/// Transport matching the Idris2 ABI tags.
public enum Transport: UInt8, CaseIterable, Sendable {
    case stdio = 0
    case sse = 1
    case webSocket = 2
    case streamableHttp = 3
}

/// McpContentType matching the Idris2 ABI tags.
public enum McpContentType: UInt8, CaseIterable, Sendable {
    case text = 0
    case image = 1
    case resource = 2
    case embedding = 3
}

/// McpErrorCode matching the Idris2 ABI tags.
public enum McpErrorCode: UInt8, CaseIterable, Sendable {
    case parseError = 0
    case invalidRequest = 1
    case methodNotFound = 2
    case invalidParams = 3
    case internalError = 4
    case timeout = 5
}

/// McpCapability matching the Idris2 ABI tags.
public enum McpCapability: UInt8, CaseIterable, Sendable {
    case tools = 0
    case resources = 1
    case prompts = 2
    case logging = 3
    case sampling = 4
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connecting = 1
    case ready = 2
    case processing = 3
    case disconnecting = 4
}
