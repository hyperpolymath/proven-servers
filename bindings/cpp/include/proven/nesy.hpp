// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file nesy.hpp
/// @brief NeSy protocol types for proven-servers.

#ifndef PROVEN_NESY_HPP
#define PROVEN_NESY_HPP

#include <cstdint>

namespace proven {

/// @brief ReasoningMode matching the Idris2 ABI tags.
enum class ReasoningMode : uint8_t {
    Symbolic = 0,
    Neural = 1,
    SymToNeural = 2,
    NeuralToSym = 3,
    Ensemble = 4,
    Cascade = 5
};

/// @brief ProofStatus matching the Idris2 ABI tags.
enum class ProofStatus : uint8_t {
    Pending = 0,
    Attempting = 1,
    Proved = 2,
    Failed = 3,
    Assumed = 4,
    Vacuous = 5
};

/// @brief ConstraintKind matching the Idris2 ABI tags.
enum class ConstraintKind : uint8_t {
    TypeEquality = 0,
    Subtype = 1,
    Linearity = 2,
    Termination = 3,
    Totality = 4,
    Invariant = 5,
    Refinement = 6,
    DependentIndex = 7
};

/// @brief NeuralBackend matching the Idris2 ABI tags.
enum class NeuralBackend : uint8_t {
    LocalModel = 0,
    Claude = 1,
    Gemini = 2,
    Mistral = 3,
    Gpt = 4,
    CustomNeural = 5
};

/// @brief Confidence matching the Idris2 ABI tags.
enum class Confidence : uint8_t {
    Verified = 0,
    HighNeural = 1,
    MediumNeural = 2,
    LowNeural = 3,
    Unknown = 4,
    Contradicted = 5
};

/// @brief DriftKind matching the Idris2 ABI tags.
enum class DriftKind : uint8_t {
    NoDrift = 0,
    SemanticDrift = 1,
    ConfidenceDrift = 2,
    FactualDrift = 3,
    TemporalDrift = 4,
    CatastrophicDrift = 5
};

/// @brief NeSyState matching the Idris2 ABI tags.
enum class NeSyState : uint8_t {
    Idle = 0,
    Ready = 1,
    Reasoning = 2,
    Verifying = 3,
    Drift = 4,
    Shutdown = 5
};

} // namespace proven

#endif // PROVEN_NESY_HPP
