// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file pqc.hpp
/// @brief PQC protocol types for proven-servers.

#ifndef PROVEN_PQC_HPP
#define PROVEN_PQC_HPP

#include <cstdint>

namespace proven {

/// @brief PqcAlgorithm matching the Idris2 ABI tags.
enum class PqcAlgorithm : uint8_t {
    CrystalsKyber = 0,
    CrystalsDilithium = 1,
    Falcon = 2,
    SphincsPlus = 3,
    ClassicMceliece = 4,
    Bike = 5,
    Hqc = 6,
    Frodokem = 7
};

/// @brief NistLevel matching the Idris2 ABI tags.
enum class NistLevel : uint8_t {
    Nist1 = 0,
    Nist2 = 1,
    Nist3 = 2,
    Nist4 = 3,
    Nist5 = 4
};

/// @brief Operation matching the Idris2 ABI tags.
enum class Operation : uint8_t {
    Keygen = 0,
    Encapsulate = 1,
    Decapsulate = 2,
    Sign = 3,
    Verify = 4
};

/// @brief HybridMode matching the Idris2 ABI tags.
enum class HybridMode : uint8_t {
    ClassicalOnly = 0,
    PqcOnly = 1,
    Hybrid = 2
};

/// @brief AlgorithmCategory matching the Idris2 ABI tags.
enum class AlgorithmCategory : uint8_t {
    Kem = 0,
    Signature = 1
};

/// @brief KeyState matching the Idris2 ABI tags.
enum class KeyState : uint8_t {
    Empty = 0,
    Generating = 1,
    Generated = 2,
    Active = 3,
    Expired = 4,
    Compromised = 5
};

} // namespace proven

#endif // PROVEN_PQC_HPP
