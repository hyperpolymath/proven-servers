// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// STUN/TURN protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeBindingRequest MessageType = iota
	MessageTypeBindingResponse
	MessageTypeBindingError
	MessageTypeAllocateRequest
	MessageTypeAllocateResponse
	MessageTypeAllocateError
	MessageTypeRefreshRequest
	MessageTypeRefreshResponse
	MessageTypeSendIndication
	MessageTypeDataIndication
	MessageTypeCreatePermission
	MessageTypeChannelBind
)

// TransportProtocol represents the TransportProtocol type (Idris2 ABI tags).
type TransportProtocol uint8

const (
	TransportProtocolUdp TransportProtocol = iota
	TransportProtocolTcp
	TransportProtocolTls
	TransportProtocolDtls
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeTryAlternate ErrorCode = iota
	ErrorCodeBadRequest
	ErrorCodeUnauthorized
	ErrorCodeForbidden
	ErrorCodeMobilityForbidden
	ErrorCodeStaleNonce
	ErrorCodeServerError
	ErrorCodeInsufficientCapacity
)
