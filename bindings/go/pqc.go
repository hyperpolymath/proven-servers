// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// PQC protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PqcAlgorithm represents the PqcAlgorithm type (Idris2 ABI tags).
type PqcAlgorithm uint8

const (
	PqcAlgorithmCrystalsKyber PqcAlgorithm = iota
	PqcAlgorithmCrystalsDilithium
	PqcAlgorithmFalcon
	PqcAlgorithmSphincsPlus
	PqcAlgorithmClassicMceliece
	PqcAlgorithmBike
	PqcAlgorithmHqc
	PqcAlgorithmFrodokem
)

// NistLevel represents the NistLevel type (Idris2 ABI tags).
type NistLevel uint8

const (
	NistLevelNist1 NistLevel = iota
	NistLevelNist2
	NistLevelNist3
	NistLevelNist4
	NistLevelNist5
)

// Operation represents the Operation type (Idris2 ABI tags).
type Operation uint8

const (
	OperationKeygen Operation = iota
	OperationEncapsulate
	OperationDecapsulate
	OperationSign
	OperationVerify
)

// HybridMode represents the HybridMode type (Idris2 ABI tags).
type HybridMode uint8

const (
	HybridModeClassicalOnly HybridMode = iota
	HybridModePqcOnly
	HybridModeHybrid
)

// AlgorithmCategory represents the AlgorithmCategory type (Idris2 ABI tags).
type AlgorithmCategory uint8

const (
	AlgorithmCategoryKem AlgorithmCategory = iota
	AlgorithmCategorySignature
)

// KeyState represents the KeyState type (Idris2 ABI tags).
type KeyState uint8

const (
	KeyStateEmpty KeyState = iota
	KeyStateGenerating
	KeyStateGenerated
	KeyStateActive
	KeyStateExpired
	KeyStateCompromised
)
