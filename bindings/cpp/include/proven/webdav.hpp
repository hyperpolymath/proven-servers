// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file webdav.hpp
/// @brief WebDAV protocol types for proven-servers.

#ifndef PROVEN_WEBDAV_HPP
#define PROVEN_WEBDAV_HPP

#include <cstdint>

namespace proven {

/// @brief Method matching the Idris2 ABI tags.
enum class Method : uint8_t {
    Propfind = 0,
    Proppatch = 1,
    Mkcol = 2,
    Copy = 3,
    Move = 4,
    Lock = 5,
    Unlock = 6
};

/// @brief StatusCode matching the Idris2 ABI tags.
enum class StatusCode : uint8_t {
    MultiStatus = 0,
    UnprocessableEntity = 1,
    Locked = 2,
    FailedDependency = 3,
    InsufficientStorage = 4
};

/// @brief LockScope matching the Idris2 ABI tags.
enum class LockScope : uint8_t {
    Exclusive = 0,
    Shared = 1
};

/// @brief LockType matching the Idris2 ABI tags.
enum class LockType : uint8_t {
    Write = 0
};

/// @brief Depth matching the Idris2 ABI tags.
enum class Depth : uint8_t {
    Zero = 0,
    One = 1,
    Infinity = 2
};

/// @brief PropertyOp matching the Idris2 ABI tags.
enum class PropertyOp : uint8_t {
    Set = 0,
    Remove = 1
};

} // namespace proven

#endif // PROVEN_WEBDAV_HPP
