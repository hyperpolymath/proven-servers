-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- abi.Types: C-ABI-compatible numeric representations of MCP types.
--
-- Maps every constructor of the core MCP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/mcp.zig)
-- exactly.
--
-- Types covered:
--   MessageType     (14 constructors, tags 0-13)
--   Transport       (4 constructors, tags 0-3)
--   ContentType     (4 constructors, tags 0-3)
--   ErrorCode       (6 constructors, tags 0-5)
--   Capability      (5 constructors, tags 0-4)
--   SessionState    (5 constructors, tags 0-4)

module abi.Types

import Mcp.Types

%default total

---------------------------------------------------------------------------
-- MessageType (14 constructors, tags 0-13)
---------------------------------------------------------------------------

public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Initialize    = 0
messageTypeToTag Initialized   = 1
messageTypeToTag Ping          = 2
messageTypeToTag CallTool      = 3
messageTypeToTag ToolResult    = 4
messageTypeToTag ListTools     = 5
messageTypeToTag ListResources = 6
messageTypeToTag ReadResource  = 7
messageTypeToTag ListPrompts   = 8
messageTypeToTag GetPrompt     = 9
messageTypeToTag Subscribe     = 10
messageTypeToTag Unsubscribe   = 11
messageTypeToTag Notification  = 12
messageTypeToTag Cancel        = 13

public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0  = Just Initialize
tagToMessageType 1  = Just Initialized
tagToMessageType 2  = Just Ping
tagToMessageType 3  = Just CallTool
tagToMessageType 4  = Just ToolResult
tagToMessageType 5  = Just ListTools
tagToMessageType 6  = Just ListResources
tagToMessageType 7  = Just ReadResource
tagToMessageType 8  = Just ListPrompts
tagToMessageType 9  = Just GetPrompt
tagToMessageType 10 = Just Subscribe
tagToMessageType 11 = Just Unsubscribe
tagToMessageType 12 = Just Notification
tagToMessageType 13 = Just Cancel
tagToMessageType _  = Nothing

public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Initialize    = Refl
messageTypeRoundtrip Initialized   = Refl
messageTypeRoundtrip Ping          = Refl
messageTypeRoundtrip CallTool      = Refl
messageTypeRoundtrip ToolResult    = Refl
messageTypeRoundtrip ListTools     = Refl
messageTypeRoundtrip ListResources = Refl
messageTypeRoundtrip ReadResource  = Refl
messageTypeRoundtrip ListPrompts   = Refl
messageTypeRoundtrip GetPrompt     = Refl
messageTypeRoundtrip Subscribe     = Refl
messageTypeRoundtrip Unsubscribe   = Refl
messageTypeRoundtrip Notification  = Refl
messageTypeRoundtrip Cancel        = Refl

---------------------------------------------------------------------------
-- Transport (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
transportToTag : Transport -> Bits8
transportToTag Stdio          = 0
transportToTag SSE            = 1
transportToTag WebSocket      = 2
transportToTag StreamableHTTP = 3

public export
tagToTransport : Bits8 -> Maybe Transport
tagToTransport 0 = Just Stdio
tagToTransport 1 = Just SSE
tagToTransport 2 = Just WebSocket
tagToTransport 3 = Just StreamableHTTP
tagToTransport _ = Nothing

public export
transportRoundtrip : (t : Transport) -> tagToTransport (transportToTag t) = Just t
transportRoundtrip Stdio          = Refl
transportRoundtrip SSE            = Refl
transportRoundtrip WebSocket      = Refl
transportRoundtrip StreamableHTTP = Refl

---------------------------------------------------------------------------
-- ContentType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
contentTypeToTag : ContentType -> Bits8
contentTypeToTag Text      = 0
contentTypeToTag Image     = 1
contentTypeToTag Resource  = 2
contentTypeToTag Embedding = 3

public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just Text
tagToContentType 1 = Just Image
tagToContentType 2 = Just Resource
tagToContentType 3 = Just Embedding
tagToContentType _ = Nothing

public export
contentTypeRoundtrip : (c : ContentType) -> tagToContentType (contentTypeToTag c) = Just c
contentTypeRoundtrip Text      = Refl
contentTypeRoundtrip Image     = Refl
contentTypeRoundtrip Resource  = Refl
contentTypeRoundtrip Embedding = Refl

---------------------------------------------------------------------------
-- ErrorCode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag ParseError     = 0
errorCodeToTag InvalidRequest = 1
errorCodeToTag MethodNotFound = 2
errorCodeToTag InvalidParams  = 3
errorCodeToTag InternalError  = 4
errorCodeToTag Timeout        = 5

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just ParseError
tagToErrorCode 1 = Just InvalidRequest
tagToErrorCode 2 = Just MethodNotFound
tagToErrorCode 3 = Just InvalidParams
tagToErrorCode 4 = Just InternalError
tagToErrorCode 5 = Just Timeout
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip ParseError     = Refl
errorCodeRoundtrip InvalidRequest = Refl
errorCodeRoundtrip MethodNotFound = Refl
errorCodeRoundtrip InvalidParams  = Refl
errorCodeRoundtrip InternalError  = Refl
errorCodeRoundtrip Timeout        = Refl

---------------------------------------------------------------------------
-- Capability (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
capabilityToTag : Capability -> Bits8
capabilityToTag Tools     = 0
capabilityToTag Resources = 1
capabilityToTag Prompts   = 2
capabilityToTag Logging   = 3
capabilityToTag Sampling  = 4

public export
tagToCapability : Bits8 -> Maybe Capability
tagToCapability 0 = Just Tools
tagToCapability 1 = Just Resources
tagToCapability 2 = Just Prompts
tagToCapability 3 = Just Logging
tagToCapability 4 = Just Sampling
tagToCapability _ = Nothing

public export
capabilityRoundtrip : (c : Capability) -> tagToCapability (capabilityToTag c) = Just c
capabilityRoundtrip Tools     = Refl
capabilityRoundtrip Resources = Refl
capabilityRoundtrip Prompts   = Refl
capabilityRoundtrip Logging   = Refl
capabilityRoundtrip Sampling  = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| MCP server session lifecycle states.
||| This is a simplified view used by the FFI layer, combining
||| transport + protocol states into a single enum for the C ABI.
public export
data SessionState : Type where
  ||| No connection. Initial and terminal state.
  SSIdle          : SessionState
  ||| Transport connected, awaiting Initialize message.
  SSConnecting    : SessionState
  ||| Initialize received, capabilities exchanged.
  SSReady         : SessionState
  ||| Actively processing tool/resource/prompt requests.
  SSProcessing    : SessionState
  ||| Session closing (shutdown handshake in progress).
  SSDisconnecting : SessionState

public export
Eq SessionState where
  SSIdle          == SSIdle          = True
  SSConnecting    == SSConnecting    = True
  SSReady         == SSReady         = True
  SSProcessing    == SSProcessing    = True
  SSDisconnecting == SSDisconnecting = True
  _               == _               = False

public export
Show SessionState where
  show SSIdle          = "Idle"
  show SSConnecting    = "Connecting"
  show SSReady         = "Ready"
  show SSProcessing    = "Processing"
  show SSDisconnecting = "Disconnecting"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle          = 0
sessionStateToTag SSConnecting    = 1
sessionStateToTag SSReady         = 2
sessionStateToTag SSProcessing    = 3
sessionStateToTag SSDisconnecting = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSConnecting
tagToSessionState 2 = Just SSReady
tagToSessionState 3 = Just SSProcessing
tagToSessionState 4 = Just SSDisconnecting
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle          = Refl
sessionStateRoundtrip SSConnecting    = Refl
sessionStateRoundtrip SSReady         = Refl
sessionStateRoundtrip SSProcessing    = Refl
sessionStateRoundtrip SSDisconnecting = Refl
