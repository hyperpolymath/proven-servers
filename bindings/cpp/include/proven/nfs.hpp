// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file nfs.hpp
/// @brief NFS protocol types for proven-servers.

#ifndef PROVEN_NFS_HPP
#define PROVEN_NFS_HPP

#include <cstdint>

namespace proven {

/// @brief Operation matching the Idris2 ABI tags.
enum class Operation : uint8_t {
    Access = 0,
    Close = 1,
    Commit = 2,
    Create = 3,
    GetAttr = 4,
    Link = 5,
    Lock = 6,
    Lookup = 7,
    Open = 8,
    Read = 9,
    ReadDir = 10,
    Remove = 11,
    Rename = 12,
    SetAttr = 13,
    Write = 14
};

/// @brief FileType matching the Idris2 ABI tags.
enum class FileType : uint8_t {
    Regular = 0,
    Directory = 1,
    BlockDevice = 2,
    CharDevice = 3,
    Link = 4,
    Socket = 5,
    Fifo = 6
};

/// @brief Status matching the Idris2 ABI tags.
enum class Status : uint8_t {
    Ok = 0,
    Perm = 1,
    NoEnt = 2,
    Io = 3,
    NxIo = 4,
    Access = 5,
    Exist = 6,
    NotDir = 7,
    IsDir = 8,
    FBig = 9,
    NoSpc = 10,
    ROfs = 11,
    NotEmpty = 12,
    Stale = 13
};

/// @brief NfsState matching the Idris2 ABI tags.
enum class NfsState : uint8_t {
    Idle = 0,
    Mounted = 1,
    FileOpen = 2,
    Locked = 3,
    Busy = 4,
    Unmounting = 5
};

} // namespace proven

#endif // PROVEN_NFS_HPP
