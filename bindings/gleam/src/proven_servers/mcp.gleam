//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Model Context Protocol protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `McpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// McpMessageType
// ===========================================================================

/// MCP message types.
/// 
/// Matches `McpMessageType` in `McpABI.Types`.
pub type McpMessageType {
  /// Initialize (tag 0).
  Initialize
  /// Initialized (tag 1).
  Initialized
  /// Ping (tag 2).
  Ping
  /// CallTool (tag 3).
  CallTool
  /// ToolResult (tag 4).
  ToolResult
  /// ListTools (tag 5).
  ListTools
  /// ListResources (tag 6).
  ListResources
  /// ReadResource (tag 7).
  ReadResource
  /// ListPrompts (tag 8).
  ListPrompts
  /// GetPrompt (tag 9).
  GetPrompt
  /// Subscribe (tag 10).
  Subscribe
  /// Unsubscribe (tag 11).
  Unsubscribe
  /// Notification (tag 12).
  Notification
  /// Cancel (tag 13).
  Cancel
}

/// Convert a `McpMessageType` to its C-ABI tag value.
pub fn mcp_message_type_to_int(value: McpMessageType) -> Int {
  case value {
    Initialize -> 0
    Initialized -> 1
    Ping -> 2
    CallTool -> 3
    ToolResult -> 4
    ListTools -> 5
    ListResources -> 6
    ReadResource -> 7
    ListPrompts -> 8
    GetPrompt -> 9
    Subscribe -> 10
    Unsubscribe -> 11
    Notification -> 12
    Cancel -> 13
  }
}

/// Decode from a C-ABI tag value.
pub fn mcp_message_type_from_int(tag: Int) -> Result(McpMessageType, Nil) {
  case tag {
    0 -> Ok(Initialize)
    1 -> Ok(Initialized)
    2 -> Ok(Ping)
    3 -> Ok(CallTool)
    4 -> Ok(ToolResult)
    5 -> Ok(ListTools)
    6 -> Ok(ListResources)
    7 -> Ok(ReadResource)
    8 -> Ok(ListPrompts)
    9 -> Ok(GetPrompt)
    10 -> Ok(Subscribe)
    11 -> Ok(Unsubscribe)
    12 -> Ok(Notification)
    13 -> Ok(Cancel)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Transport
// ===========================================================================

/// MCP transport types.
/// 
/// Matches `Transport` in `McpABI.Types`.
pub type Transport {
  /// Stdio (tag 0).
  Stdio
  /// SSE (tag 1).
  Sse
  /// WebSocket (tag 2).
  WebSocket
  /// Streamable HTTP (tag 3).
  StreamableHttp
}

/// Convert a `Transport` to its C-ABI tag value.
pub fn transport_to_int(value: Transport) -> Int {
  case value {
    Stdio -> 0
    Sse -> 1
    WebSocket -> 2
    StreamableHttp -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn transport_from_int(tag: Int) -> Result(Transport, Nil) {
  case tag {
    0 -> Ok(Stdio)
    1 -> Ok(Sse)
    2 -> Ok(WebSocket)
    3 -> Ok(StreamableHttp)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// McpContentType
// ===========================================================================

/// MCP content types.
/// 
/// Matches `McpContentType` in `McpABI.Types`.
pub type McpContentType {
  /// Text (tag 0).
  Text
  /// Image (tag 1).
  Image
  /// Resource (tag 2).
  Resource
  /// Embedding (tag 3).
  Embedding
}

/// Convert a `McpContentType` to its C-ABI tag value.
pub fn mcp_content_type_to_int(value: McpContentType) -> Int {
  case value {
    Text -> 0
    Image -> 1
    Resource -> 2
    Embedding -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn mcp_content_type_from_int(tag: Int) -> Result(McpContentType, Nil) {
  case tag {
    0 -> Ok(Text)
    1 -> Ok(Image)
    2 -> Ok(Resource)
    3 -> Ok(Embedding)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// McpErrorCode
// ===========================================================================

/// MCP error codes.
/// 
/// Matches `McpErrorCode` in `McpABI.Types`.
pub type McpErrorCode {
  /// ParseError (tag 0).
  ParseError
  /// InvalidRequest (tag 1).
  InvalidRequest
  /// MethodNotFound (tag 2).
  MethodNotFound
  /// InvalidParams (tag 3).
  InvalidParams
  /// InternalError (tag 4).
  InternalError
  /// Timeout (tag 5).
  Timeout
}

/// Convert a `McpErrorCode` to its C-ABI tag value.
pub fn mcp_error_code_to_int(value: McpErrorCode) -> Int {
  case value {
    ParseError -> 0
    InvalidRequest -> 1
    MethodNotFound -> 2
    InvalidParams -> 3
    InternalError -> 4
    Timeout -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn mcp_error_code_from_int(tag: Int) -> Result(McpErrorCode, Nil) {
  case tag {
    0 -> Ok(ParseError)
    1 -> Ok(InvalidRequest)
    2 -> Ok(MethodNotFound)
    3 -> Ok(InvalidParams)
    4 -> Ok(InternalError)
    5 -> Ok(Timeout)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// McpCapability
// ===========================================================================

/// MCP server capabilities.
/// 
/// Matches `McpCapability` in `McpABI.Types`.
pub type McpCapability {
  /// Tools (tag 0).
  Tools
  /// Resources (tag 1).
  Resources
  /// Prompts (tag 2).
  Prompts
  /// Logging (tag 3).
  Logging
  /// Sampling (tag 4).
  Sampling
}

/// Convert a `McpCapability` to its C-ABI tag value.
pub fn mcp_capability_to_int(value: McpCapability) -> Int {
  case value {
    Tools -> 0
    Resources -> 1
    Prompts -> 2
    Logging -> 3
    Sampling -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn mcp_capability_from_int(tag: Int) -> Result(McpCapability, Nil) {
  case tag {
    0 -> Ok(Tools)
    1 -> Ok(Resources)
    2 -> Ok(Prompts)
    3 -> Ok(Logging)
    4 -> Ok(Sampling)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// MCP session lifecycle states.
/// 
/// Matches `SessionState` in `McpABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Connecting (tag 1).
  Connecting
  /// Ready (tag 2).
  Ready
  /// Processing (tag 3).
  Processing
  /// Disconnecting (tag 4).
  Disconnecting
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Connecting -> 1
    Ready -> 2
    Processing -> 3
    Disconnecting -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connecting)
    2 -> Ok(Ready)
    3 -> Ok(Processing)
    4 -> Ok(Disconnecting)
    _ -> Error(Nil)
  }
}

