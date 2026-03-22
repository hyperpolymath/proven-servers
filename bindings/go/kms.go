// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// KMS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ObjectType represents the ObjectType type (Idris2 ABI tags).
type ObjectType uint8

const (
	ObjectTypeSymmetricKey ObjectType = iota
	ObjectTypePublicKey
	ObjectTypePrivateKey
	ObjectTypeSecretData
	ObjectTypeCertificate
	ObjectTypeOpaqueData
)

// Operation represents the Operation type (Idris2 ABI tags).
type Operation uint8

const (
	OperationCreate Operation = iota
	OperationGet
	OperationActivate
	OperationRevoke
	OperationDestroy
	OperationLocate
	OperationRegister
	OperationRekey
	OperationEncrypt
	OperationDecrypt
	OperationSign
	OperationVerify
	OperationWrap
	OperationUnwrap
	OperationMac
)

// KeyState represents the KeyState type (Idris2 ABI tags).
type KeyState uint8

const (
	KeyStatePreActive KeyState = iota
	KeyStateActive
	KeyStateDeactivated
	KeyStateCompromised
	KeyStateDestroyed
	KeyStateDestroyedCompromised
)

// KmsAlgorithm represents the KmsAlgorithm type (Idris2 ABI tags).
type KmsAlgorithm uint8

const (
	KmsAlgorithmAes128 KmsAlgorithm = iota
	KmsAlgorithmAes256
	KmsAlgorithmRsa2048
	KmsAlgorithmRsa4096
	KmsAlgorithmEcdsaP256
	KmsAlgorithmEcdsaP384
	KmsAlgorithmEd25519
	KmsAlgorithmChacha20Poly1305
	KmsAlgorithmHmacSha256
)
