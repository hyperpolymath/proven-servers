// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ntp.hpp
/// @brief NTP protocol types for proven-servers.

#ifndef PROVEN_NTP_HPP
#define PROVEN_NTP_HPP

#include <cstdint>

namespace proven {

/// @brief LeapIndicator matching the Idris2 ABI tags.
enum class LeapIndicator : uint8_t {
    NoWarning = 0,
    LastMinute61 = 1,
    LastMinute59 = 2,
    Unsynchronised = 3
};

/// @brief NtpMode matching the Idris2 ABI tags.
enum class NtpMode : uint8_t {
    Reserved = 0,
    SymmetricActive = 1,
    SymmetricPassive = 2,
    Client = 3,
    Server = 4,
    Broadcast = 5,
    ControlMessage = 6,
    Private = 7
};

/// @brief ExchangeState matching the Idris2 ABI tags.
enum class ExchangeState : uint8_t {
    Idle = 0,
    RequestReceived = 1,
    TimestampCalculated = 2,
    ResponseSent = 3
};

/// @brief ClockDisciplineState matching the Idris2 ABI tags.
enum class ClockDisciplineState : uint8_t {
    Unset = 0,
    Spike = 1,
    Freq = 2,
    Sync = 3,
    Panic = 4
};

/// @brief KissCode matching the Idris2 ABI tags.
enum class KissCode : uint8_t {
    Deny = 0,
    Rstr = 1,
    Rate = 2,
    Other = 3
};

/// @brief NtpError matching the Idris2 ABI tags.
enum class NtpError : uint8_t {
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidPacket = 3,
    KissOfDeath = 4,
    StratumTooHigh = 5
};

} // namespace proven

#endif // PROVEN_NTP_HPP
