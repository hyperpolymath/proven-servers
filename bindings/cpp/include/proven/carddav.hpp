// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file carddav.hpp
/// @brief CardDAV protocol types for proven-servers.

#ifndef PROVEN_CARDDAV_HPP
#define PROVEN_CARDDAV_HPP

#include <cstdint>

namespace proven {

/// @brief PropertyType matching the Idris2 ABI tags.
enum class PropertyType : uint8_t {
    FnName = 0,
    N = 1,
    Email = 2,
    Tel = 3,
    Adr = 4,
    Org = 5,
    Photo = 6,
    Url = 7,
    Note = 8
};

/// @brief CardMethod matching the Idris2 ABI tags.
enum class CardMethod : uint8_t {
    Get = 0,
    Put = 1,
    Delete = 2,
    Propfind = 3,
    Proppatch = 4,
    Report = 5,
    Mkcol = 6
};

/// @brief VCardVersion matching the Idris2 ABI tags.
enum class VCardVersion : uint8_t {
    Vcard3 = 0,
    Vcard4 = 1
};

/// @brief CardError matching the Idris2 ABI tags.
enum class CardError : uint8_t {
    ValidAddressData = 0,
    NoResourceType = 1,
    MaxResourceSize = 2,
    UidConflict = 3,
    SupportedAddressData = 4,
    PreconditionFailed = 5
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Shutdown = 3
};

} // namespace proven

#endif // PROVEN_CARDDAV_HPP
