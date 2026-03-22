<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case Login = 0;
    case Command_Logout = 1;
    case Select = 2;
    case Examine = 3;
    case Create = 4;
    case Delete = 5;
    case Rename = 6;
    case List = 7;
    case Fetch = 8;
    case Store = 9;
    case Search = 10;
    case Copy = 11;
    case Noop = 12;
    case Capability = 13;
}

/** State matching the Idris2 ABI tags. */
enum State: int
{
    case NotAuthenticated = 0;
    case Authenticated = 1;
    case Selected = 2;
    case State_Logout = 3;
}

/** Flag matching the Idris2 ABI tags. */
enum Flag: int
{
    case Seen = 0;
    case Answered = 1;
    case Flagged = 2;
    case Deleted = 3;
    case Draft = 4;
    case Recent = 5;
}
