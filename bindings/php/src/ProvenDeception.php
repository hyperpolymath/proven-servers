<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** DecoyType matching the Idris2 ABI tags. */
enum DecoyType: int
{
    case Service = 0;
    case Credential = 1;
    case File = 2;
    case Network = 3;
    case Token = 4;
    case Breadcrumb = 5;
}

/** TriggerEvent matching the Idris2 ABI tags. */
enum TriggerEvent: int
{
    case Access = 0;
    case Login = 1;
    case Read = 2;
    case Write = 3;
    case Execute = 4;
    case Scan = 5;
}

/** AlertPriority matching the Idris2 ABI tags. */
enum AlertPriority: int
{
    case Low = 0;
    case Medium = 1;
    case High = 2;
    case Critical = 3;
}

/** DecoyState matching the Idris2 ABI tags. */
enum DecoyState: int
{
    case Active = 0;
    case Triggered = 1;
    case Disabled = 2;
    case Expired = 3;
}

/** ResponseAction matching the Idris2 ABI tags. */
enum ResponseAction: int
{
    case Alert = 0;
    case Redirect = 1;
    case Delay = 2;
    case Fingerprint = 3;
    case Isolate = 4;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Configured = 1;
    case Monitoring = 2;
    case Responding = 3;
    case Shutdown = 4;
}
