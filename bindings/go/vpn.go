// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// VPN protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// TunnelType represents the TunnelType type (Idris2 ABI tags).
type TunnelType uint8

const (
	TunnelTypeIpsec TunnelType = iota
	TunnelTypeWireguard
	TunnelTypeOpenvpn
	TunnelTypeL2tp
)

// TunnelPhase represents the TunnelPhase type (Idris2 ABI tags).
type TunnelPhase uint8

const (
	TunnelPhaseIdle TunnelPhase = iota
	TunnelPhasePhase1Init
	TunnelPhasePhase1Auth
	TunnelPhasePhase1Done
	TunnelPhasePhase2Negotiating
	TunnelPhaseEstablished
	TunnelPhaseExpired
)

// EncryptionAlgorithm represents the EncryptionAlgorithm type (Idris2 ABI tags).
type EncryptionAlgorithm uint8

const (
	EncryptionAlgorithmAes128Cbc EncryptionAlgorithm = iota
	EncryptionAlgorithmAes256Cbc
	EncryptionAlgorithmAes128Gcm
	EncryptionAlgorithmAes256Gcm
	EncryptionAlgorithmChacha20Poly1305
	EncryptionAlgorithmNullCipher
)

// IntegrityAlgorithm represents the IntegrityAlgorithm type (Idris2 ABI tags).
type IntegrityAlgorithm uint8

const (
	IntegrityAlgorithmHmacSha1 IntegrityAlgorithm = iota
	IntegrityAlgorithmHmacSha256
	IntegrityAlgorithmHmacSha384
	IntegrityAlgorithmHmacSha512
	IntegrityAlgorithmNoIntegrity
)

// DhGroup represents the DhGroup type (Idris2 ABI tags).
type DhGroup uint8

const (
	DhGroupDh14 DhGroup = iota
	DhGroupEcp256
	DhGroupEcp384
	DhGroupCurve25519
)

// SaLifecycle represents the SaLifecycle type (Idris2 ABI tags).
type SaLifecycle uint8

const (
	SaLifecycleNone SaLifecycle = iota
	SaLifecycleActive
	SaLifecycleRekeying
	SaLifecycleExpired
	SaLifecycleDeleted
)

// IkeVersion represents the IkeVersion type (Idris2 ABI tags).
type IkeVersion uint8

const (
	IkeVersionV1 IkeVersion = iota
	IkeVersionV2
)

// VpnError represents the VpnError type (Idris2 ABI tags).
type VpnError uint8

const (
	VpnErrorAuthenticationFailed VpnError = iota
	VpnErrorNoProposalChosen
	VpnErrorLifetimeExpired
	VpnErrorInvalidSpi
	VpnErrorReplayDetected
	VpnErrorNegotiationTimeout
)
