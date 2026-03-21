// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! MCP types for the proven-servers ABI.
//!
//! Formally verified Model Context Protocol types.
//! Mirrors the Idris2 module `McpABI.Types`.
//!
//! - `McpMessageType` -- MCP message types.
//! - `Transport` -- MCP transport types.
//! - `McpContentType` -- MCP content types.
//! - `McpErrorCode` -- MCP error codes.
//! - `McpCapability` -- MCP server capabilities.
//! - `SessionState` -- MCP session lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// McpMessageType (tags 0-13)
// ===========================================================================

/// MCP message types.
///
/// Matches `McpMessageType` in `McpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum McpMessageType {
    /// Initialize (tag 0).
    Initialize = 0,
    /// Initialized (tag 1).
    Initialized = 1,
    /// Ping (tag 2).
    Ping = 2,
    /// CallTool (tag 3).
    CallTool = 3,
    /// ToolResult (tag 4).
    ToolResult = 4,
    /// ListTools (tag 5).
    ListTools = 5,
    /// ListResources (tag 6).
    ListResources = 6,
    /// ReadResource (tag 7).
    ReadResource = 7,
    /// ListPrompts (tag 8).
    ListPrompts = 8,
    /// GetPrompt (tag 9).
    GetPrompt = 9,
    /// Subscribe (tag 10).
    Subscribe = 10,
    /// Unsubscribe (tag 11).
    Unsubscribe = 11,
    /// Notification (tag 12).
    Notification = 12,
    /// Cancel (tag 13).
    Cancel = 13,
}

impl McpMessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initialize),
            1 => Some(Self::Initialized),
            2 => Some(Self::Ping),
            3 => Some(Self::CallTool),
            4 => Some(Self::ToolResult),
            5 => Some(Self::ListTools),
            6 => Some(Self::ListResources),
            7 => Some(Self::ReadResource),
            8 => Some(Self::ListPrompts),
            9 => Some(Self::GetPrompt),
            10 => Some(Self::Subscribe),
            11 => Some(Self::Unsubscribe),
            12 => Some(Self::Notification),
            13 => Some(Self::Cancel),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [McpMessageType; 14] = [
        Self::Initialize, Self::Initialized, Self::Ping, Self::CallTool, Self::ToolResult, Self::ListTools, Self::ListResources, Self::ReadResource, Self::ListPrompts, Self::GetPrompt, Self::Subscribe, Self::Unsubscribe, Self::Notification, Self::Cancel,
    ];
}

impl fmt::Display for McpMessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Transport (tags 0-3)
// ===========================================================================

/// MCP transport types.
///
/// Matches `Transport` in `McpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Transport {
    /// Stdio (tag 0).
    Stdio = 0,
    /// SSE (tag 1).
    Sse = 1,
    /// WebSocket (tag 2).
    WebSocket = 2,
    /// Streamable HTTP (tag 3).
    StreamableHttp = 3,
}

impl Transport {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Stdio),
            1 => Some(Self::Sse),
            2 => Some(Self::WebSocket),
            3 => Some(Self::StreamableHttp),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Transport; 4] = [
        Self::Stdio, Self::Sse, Self::WebSocket, Self::StreamableHttp,
    ];
}

impl fmt::Display for Transport {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// McpContentType (tags 0-3)
// ===========================================================================

/// MCP content types.
///
/// Matches `McpContentType` in `McpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum McpContentType {
    /// Text (tag 0).
    Text = 0,
    /// Image (tag 1).
    Image = 1,
    /// Resource (tag 2).
    Resource = 2,
    /// Embedding (tag 3).
    Embedding = 3,
}

impl McpContentType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Text),
            1 => Some(Self::Image),
            2 => Some(Self::Resource),
            3 => Some(Self::Embedding),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [McpContentType; 4] = [
        Self::Text, Self::Image, Self::Resource, Self::Embedding,
    ];
}

impl fmt::Display for McpContentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// McpErrorCode (tags 0-5)
// ===========================================================================

/// MCP error codes.
///
/// Matches `McpErrorCode` in `McpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum McpErrorCode {
    /// ParseError (tag 0).
    ParseError = 0,
    /// InvalidRequest (tag 1).
    InvalidRequest = 1,
    /// MethodNotFound (tag 2).
    MethodNotFound = 2,
    /// InvalidParams (tag 3).
    InvalidParams = 3,
    /// InternalError (tag 4).
    InternalError = 4,
    /// Timeout (tag 5).
    Timeout = 5,
}

impl McpErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ParseError),
            1 => Some(Self::InvalidRequest),
            2 => Some(Self::MethodNotFound),
            3 => Some(Self::InvalidParams),
            4 => Some(Self::InternalError),
            5 => Some(Self::Timeout),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [McpErrorCode; 6] = [
        Self::ParseError, Self::InvalidRequest, Self::MethodNotFound, Self::InvalidParams, Self::InternalError, Self::Timeout,
    ];
}

impl fmt::Display for McpErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// McpCapability (tags 0-4)
// ===========================================================================

/// MCP server capabilities.
///
/// Matches `McpCapability` in `McpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum McpCapability {
    /// Tools (tag 0).
    Tools = 0,
    /// Resources (tag 1).
    Resources = 1,
    /// Prompts (tag 2).
    Prompts = 2,
    /// Logging (tag 3).
    Logging = 3,
    /// Sampling (tag 4).
    Sampling = 4,
}

impl McpCapability {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Tools),
            1 => Some(Self::Resources),
            2 => Some(Self::Prompts),
            3 => Some(Self::Logging),
            4 => Some(Self::Sampling),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [McpCapability; 5] = [
        Self::Tools, Self::Resources, Self::Prompts, Self::Logging, Self::Sampling,
    ];
}

impl fmt::Display for McpCapability {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// MCP session lifecycle states.
///
/// Matches `SessionState` in `McpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Connecting (tag 1).
    Connecting = 1,
    /// Ready (tag 2).
    Ready = 2,
    /// Processing (tag 3).
    Processing = 3,
    /// Disconnecting (tag 4).
    Disconnecting = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connecting),
            2 => Some(Self::Ready),
            3 => Some(Self::Processing),
            4 => Some(Self::Disconnecting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Connecting, Self::Ready, Self::Processing, Self::Disconnecting,
    ];
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mcp_message_type_roundtrip() {
        for v in McpMessageType::ALL {
            let tag = v.to_tag();
            let decoded = McpMessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(McpMessageType::from_tag(14).is_none());
    }

    #[test]
    fn transport_roundtrip() {
        for v in Transport::ALL {
            let tag = v.to_tag();
            let decoded = Transport::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Transport::from_tag(4).is_none());
    }

    #[test]
    fn mcp_content_type_roundtrip() {
        for v in McpContentType::ALL {
            let tag = v.to_tag();
            let decoded = McpContentType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(McpContentType::from_tag(4).is_none());
    }

    #[test]
    fn mcp_error_code_roundtrip() {
        for v in McpErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = McpErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(McpErrorCode::from_tag(6).is_none());
    }

    #[test]
    fn mcp_capability_roundtrip() {
        for v in McpCapability::ALL {
            let tag = v.to_tag();
            let decoded = McpCapability::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(McpCapability::from_tag(5).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

}
