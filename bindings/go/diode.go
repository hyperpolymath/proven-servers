// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Data Diode protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Direction represents the Direction type (Idris2 ABI tags).
type Direction uint8

const (
	DirectionHighToLow Direction = iota
	DirectionLowToHigh
)

// DiodeProtocol represents the DiodeProtocol type (Idris2 ABI tags).
type DiodeProtocol uint8

const (
	DiodeProtocolUdp DiodeProtocol = iota
	DiodeProtocolTcp
	DiodeProtocolFileTransfer
	DiodeProtocolSyslog
	DiodeProtocolSnmp
)

// TransferState represents the TransferState type (Idris2 ABI tags).
type TransferState uint8

const (
	TransferStateQueued TransferState = iota
	TransferStateSending
	TransferStateConfirming
	TransferStateComplete
	TransferStateFailed
)

// ValidationResult represents the ValidationResult type (Idris2 ABI tags).
type ValidationResult uint8

const (
	ValidationResultPassed ValidationResult = iota
	ValidationResultFormatError
	ValidationResultSizeExceeded
	ValidationResultPolicyBlocked
)

// IntegrityCheck represents the IntegrityCheck type (Idris2 ABI tags).
type IntegrityCheck uint8

const (
	IntegrityCheckCrc32 IntegrityCheck = iota
	IntegrityCheckSha256
	IntegrityCheckHmac
)

// GatewayState represents the GatewayState type (Idris2 ABI tags).
type GatewayState uint8

const (
	GatewayStateIdle GatewayState = iota
	GatewayStateConfigured
	GatewayStateTransferring
	GatewayStateValidating
	GatewayStateShutdown
)
