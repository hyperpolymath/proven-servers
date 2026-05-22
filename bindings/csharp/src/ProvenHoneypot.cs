// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

namespace Proven;

/// <summary>ServiceEmulation matching the Idris2 ABI tags (0-6).</summary>
public enum ServiceEmulation : byte
{
    Ssh = 0,
    Http = 1,
    Ftp = 2,
    Smtp = 3,
    Telnet = 4,
    Mysql = 5,
    Rdp = 6
}

/// <summary>InteractionLevel matching the Idris2 ABI tags (0-2).</summary>
public enum InteractionLevel : byte
{
    Low = 0,
    Medium = 1,
    High = 2
}

/// <summary>HoneypotAlertSeverity matching the Idris2 ABI tags (0-4).</summary>
public enum HoneypotAlertSeverity : byte
{
    Info = 0,
    AsLow = 1,
    AsMedium = 2,
    AsHigh = 3,
    Critical = 4
}

/// <summary>AttackerAction matching the Idris2 ABI tags (0-5).</summary>
public enum AttackerAction : byte
{
    Scan = 0,
    BruteForce = 1,
    Exploit = 2,
    Payload = 3,
    Lateral = 4,
    Exfiltration = 5
}

/// <summary>ServerState matching the Idris2 ABI tags (0-3).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Deployed = 1,
    Engaged = 2,
    Shutdown = 3
}
