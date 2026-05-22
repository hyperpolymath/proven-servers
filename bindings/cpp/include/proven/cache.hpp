// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file cache.hpp
/// @brief Cache protocol types for proven-servers.

#ifndef PROVEN_CACHE_HPP
#define PROVEN_CACHE_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    Get = 0,
    Set = 1,
    Delete = 2,
    Exists = 3,
    Expire = 4,
    Ttl = 5,
    Keys = 6,
    Flush = 7,
    Incr = 8,
    Decr = 9,
    Append = 10,
    Prepend = 11,
    Cas = 12
};

/// @brief EvictionPolicy matching the Idris2 ABI tags.
enum class EvictionPolicy : uint8_t {
    Lru = 0,
    Lfu = 1,
    Random = 2,
    EvictTtl = 3,
    NoEviction = 4
};

/// @brief DataType matching the Idris2 ABI tags.
enum class DataType : uint8_t {
    StringVal = 0,
    IntVal = 1,
    ListVal = 2,
    SetVal = 3,
    HashVal = 4
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    NotFound = 0,
    TypeMismatch = 1,
    OutOfMemory = 2,
    KeyTooLong = 3,
    ValueTooLarge = 4,
    CasConflict = 5
};

/// @brief ReplicationMode matching the Idris2 ABI tags.
enum class ReplicationMode : uint8_t {
    None = 0,
    Primary = 1,
    Replica = 2,
    Sentinel = 3
};

} // namespace proven

#endif // PROVEN_CACHE_HPP
