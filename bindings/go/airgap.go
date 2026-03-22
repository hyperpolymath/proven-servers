// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Air Gap protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// TransferDirection represents the TransferDirection type (Idris2 ABI tags).
type TransferDirection uint8

const (
	TransferDirectionImport TransferDirection = iota
	TransferDirectionExport
)

// MediaType represents the MediaType type (Idris2 ABI tags).
type MediaType uint8

const (
	MediaTypeUsb MediaType = iota
	MediaTypeOpticalDisc
	MediaTypeTapeCartridge
	MediaTypeDiodeLink
)

// ScanResult represents the ScanResult type (Idris2 ABI tags).
type ScanResult uint8

const (
	ScanResultClean ScanResult = iota
	ScanResultSuspicious
	ScanResultMalicious
	ScanResultUnscannable
)

// TransferState represents the TransferState type (Idris2 ABI tags).
type TransferState uint8

const (
	TransferStatePending TransferState = iota
	TransferStateScanning
	TransferStateApproved
	TransferStateRejected
	TransferStateInProgress
	TransferStateComplete
	TransferStateFailed
)

// ValidationCheck represents the ValidationCheck type (Idris2 ABI tags).
type ValidationCheck uint8

const (
	ValidationCheckHashVerify ValidationCheck = iota
	ValidationCheckSignatureVerify
	ValidationCheckFormatCheck
	ValidationCheckContentInspection
	ValidationCheckMalwareScan
)
