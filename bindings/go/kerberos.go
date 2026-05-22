// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Kerberos protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeAsReq MessageType = iota
	MessageTypeAsRep
	MessageTypeTgsReq
	MessageTypeTgsRep
	MessageTypeApReq
	MessageTypeApRep
	MessageTypeKrbError
	MessageTypeKrbSafe
	MessageTypeKrbPriv
	MessageTypeKrbCred
)

// EncryptionType represents the EncryptionType type (Idris2 ABI tags).
type EncryptionType uint8

const (
	EncryptionTypeAes256CtsHmacSha1 EncryptionType = iota
	EncryptionTypeAes128CtsHmacSha1
	EncryptionTypeAes256CtsHmacSha384
	EncryptionTypeRc4Hmac
	EncryptionTypeDes3CbcSha1
)

// PrincipalType represents the PrincipalType type (Idris2 ABI tags).
type PrincipalType uint8

const (
	PrincipalTypeNtUnknown PrincipalType = iota
	PrincipalTypeNtPrincipal
	PrincipalTypeNtSrvInst
	PrincipalTypeNtSrvHst
	PrincipalTypeNtUid
	PrincipalTypeNtX500
	PrincipalTypeNtEnterprise
)

// TicketFlag represents the TicketFlag type (Idris2 ABI tags).
type TicketFlag uint8

const (
	TicketFlagForwardable TicketFlag = iota
	TicketFlagForwarded
	TicketFlagProxiable
	TicketFlagProxy
	TicketFlagRenewable
	TicketFlagPreAuthent
	TicketFlagHwAuthent
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeKdcErrNone ErrorCode = iota
	ErrorCodeKdcErrNameExp
	ErrorCodeKdcErrServiceExp
	ErrorCodeKdcErrBadPvno
	ErrorCodeKdcErrCOldMastKvno
	ErrorCodeKdcErrSOldMastKvno
	ErrorCodeKdcErrCPrincipalUnknown
	ErrorCodeKdcErrSPrincipalUnknown
	ErrorCodeKdcErrPreauthFailed
	ErrorCodeKdcErrPreauthRequired
)

// AuthState represents the AuthState type (Idris2 ABI tags).
type AuthState uint8

const (
	AuthStateInitial AuthState = iota
	AuthStateTgtObtained
	AuthStateServiceTicketObtained
	AuthStateAuthenticated
	AuthStateAuthFailed
)

// EncStrength represents the EncStrength type (Idris2 ABI tags).
type EncStrength uint8

const (
	EncStrengthStrong EncStrength = iota
	EncStrengthMedium
	EncStrengthWeak
)

// PreAuthType represents the PreAuthType type (Idris2 ABI tags).
type PreAuthType uint8

const (
	PreAuthTypePaEncTimestamp PreAuthType = iota
	PreAuthTypePaEtypeInfo2
	PreAuthTypePaFxFast
	PreAuthTypePaFxCookie
)

// NegotiationState represents the NegotiationState type (Idris2 ABI tags).
type NegotiationState uint8

const (
	NegotiationStateNegIdle NegotiationState = iota
	NegotiationStateProposed
	NegotiationStateSelected
	NegotiationStateNegFailed
)
