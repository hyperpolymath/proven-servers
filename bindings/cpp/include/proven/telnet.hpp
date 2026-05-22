// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file telnet.hpp
/// @brief Telnet protocol types for proven-servers.

#ifndef PROVEN_TELNET_HPP
#define PROVEN_TELNET_HPP

#include <cstdint>

namespace proven {

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    Se = 0,
    Nop = 1,
    DataMark = 2,
    Break = 3,
    InterruptProcess = 4,
    AbortOutput = 5,
    AreYouThere = 6,
    EraseChar = 7,
    EraseLine = 8,
    GoAhead = 9,
    Sb = 10,
    Will = 11,
    Wont = 12,
    Do = 13,
    Dont = 14,
    Iac = 15
};

/// @brief TelnetOption matching the Idris2 ABI tags.
enum class TelnetOption : uint8_t {
    Echo = 0,
    SuppressGoAhead = 1,
    Status = 2,
    TimingMark = 3,
    TerminalType = 4,
    WindowSize = 5,
    TerminalSpeed = 6,
    RemoteFlowControl = 7,
    Linemode = 8,
    Environment = 9
};

/// @brief NegotiationState matching the Idris2 ABI tags.
enum class NegotiationState : uint8_t {
    Inactive = 0,
    WillSent = 1,
    DoSent = 2,
    Active = 3
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Negotiating = 1,
    Active = 2,
    Subneg = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_TELNET_HPP
