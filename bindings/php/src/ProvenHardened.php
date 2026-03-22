<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** HardeningLevel matching the Idris2 ABI tags. */
enum HardeningLevel: int
{
    case Minimal = 0;
    case Standard = 1;
    case High = 2;
    case Maximum = 3;
}

/** SecurityControl matching the Idris2 ABI tags. */
enum SecurityControl: int
{
    case Aslr = 0;
    case Dep = 1;
    case StackCanary = 2;
    case Cfi = 3;
    case Sandboxing = 4;
    case SecureBoot = 5;
    case AuditLog = 6;
}

/** ComplianceStandard matching the Idris2 ABI tags. */
enum ComplianceStandard: int
{
    case Cis = 0;
    case Stig = 1;
    case Nist80053 = 2;
    case PciDss = 3;
    case Fips140 = 4;
}

/** AuditEvent matching the Idris2 ABI tags. */
enum AuditEvent: int
{
    case ProcessStart = 0;
    case FileAccess = 1;
    case NetworkConn = 2;
    case PrivilegeEscalation = 3;
    case ConfigChange = 4;
    case AuthAttempt = 5;
}

/** HardenedHealthStatus matching the Idris2 ABI tags. */
enum HardenedHealthStatus: int
{
    case Healthy = 0;
    case Degraded = 1;
    case Compromised = 2;
    case Unresponsive = 3;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Hardening = 1;
    case Active = 2;
    case Auditing = 3;
    case Shutdown = 4;
}
