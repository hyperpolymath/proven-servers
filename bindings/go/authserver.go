// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Auth protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// AuthMethod represents the AuthMethod type (Idris2 ABI tags).
type AuthMethod uint8

const (
	AuthMethodPassword AuthMethod = iota
	AuthMethodCertificate
	AuthMethodOAuth2
	AuthMethodSaml
	AuthMethodFido2
	AuthMethodKerberos
	AuthMethodLdap
	AuthMethodRadius
)

// TokenType represents the TokenType type (Idris2 ABI tags).
type TokenType uint8

const (
	TokenTypeAccess TokenType = iota
	TokenTypeRefresh
	TokenTypeId
	TokenTypeApi
)

// AuthResult represents the AuthResult type (Idris2 ABI tags).
type AuthResult uint8

const (
	AuthResultSuccess AuthResult = iota
	AuthResultInvalidCredentials
	AuthResultAccountLocked
	AuthResultAccountExpired
	AuthResultMfaRequired
	AuthResultIpBlocked
)

// MfaMethod represents the MfaMethod type (Idris2 ABI tags).
type MfaMethod uint8

const (
	MfaMethodTotp MfaMethod = iota
	MfaMethodSms
	MfaMethodPush
	MfaMethodFido2Mfa
	MfaMethodEmail
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateActive SessionState = iota
	SessionStateExpired
	SessionStateRevoked
	SessionStateLocked
)
