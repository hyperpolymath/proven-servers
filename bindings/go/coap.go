// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// CoAP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Method represents the Method type (Idris2 ABI tags).
type Method uint8

const (
	MethodGet Method = iota
	MethodPost
	MethodPut
	MethodDelete
)

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeConfirmable MessageType = iota
	MessageTypeNonConfirmable
	MessageTypeAcknowledgement
	MessageTypeReset
)

// ContentFormat represents the ContentFormat type (Idris2 ABI tags).
type ContentFormat uint8

const (
	ContentFormatTextPlain ContentFormat = iota
	ContentFormatLinkFormat
	ContentFormatXml
	ContentFormatOctetStream
	ContentFormatExi
	ContentFormatJson
	ContentFormatCbor
)

// ResponseClass represents the ResponseClass type (Idris2 ABI tags).
type ResponseClass uint8

const (
	ResponseClassSuccess ResponseClass = iota
	ResponseClassClientError
	ResponseClassServerError
	ResponseClassSignaling
	ResponseClassEmpty
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateBound
	SessionStateServing
	SessionStateObserving
	SessionStateShutdown
)
