// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file fileserver.hpp
/// @brief File Server protocol types for proven-servers.

#ifndef PROVEN_FILESERVER_HPP
#define PROVEN_FILESERVER_HPP

#include <cstdint>

namespace proven {

/// @brief FileOperation matching the Idris2 ABI tags.
enum class FileOperation : uint8_t {
    Read = 0,
    Write = 1,
    Create = 2,
    Delete = 3,
    Rename = 4,
    List = 5,
    Stat = 6,
    Lock = 7,
    Unlock = 8,
    Watch = 9
};

/// @brief FileType matching the Idris2 ABI tags.
enum class FileType : uint8_t {
    Regular = 0,
    Directory = 1,
    Symlink = 2,
    BlockDevice = 3,
    CharDevice = 4,
    Fifo = 5,
    Socket = 6
};

/// @brief FilePermission matching the Idris2 ABI tags.
enum class FilePermission : uint8_t {
    OwnerRead = 0,
    OwnerWrite = 1,
    OwnerExecute = 2,
    GroupRead = 3,
    GroupWrite = 4,
    GroupExecute = 5,
    OtherRead = 6,
    OtherWrite = 7,
    OtherExecute = 8
};

/// @brief LockType matching the Idris2 ABI tags.
enum class LockType : uint8_t {
    Shared = 0,
    Exclusive = 1,
    Advisory = 2,
    Mandatory = 3
};

/// @brief FileErrorCode matching the Idris2 ABI tags.
enum class FileErrorCode : uint8_t {
    NotFound = 0,
    PermissionDenied = 1,
    AlreadyExists = 2,
    NotEmpty = 3,
    IsDirectory = 4,
    NotDirectory = 5,
    NoSpace = 6,
    ReadOnly = 7,
    Locked = 8,
    IoError = 9
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Connected = 1,
    Operating = 2,
    FsLocked = 3,
    Disconnecting = 4
};

} // namespace proven

#endif // PROVEN_FILESERVER_HPP
