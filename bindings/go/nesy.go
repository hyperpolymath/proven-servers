// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// NeSy protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ReasoningMode represents the ReasoningMode type (Idris2 ABI tags).
type ReasoningMode uint8

const (
	ReasoningModeSymbolic ReasoningMode = iota
	ReasoningModeNeural
	ReasoningModeSymToNeural
	ReasoningModeNeuralToSym
	ReasoningModeEnsemble
	ReasoningModeCascade
)

// ProofStatus represents the ProofStatus type (Idris2 ABI tags).
type ProofStatus uint8

const (
	ProofStatusPending ProofStatus = iota
	ProofStatusAttempting
	ProofStatusProved
	ProofStatusFailed
	ProofStatusAssumed
	ProofStatusVacuous
)

// ConstraintKind represents the ConstraintKind type (Idris2 ABI tags).
type ConstraintKind uint8

const (
	ConstraintKindTypeEquality ConstraintKind = iota
	ConstraintKindSubtype
	ConstraintKindLinearity
	ConstraintKindTermination
	ConstraintKindTotality
	ConstraintKindInvariant
	ConstraintKindRefinement
	ConstraintKindDependentIndex
)

// NeuralBackend represents the NeuralBackend type (Idris2 ABI tags).
type NeuralBackend uint8

const (
	NeuralBackendLocalModel NeuralBackend = iota
	NeuralBackendClaude
	NeuralBackendGemini
	NeuralBackendMistral
	NeuralBackendGpt
	NeuralBackendCustomNeural
)

// Confidence represents the Confidence type (Idris2 ABI tags).
type Confidence uint8

const (
	ConfidenceVerified Confidence = iota
	ConfidenceHighNeural
	ConfidenceMediumNeural
	ConfidenceLowNeural
	ConfidenceUnknown
	ConfidenceContradicted
)

// DriftKind represents the DriftKind type (Idris2 ABI tags).
type DriftKind uint8

const (
	DriftKindNoDrift DriftKind = iota
	DriftKindSemanticDrift
	DriftKindConfidenceDrift
	DriftKindFactualDrift
	DriftKindTemporalDrift
	DriftKindCatastrophicDrift
)

// NeSyState represents the NeSyState type (Idris2 ABI tags).
type NeSyState uint8

const (
	NeSyStateIdle NeSyState = iota
	NeSyStateReady
	NeSyStateReasoning
	NeSyStateVerifying
	NeSyStateDrift
	NeSyStateShutdown
)
