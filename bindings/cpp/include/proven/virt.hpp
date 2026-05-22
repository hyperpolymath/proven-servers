// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file virt.hpp
/// @brief Virtualization protocol types for proven-servers.

#ifndef PROVEN_VIRT_HPP
#define PROVEN_VIRT_HPP

#include <cstdint>

namespace proven {

/// @brief VmState matching the Idris2 ABI tags.
enum class VmState : uint8_t {
    Creating = 0,
    Running = 1,
    Paused = 2,
    Suspended = 3,
    ShuttingDown = 4,
    Stopped = 5,
    Crashed = 6,
    Migrating = 7
};

/// @brief VirtOperation matching the Idris2 ABI tags.
enum class VirtOperation : uint8_t {
    Create = 0,
    Start = 1,
    Stop = 2,
    Restart = 3,
    Pause = 4,
    Resume = 5,
    Suspend = 6,
    Migrate = 7,
    Snapshot = 8,
    Clone = 9,
    Delete = 10
};

/// @brief DiskFormat matching the Idris2 ABI tags.
enum class DiskFormat : uint8_t {
    Raw = 0,
    Qcow2 = 1,
    Vdi = 2,
    Vmdk = 3,
    Vhd = 4
};

/// @brief NetworkType matching the Idris2 ABI tags.
enum class NetworkType : uint8_t {
    Nat = 0,
    Bridged = 1,
    Internal = 2,
    HostOnly = 3
};

/// @brief BootDevice matching the Idris2 ABI tags.
enum class BootDevice : uint8_t {
    HardDisk = 0,
    Cdrom = 1,
    Network = 2,
    Usb = 3
};

} // namespace proven

#endif // PROVEN_VIRT_HPP
