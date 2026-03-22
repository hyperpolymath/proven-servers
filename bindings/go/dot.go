// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// DoT protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateConnecting SessionState = iota
	SessionStateHandshaking
	SessionStateEstablished
	SessionStateClosing
	SessionStateClosed
)

// PaddingStrategy represents the PaddingStrategy type (Idris2 ABI tags).
type PaddingStrategy uint8

const (
	PaddingStrategyNoPadding PaddingStrategy = iota
	PaddingStrategyBlockPadding
	PaddingStrategyRandomPadding
)

// ErrorReason represents the ErrorReason type (Idris2 ABI tags).
type ErrorReason uint8

const (
	ErrorReasonHandshakeFailed ErrorReason = iota
	ErrorReasonCertificateInvalid
	ErrorReasonTimeout
	ErrorReasonUpstreamError
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateBound
	ServerStateListening
	ServerStateProcessing
	ServerStateShutdown
)
