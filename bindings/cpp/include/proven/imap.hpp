// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file imap.hpp
/// @brief IMAP protocol types for proven-servers.

#ifndef PROVEN_IMAP_HPP
#define PROVEN_IMAP_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    Login = 0,
    Logout = 1,
    Select = 2,
    Examine = 3,
    Create = 4,
    Delete = 5,
    Rename = 6,
    List = 7,
    Fetch = 8,
    Store = 9,
    Search = 10,
    Copy = 11,
    Noop = 12,
    Capability = 13
};

/// @brief State matching the Idris2 ABI tags.
enum class State : uint8_t {
    NotAuthenticated = 0,
    Authenticated = 1,
    Selected = 2,
    Logout = 3
};

/// @brief Flag matching the Idris2 ABI tags.
enum class Flag : uint8_t {
    Seen = 0,
    Answered = 1,
    Flagged = 2,
    Deleted = 3,
    Draft = 4,
    Recent = 5
};

} // namespace proven

#endif // PROVEN_IMAP_HPP
