// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file tftp.hpp
/// @brief TFTP protocol types for proven-servers.

#ifndef PROVEN_TFTP_HPP
#define PROVEN_TFTP_HPP

#include <cstdint>

namespace proven {

/// @brief Opcode matching the Idris2 ABI tags.
enum class Opcode : uint8_t {
    Rrq = 0,
    Wrq = 1,
    Data = 2,
    Ack = 3,
    Error = 4
};

/// @brief TransferMode matching the Idris2 ABI tags.
enum class TransferMode : uint8_t {
    NetAscii = 0,
    Octet = 1,
    Mail = 2
};

/// @brief TftpError matching the Idris2 ABI tags.
enum class TftpError : uint8_t {
    NotDefined = 0,
    FileNotFound = 1,
    AccessViolation = 2,
    DiskFull = 3,
    IllegalOperation = 4,
    UnknownTid = 5,
    FileExists = 6,
    NoSuchUser = 7
};

/// @brief TransferState matching the Idris2 ABI tags.
enum class TransferState : uint8_t {
    Idle = 0,
    Reading = 1,
    Writing = 2,
    InError = 3,
    Complete = 4
};

} // namespace proven

#endif // PROVEN_TFTP_HPP
