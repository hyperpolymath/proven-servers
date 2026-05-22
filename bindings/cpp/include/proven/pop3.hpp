// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file pop3.hpp
/// @brief POP3 protocol types for proven-servers.

#ifndef PROVEN_POP3_HPP
#define PROVEN_POP3_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    User = 0,
    Pass = 1,
    Stat = 2,
    List = 3,
    Retr = 4,
    Dele = 5,
    Noop = 6,
    Rset = 7,
    Quit = 8,
    Top = 9,
    Uidl = 10
};

/// @brief State matching the Idris2 ABI tags.
enum class State : uint8_t {
    Authorization = 0,
    Transaction = 1,
    Update = 2
};

/// @brief Response matching the Idris2 ABI tags.
enum class Response : uint8_t {
    Ok = 0,
    Err = 1
};

/// @brief Pop3Error matching the Idris2 ABI tags.
enum class Pop3Error : uint8_t {
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidTransition = 3,
    InvalidCommand = 4,
    AuthFailed = 5
};

} // namespace proven

#endif // PROVEN_POP3_HPP
