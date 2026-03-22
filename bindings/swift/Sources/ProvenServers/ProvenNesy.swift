// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

/// ReasoningMode matching the Idris2 ABI tags.
public enum ReasoningMode: UInt8, CaseIterable, Sendable {
    case symbolic = 0
    case neural = 1
    case symToNeural = 2
    case neuralToSym = 3
    case ensemble = 4
    case cascade = 5
}

/// ProofStatus matching the Idris2 ABI tags.
public enum ProofStatus: UInt8, CaseIterable, Sendable {
    case pending = 0
    case attempting = 1
    case proved = 2
    case failed = 3
    case assumed = 4
    case vacuous = 5
}

/// ConstraintKind matching the Idris2 ABI tags.
public enum ConstraintKind: UInt8, CaseIterable, Sendable {
    case typeEquality = 0
    case subtype = 1
    case linearity = 2
    case termination = 3
    case totality = 4
    case invariant = 5
    case refinement = 6
    case dependentIndex = 7
}

/// NeuralBackend matching the Idris2 ABI tags.
public enum NeuralBackend: UInt8, CaseIterable, Sendable {
    case localModel = 0
    case claude = 1
    case gemini = 2
    case mistral = 3
    case gpt = 4
    case customNeural = 5
}

/// Confidence matching the Idris2 ABI tags.
public enum Confidence: UInt8, CaseIterable, Sendable {
    case verified = 0
    case highNeural = 1
    case mediumNeural = 2
    case lowNeural = 3
    case unknown = 4
    case contradicted = 5
}

/// DriftKind matching the Idris2 ABI tags.
public enum DriftKind: UInt8, CaseIterable, Sendable {
    case noDrift = 0
    case semanticDrift = 1
    case confidenceDrift = 2
    case factualDrift = 3
    case temporalDrift = 4
    case catastrophicDrift = 5
}

/// NeSyState matching the Idris2 ABI tags.
public enum NeSyState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ready = 1
    case reasoning = 2
    case verifying = 3
    case drift = 4
    case shutdown = 5
}
