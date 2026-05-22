// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP types for the proven-servers ABI.
//
// Mirrors the Idris2 module McpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// McpMessageType (tags 0-13)
// ===========================================================================

/// MCP message types.
type mcpMessageType =
  | @as(0) Initialize
  | @as(1) Initialized
  | @as(2) Ping
  | @as(3) CallTool
  | @as(4) ToolResult
  | @as(5) ListTools
  | @as(6) ListResources
  | @as(7) ReadResource
  | @as(8) ListPrompts
  | @as(9) GetPrompt
  | @as(10) Subscribe
  | @as(11) Unsubscribe
  | @as(12) Notification
  | @as(13) Cancel

/// Decode from the C-ABI tag value.
let mcpMessageTypeFromTag = (tag: int): option<mcpMessageType> =>
  switch tag {
  | 0 => Some(Initialize)
  | 1 => Some(Initialized)
  | 2 => Some(Ping)
  | 3 => Some(CallTool)
  | 4 => Some(ToolResult)
  | 5 => Some(ListTools)
  | 6 => Some(ListResources)
  | 7 => Some(ReadResource)
  | 8 => Some(ListPrompts)
  | 9 => Some(GetPrompt)
  | 10 => Some(Subscribe)
  | 11 => Some(Unsubscribe)
  | 12 => Some(Notification)
  | 13 => Some(Cancel)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mcpMessageTypeToTag = (v: mcpMessageType): int =>
  switch v {
  | Initialize => 0
  | Initialized => 1
  | Ping => 2
  | CallTool => 3
  | ToolResult => 4
  | ListTools => 5
  | ListResources => 6
  | ReadResource => 7
  | ListPrompts => 8
  | GetPrompt => 9
  | Subscribe => 10
  | Unsubscribe => 11
  | Notification => 12
  | Cancel => 13
  }

// ===========================================================================
// Transport (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type transport =
  | @as(0) Stdio
  | @as(1) Sse
  | @as(2) WebSocket
  | @as(3) StreamableHttp

/// Decode from the C-ABI tag value.
let transportFromTag = (tag: int): option<transport> =>
  switch tag {
  | 0 => Some(Stdio)
  | 1 => Some(Sse)
  | 2 => Some(WebSocket)
  | 3 => Some(StreamableHttp)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transportToTag = (v: transport): int =>
  switch v {
  | Stdio => 0
  | Sse => 1
  | WebSocket => 2
  | StreamableHttp => 3
  }

// ===========================================================================
// McpContentType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type mcpContentType =
  | @as(0) Text
  | @as(1) Image
  | @as(2) Resource
  | @as(3) Embedding

/// Decode from the C-ABI tag value.
let mcpContentTypeFromTag = (tag: int): option<mcpContentType> =>
  switch tag {
  | 0 => Some(Text)
  | 1 => Some(Image)
  | 2 => Some(Resource)
  | 3 => Some(Embedding)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mcpContentTypeToTag = (v: mcpContentType): int =>
  switch v {
  | Text => 0
  | Image => 1
  | Resource => 2
  | Embedding => 3
  }

// ===========================================================================
// McpErrorCode (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type mcpErrorCode =
  | @as(0) ParseError
  | @as(1) InvalidRequest
  | @as(2) MethodNotFound
  | @as(3) InvalidParams
  | @as(4) InternalError
  | @as(5) Timeout

/// Decode from the C-ABI tag value.
let mcpErrorCodeFromTag = (tag: int): option<mcpErrorCode> =>
  switch tag {
  | 0 => Some(ParseError)
  | 1 => Some(InvalidRequest)
  | 2 => Some(MethodNotFound)
  | 3 => Some(InvalidParams)
  | 4 => Some(InternalError)
  | 5 => Some(Timeout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mcpErrorCodeToTag = (v: mcpErrorCode): int =>
  switch v {
  | ParseError => 0
  | InvalidRequest => 1
  | MethodNotFound => 2
  | InvalidParams => 3
  | InternalError => 4
  | Timeout => 5
  }

// ===========================================================================
// McpCapability (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type mcpCapability =
  | @as(0) Tools
  | @as(1) Resources
  | @as(2) Prompts
  | @as(3) Logging
  | @as(4) Sampling

/// Decode from the C-ABI tag value.
let mcpCapabilityFromTag = (tag: int): option<mcpCapability> =>
  switch tag {
  | 0 => Some(Tools)
  | 1 => Some(Resources)
  | 2 => Some(Prompts)
  | 3 => Some(Logging)
  | 4 => Some(Sampling)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mcpCapabilityToTag = (v: mcpCapability): int =>
  switch v {
  | Tools => 0
  | Resources => 1
  | Prompts => 2
  | Logging => 3
  | Sampling => 4
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Connecting
  | @as(2) Ready
  | @as(3) Processing
  | @as(4) Disconnecting

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connecting)
  | 2 => Some(Ready)
  | 3 => Some(Processing)
  | 4 => Some(Disconnecting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Connecting => 1
  | Ready => 2
  | Processing => 3
  | Disconnecting => 4
  }

