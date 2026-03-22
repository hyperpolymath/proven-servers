// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file snmp.hpp
/// @brief SNMP protocol types for proven-servers.

#ifndef PROVEN_SNMP_HPP
#define PROVEN_SNMP_HPP

#include <cstdint>

namespace proven {

/// @brief Version matching the Idris2 ABI tags.
enum class Version : uint8_t {
    V1 = 0,
    V2c = 1,
    V3 = 2
};

/// @brief PduType matching the Idris2 ABI tags.
enum class PduType : uint8_t {
    GetRequest = 0,
    GetNextRequest = 1,
    GetResponse = 2,
    SetRequest = 3,
    GetBulkRequest = 4,
    InformRequest = 5,
    SnmpV2Trap = 6
};

/// @brief ErrorStatus matching the Idris2 ABI tags.
enum class ErrorStatus : uint8_t {
    NoError = 0,
    TooBig = 1,
    NoSuchName = 2,
    BadValue = 3,
    ReadOnly = 4,
    GenErr = 5,
    NoAccess = 6,
    WrongType = 7,
    WrongLength = 8,
    WrongValue = 9,
    NoCreation = 10,
    InconsistentValue = 11,
    ResourceUnavailable = 12,
    CommitFailed = 13,
    UndoFailed = 14,
    AuthorizationError = 15
};

} // namespace proven

#endif // PROVEN_SNMP_HPP
