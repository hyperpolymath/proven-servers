// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file neurosym.hpp
/// @brief Neurosym protocol types for proven-servers.

#ifndef PROVEN_NEUROSYM_HPP
#define PROVEN_NEUROSYM_HPP

#include <cstdint>

namespace proven {

/// @brief InferenceMode matching the Idris2 ABI tags.
enum class InferenceMode : uint8_t {
    Neural = 0,
    Symbolic = 1,
    Hybrid = 2,
    Cascade = 3
};

/// @brief SymbolicOp matching the Idris2 ABI tags.
enum class SymbolicOp : uint8_t {
    Unify = 0,
    Resolve = 1,
    Rewrite = 2,
    Prove = 3,
    Search = 4,
    Constrain = 5
};

/// @brief NeuralOp matching the Idris2 ABI tags.
enum class NeuralOp : uint8_t {
    Embed = 0,
    Classify = 1,
    Generate = 2,
    Attend = 3,
    Retrieve = 4,
    Finetune = 5
};

/// @brief FusionStrategy matching the Idris2 ABI tags.
enum class FusionStrategy : uint8_t {
    NeuralThenSymbolic = 0,
    SymbolicThenNeural = 1,
    Parallel = 2,
    Iterative = 3,
    Gated = 4
};

/// @brief ConfidenceLevel matching the Idris2 ABI tags.
enum class ConfidenceLevel : uint8_t {
    Proven = 0,
    HighConfidence = 1,
    Moderate = 2,
    LowConfidence = 3,
    Uncertain = 4,
    Contradicted = 5
};

/// @brief KnowledgeType matching the Idris2 ABI tags.
enum class KnowledgeType : uint8_t {
    Axiom = 0,
    Learned = 1,
    Inferred = 2,
    Grounded = 3,
    Hypothetical = 4,
    Retracted = 5
};

/// @brief NeurosymState matching the Idris2 ABI tags.
enum class NeurosymState : uint8_t {
    Idle = 0,
    Ready = 1,
    Inferring = 2,
    Reasoning = 3,
    Fusing = 4,
    Shutdown = 5
};

} // namespace proven

#endif // PROVEN_NEUROSYM_HPP
