// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file diode.hpp
/// @brief Data Diode protocol types for proven-servers.

#ifndef PROVEN_DIODE_HPP
#define PROVEN_DIODE_HPP

#include <cstdint>

namespace proven {

/// @brief Direction matching the Idris2 ABI tags.
enum class Direction : uint8_t {
    HighToLow = 0,
    LowToHigh = 1
};

/// @brief DiodeProtocol matching the Idris2 ABI tags.
enum class DiodeProtocol : uint8_t {
    Udp = 0,
    Tcp = 1,
    FileTransfer = 2,
    Syslog = 3,
    Snmp = 4
};

/// @brief TransferState matching the Idris2 ABI tags.
enum class TransferState : uint8_t {
    Queued = 0,
    Sending = 1,
    Confirming = 2,
    Complete = 3,
    Failed = 4
};

/// @brief ValidationResult matching the Idris2 ABI tags.
enum class ValidationResult : uint8_t {
    Passed = 0,
    FormatError = 1,
    SizeExceeded = 2,
    PolicyBlocked = 3
};

/// @brief IntegrityCheck matching the Idris2 ABI tags.
enum class IntegrityCheck : uint8_t {
    Crc32 = 0,
    Sha256 = 1,
    Hmac = 2
};

/// @brief GatewayState matching the Idris2 ABI tags.
enum class GatewayState : uint8_t {
    Idle = 0,
    Configured = 1,
    Transferring = 2,
    Validating = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_DIODE_HPP
