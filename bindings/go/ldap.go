// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// LDAP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateAnonymous SessionState = iota
	SessionStateBound
	SessionStateClosed
	SessionStateBinding
)

// Operation represents the Operation type (Idris2 ABI tags).
type Operation uint8

const (
	OperationBind Operation = iota
	OperationUnbind
	OperationSearch
	OperationModify
	OperationAdd
	OperationDelete
	OperationModDn
	OperationCompare
	OperationAbandon
	OperationExtended
)

// SearchScope represents the SearchScope type (Idris2 ABI tags).
type SearchScope uint8

const (
	SearchScopeBaseObject SearchScope = iota
	SearchScopeSingleLevel
	SearchScopeWholeSubtree
)

// ResultCode represents the ResultCode type (Idris2 ABI tags).
type ResultCode uint8

const (
	ResultCodeSuccess ResultCode = iota
	ResultCodeOperationsError
	ResultCodeProtocolError
	ResultCodeTimeLimitExceeded
	ResultCodeSizeLimitExceeded
	ResultCodeAuthMethodNotSupported
	ResultCodeNoSuchObject
	ResultCodeInvalidCredentials
	ResultCodeInsufficientAccessRights
	ResultCodeBusy
	ResultCodeUnavailable
)
