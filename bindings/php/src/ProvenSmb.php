<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMB protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case Negotiate = 0;
    case SessionSetup = 1;
    case Logoff = 2;
    case TreeConnect = 3;
    case TreeDisconnect = 4;
    case Create = 5;
    case Close = 6;
    case Read = 7;
    case Write = 8;
    case Lock = 9;
    case Ioctl = 10;
    case Cancel = 11;
    case QueryDirectory = 12;
    case ChangeNotify = 13;
    case QueryInfo = 14;
    case SetInfo = 15;
}

/** Dialect matching the Idris2 ABI tags. */
enum Dialect: int
{
    case Smb2_0_2 = 0;
    case Smb2_1 = 1;
    case Smb3_0 = 2;
    case Smb3_0_2 = 3;
    case Smb3_1_1 = 4;
}

/** ShareType matching the Idris2 ABI tags. */
enum ShareType: int
{
    case Disk = 0;
    case Pipe = 1;
    case Print = 2;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Negotiated = 1;
    case Authenticated = 2;
    case TreeConnected = 3;
    case FileOpen = 4;
    case Disconnecting = 5;
}
