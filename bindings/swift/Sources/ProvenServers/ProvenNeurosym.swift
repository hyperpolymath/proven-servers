// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

/// InferenceMode matching the Idris2 ABI tags.
public enum InferenceMode: UInt8, CaseIterable, Sendable {
    case neural = 0
    case symbolic = 1
    case hybrid = 2
    case cascade = 3
}

/// SymbolicOp matching the Idris2 ABI tags.
public enum SymbolicOp: UInt8, CaseIterable, Sendable {
    case unify = 0
    case resolve = 1
    case rewrite = 2
    case prove = 3
    case search = 4
    case constrain = 5
}

/// NeuralOp matching the Idris2 ABI tags.
public enum NeuralOp: UInt8, CaseIterable, Sendable {
    case embed = 0
    case classify = 1
    case generate = 2
    case attend = 3
    case retrieve = 4
    case finetune = 5
}

/// FusionStrategy matching the Idris2 ABI tags.
public enum FusionStrategy: UInt8, CaseIterable, Sendable {
    case neuralThenSymbolic = 0
    case symbolicThenNeural = 1
    case parallel = 2
    case iterative = 3
    case gated = 4
}

/// ConfidenceLevel matching the Idris2 ABI tags.
public enum ConfidenceLevel: UInt8, CaseIterable, Sendable {
    case proven = 0
    case highConfidence = 1
    case moderate = 2
    case lowConfidence = 3
    case uncertain = 4
    case contradicted = 5
}

/// KnowledgeType matching the Idris2 ABI tags.
public enum KnowledgeType: UInt8, CaseIterable, Sendable {
    case axiom = 0
    case learned = 1
    case inferred = 2
    case grounded = 3
    case hypothetical = 4
    case retracted = 5
}

/// NeurosymState matching the Idris2 ABI tags.
public enum NeurosymState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ready = 1
    case inferring = 2
    case reasoning = 3
    case fusing = 4
    case shutdown = 5
}
