-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | MCP types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Mcp
  (
    McpMessageType(..)
  , mcpMessageTypeToTag
  , mcpMessageTypeFromTag
  , Transport(..)
  , transportToTag
  , transportFromTag
  , McpContentType(..)
  , mcpContentTypeToTag
  , mcpContentTypeFromTag
  , McpErrorCode(..)
  , mcpErrorCodeToTag
  , mcpErrorCodeFromTag
  , McpCapability(..)
  , mcpCapabilityToTag
  , mcpCapabilityFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- McpMessageType
-- ---------------------------------------------------------------------------

-- | MCP message types.
--
-- Tags 0-13 (14 constructors).
data McpMessageType
  = Initialize  -- ^ Initialize (tag 0).
  | Initialized  -- ^ Initialized (tag 1).
  | Ping  -- ^ Ping (tag 2).
  | CallTool  -- ^ CallTool (tag 3).
  | ToolResult  -- ^ ToolResult (tag 4).
  | ListTools  -- ^ ListTools (tag 5).
  | ListResources  -- ^ ListResources (tag 6).
  | ReadResource  -- ^ ReadResource (tag 7).
  | ListPrompts  -- ^ ListPrompts (tag 8).
  | GetPrompt  -- ^ GetPrompt (tag 9).
  | Subscribe  -- ^ Subscribe (tag 10).
  | Unsubscribe  -- ^ Unsubscribe (tag 11).
  | Notification  -- ^ Notification (tag 12).
  | Cancel  -- ^ Cancel (tag 13).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'McpMessageType' to its ABI tag value.
mcpMessageTypeToTag :: McpMessageType -> Word8
mcpMessageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'McpMessageType' from its ABI tag value.
mcpMessageTypeFromTag :: Word8 -> Maybe McpMessageType
mcpMessageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: McpMessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Transport
-- ---------------------------------------------------------------------------

-- | MCP transport types.
--
-- Tags 0-3 (4 constructors).
data Transport
  = Stdio  -- ^ Stdio (tag 0).
  | Sse  -- ^ SSE (tag 1).
  | WebSocket  -- ^ WebSocket (tag 2).
  | StreamableHttp  -- ^ Streamable HTTP (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Transport' to its ABI tag value.
transportToTag :: Transport -> Word8
transportToTag = fromIntegral . fromEnum

-- | Decode a 'Transport' from its ABI tag value.
transportFromTag :: Word8 -> Maybe Transport
transportFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Transport)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- McpContentType
-- ---------------------------------------------------------------------------

-- | MCP content types.
--
-- Tags 0-3 (4 constructors).
data McpContentType
  = Text  -- ^ Text (tag 0).
  | Image  -- ^ Image (tag 1).
  | Resource  -- ^ Resource (tag 2).
  | Embedding  -- ^ Embedding (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'McpContentType' to its ABI tag value.
mcpContentTypeToTag :: McpContentType -> Word8
mcpContentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'McpContentType' from its ABI tag value.
mcpContentTypeFromTag :: Word8 -> Maybe McpContentType
mcpContentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: McpContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- McpErrorCode
-- ---------------------------------------------------------------------------

-- | MCP error codes.
--
-- Tags 0-5 (6 constructors).
data McpErrorCode
  = ParseError  -- ^ ParseError (tag 0).
  | InvalidRequest  -- ^ InvalidRequest (tag 1).
  | MethodNotFound  -- ^ MethodNotFound (tag 2).
  | InvalidParams  -- ^ InvalidParams (tag 3).
  | InternalError  -- ^ InternalError (tag 4).
  | Timeout  -- ^ Timeout (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'McpErrorCode' to its ABI tag value.
mcpErrorCodeToTag :: McpErrorCode -> Word8
mcpErrorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'McpErrorCode' from its ABI tag value.
mcpErrorCodeFromTag :: Word8 -> Maybe McpErrorCode
mcpErrorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: McpErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- McpCapability
-- ---------------------------------------------------------------------------

-- | MCP server capabilities.
--
-- Tags 0-4 (5 constructors).
data McpCapability
  = Tools  -- ^ Tools (tag 0).
  | Resources  -- ^ Resources (tag 1).
  | Prompts  -- ^ Prompts (tag 2).
  | Logging  -- ^ Logging (tag 3).
  | Sampling  -- ^ Sampling (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'McpCapability' to its ABI tag value.
mcpCapabilityToTag :: McpCapability -> Word8
mcpCapabilityToTag = fromIntegral . fromEnum

-- | Decode a 'McpCapability' from its ABI tag value.
mcpCapabilityFromTag :: Word8 -> Maybe McpCapability
mcpCapabilityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: McpCapability)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | MCP session lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Connecting  -- ^ Connecting (tag 1).
  | Ready  -- ^ Ready (tag 2).
  | Processing  -- ^ Processing (tag 3).
  | Disconnecting  -- ^ Disconnecting (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
