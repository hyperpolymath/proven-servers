<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Anonymous = 0;
    case Bound = 1;
    case Closed = 2;
    case Binding = 3;
}

/** Operation matching the Idris2 ABI tags. */
enum Operation: int
{
    case Bind = 0;
    case Unbind = 1;
    case Search = 2;
    case Modify = 3;
    case Add = 4;
    case Delete = 5;
    case ModDn = 6;
    case Compare = 7;
    case Abandon = 8;
    case Extended = 9;
}

/** SearchScope matching the Idris2 ABI tags. */
enum SearchScope: int
{
    case BaseObject = 0;
    case SingleLevel = 1;
    case WholeSubtree = 2;
}

/** ResultCode matching the Idris2 ABI tags. */
enum ResultCode: int
{
    case Success = 0;
    case OperationsError = 1;
    case ProtocolError = 2;
    case TimeLimitExceeded = 3;
    case SizeLimitExceeded = 4;
    case AuthMethodNotSupported = 5;
    case NoSuchObject = 6;
    case InvalidCredentials = 7;
    case InsufficientAccessRights = 8;
    case Busy = 9;
    case Unavailable = 10;
}
