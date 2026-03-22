// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// RADIUS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PacketType represents the PacketType type (Idris2 ABI tags).
type PacketType uint8

const (
	PacketTypeAccessRequest PacketType = iota
	PacketTypeAccessAccept
	PacketTypeAccessReject
	PacketTypeAccountingRequest
	PacketTypeAccountingResponse
	PacketTypeAccessChallenge
)

// AttributeType represents the AttributeType type (Idris2 ABI tags).
type AttributeType uint8

const (
	AttributeTypeUserName AttributeType = iota
	AttributeTypeUserPassword
	AttributeTypeNasIpAddress
	AttributeTypeNasPort
	AttributeTypeServiceType
	AttributeTypeFramedProtocol
	AttributeTypeFramedIpAddress
	AttributeTypeReplyMessage
	AttributeTypeSessionTimeout
)

// ServiceType represents the ServiceType type (Idris2 ABI tags).
type ServiceType uint8

const (
	ServiceTypeLogin ServiceType = iota
	ServiceTypeFramed
	ServiceTypeCallbackLogin
	ServiceTypeCallbackFramed
	ServiceTypeOutbound
	ServiceTypeAdministrative
)

// AuthMethod represents the AuthMethod type (Idris2 ABI tags).
type AuthMethod uint8

const (
	AuthMethodPap AuthMethod = iota
	AuthMethodChap
	AuthMethodMschap
	AuthMethodMschapv2
	AuthMethodEap
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateAuthenticating
	SessionStateAuthorized
	SessionStateRejected
	SessionStateChallenged
	SessionStateAccounting
	SessionStateComplete
)

// RadiusResult represents the RadiusResult type (Idris2 ABI tags).
type RadiusResult uint8

const (
	RadiusResultOk RadiusResult = iota
	RadiusResultErr
	RadiusResultInvalidParam
	RadiusResultPoolExhausted
	RadiusResultBadSecret
)
