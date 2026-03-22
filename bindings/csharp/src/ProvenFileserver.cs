// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server protocol types for proven-servers.

namespace Proven;

/// <summary>FileOperation matching the Idris2 ABI tags (0-9).</summary>
public enum FileOperation : byte
{
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
}

/// <summary>FileType matching the Idris2 ABI tags (0-6).</summary>
public enum FileType : byte
{
    Regular = 0,
    Directory = 1,
    Symlink = 2,
    BlockDevice = 3,
    CharDevice = 4,
    Fifo = 5,
    Socket = 6
}

/// <summary>FilePermission matching the Idris2 ABI tags (0-8).</summary>
public enum FilePermission : byte
{
    OwnerRead = 0,
    OwnerWrite = 1,
    OwnerExecute = 2,
    GroupRead = 3,
    GroupWrite = 4,
    GroupExecute = 5,
    OtherRead = 6,
    OtherWrite = 7,
    OtherExecute = 8
}

/// <summary>LockType matching the Idris2 ABI tags (0-3).</summary>
public enum LockType : byte
{
    Shared = 0,
    Exclusive = 1,
    Advisory = 2,
    Mandatory = 3
}

/// <summary>FileErrorCode matching the Idris2 ABI tags (0-9).</summary>
public enum FileErrorCode : byte
{
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
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Connected = 1,
    Operating = 2,
    FsLocked = 3,
    Disconnecting = 4
}
