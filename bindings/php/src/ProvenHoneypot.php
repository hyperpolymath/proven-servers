<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ServiceEmulation matching the Idris2 ABI tags. */
enum ServiceEmulation: int
{
    case Ssh = 0;
    case Http = 1;
    case Ftp = 2;
    case Smtp = 3;
    case Telnet = 4;
    case Mysql = 5;
    case Rdp = 6;
}

/** InteractionLevel matching the Idris2 ABI tags. */
enum InteractionLevel: int
{
    case Low = 0;
    case Medium = 1;
    case High = 2;
}

/** HoneypotAlertSeverity matching the Idris2 ABI tags. */
enum HoneypotAlertSeverity: int
{
    case Info = 0;
    case AsLow = 1;
    case AsMedium = 2;
    case AsHigh = 3;
    case Critical = 4;
}

/** AttackerAction matching the Idris2 ABI tags. */
enum AttackerAction: int
{
    case Scan = 0;
    case BruteForce = 1;
    case Exploit = 2;
    case Payload = 3;
    case Lateral = 4;
    case Exfiltration = 5;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Deployed = 1;
    case Engaged = 2;
    case Shutdown = 3;
}
