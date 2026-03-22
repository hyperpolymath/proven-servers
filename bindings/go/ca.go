// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// CA protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// CertType represents the CertType type (Idris2 ABI tags).
type CertType uint8

const (
	CertTypeRoot CertType = iota
	CertTypeIntermediate
	CertTypeEndEntity
	CertTypeCrossSigned
	CertTypeCodeSigning
	CertTypeEmailProtection
	CertTypeOcspSigning
)

// KeyAlgorithm represents the KeyAlgorithm type (Idris2 ABI tags).
type KeyAlgorithm uint8

const (
	KeyAlgorithmRsa2048 KeyAlgorithm = iota
	KeyAlgorithmRsa4096
	KeyAlgorithmEcdsaP256
	KeyAlgorithmEcdsaP384
	KeyAlgorithmEd25519
	KeyAlgorithmEd448
)

// SignatureAlgorithm represents the SignatureAlgorithm type (Idris2 ABI tags).
type SignatureAlgorithm uint8

const (
	SignatureAlgorithmSha256WithRsa SignatureAlgorithm = iota
	SignatureAlgorithmSha384WithRsa
	SignatureAlgorithmSha512WithRsa
	SignatureAlgorithmSha256WithEcdsa
	SignatureAlgorithmSha384WithEcdsa
	SignatureAlgorithmPureEd25519
	SignatureAlgorithmPureEd448
)

// CertState represents the CertState type (Idris2 ABI tags).
type CertState uint8

const (
	CertStatePending CertState = iota
	CertStateActive
	CertStateRevoked
	CertStateExpired
	CertStateSuspended
)

// RevocationReason represents the RevocationReason type (Idris2 ABI tags).
type RevocationReason uint8

const (
	RevocationReasonUnspecified RevocationReason = iota
	RevocationReasonKeyCompromise
	RevocationReasonCaCompromise
	RevocationReasonAffiliationChanged
	RevocationReasonSuperseded
	RevocationReasonCessationOfOperation
	RevocationReasonCertificateHold
)

// CrlStatus represents the CrlStatus type (Idris2 ABI tags).
type CrlStatus uint8

const (
	CrlStatusCurrent CrlStatus = iota
	CrlStatusCrlExpired
	CrlStatusCrlPending
	CrlStatusCrlError
)

// OcspStatus represents the OcspStatus type (Idris2 ABI tags).
type OcspStatus uint8

const (
	OcspStatusGood OcspStatus = iota
	OcspStatusOcspRevoked
	OcspStatusUnknown
	OcspStatusUnavailable
)

// Extension represents the Extension type (Idris2 ABI tags).
type Extension uint8

const (
	ExtensionBasicConstraints Extension = iota
	ExtensionKeyUsage
	ExtensionExtKeyUsage
	ExtensionSubjectAltName
	ExtensionAuthorityInfoAccess
	ExtensionCrlDistributionPoints
)

// KeyUsageBit represents the KeyUsageBit type (Idris2 ABI tags).
type KeyUsageBit uint8

const (
	KeyUsageBitDigitalSignature KeyUsageBit = iota
	KeyUsageBitNonRepudiation
	KeyUsageBitKeyEncipherment
	KeyUsageBitDataEncipherment
	KeyUsageBitKeyAgreement
	KeyUsageBitKeyCertSign
	KeyUsageBitCrlSign
	KeyUsageBitEncipherOnly
	KeyUsageBitDecipherOnly
)
