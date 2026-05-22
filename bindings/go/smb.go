// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SMB protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandNegotiate Command = iota
	CommandSessionSetup
	CommandLogoff
	CommandTreeConnect
	CommandTreeDisconnect
	CommandCreate
	CommandClose
	CommandRead
	CommandWrite
	CommandLock
	CommandIoctl
	CommandCancel
	CommandQueryDirectory
	CommandChangeNotify
	CommandQueryInfo
	CommandSetInfo
)

// Dialect represents the Dialect type (Idris2 ABI tags).
type Dialect uint8

const (
	DialectSmb2_0_2 Dialect = iota
	DialectSmb2_1
	DialectSmb3_0
	DialectSmb3_0_2
	DialectSmb3_1_1
)

// ShareType represents the ShareType type (Idris2 ABI tags).
type ShareType uint8

const (
	ShareTypeDisk ShareType = iota
	ShareTypePipe
	ShareTypePrint
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateNegotiated
	SessionStateAuthenticated
	SessionStateTreeConnected
	SessionStateFileOpen
	SessionStateDisconnecting
)
