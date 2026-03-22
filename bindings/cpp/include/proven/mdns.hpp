// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file mdns.hpp
/// @brief mDNS protocol types for proven-servers.

#ifndef PROVEN_MDNS_HPP
#define PROVEN_MDNS_HPP

#include <cstdint>

namespace proven {

/// @brief MdnsRecordType matching the Idris2 ABI tags.
enum class MdnsRecordType : uint8_t {
    A = 0,
    Aaaa = 1,
    Ptr = 2,
    Srv = 3,
    Txt = 4
};

/// @brief QueryType matching the Idris2 ABI tags.
enum class QueryType : uint8_t {
    Standard = 0,
    OneShot = 1,
    Continuous = 2
};

/// @brief ConflictAction matching the Idris2 ABI tags.
enum class ConflictAction : uint8_t {
    Probe = 0,
    Defend = 1,
    Withdraw = 2
};

/// @brief ServiceFlag matching the Idris2 ABI tags.
enum class ServiceFlag : uint8_t {
    Unique = 0,
    Shared = 1
};

/// @brief ResponderState matching the Idris2 ABI tags.
enum class ResponderState : uint8_t {
    Idle = 0,
    Probing = 1,
    Announcing = 2,
    Running = 3,
    ShuttingDown = 4
};

} // namespace proven

#endif // PROVEN_MDNS_HPP
