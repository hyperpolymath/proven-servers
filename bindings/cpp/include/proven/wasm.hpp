// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file wasm.hpp
/// @brief WASM protocol types for proven-servers.

#ifndef PROVEN_WASM_HPP
#define PROVEN_WASM_HPP

#include <cstdint>

namespace proven {

/// @brief ValType matching the Idris2 ABI tags.
enum class ValType : uint8_t {
    I32 = 0,
    I64 = 1,
    F32 = 2,
    F64 = 3,
    V128 = 4,
    FuncRef = 5,
    ExternRef = 6
};

/// @brief ExternKind matching the Idris2 ABI tags.
enum class ExternKind : uint8_t {
    FuncExtern = 0,
    TableExtern = 1,
    MemExtern = 2,
    GlobalExtern = 3
};

/// @brief Mutability matching the Idris2 ABI tags.
enum class Mutability : uint8_t {
    Immutable = 0,
    Mutable = 1
};

} // namespace proven

#endif // PROVEN_WASM_HPP
