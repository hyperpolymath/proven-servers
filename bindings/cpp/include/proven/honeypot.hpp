// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file honeypot.hpp
/// @brief Honeypot protocol types for proven-servers.

#ifndef PROVEN_HONEYPOT_HPP
#define PROVEN_HONEYPOT_HPP

#include <cstdint>

namespace proven {

/// @brief ServiceEmulation matching the Idris2 ABI tags.
enum class ServiceEmulation : uint8_t {
    Ssh = 0,
    Http = 1,
    Ftp = 2,
    Smtp = 3,
    Telnet = 4,
    Mysql = 5,
    Rdp = 6
};

/// @brief InteractionLevel matching the Idris2 ABI tags.
enum class InteractionLevel : uint8_t {
    Low = 0,
    Medium = 1,
    High = 2
};

/// @brief HoneypotAlertSeverity matching the Idris2 ABI tags.
enum class HoneypotAlertSeverity : uint8_t {
    Info = 0,
    AsLow = 1,
    AsMedium = 2,
    AsHigh = 3,
    Critical = 4
};

/// @brief AttackerAction matching the Idris2 ABI tags.
enum class AttackerAction : uint8_t {
    Scan = 0,
    BruteForce = 1,
    Exploit = 2,
    Payload = 3,
    Lateral = 4,
    Exfiltration = 5
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Deployed = 1,
    Engaged = 2,
    Shutdown = 3
};

} // namespace proven

#endif // PROVEN_HONEYPOT_HPP
