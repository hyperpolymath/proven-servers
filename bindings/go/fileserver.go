// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// File Server protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// FileOperation represents the FileOperation type (Idris2 ABI tags).
type FileOperation uint8

const (
	FileOperationRead FileOperation = iota
	FileOperationWrite
	FileOperationCreate
	FileOperationDelete
	FileOperationRename
	FileOperationList
	FileOperationStat
	FileOperationLock
	FileOperationUnlock
	FileOperationWatch
)

// FileType represents the FileType type (Idris2 ABI tags).
type FileType uint8

const (
	FileTypeRegular FileType = iota
	FileTypeDirectory
	FileTypeSymlink
	FileTypeBlockDevice
	FileTypeCharDevice
	FileTypeFifo
	FileTypeSocket
)

// FilePermission represents the FilePermission type (Idris2 ABI tags).
type FilePermission uint8

const (
	FilePermissionOwnerRead FilePermission = iota
	FilePermissionOwnerWrite
	FilePermissionOwnerExecute
	FilePermissionGroupRead
	FilePermissionGroupWrite
	FilePermissionGroupExecute
	FilePermissionOtherRead
	FilePermissionOtherWrite
	FilePermissionOtherExecute
)

// LockType represents the LockType type (Idris2 ABI tags).
type LockType uint8

const (
	LockTypeShared LockType = iota
	LockTypeExclusive
	LockTypeAdvisory
	LockTypeMandatory
)

// FileErrorCode represents the FileErrorCode type (Idris2 ABI tags).
type FileErrorCode uint8

const (
	FileErrorCodeNotFound FileErrorCode = iota
	FileErrorCodePermissionDenied
	FileErrorCodeAlreadyExists
	FileErrorCodeNotEmpty
	FileErrorCodeIsDirectory
	FileErrorCodeNotDirectory
	FileErrorCodeNoSpace
	FileErrorCodeReadOnly
	FileErrorCodeLocked
	FileErrorCodeIoError
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateConnected
	SessionStateOperating
	SessionStateFsLocked
	SessionStateDisconnecting
)
