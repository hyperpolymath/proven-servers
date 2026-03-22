// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// BFD protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// BfdState represents the BfdState type (Idris2 ABI tags).
type BfdState uint8

const (
	BfdStateAdminDown BfdState = iota
	BfdStateDown
	BfdStateInit
	BfdStateUp
)

// Diagnostic represents the Diagnostic type (Idris2 ABI tags).
type Diagnostic uint8

const (
	DiagnosticNoDiagnostic Diagnostic = iota
	DiagnosticControlDetectionTimeExpired
	DiagnosticEchoFunctionFailed
	DiagnosticNeighborSignaledSessionDown
	DiagnosticForwardingPlaneReset
	DiagnosticPathDown
	DiagnosticConcatenatedPathDown
	DiagnosticAdministrativelyDown
	DiagnosticReverseConcatenatedPathDown
)

// SessionMode represents the SessionMode type (Idris2 ABI tags).
type SessionMode uint8

const (
	SessionModeAsyncMode SessionMode = iota
	SessionModeDemandMode
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateSsDown
	SessionStateNegotiating
	SessionStateEstablished
	SessionStateTeardown
)
