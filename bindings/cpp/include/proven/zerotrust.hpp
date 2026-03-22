// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file zerotrust.hpp
/// @brief Zero Trust protocol types for proven-servers.

#ifndef PROVEN_ZEROTRUST_HPP
#define PROVEN_ZEROTRUST_HPP

#include <cstdint>

namespace proven {

/// @brief PolicyType matching the Idris2 ABI tags.
enum class PolicyType : uint8_t {
    AlwaysVerify = 0,
    NeverTrust = 1,
    LeastPrivilege = 2,
    MicroSegmentation = 3
};

/// @brief IdentityConfidence matching the Idris2 ABI tags.
enum class IdentityConfidence : uint8_t {
    Unverified = 0,
    BasicAuth = 1,
    MfaVerified = 2,
    StrongAuth = 3,
    ContinuousAuth = 4
};

/// @brief DeviceTrustScore matching the Idris2 ABI tags.
enum class DeviceTrustScore : uint8_t {
    DeviceUnknown = 0,
    DevicePartial = 1,
    DeviceCompliant = 2,
    DeviceManaged = 3,
    DeviceHardened = 4
};

/// @brief AccessDecision matching the Idris2 ABI tags.
enum class AccessDecision : uint8_t {
    Allow = 0,
    Deny = 1,
    Challenge = 2,
    StepUp = 3
};

/// @brief ContextSignalKind matching the Idris2 ABI tags.
enum class ContextSignalKind : uint8_t {
    Location = 0,
    Time = 1,
    Device = 2,
    Behavior = 3,
    Network = 4
};

/// @brief AuthFactor matching the Idris2 ABI tags.
enum class AuthFactor : uint8_t {
    Certificate = 0,
    Token = 1,
    Biometric = 2,
    Fido2 = 3,
    Totp = 4,
    Push = 5
};

} // namespace proven

#endif // PROVEN_ZEROTRUST_HPP
