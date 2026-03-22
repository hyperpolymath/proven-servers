<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PropertyType matching the Idris2 ABI tags. */
enum PropertyType: int
{
    case FnName = 0;
    case N = 1;
    case Email = 2;
    case Tel = 3;
    case Adr = 4;
    case Org = 5;
    case Photo = 6;
    case Url = 7;
    case Note = 8;
}

/** CardMethod matching the Idris2 ABI tags. */
enum CardMethod: int
{
    case Get = 0;
    case Put = 1;
    case Delete = 2;
    case Propfind = 3;
    case Proppatch = 4;
    case Report = 5;
    case Mkcol = 6;
}

/** VCardVersion matching the Idris2 ABI tags. */
enum VCardVersion: int
{
    case Vcard3 = 0;
    case Vcard4 = 1;
}

/** CardError matching the Idris2 ABI tags. */
enum CardError: int
{
    case ValidAddressData = 0;
    case NoResourceType = 1;
    case MaxResourceSize = 2;
    case UidConflict = 3;
    case SupportedAddressData = 4;
    case PreconditionFailed = 5;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Bound = 1;
    case Serving = 2;
    case Shutdown = 3;
}
