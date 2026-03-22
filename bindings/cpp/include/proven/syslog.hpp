// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file syslog.hpp
/// @brief Syslog protocol types for proven-servers.

#ifndef PROVEN_SYSLOG_HPP
#define PROVEN_SYSLOG_HPP

#include <cstdint>

namespace proven {

/// @brief Severity matching the Idris2 ABI tags.
enum class Severity : uint8_t {
    Emergency = 0,
    Alert = 1,
    Critical = 2,
    Error = 3,
    Warning = 4,
    Notice = 5,
    Informational = 6,
    Debug = 7
};

/// @brief Facility matching the Idris2 ABI tags.
enum class Facility : uint8_t {
    Kern = 0,
    User = 1,
    Mail = 2,
    Daemon = 3,
    Auth = 4,
    Syslog = 5,
    Lpr = 6,
    News = 7,
    Uucp = 8,
    Cron = 9,
    AuthPriv = 10,
    Ftp = 11,
    Ntp = 12,
    Audit = 13,
    Alert = 14,
    Clock = 15,
    Local0 = 16,
    Local1 = 17,
    Local2 = 18,
    Local3 = 19,
    Local4 = 20,
    Local5 = 21,
    Local6 = 22,
    Local7 = 23
};

/// @brief Transport matching the Idris2 ABI tags.
enum class Transport : uint8_t {
    Udp514 = 0,
    Tcp514 = 1,
    Tls6514 = 2
};

} // namespace proven

#endif // PROVEN_SYSLOG_HPP
