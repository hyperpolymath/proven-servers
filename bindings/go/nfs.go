// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// NFS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Operation represents the Operation type (Idris2 ABI tags).
type Operation uint8

const (
	OperationAccess Operation = iota
	OperationClose
	OperationCommit
	OperationCreate
	OperationGetAttr
	OperationLink
	OperationLock
	OperationLookup
	OperationOpen
	OperationRead
	OperationReadDir
	OperationRemove
	OperationRename
	OperationSetAttr
	OperationWrite
)

// FileType represents the FileType type (Idris2 ABI tags).
type FileType uint8

const (
	FileTypeRegular FileType = iota
	FileTypeDirectory
	FileTypeBlockDevice
	FileTypeCharDevice
	FileTypeLink
	FileTypeSocket
	FileTypeFifo
)

// Status represents the Status type (Idris2 ABI tags).
type Status uint8

const (
	StatusOk Status = iota
	StatusPerm
	StatusNoEnt
	StatusIo
	StatusNxIo
	StatusAccess
	StatusExist
	StatusNotDir
	StatusIsDir
	StatusFBig
	StatusNoSpc
	StatusROfs
	StatusNotEmpty
	StatusStale
)

// NfsState represents the NfsState type (Idris2 ABI tags).
type NfsState uint8

const (
	NfsStateIdle NfsState = iota
	NfsStateMounted
	NfsStateFileOpen
	NfsStateLocked
	NfsStateBusy
	NfsStateUnmounting
)
