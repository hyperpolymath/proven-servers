// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file hardened.hpp
/// @brief Hardened protocol types for proven-servers.

#ifndef PROVEN_HARDENED_HPP
#define PROVEN_HARDENED_HPP

#include <cstdint>

namespace proven {

/// @brief HardeningLevel matching the Idris2 ABI tags.
enum class HardeningLevel : uint8_t {
    Minimal = 0,
    Standard = 1,
    High = 2,
    Maximum = 3
};

/// @brief SecurityControl matching the Idris2 ABI tags.
enum class SecurityControl : uint8_t {
    Aslr = 0,
    Dep = 1,
    StackCanary = 2,
    Cfi = 3,
    Sandboxing = 4,
    SecureBoot = 5,
    AuditLog = 6
};

/// @brief ComplianceStandard matching the Idris2 ABI tags.
enum class ComplianceStandard : uint8_t {
    Cis = 0,
    Stig = 1,
    Nist80053 = 2,
    PciDss = 3,
    Fips140 = 4
};

/// @brief AuditEvent matching the Idris2 ABI tags.
enum class AuditEvent : uint8_t {
    ProcessStart = 0,
    FileAccess = 1,
    NetworkConn = 2,
    PrivilegeEscalation = 3,
    ConfigChange = 4,
    AuthAttempt = 5
};

/// @brief HardenedHealthStatus matching the Idris2 ABI tags.
enum class HardenedHealthStatus : uint8_t {
    Healthy = 0,
    Degraded = 1,
    Compromised = 2,
    Unresponsive = 3
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Hardening = 1,
    Active = 2,
    Auditing = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_HARDENED_HPP
