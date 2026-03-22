// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file triplestore.hpp
/// @brief Triplestore protocol types for proven-servers.

#ifndef PROVEN_TRIPLESTORE_HPP
#define PROVEN_TRIPLESTORE_HPP

#include <cstdint>

namespace proven {

/// @brief Statement matching the Idris2 ABI tags.
enum class Statement : uint8_t {
    Triple = 0,
    Quad = 1
};

/// @brief IndexOrder matching the Idris2 ABI tags.
enum class IndexOrder : uint8_t {
    Spo = 0,
    Pos = 1,
    Osp = 2,
    Gspo = 3,
    Gpos = 4,
    Gosp = 5
};

/// @brief StorageBackend matching the Idris2 ABI tags.
enum class StorageBackend : uint8_t {
    InMemory = 0,
    BTree = 1,
    Lsm = 2,
    Persistent = 3
};

/// @brief ImportFormat matching the Idris2 ABI tags.
enum class ImportFormat : uint8_t {
    NTriples = 0,
    Turtle = 1,
    RdfXml = 2,
    JsonLd = 3,
    NQuads = 4,
    Trig = 5
};

/// @brief TransactionIsolation matching the Idris2 ABI tags.
enum class TransactionIsolation : uint8_t {
    ReadCommitted = 0,
    Serializable = 1,
    Snapshot = 2
};

/// @brief StoreState matching the Idris2 ABI tags.
enum class StoreState : uint8_t {
    Idle = 0,
    Ready = 1,
    InTransaction = 2,
    Importing = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_TRIPLESTORE_HPP
