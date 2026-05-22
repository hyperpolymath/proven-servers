// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SNMP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Version represents the Version type (Idris2 ABI tags).
type Version uint8

const (
	VersionV1 Version = iota
	VersionV2c
	VersionV3
)

// PduType represents the PduType type (Idris2 ABI tags).
type PduType uint8

const (
	PduTypeGetRequest PduType = iota
	PduTypeGetNextRequest
	PduTypeGetResponse
	PduTypeSetRequest
	PduTypeGetBulkRequest
	PduTypeInformRequest
	PduTypeSnmpV2Trap
)

// ErrorStatus represents the ErrorStatus type (Idris2 ABI tags).
type ErrorStatus uint8

const (
	ErrorStatusNoError ErrorStatus = iota
	ErrorStatusTooBig
	ErrorStatusNoSuchName
	ErrorStatusBadValue
	ErrorStatusReadOnly
	ErrorStatusGenErr
	ErrorStatusNoAccess
	ErrorStatusWrongType
	ErrorStatusWrongLength
	ErrorStatusWrongValue
	ErrorStatusNoCreation
	ErrorStatusInconsistentValue
	ErrorStatusResourceUnavailable
	ErrorStatusCommitFailed
	ErrorStatusUndoFailed
	ErrorStatusAuthorizationError
)
