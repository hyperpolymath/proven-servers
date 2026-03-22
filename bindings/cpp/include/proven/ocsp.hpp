// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ocsp.hpp
/// @brief OCSP protocol types for proven-servers.

#ifndef PROVEN_OCSP_HPP
#define PROVEN_OCSP_HPP

#include <cstdint>

namespace proven {

/// @brief CertStatus matching the Idris2 ABI tags.
enum class CertStatus : uint8_t {
    Good = 0,
    Revoked = 1,
    Unknown = 2
};

/// @brief ResponseStatus matching the Idris2 ABI tags.
enum class ResponseStatus : uint8_t {
    Successful = 0,
    MalformedRequest = 1,
    InternalError = 2,
    TryLater = 3,
    SigRequired = 4,
    Unauthorized = 5
};

/// @brief HashAlgorithm matching the Idris2 ABI tags.
enum class HashAlgorithm : uint8_t {
    Sha1 = 0,
    Sha256 = 1,
    Sha384 = 2,
    Sha512 = 3
};

/// @brief ResponderState matching the Idris2 ABI tags.
enum class ResponderState : uint8_t {
    Idle = 0,
    Ready = 1,
    Processing = 2,
    Signing = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_OCSP_HPP
