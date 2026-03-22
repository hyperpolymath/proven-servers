// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// DoQ protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// StreamType represents the StreamType type (Idris2 ABI tags).
type StreamType uint8

const (
	StreamTypeUnidirectional StreamType = iota
	StreamTypeBidirectional
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeNoError ErrorCode = iota
	ErrorCodeInternalError
	ErrorCodeExcessiveLoad
	ErrorCodeProtocolError
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateInitial SessionState = iota
	SessionStateHandshaking
	SessionStateReady
	SessionStateDraining
	SessionStateClosed
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
