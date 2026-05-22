// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

namespace Proven;

/// <summary>ComponentType matching the Idris2 ABI tags (0-3).</summary>
public enum ComponentType : byte
{
    Vevent = 0,
    Vtodo = 1,
    Vjournal = 2,
    Vfreebusy = 3
}

/// <summary>CalMethod matching the Idris2 ABI tags (0-6).</summary>
public enum CalMethod : byte
{
    Get = 0,
    Put = 1,
    Delete = 2,
    Propfind = 3,
    Proppatch = 4,
    Report = 5,
    Mkcalendar = 6
}

/// <summary>ScheduleStatus matching the Idris2 ABI tags (0-4).</summary>
public enum ScheduleStatus : byte
{
    NeedsAction = 0,
    Accepted = 1,
    Declined = 2,
    Tentative = 3,
    Delegated = 4
}

/// <summary>CalError matching the Idris2 ABI tags (0-5).</summary>
public enum CalError : byte
{
    ValidCalendarData = 0,
    NoResourceTypeChange = 1,
    SupportedComponentMismatch = 2,
    MaxResourceSize = 3,
    UidConflict = 4,
    PreconditionFailed = 5
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Scheduling = 3,
    Shutdown = 4
}
