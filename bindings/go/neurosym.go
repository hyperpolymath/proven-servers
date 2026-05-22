// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Neurosym protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// InferenceMode represents the InferenceMode type (Idris2 ABI tags).
type InferenceMode uint8

const (
	InferenceModeNeural InferenceMode = iota
	InferenceModeSymbolic
	InferenceModeHybrid
	InferenceModeCascade
)

// SymbolicOp represents the SymbolicOp type (Idris2 ABI tags).
type SymbolicOp uint8

const (
	SymbolicOpUnify SymbolicOp = iota
	SymbolicOpResolve
	SymbolicOpRewrite
	SymbolicOpProve
	SymbolicOpSearch
	SymbolicOpConstrain
)

// NeuralOp represents the NeuralOp type (Idris2 ABI tags).
type NeuralOp uint8

const (
	NeuralOpEmbed NeuralOp = iota
	NeuralOpClassify
	NeuralOpGenerate
	NeuralOpAttend
	NeuralOpRetrieve
	NeuralOpFinetune
)

// FusionStrategy represents the FusionStrategy type (Idris2 ABI tags).
type FusionStrategy uint8

const (
	FusionStrategyNeuralThenSymbolic FusionStrategy = iota
	FusionStrategySymbolicThenNeural
	FusionStrategyParallel
	FusionStrategyIterative
	FusionStrategyGated
)

// ConfidenceLevel represents the ConfidenceLevel type (Idris2 ABI tags).
type ConfidenceLevel uint8

const (
	ConfidenceLevelProven ConfidenceLevel = iota
	ConfidenceLevelHighConfidence
	ConfidenceLevelModerate
	ConfidenceLevelLowConfidence
	ConfidenceLevelUncertain
	ConfidenceLevelContradicted
)

// KnowledgeType represents the KnowledgeType type (Idris2 ABI tags).
type KnowledgeType uint8

const (
	KnowledgeTypeAxiom KnowledgeType = iota
	KnowledgeTypeLearned
	KnowledgeTypeInferred
	KnowledgeTypeGrounded
	KnowledgeTypeHypothetical
	KnowledgeTypeRetracted
)

// NeurosymState represents the NeurosymState type (Idris2 ABI tags).
type NeurosymState uint8

const (
	NeurosymStateIdle NeurosymState = iota
	NeurosymStateReady
	NeurosymStateInferring
	NeurosymStateReasoning
	NeurosymStateFusing
	NeurosymStateShutdown
)
