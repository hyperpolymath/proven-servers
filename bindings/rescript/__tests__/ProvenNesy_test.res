// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenNesy protocol bindings.

open ProvenNesy

let test_reasoningMode_roundtrip = () => {
  assert(reasoningModeFromTag(0) == Some(Symbolic))
  assert(reasoningModeFromTag(1) == Some(Neural))
  assert(reasoningModeFromTag(2) == Some(SymToNeural))
  assert(reasoningModeFromTag(3) == Some(NeuralToSym))
  assert(reasoningModeFromTag(4) == Some(Ensemble))
  assert(reasoningModeFromTag(5) == Some(Cascade))
  assert(reasoningModeFromTag(6) == None)
}

let test_reasoningMode_toTag = () => {
  assert(reasoningModeToTag(Symbolic) == 0)
  assert(reasoningModeToTag(Neural) == 1)
  assert(reasoningModeToTag(SymToNeural) == 2)
  assert(reasoningModeToTag(NeuralToSym) == 3)
  assert(reasoningModeToTag(Ensemble) == 4)
  assert(reasoningModeToTag(Cascade) == 5)
}

let test_proofStatus_roundtrip = () => {
  assert(proofStatusFromTag(0) == Some(Pending))
  assert(proofStatusFromTag(1) == Some(Attempting))
  assert(proofStatusFromTag(2) == Some(Proved))
  assert(proofStatusFromTag(3) == Some(Failed))
  assert(proofStatusFromTag(4) == Some(Assumed))
  assert(proofStatusFromTag(5) == Some(Vacuous))
  assert(proofStatusFromTag(6) == None)
}

let test_proofStatus_toTag = () => {
  assert(proofStatusToTag(Pending) == 0)
  assert(proofStatusToTag(Attempting) == 1)
  assert(proofStatusToTag(Proved) == 2)
  assert(proofStatusToTag(Failed) == 3)
  assert(proofStatusToTag(Assumed) == 4)
  assert(proofStatusToTag(Vacuous) == 5)
}

let test_constraintKind_roundtrip = () => {
  assert(constraintKindFromTag(0) == Some(TypeEquality))
  assert(constraintKindFromTag(1) == Some(Subtype))
  assert(constraintKindFromTag(2) == Some(Linearity))
  assert(constraintKindFromTag(3) == Some(Termination))
  assert(constraintKindFromTag(4) == Some(Totality))
  assert(constraintKindFromTag(5) == Some(Invariant))
  assert(constraintKindFromTag(6) == Some(Refinement))
  assert(constraintKindFromTag(7) == Some(DependentIndex))
  assert(constraintKindFromTag(8) == None)
}

let test_constraintKind_toTag = () => {
  assert(constraintKindToTag(TypeEquality) == 0)
  assert(constraintKindToTag(Subtype) == 1)
  assert(constraintKindToTag(Linearity) == 2)
  assert(constraintKindToTag(Termination) == 3)
  assert(constraintKindToTag(Totality) == 4)
  assert(constraintKindToTag(Invariant) == 5)
  assert(constraintKindToTag(Refinement) == 6)
  assert(constraintKindToTag(DependentIndex) == 7)
}

let test_neuralBackend_roundtrip = () => {
  assert(neuralBackendFromTag(0) == Some(LocalModel))
  assert(neuralBackendFromTag(1) == Some(Claude))
  assert(neuralBackendFromTag(2) == Some(Gemini))
  assert(neuralBackendFromTag(3) == Some(Mistral))
  assert(neuralBackendFromTag(4) == Some(Gpt))
  assert(neuralBackendFromTag(5) == Some(CustomNeural))
  assert(neuralBackendFromTag(6) == None)
}

let test_neuralBackend_toTag = () => {
  assert(neuralBackendToTag(LocalModel) == 0)
  assert(neuralBackendToTag(Claude) == 1)
  assert(neuralBackendToTag(Gemini) == 2)
  assert(neuralBackendToTag(Mistral) == 3)
  assert(neuralBackendToTag(Gpt) == 4)
  assert(neuralBackendToTag(CustomNeural) == 5)
}

let test_confidence_roundtrip = () => {
  assert(confidenceFromTag(0) == Some(Verified))
  assert(confidenceFromTag(1) == Some(HighNeural))
  assert(confidenceFromTag(2) == Some(MediumNeural))
  assert(confidenceFromTag(3) == Some(LowNeural))
  assert(confidenceFromTag(4) == Some(Unknown))
  assert(confidenceFromTag(5) == Some(Contradicted))
  assert(confidenceFromTag(6) == None)
}

let test_confidence_toTag = () => {
  assert(confidenceToTag(Verified) == 0)
  assert(confidenceToTag(HighNeural) == 1)
  assert(confidenceToTag(MediumNeural) == 2)
  assert(confidenceToTag(LowNeural) == 3)
  assert(confidenceToTag(Unknown) == 4)
  assert(confidenceToTag(Contradicted) == 5)
}

let test_driftKind_roundtrip = () => {
  assert(driftKindFromTag(0) == Some(NoDrift))
  assert(driftKindFromTag(1) == Some(SemanticDrift))
  assert(driftKindFromTag(2) == Some(ConfidenceDrift))
  assert(driftKindFromTag(3) == Some(FactualDrift))
  assert(driftKindFromTag(4) == Some(TemporalDrift))
  assert(driftKindFromTag(5) == Some(CatastrophicDrift))
  assert(driftKindFromTag(6) == None)
}

let test_driftKind_toTag = () => {
  assert(driftKindToTag(NoDrift) == 0)
  assert(driftKindToTag(SemanticDrift) == 1)
  assert(driftKindToTag(ConfidenceDrift) == 2)
  assert(driftKindToTag(FactualDrift) == 3)
  assert(driftKindToTag(TemporalDrift) == 4)
  assert(driftKindToTag(CatastrophicDrift) == 5)
}

let test_neSyState_roundtrip = () => {
  assert(neSyStateFromTag(0) == Some(Idle))
  assert(neSyStateFromTag(1) == Some(Ready))
  assert(neSyStateFromTag(2) == Some(Reasoning))
  assert(neSyStateFromTag(3) == Some(Verifying))
  assert(neSyStateFromTag(4) == Some(Drift))
  assert(neSyStateFromTag(5) == Some(Shutdown))
  assert(neSyStateFromTag(6) == None)
}

let test_neSyState_toTag = () => {
  assert(neSyStateToTag(Idle) == 0)
  assert(neSyStateToTag(Ready) == 1)
  assert(neSyStateToTag(Reasoning) == 2)
  assert(neSyStateToTag(Verifying) == 3)
  assert(neSyStateToTag(Drift) == 4)
  assert(neSyStateToTag(Shutdown) == 5)
}

// Run all tests
test_reasoningMode_roundtrip()
test_reasoningMode_toTag()
test_proofStatus_roundtrip()
test_proofStatus_toTag()
test_constraintKind_roundtrip()
test_constraintKind_toTag()
test_neuralBackend_roundtrip()
test_neuralBackend_toTag()
test_confidence_roundtrip()
test_confidence_toTag()
test_driftKind_roundtrip()
test_driftKind_toTag()
test_neSyState_roundtrip()
test_neSyState_toTag()
