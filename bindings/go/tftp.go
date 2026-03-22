// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// TFTP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Opcode represents the Opcode type (Idris2 ABI tags).
type Opcode uint8

const (
	OpcodeRrq Opcode = iota
	OpcodeWrq
	OpcodeData
	OpcodeAck
	OpcodeError
)

// TransferMode represents the TransferMode type (Idris2 ABI tags).
type TransferMode uint8

const (
	TransferModeNetAscii TransferMode = iota
	TransferModeOctet
	TransferModeMail
)

// TftpError represents the TftpError type (Idris2 ABI tags).
type TftpError uint8

const (
	TftpErrorNotDefined TftpError = iota
	TftpErrorFileNotFound
	TftpErrorAccessViolation
	TftpErrorDiskFull
	TftpErrorIllegalOperation
	TftpErrorUnknownTid
	TftpErrorFileExists
	TftpErrorNoSuchUser
)

// TransferState represents the TransferState type (Idris2 ABI tags).
type TransferState uint8

const (
	TransferStateIdle TransferState = iota
	TransferStateReading
	TransferStateWriting
	TransferStateInError
	TransferStateComplete
)
