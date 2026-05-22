// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ldap.hpp
/// @brief LDAP protocol types for proven-servers.

#ifndef PROVEN_LDAP_HPP
#define PROVEN_LDAP_HPP

#include <cstdint>

namespace proven {

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Anonymous = 0,
    Bound = 1,
    Closed = 2,
    Binding = 3
};

/// @brief Operation matching the Idris2 ABI tags.
enum class Operation : uint8_t {
    Bind = 0,
    Unbind = 1,
    Search = 2,
    Modify = 3,
    Add = 4,
    Delete = 5,
    ModDn = 6,
    Compare = 7,
    Abandon = 8,
    Extended = 9
};

/// @brief SearchScope matching the Idris2 ABI tags.
enum class SearchScope : uint8_t {
    BaseObject = 0,
    SingleLevel = 1,
    WholeSubtree = 2
};

/// @brief ResultCode matching the Idris2 ABI tags.
enum class ResultCode : uint8_t {
    Success = 0,
    OperationsError = 1,
    ProtocolError = 2,
    TimeLimitExceeded = 3,
    SizeLimitExceeded = 4,
    AuthMethodNotSupported = 5,
    NoSuchObject = 6,
    InvalidCredentials = 7,
    InsufficientAccessRights = 8,
    Busy = 9,
    Unavailable = 10
};

} // namespace proven

#endif // PROVEN_LDAP_HPP
