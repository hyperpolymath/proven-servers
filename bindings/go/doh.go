// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// DoH protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ContentType represents the ContentType type (Idris2 ABI tags).
type ContentType uint8

const (
	ContentTypeDnsMessage ContentType = iota
	ContentTypeDnsJson
)

// RequestMethod represents the RequestMethod type (Idris2 ABI tags).
type RequestMethod uint8

const (
	RequestMethodGet RequestMethod = iota
	RequestMethodPost
)

// WireFormat represents the WireFormat type (Idris2 ABI tags).
type WireFormat uint8

const (
	WireFormatBinary WireFormat = iota
	WireFormatJson
)

// ErrorReason represents the ErrorReason type (Idris2 ABI tags).
type ErrorReason uint8

const (
	ErrorReasonBadContentType ErrorReason = iota
	ErrorReasonBadMethod
	ErrorReasonPayloadTooLarge
	ErrorReasonUpstreamTimeout
	ErrorReasonUpstreamError
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateBound
	SessionStateServing
	SessionStateResolving
	SessionStateShutdown
)
