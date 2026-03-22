<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NFS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Operation matching the Idris2 ABI tags. */
enum Operation: int
{
    case Operation_Access = 0;
    case Close = 1;
    case Commit = 2;
    case Create = 3;
    case GetAttr = 4;
    case Operation_Link = 5;
    case Lock = 6;
    case Lookup = 7;
    case Open = 8;
    case Read = 9;
    case ReadDir = 10;
    case Remove = 11;
    case Rename = 12;
    case SetAttr = 13;
    case Write = 14;
}

/** FileType matching the Idris2 ABI tags. */
enum FileType: int
{
    case Regular = 0;
    case Directory = 1;
    case BlockDevice = 2;
    case CharDevice = 3;
    case FileType_Link = 4;
    case Socket = 5;
    case Fifo = 6;
}

/** Status matching the Idris2 ABI tags. */
enum Status: int
{
    case Ok = 0;
    case Perm = 1;
    case NoEnt = 2;
    case Io = 3;
    case NxIo = 4;
    case Status_Access = 5;
    case Exist = 6;
    case NotDir = 7;
    case IsDir = 8;
    case FBig = 9;
    case NoSpc = 10;
    case ROfs = 11;
    case NotEmpty = 12;
    case Stale = 13;
}

/** NfsState matching the Idris2 ABI tags. */
enum NfsState: int
{
    case Idle = 0;
    case Mounted = 1;
    case FileOpen = 2;
    case Locked = 3;
    case Busy = 4;
    case Unmounting = 5;
}
