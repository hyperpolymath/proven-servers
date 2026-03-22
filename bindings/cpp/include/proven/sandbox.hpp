// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file sandbox.hpp
/// @brief Sandbox protocol types for proven-servers.

#ifndef PROVEN_SANDBOX_HPP
#define PROVEN_SANDBOX_HPP

#include <cstdint>

namespace proven {

/// @brief ExecutionPolicy matching the Idris2 ABI tags.
enum class ExecutionPolicy : uint8_t {
    Unrestricted = 0,
    ReadOnly = 1,
    NetworkDenied = 2,
    Isolated = 3,
    Ephemeral = 4
};

/// @brief ResourceLimit matching the Idris2 ABI tags.
enum class ResourceLimit : uint8_t {
    CpuTime = 0,
    Memory = 1,
    DiskIo = 2,
    NetworkIo = 3,
    FileDescriptors = 4,
    Processes = 5
};

/// @brief SandboxState matching the Idris2 ABI tags.
enum class SandboxState : uint8_t {
    Creating = 0,
    Ready = 1,
    Running = 2,
    Suspended = 3,
    Terminated = 4,
    Destroyed = 5
};

/// @brief ExitReason matching the Idris2 ABI tags.
enum class ExitReason : uint8_t {
    Normal = 0,
    Timeout = 1,
    MemoryExceeded = 2,
    PolicyViolation = 3,
    Killed = 4,
    Error = 5
};

/// @brief SyscallPolicy matching the Idris2 ABI tags.
enum class SyscallPolicy : uint8_t {
    Allow = 0,
    Deny = 1,
    Log = 2,
    Trap = 3
};

} // namespace proven

#endif // PROVEN_SANDBOX_HPP
