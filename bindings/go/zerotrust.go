// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Zero Trust protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PolicyType represents the PolicyType type (Idris2 ABI tags).
type PolicyType uint8

const (
	PolicyTypeAlwaysVerify PolicyType = iota
	PolicyTypeNeverTrust
	PolicyTypeLeastPrivilege
	PolicyTypeMicroSegmentation
)

// IdentityConfidence represents the IdentityConfidence type (Idris2 ABI tags).
type IdentityConfidence uint8

const (
	IdentityConfidenceUnverified IdentityConfidence = iota
	IdentityConfidenceBasicAuth
	IdentityConfidenceMfaVerified
	IdentityConfidenceStrongAuth
	IdentityConfidenceContinuousAuth
)

// DeviceTrustScore represents the DeviceTrustScore type (Idris2 ABI tags).
type DeviceTrustScore uint8

const (
	DeviceTrustScoreDeviceUnknown DeviceTrustScore = iota
	DeviceTrustScoreDevicePartial
	DeviceTrustScoreDeviceCompliant
	DeviceTrustScoreDeviceManaged
	DeviceTrustScoreDeviceHardened
)

// AccessDecision represents the AccessDecision type (Idris2 ABI tags).
type AccessDecision uint8

const (
	AccessDecisionAllow AccessDecision = iota
	AccessDecisionDeny
	AccessDecisionChallenge
	AccessDecisionStepUp
)

// ContextSignalKind represents the ContextSignalKind type (Idris2 ABI tags).
type ContextSignalKind uint8

const (
	ContextSignalKindLocation ContextSignalKind = iota
	ContextSignalKindTime
	ContextSignalKindDevice
	ContextSignalKindBehavior
	ContextSignalKindNetwork
)

// AuthFactor represents the AuthFactor type (Idris2 ABI tags).
type AuthFactor uint8

const (
	AuthFactorCertificate AuthFactor = iota
	AuthFactorToken
	AuthFactorBiometric
	AuthFactorFido2
	AuthFactorTotp
	AuthFactorPush
)
