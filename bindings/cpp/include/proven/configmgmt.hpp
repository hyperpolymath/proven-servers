// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file configmgmt.hpp
/// @brief Config Mgmt protocol types for proven-servers.

#ifndef PROVEN_CONFIGMGMT_HPP
#define PROVEN_CONFIGMGMT_HPP

#include <cstdint>

namespace proven {

/// @brief ResourceType matching the Idris2 ABI tags.
enum class ResourceType : uint8_t {
    File = 0,
    Package = 1,
    Service = 2,
    User = 3,
    Group = 4,
    Cron = 5,
    Mount = 6,
    Firewall = 7,
    Registry = 8
};

/// @brief ResourceState matching the Idris2 ABI tags.
enum class ResourceState : uint8_t {
    Present = 0,
    Absent = 1,
    Running = 2,
    Stopped = 3,
    Enabled = 4,
    Disabled = 5
};

/// @brief ChangeAction matching the Idris2 ABI tags.
enum class ChangeAction : uint8_t {
    Create = 0,
    Modify = 1,
    Delete = 2,
    Restart = 3,
    Reload = 4,
    Skip = 5
};

/// @brief DriftStatus matching the Idris2 ABI tags.
enum class DriftStatus : uint8_t {
    InSync = 0,
    Drifted = 1,
    DUnknown = 2,
    Unmanaged = 3
};

/// @brief ApplyMode matching the Idris2 ABI tags.
enum class ApplyMode : uint8_t {
    Enforce = 0,
    DryRun = 1,
    Audit = 2
};

} // namespace proven

#endif // PROVEN_CONFIGMGMT_HPP
