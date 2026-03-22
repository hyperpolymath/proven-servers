<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** FileOperation matching the Idris2 ABI tags. */
enum FileOperation: int
{
    case Read = 0;
    case Write = 1;
    case Create = 2;
    case Delete = 3;
    case Rename = 4;
    case List = 5;
    case Stat = 6;
    case Lock = 7;
    case Unlock = 8;
    case Watch = 9;
}

/** FileType matching the Idris2 ABI tags. */
enum FileType: int
{
    case Regular = 0;
    case Directory = 1;
    case Symlink = 2;
    case BlockDevice = 3;
    case CharDevice = 4;
    case Fifo = 5;
    case Socket = 6;
}

/** FilePermission matching the Idris2 ABI tags. */
enum FilePermission: int
{
    case OwnerRead = 0;
    case OwnerWrite = 1;
    case OwnerExecute = 2;
    case GroupRead = 3;
    case GroupWrite = 4;
    case GroupExecute = 5;
    case OtherRead = 6;
    case OtherWrite = 7;
    case OtherExecute = 8;
}

/** LockType matching the Idris2 ABI tags. */
enum LockType: int
{
    case Shared = 0;
    case Exclusive = 1;
    case Advisory = 2;
    case Mandatory = 3;
}

/** FileErrorCode matching the Idris2 ABI tags. */
enum FileErrorCode: int
{
    case NotFound = 0;
    case PermissionDenied = 1;
    case AlreadyExists = 2;
    case NotEmpty = 3;
    case IsDirectory = 4;
    case NotDirectory = 5;
    case NoSpace = 6;
    case ReadOnly = 7;
    case Locked = 8;
    case IoError = 9;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Connected = 1;
    case Operating = 2;
    case FsLocked = 3;
    case Disconnecting = 4;
}
