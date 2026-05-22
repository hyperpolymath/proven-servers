// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// NETCONF protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// NetconfOperation represents the NetconfOperation type (Idris2 ABI tags).
type NetconfOperation uint8

const (
	NetconfOperationGet NetconfOperation = iota
	NetconfOperationGetConfig
	NetconfOperationEditConfig
	NetconfOperationCopyConfig
	NetconfOperationDeleteConfig
	NetconfOperationLock
	NetconfOperationUnlock
	NetconfOperationCloseSession
	NetconfOperationKillSession
	NetconfOperationCommit
	NetconfOperationValidate
	NetconfOperationDiscardChanges
)

// Datastore represents the Datastore type (Idris2 ABI tags).
type Datastore uint8

const (
	DatastoreRunning Datastore = iota
	DatastoreStartup
	DatastoreCandidate
)

// EditOperation represents the EditOperation type (Idris2 ABI tags).
type EditOperation uint8

const (
	EditOperationMerge EditOperation = iota
	EditOperationReplace
	EditOperationCreate
	EditOperationDelete
	EditOperationRemove
)

// NetconfErrorType represents the NetconfErrorType type (Idris2 ABI tags).
type NetconfErrorType uint8

const (
	NetconfErrorTypeTransport NetconfErrorType = iota
	NetconfErrorTypeRpc
	NetconfErrorTypeProtocol
	NetconfErrorTypeApplication
)

// ErrorSeverity represents the ErrorSeverity type (Idris2 ABI tags).
type ErrorSeverity uint8

const (
	ErrorSeverityError ErrorSeverity = iota
	ErrorSeverityWarning
)

// NetconfState represents the NetconfState type (Idris2 ABI tags).
type NetconfState uint8

const (
	NetconfStateIdle NetconfState = iota
	NetconfStateConnected
	NetconfStateLocked
	NetconfStateEditing
	NetconfStateClosing
	NetconfStateTerminated
)
