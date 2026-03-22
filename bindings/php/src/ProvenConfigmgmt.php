<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Config Mgmt protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ResourceType matching the Idris2 ABI tags. */
enum ResourceType: int
{
    case File = 0;
    case Package = 1;
    case Service = 2;
    case User = 3;
    case Group = 4;
    case Cron = 5;
    case Mount = 6;
    case Firewall = 7;
    case Registry = 8;
}

/** ResourceState matching the Idris2 ABI tags. */
enum ResourceState: int
{
    case Present = 0;
    case Absent = 1;
    case Running = 2;
    case Stopped = 3;
    case Enabled = 4;
    case Disabled = 5;
}

/** ChangeAction matching the Idris2 ABI tags. */
enum ChangeAction: int
{
    case Create = 0;
    case Modify = 1;
    case Delete = 2;
    case Restart = 3;
    case Reload = 4;
    case Skip = 5;
}

/** DriftStatus matching the Idris2 ABI tags. */
enum DriftStatus: int
{
    case InSync = 0;
    case Drifted = 1;
    case DUnknown = 2;
    case Unmanaged = 3;
}

/** ApplyMode matching the Idris2 ABI tags. */
enum ApplyMode: int
{
    case Enforce = 0;
    case DryRun = 1;
    case Audit = 2;
}
