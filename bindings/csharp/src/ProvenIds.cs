// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

namespace Proven;

/// <summary>AlertSeverity matching the Idris2 ABI tags (0-3).</summary>
public enum AlertSeverity : byte
{
    Low = 0,
    Medium = 1,
    High = 2,
    Critical = 3
}

/// <summary>DetectionMethod matching the Idris2 ABI tags (0-3).</summary>
public enum DetectionMethod : byte
{
    Signature = 0,
    Anomaly = 1,
    Stateful = 2,
    Heuristic = 3
}

/// <summary>IdsProtocol matching the Idris2 ABI tags (0-6).</summary>
public enum IdsProtocol : byte
{
    Tcp = 0,
    Udp = 1,
    Icmp = 2,
    Dns = 3,
    Http = 4,
    Tls = 5,
    Ssh = 6
}

/// <summary>IdsAction matching the Idris2 ABI tags (0-4).</summary>
public enum IdsAction : byte
{
    Alert = 0,
    Drop = 1,
    Log = 2,
    Block = 3,
    Pass = 4
}

/// <summary>Direction matching the Idris2 ABI tags (0-2).</summary>
public enum Direction : byte
{
    Inbound = 0,
    Outbound = 1,
    Both = 2
}

/// <summary>ThreatLevel matching the Idris2 ABI tags (0-4).</summary>
public enum ThreatLevel : byte
{
    Info = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Critical = 4
}
