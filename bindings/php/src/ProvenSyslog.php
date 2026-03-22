<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Syslog protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Severity matching the Idris2 ABI tags. */
enum Severity: int
{
    case Emergency = 0;
    case Severity_Alert = 1;
    case Critical = 2;
    case Error = 3;
    case Warning = 4;
    case Notice = 5;
    case Informational = 6;
    case Debug = 7;
}

/** Facility matching the Idris2 ABI tags. */
enum Facility: int
{
    case Kern = 0;
    case User = 1;
    case Mail = 2;
    case Daemon = 3;
    case Auth = 4;
    case Syslog = 5;
    case Lpr = 6;
    case News = 7;
    case Uucp = 8;
    case Cron = 9;
    case AuthPriv = 10;
    case Ftp = 11;
    case Ntp = 12;
    case Audit = 13;
    case Facility_Alert = 14;
    case Clock = 15;
    case Local0 = 16;
    case Local1 = 17;
    case Local2 = 18;
    case Local3 = 19;
    case Local4 = 20;
    case Local5 = 21;
    case Local6 = 22;
    case Local7 = 23;
}

/** Transport matching the Idris2 ABI tags. */
enum Transport: int
{
    case Udp514 = 0;
    case Tcp514 = 1;
    case Tls6514 = 2;
}
