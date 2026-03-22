<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ComponentType matching the Idris2 ABI tags. */
enum ComponentType: int
{
    case Vevent = 0;
    case Vtodo = 1;
    case Vjournal = 2;
    case Vfreebusy = 3;
}

/** CalMethod matching the Idris2 ABI tags. */
enum CalMethod: int
{
    case Get = 0;
    case Put = 1;
    case Delete = 2;
    case Propfind = 3;
    case Proppatch = 4;
    case Report = 5;
    case Mkcalendar = 6;
}

/** ScheduleStatus matching the Idris2 ABI tags. */
enum ScheduleStatus: int
{
    case NeedsAction = 0;
    case Accepted = 1;
    case Declined = 2;
    case Tentative = 3;
    case Delegated = 4;
}

/** CalError matching the Idris2 ABI tags. */
enum CalError: int
{
    case ValidCalendarData = 0;
    case NoResourceTypeChange = 1;
    case SupportedComponentMismatch = 2;
    case MaxResourceSize = 3;
    case UidConflict = 4;
    case PreconditionFailed = 5;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Bound = 1;
    case Serving = 2;
    case Scheduling = 3;
    case Shutdown = 4;
}
