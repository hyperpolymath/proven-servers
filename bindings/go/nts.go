// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// NTS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// RecordType represents the RecordType type (Idris2 ABI tags).
type RecordType uint8

const (
	RecordTypeEndOfMessage RecordType = iota
	RecordTypeNextProtocol
	RecordTypeError
	RecordTypeWarning
	RecordTypeAeadAlgorithm
	RecordTypeCookie
	RecordTypeCookiePlaceholder
	RecordTypeNtskeServer
	RecordTypeNtskePort
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeUnrecognizedCritical ErrorCode = iota
	ErrorCodeBadRequest
	ErrorCodeInternalError
)

// AeadAlgorithm represents the AeadAlgorithm type (Idris2 ABI tags).
type AeadAlgorithm uint8

const (
	AeadAlgorithmAeadAes128Gcm AeadAlgorithm = iota
	AeadAlgorithmAeadAes256Gcm
	AeadAlgorithmAeadAesSivCmac256
)

// HandshakeState represents the HandshakeState type (Idris2 ABI tags).
type HandshakeState uint8

const (
	HandshakeStateInitial HandshakeState = iota
	HandshakeStateNegotiating
	HandshakeStateEstablished
	HandshakeStateFailed
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateHandshaking
	SessionStateNegotiating
	SessionStateEstablished
	SessionStateClosing
)
