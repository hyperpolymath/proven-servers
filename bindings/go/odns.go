// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// ODNS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Role represents the Role type (Idris2 ABI tags).
type Role uint8

const (
	RoleClient Role = iota
	RoleProxy
	RoleTarget
)

// OdnsMessageType represents the OdnsMessageType type (Idris2 ABI tags).
type OdnsMessageType uint8

const (
	OdnsMessageTypeQuery OdnsMessageType = iota
	OdnsMessageTypeResponse
)

// OdnsErrorReason represents the OdnsErrorReason type (Idris2 ABI tags).
type OdnsErrorReason uint8

const (
	OdnsErrorReasonProxyError OdnsErrorReason = iota
	OdnsErrorReasonTargetError
	OdnsErrorReasonDecryptionFailed
	OdnsErrorReasonInvalidConfig
	OdnsErrorReasonPayloadTooLarge
)

// EncapsulationFormat represents the EncapsulationFormat type (Idris2 ABI tags).
type EncapsulationFormat uint8

const (
	EncapsulationFormatHpke EncapsulationFormat = iota
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateKeyExchange
	SessionStateReady
	SessionStateProcessing
	SessionStateClosing
)
