// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenNeurosym protocol bindings.

open ProvenNeurosym

let test_inferenceMode_roundtrip = () => {
  assert(inferenceModeFromTag(0) == Some(Neural))
  assert(inferenceModeFromTag(1) == Some(Symbolic))
  assert(inferenceModeFromTag(2) == Some(Hybrid))
  assert(inferenceModeFromTag(3) == Some(Cascade))
  assert(inferenceModeFromTag(4) == None)
}

let test_inferenceMode_toTag = () => {
  assert(inferenceModeToTag(Neural) == 0)
  assert(inferenceModeToTag(Symbolic) == 1)
  assert(inferenceModeToTag(Hybrid) == 2)
  assert(inferenceModeToTag(Cascade) == 3)
}

let test_symbolicOp_roundtrip = () => {
  assert(symbolicOpFromTag(0) == Some(Unify))
  assert(symbolicOpFromTag(1) == Some(Resolve))
  assert(symbolicOpFromTag(2) == Some(Rewrite))
  assert(symbolicOpFromTag(3) == Some(Prove))
  assert(symbolicOpFromTag(4) == Some(Search))
  assert(symbolicOpFromTag(5) == Some(Constrain))
  assert(symbolicOpFromTag(6) == None)
}

let test_symbolicOp_toTag = () => {
  assert(symbolicOpToTag(Unify) == 0)
  assert(symbolicOpToTag(Resolve) == 1)
  assert(symbolicOpToTag(Rewrite) == 2)
  assert(symbolicOpToTag(Prove) == 3)
  assert(symbolicOpToTag(Search) == 4)
  assert(symbolicOpToTag(Constrain) == 5)
}

let test_neuralOp_roundtrip = () => {
  assert(neuralOpFromTag(0) == Some(Embed))
  assert(neuralOpFromTag(1) == Some(Classify))
  assert(neuralOpFromTag(2) == Some(Generate))
  assert(neuralOpFromTag(3) == Some(Attend))
  assert(neuralOpFromTag(4) == Some(Retrieve))
  assert(neuralOpFromTag(5) == Some(Finetune))
  assert(neuralOpFromTag(6) == None)
}

let test_neuralOp_toTag = () => {
  assert(neuralOpToTag(Embed) == 0)
  assert(neuralOpToTag(Classify) == 1)
  assert(neuralOpToTag(Generate) == 2)
  assert(neuralOpToTag(Attend) == 3)
  assert(neuralOpToTag(Retrieve) == 4)
  assert(neuralOpToTag(Finetune) == 5)
}

let test_fusionStrategy_roundtrip = () => {
  assert(fusionStrategyFromTag(0) == Some(NeuralThenSymbolic))
  assert(fusionStrategyFromTag(1) == Some(SymbolicThenNeural))
  assert(fusionStrategyFromTag(2) == Some(Parallel))
  assert(fusionStrategyFromTag(3) == Some(Iterative))
  assert(fusionStrategyFromTag(4) == Some(Gated))
  assert(fusionStrategyFromTag(5) == None)
}

let test_fusionStrategy_toTag = () => {
  assert(fusionStrategyToTag(NeuralThenSymbolic) == 0)
  assert(fusionStrategyToTag(SymbolicThenNeural) == 1)
  assert(fusionStrategyToTag(Parallel) == 2)
  assert(fusionStrategyToTag(Iterative) == 3)
  assert(fusionStrategyToTag(Gated) == 4)
}

let test_confidenceLevel_roundtrip = () => {
  assert(confidenceLevelFromTag(0) == Some(Proven))
  assert(confidenceLevelFromTag(1) == Some(HighConfidence))
  assert(confidenceLevelFromTag(2) == Some(Moderate))
  assert(confidenceLevelFromTag(3) == Some(LowConfidence))
  assert(confidenceLevelFromTag(4) == Some(Uncertain))
  assert(confidenceLevelFromTag(5) == Some(Contradicted))
  assert(confidenceLevelFromTag(6) == None)
}

let test_confidenceLevel_toTag = () => {
  assert(confidenceLevelToTag(Proven) == 0)
  assert(confidenceLevelToTag(HighConfidence) == 1)
  assert(confidenceLevelToTag(Moderate) == 2)
  assert(confidenceLevelToTag(LowConfidence) == 3)
  assert(confidenceLevelToTag(Uncertain) == 4)
  assert(confidenceLevelToTag(Contradicted) == 5)
}

let test_knowledgeType_roundtrip = () => {
  assert(knowledgeTypeFromTag(0) == Some(Axiom))
  assert(knowledgeTypeFromTag(1) == Some(Learned))
  assert(knowledgeTypeFromTag(2) == Some(Inferred))
  assert(knowledgeTypeFromTag(3) == Some(Grounded))
  assert(knowledgeTypeFromTag(4) == Some(Hypothetical))
  assert(knowledgeTypeFromTag(5) == Some(Retracted))
  assert(knowledgeTypeFromTag(6) == None)
}

let test_knowledgeType_toTag = () => {
  assert(knowledgeTypeToTag(Axiom) == 0)
  assert(knowledgeTypeToTag(Learned) == 1)
  assert(knowledgeTypeToTag(Inferred) == 2)
  assert(knowledgeTypeToTag(Grounded) == 3)
  assert(knowledgeTypeToTag(Hypothetical) == 4)
  assert(knowledgeTypeToTag(Retracted) == 5)
}

let test_neurosymState_roundtrip = () => {
  assert(neurosymStateFromTag(0) == Some(Idle))
  assert(neurosymStateFromTag(1) == Some(Ready))
  assert(neurosymStateFromTag(2) == Some(Inferring))
  assert(neurosymStateFromTag(3) == Some(Reasoning))
  assert(neurosymStateFromTag(4) == Some(Fusing))
  assert(neurosymStateFromTag(5) == Some(Shutdown))
  assert(neurosymStateFromTag(6) == None)
}

let test_neurosymState_toTag = () => {
  assert(neurosymStateToTag(Idle) == 0)
  assert(neurosymStateToTag(Ready) == 1)
  assert(neurosymStateToTag(Inferring) == 2)
  assert(neurosymStateToTag(Reasoning) == 3)
  assert(neurosymStateToTag(Fusing) == 4)
  assert(neurosymStateToTag(Shutdown) == 5)
}

// Run all tests
test_inferenceMode_roundtrip()
test_inferenceMode_toTag()
test_symbolicOp_roundtrip()
test_symbolicOp_toTag()
test_neuralOp_roundtrip()
test_neuralOp_toTag()
test_fusionStrategy_roundtrip()
test_fusionStrategy_toTag()
test_confidenceLevel_roundtrip()
test_confidenceLevel_toTag()
test_knowledgeType_roundtrip()
test_knowledgeType_toTag()
test_neurosymState_roundtrip()
test_neurosymState_toTag()
