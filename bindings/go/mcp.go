// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// MCP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// McpMessageType represents the McpMessageType type (Idris2 ABI tags).
type McpMessageType uint8

const (
	McpMessageTypeInitialize McpMessageType = iota
	McpMessageTypeInitialized
	McpMessageTypePing
	McpMessageTypeCallTool
	McpMessageTypeToolResult
	McpMessageTypeListTools
	McpMessageTypeListResources
	McpMessageTypeReadResource
	McpMessageTypeListPrompts
	McpMessageTypeGetPrompt
	McpMessageTypeSubscribe
	McpMessageTypeUnsubscribe
	McpMessageTypeNotification
	McpMessageTypeCancel
)

// Transport represents the Transport type (Idris2 ABI tags).
type Transport uint8

const (
	TransportStdio Transport = iota
	TransportSse
	TransportWebSocket
	TransportStreamableHttp
)

// McpContentType represents the McpContentType type (Idris2 ABI tags).
type McpContentType uint8

const (
	McpContentTypeText McpContentType = iota
	McpContentTypeImage
	McpContentTypeResource
	McpContentTypeEmbedding
)

// McpErrorCode represents the McpErrorCode type (Idris2 ABI tags).
type McpErrorCode uint8

const (
	McpErrorCodeParseError McpErrorCode = iota
	McpErrorCodeInvalidRequest
	McpErrorCodeMethodNotFound
	McpErrorCodeInvalidParams
	McpErrorCodeInternalError
	McpErrorCodeTimeout
)

// McpCapability represents the McpCapability type (Idris2 ABI tags).
type McpCapability uint8

const (
	McpCapabilityTools McpCapability = iota
	McpCapabilityResources
	McpCapabilityPrompts
	McpCapabilityLogging
	McpCapabilitySampling
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateConnecting
	SessionStateReady
	SessionStateProcessing
	SessionStateDisconnecting
)
