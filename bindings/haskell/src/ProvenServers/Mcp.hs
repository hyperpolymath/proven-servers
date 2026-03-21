-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | MCP protocol types for proven-servers.
--
-- Model Context Protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Mcp
  ( -- * ADT types matching Idris2 ABI
      McpMessageType(..)
    , Transport(..)
    , McpContentType(..)
    , McpErrorCode(..)
    , McpCapability(..)
    , SessionState(..)
    , mcpMessageTypeToTag
    , mcpMessageTypeFromTag
    , transportToTag
    , transportFromTag
    , mcpContentTypeToTag
    , mcpContentTypeFromTag
    , mcpErrorCodeToTag
    , mcpErrorCodeFromTag
    , mcpCapabilityToTag
    , mcpCapabilityFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- McpMessageType
-- ---------------------------------------------------------------------------

-- | McpMessageType type matching the Idris2 ABI.
--
-- Tags 0-13 (14 constructors).
data McpMessageType
  = Initialize  -- ^ Tag 0.
  | Initialized  -- ^ Tag 1.
  | Ping  -- ^ Tag 2.
  | CallTool  -- ^ Tag 3.
  | ToolResult  -- ^ Tag 4.
  | ListTools  -- ^ Tag 5.
  | ListResources  -- ^ Tag 6.
  | ReadResource  -- ^ Tag 7.
  | ListPrompts  -- ^ Tag 8.
  | GetPrompt  -- ^ Tag 9.
  | Subscribe  -- ^ Tag 10.
  | Unsubscribe  -- ^ Tag 11.
  | Notification  -- ^ Tag 12.
  | Cancel  -- ^ Tag 13.
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

-- | Transport type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data Transport
  = Stdio  -- ^ Tag 0.
  | Sse  -- ^ Tag 1.
  | WebSocket  -- ^ Tag 2.
  | StreamableHttp  -- ^ Tag 3.
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

-- | McpContentType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data McpContentType
  = Text  -- ^ Tag 0.
  | Image  -- ^ Tag 1.
  | Resource  -- ^ Tag 2.
  | Embedding  -- ^ Tag 3.
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

-- | McpErrorCode type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data McpErrorCode
  = ParseError  -- ^ Tag 0.
  | InvalidRequest  -- ^ Tag 1.
  | MethodNotFound  -- ^ Tag 2.
  | InvalidParams  -- ^ Tag 3.
  | InternalError  -- ^ Tag 4.
  | Timeout  -- ^ Tag 5.
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

-- | McpCapability type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data McpCapability
  = Tools  -- ^ Tag 0.
  | Resources  -- ^ Tag 1.
  | Prompts  -- ^ Tag 2.
  | Logging  -- ^ Tag 3.
  | Sampling  -- ^ Tag 4.
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

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Connecting  -- ^ Tag 1.
  | Ready  -- ^ Tag 2.
  | Processing  -- ^ Tag 3.
  | Disconnecting  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
